-----------------------------------------------------------------------------------------
--
-- game.lua
--
-- Game is intended to be the "simulator" of the application logic tier.
-- Accessibility to child modules (like collisions) is granted depending on the 
-- simulation state.
-- At startup, this class istantiates all the domain objects by calling the initializator 
-- methods contained in the "core" modules.
-----------------------------------------------------------------------------------------

local composer   = require ( "composer"         )
local physics    = require ( "physics"          )
local player     = require ( "core.player"      )
local enemies    = require ( "core.enemies"     )
local npcs       = require ( "core.npcs"        )
local items      = require ( "core.items"       )		-- only used in addDrop [fabio]
local controller = require ( "core.controller"  )
local collisions = require ( "core.collisions"  )

local game = {}

physics.start()
physics.setGravity( 0, 50 )

--===========================================-- 
	-------------------------------
	game.MAX_LIVES             =  3
	-------------------------------

	local gameStateList = {
		RUNNING   = "Running",
		PAUSED    = "Paused",
		RESUMED   = "Resumed",
		COMPLETED = "Completed",
		ENDED     = "Ended",
		TERMINATED = "Terminated",
	}

	local playerStateList = {
		IDLE       = "Idle",
		WALKING    = "Walking",
		JUMPING    = "Jumping",
		ATTACKING  = "Attacking",
		DEAD       = "Dead",
	}
	
--===========================================-- 

-- RUNTIME FUNCTIONS ---------------------------------------------------------------
	-- The only purpose of this is for text debugging on the console, do not add anything else.
	local function debug(event)
		print("Game is " .. game.state)
		print("Steve is " .. game.steve.state)
		-- -- if (game.steve.canJump == true) then print ("Steve can jump")
		-- elseif (game.steve.canJump == false) then print ("Steve can't jump now") end
		-- print("Lives: " .. game.lives)
		-- print("Score: " .. game.score)

		-- if (controller.controlsEnabled == true) then print("Controls: enabled") 
		-- elseif (controller.controlsEnabled == false) then print ("Controls: disabled") end

		-- if (controller.SSVLaunched == true) then print("SSV is: launched") 
		-- elseif (controller.SSVLaunched == false) then print ("SSV is: stopped") end

		-- print("Death being handled in controller.onDeath:")
		-- print(controller.deathBeingHandled)
		-- print("Endgame being handled in controller.onGameOver:")
		-- print(controller.endGameOccurring)

		-- for i in pairs (game.chaserList) do
		-- 	if(game.chaserList[i] and game.chaserList[i].species=="paper") then
		-- 		print (game.chaserList[i].species .. " " .. i ..  " is following steve")
		-- 	end
		-- end
		-- print("")
	end

	-- The main game loop, every function is described as follows.
	local function onUpdate ()
		-- Keeps the player's image, sprite and sensor all joined.
		-- (remember that ONLY the image "steve" acts as the hitbox)
		if(game.steve.x and game.steve.y) then
			game.steve.sprite.x = game.steve.x
			game.steve.sprite.y = game.steve.y -10
			 	--(offset della sprite rispetto a game.steve)
			game.steve.sprite.xScale = game.steve.direction
			game.steve.sensorD.x, game.steve.sensorD.y = game.steve.x, game.steve.y
			if (game.steve.attack) then
				game.steve.attack.x, game.steve.attack.y = game.steve.x, game.steve.y
			end
		end

		-- Jumping is allowed only in two circumstances:
		-- 1) The player is touching the ground (see collisions)
		-- 2) The player isn't falling (his vertical speed is >= 0)
		-- This block checks the second condition.
		if (controller.SSVEnabled) then
			local xv, yv = game.steve:getLinearVelocity()
			if (yv > 0 and game.steve.firstJumpReady == false) then 
				game.steve.canJump = false
			elseif (yv == 0 and game.steve.firstJumpReady == true) then
				game.steve.canJump = true
			end

			-- Setting the AirState, needed for the Animation controls.
			if(yv > 0) then
				game.steve.airState= "Falling"
			elseif(yv < 0) then
				game.steve.airState= "Jumping"
			elseif(yv == 0) then
				game.steve.airState= "Idle"
			end
		end

		for i in pairs(game.chaserList) do
			if( game.chaserList[i] 
				and game.spawnPoint.x 
				and game.chaserList[i].x 
				and game.chaserList[i].species == "paper" 
				and math.abs(game.steve.x-game.chaserList[i].x)<=230
				and math.abs(game.steve.y-game.chaserList[i].y)<=150 ) then
				if(game.steve.state ~= playerStateList.DEAD) then
					game.chaserList[i]:move()
				
				elseif( game.steve.state == playerStateList.DEAD 
					and math.abs(game.chaserList[i].x-game.spawnPoint.x)<=150 ) then
					--print("Lo spawn è zona franca")
					game.chaserList[i].xScale=-1
					game.chaserList[i].x =	game.chaserList[i].x+2	
					transition.to(game.chaserList[i], {
						time = 2000,
						xScale = -1,
						x = (game.chaserList[i].x + 200)
					})
				end
			end
		end

		if ((game.steve.state == playerStateList.DEAD) and 
			(controller.deathBeingHandled ~= true) and
			(controller.endGameOccurring ~= true)) then
			controller.deathBeingHandled = true
			controller.onDeath()
		end

		-- If the game's state is changed by any event or trigger, 
		-- this invokes the corresponding method (for unification purposes).
		local state = game.state
		if (state == gameStateList.RUNNING) then
			
		elseif (state == gameStateList.RESUMED) then
			game.resume()
		elseif (state == gameStateList.PAUSED) then
			game.pause()
		elseif (state == gameStateList.ENDED) then
			game.stop() 
		elseif (state == gameStateList.COMPLETED) then
			if(controller.endGameOccurring ~= true) then
				controller.endGameOccurring = true
				game.levelHasBeenCompleted = true
				controller.onGameOver("Completed")
			end
		elseif (state == gameStateList.TERMINATED) then
			if(controller.endGameOccurring ~= true) then
				controller.endGameOccurring = true
				controller.onGameOver("Terminated")
			end
		end
	end

	-- Refresh the map around the focused object (which by default is Steve).
	local function moveCamera( event ) 
		game.map:update(event)
	end
------------------------------------------------------------------------------------

-- MISCELLANEOUS FUNCTIONS ---------------------------------------------------------

	-- Adds points to the current game's score (points are fixed for now).
	function game.addScore(points)
		-- [the purpose of this function being in Game is because 
		-- collisions should not comunicate directly with controller.
		-- Also, the reason why the function is implemented in game is
		-- because it comunicates with the UI.]
		controller.addScore(points)
	end
	
	-- Adds -one- life to the current game's lives.
	function game.addOneLife()
		-- [same reasons as above]
		controller.addOneLife()
	end

	-------------------------------------------------------------------
	-- [ fabio's refactor to-do ]

		-- Displays the item contained in the attribute -drop- of an enemy.
		function game.dropItemFrom( enemy )
			local item = items.createItem(enemy.drop)
			game.map:getTileLayer("items"):addObject(item)
			item.x = enemy.x
			item.y = enemy.y
		end

		-- Returns True if an object has an attribute specified by its name 
		-- (attributeName must be a string).
		function game.hasAttribute( obj , attributeName )
			local ris = false
			for k, v in pairs(obj) do
				if k == attributeName then
					ris =true
					break
				end
			end
			return ris
		end
	-------------------------------------------------------------------	
------------------------------------------------------------------------------------

-- GAME INITIALIZATION -------------------------------------------------------------
	-- See player.lua
	function game:loadPlayer()
		self.steve = player.loadPlayer( self )
		-- From now on, game.steve.sprite and game.steve.sensorD are accessible

		self.steve.defaultAttack = player.loadAttack( self )

		self.steve.sprite:setSequence("idle")
		--self.steve.sprite:setFrame(1)
		self.steve.sprite:play()
		--self.steve.sprite:pause()

		self.steve.direction = 1

		self.steve.preCollision = collisions.playerPreCollision
		self.steve:addEventListener( "preCollision", self.steve )

		self.map:setFocus( self.steve )
	end

	-- See npcs.lua
	function game:loadNPCS() 
		self.npcs = npcs.loadNPCs( self )
	end

	-- See enemies.lua
	function game:loadEnemies() 
		self.enemies, self.chaserList = enemies.loadEnemies( self )
	end

	-- MAIN ENTRY POINT FOR INITIALIZATION 
	-- (must be called from the current level).
	-- Triggers all the -game.load- functions.
	function game.loadGame( map, spawn )
		-- Locally stores the current level map and spawn coordinates
		game.map = map
		game.spawnPoint = spawn

		-- Instance parameters ----
		game.score = 0
		game.lives = game.MAX_LIVES
		game.levelHasBeenCompleted = false
		---------------------------

		-- Entity initialization --
		game:loadPlayer()
		game:loadEnemies()
		game:loadNPCS()

		-- Logic, controls and UI initialization -----------------
		collisions.setGame( game, gameStateList, playerStateList  )
		controller.setGame( game, gameStateList, playerStateList  )
		controller.prepareUI()
		-----------------------------------------------------------

		physics.start()
		physics.pause()
	end
------------------------------------------------------------------------------------

-- Removes every Entity on the map when -game.stop- is triggered
	-- [[ lavori in corso: introdurre lista di entità in game ]]
function game:removeAllEntities()
	self.map:getTileLayer("playerObject"):destroy()
	self.map:getTileLayer("playerEffects"):destroy()
	self.map:getTileLayer("items"):destroy()
	self.map:getTileLayer("balloons"):destroy()
	self.map:getTileLayer("sensors"):destroy()
	self.map:getTileLayer("entities"):destroy()
	self.map:getTileLayer("JUMPSCREEN"):destroy()
end


-- MAIN ENTRY POINT 
--(must be called from the current level after -game.loadGame-).
function game.start()
	physics.start()
	controller:start()
	Runtime:addEventListener("enterFrame", moveCamera)
	Runtime:addEventListener("collision", collisions.onCollision)
	Runtime:addEventListener("enterFrame", onUpdate)
	dbtimer = timer.performWithDelay(200, debug, 0)
end

function game.pause()
	physics.pause()
	controller:pause()
	--transition.pause()
end

function game.resume()
	physics.start()
	controller:start()
	--transition.resume()
end

function game.stop()
	timer.cancel( dbtimer )
	Runtime:removeEventListener( "enterFrame", moveCamera)
	Runtime:removeEventListener( "collision", collisions.onCollision)
	Runtime:removeEventListener( "enterFrame", onUpdate )
	game.map:destroy()

	package.loaded[physics] = nil
	package.loaded[player] = nil
	package.loaded[enemies] = nil
	package.loaded[npcs] = nil
	package.loaded[items] = nil
	collisions.setGame(nil)
	controller.setGame(nil)
	controller.deathBeingHandled = nil
	controller.endGameOccurring = nil

	if (game.nextScene == "highscores") then
		-- Switches scene (from "levelX" to "highscores").
		composer.setVariable( "finalScore", game.score )
		composer.removeScene( "menu.highscores" )
		composer.gotoScene( "menu.highscores", { time=1500, effect="crossFade" } )
	elseif (game.nextScene == "mainmenu") then
		composer.removeScene( "menu.mainMenu" )
		composer.gotoScene( "menu.mainMenu", { effect="fade", time=280 } )
	end
	game.nextScene = nil

	package.loaded[controller] = nil
	package.loaded[collisions] = nil
	package.loaded[composer] = nil
end

return game


