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
local items      = require ( "core.items"       )
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
		MOVING     = "Moving",
		ATTACKING  = "Attacking",
		DEAD       = "Dead",
	}
	
--===========================================-- 

-- RUNTIME FUNCTIONS ---------------------------------------------------------------
	-- The only purpose of this is for text debugging on the console.
	local function debug(event)
		-- print("Game is " .. game.state)
		-- print("Steve is " .. game.steve.state)
		-- print("Steve's sprite is " .. game.steve.sprite.sequence)
		-- print("Lives: " .. game.lives)
		-- print("Score: " .. game.score)

		-- if (game.steve.airState) then print("AirState: " .. game.steve.airState) end
		-- if (game.steve.canJump == true) then print ("Steve can jump")
		-- elseif (game.steve.canJump == false) then print ("Steve can't jump now") end
		-- if (game.steve.isAirborne == true) then print ("Steve is airborne")
		-- elseif (game.steve.isAirborne == false) then print ("Steve is on the ground") end

		-- if (game.steve.attack and game.steve.attack.sprite) then
		-- 	print(game.steve.attack.sprite.isBodyActive)
		-- end

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

		-- print("-----------------------------") -- android debugging
		-- print("") -- normal debugging
	end

	-- This loop is executed only if the game's state is RUNNING
	local function gameRunningLoop()

		-- The following block is related to jump activation and animation switching.
			-- Jump controls:
				-- Jumping is allowed only in two circumstances:
				-- 1) The player is touching the ground (see collisions)
				-- 2) The player isn't falling (his vertical speed is >= 0)
			-- Animation controls:
				-- The two following conditional blocks allow for some cool animation changes.
				-- First it's determined the player's "airState" depending on its vertical speed;
				-- Second, depending on this property, the sprite walking animation sequence is 
				-- switched depending on the airState.
		if (controller.SSVEnabled) then
			-- Context: a movement is being input (see controller -> onJumpEvent/onDpadEvent)
			if (game.steve.state == playerStateList.MOVING) then
				-- Calculates the hitbox's linear velocity.
				local xv, yv = game.steve:getLinearVelocity()

				-- Notes:
					-- [every variable change follows the rule "IF ~A, then A", this to avoid 
					-- continuous resetting of a variable to the same value which may waste
					-- cpu time.]
					-- [the value 10 is needed to soften the power of this control, to avoid accidental
					-- invalidation of a legal jump (vertical speed may differ from 0 when colliding 
					-- with dynamic crates or even tiles)].

				-- Guesses the airState and the isAirborne flags depending on the vertical speed,
					-- and modifies the sprite sequence.
					-- Vertical speed is <almost> 0, the player is moving on the ground.
					if(math.abs(yv) <= 10) then
						if (game.steve.airState ~= "Idle") then 
							game.steve.airState = "Idle"
						end
						if (game.steve.isAirborne == true) then
							game.steve.isAirborne = false
						end
						-- Horizontal speed is <almost> 0, the player is idle.
						if (math.abs(xv) <= 10) then
							if (game.steve.sprite.sequence ~= "idle") then
								game.steve.sprite:setSequence("idle")
								game.steve.sprite:play()
							end
							
							if(controller.noMovementDetected ~= true) then
								controller.noMovementDetected = true
								controller.toIdle()
							end
						
						-- Horizontal speed's absolute value is significantly high, the player is walking.
						elseif (math.abs(xv) > 10) then
							if (game.steve.sprite.sequence ~= "walking") then
								game.steve.sprite:setSequence("walking")
								game.steve.sprite:play()
							end
						end
					-- Vertical speed's absolute value is significantly high, the player is airborne.
					else
						if(yv < -10) then
							if (game.steve.airState ~= "ascending") then 
								game.steve.airState = "ascending"
								if (game.steve.sprite.sequence ~= "jumping") then
									game.steve.sprite:setSequence("jumping")
									game.steve.sprite:play();
								end
							end
						elseif(yv > 10) then
							if (game.steve.airState ~= "falling") then 
								game.steve.airState = "falling"
								if (game.steve.sprite.sequence ~= "falling") then
									game.steve.sprite:setSequence("falling")
									game.steve.sprite:play();
								end
							end
						end
						-- In both cases (ascending or falling) player is airborne.
						if (game.steve.isAirborne == false) then
							game.steve.isAirborne = true
						end
					end

				-- Jump activation is modified depending on the "isAirborne" flag.
					-- Thus, if the player can jump, but starts falling (although he hasn't jumped),
					-- a jump cannot occur ("jumping in mid air").
					if (game.steve.isAirborne == true) then 
						game.steve.canJump = false
					elseif (game.steve.isAirborne == false and 
						game.steve.hasTouchedGround == true) then
						game.steve.canJump = true 
					end
			end

			-- Moves the chasers
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
		end

		-- Listener for the "player has died" event.
		if ((game.steve.state == playerStateList.DEAD) and 
			(controller.deathBeingHandled ~= true) and
			(controller.endGameOccurring ~= true)) then
			controller.deathBeingHandled = true
			controller.onDeath()
		end
	end

	-- The main game loop, every function is described as follows.
	local function onUpdate()
		-- Keeps the player's image, sprite and sensor all joined.
		-- (remember that ONLY the image "steve" acts as the hitbox)
		if(game.steve.x and game.steve.y) then
			game.steve.sprite.x = game.steve.x
			game.steve.sprite.y = game.steve.y -10
			game.steve.sprite.xScale = game.steve.direction
			game.steve.sensorD.x, game.steve.sensorD.y = game.steve.x, game.steve.y
			if (game.steve.attack) then
				game.steve.attack.x, game.steve.attack.y = game.steve.x, game.steve.y
				game.steve.attack.sprite.x, game.steve.attack.sprite.y = game.steve.x, game.steve.y
				game.steve.attack.sprite.xScale = game.steve.direction
			end
		end

		-- If the game's state is changed by any event or trigger, 
		-- this invokes the corresponding method (for unification purposes).
		local state = game.state
		if (state == gameStateList.RUNNING) then
			gameRunningLoop()
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
				-- salva il punteggio in myData nel caso sia maggiore di quello già memorizzato
				if (game.score > myData.settings.levels[game.currentLevel].score) then
					myData.settings.levels[game.currentLevel].score = game.score
				end
			end
		elseif (state == gameStateList.TERMINATED) then
			if(controller.endGameOccurring ~= true) then
				controller.endGameOccurring = true
				controller.onGameOver("Terminated")
				game.nextScene = "mainMenu"
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

	-- Displays the item contained in the attribute -drop- of an enemy.
	function game.dropItemFrom( enemy )
		local item = items.createItem(enemy.drop)
		item:addOnMap(game.map)
		item.x = enemy.x
		item.y = enemy.y
		item.alpha = 0.5

		item.preCollision = collisions.itemPreCollision
		item:addEventListener( "preCollision", item )

		transition.to(item, { time = 1000, alpha = 1,
			onComplete = function()
				item.collision = collisions.itemCollision
				item:addEventListener("collision")
			end
		})
	end
------------------------------------------------------------------------------------

-- GAME INITIALIZATION -------------------------------------------------------------
	-- See player.lua
	function game:loadPlayer()
		self.steve = player.loadPlayer( self )
		-- From now on, game.steve.sprite and game.steve.sensorD are accessible
		self.steve.defaultAttack = player.loadAttack( self )
		self.steve.defaultAttack.collision = collisions.attackCollision
		-- Collision handling is activated in controller

		self.steve.sprite:setSequence("idle")
		--self.steve.sprite:setFrame(1)
		self.steve.sprite:play()
		--self.steve.sprite:pause()

		self.steve.direction = 1

		self.steve.collision = collisions.playerCollision
		self.steve:addEventListener( "collision", self.steve )

		self.steve.preCollision = collisions.playerPreCollision
		self.steve:addEventListener( "preCollision", self.steve )

		self.map:setFocus( self.steve )
	end

	-- See npcs.lua
	function game:loadNPCS() 
		self.npcs = npcs.loadNPCs( self )

		for i in pairs(self.npcs) do
			self.npcs[i].sensorN.collision = collisions.npcDetectByCollision
			self.npcs[i].sensorN:addEventListener( "collision", self.npcs[i].sensorN )
		end
	end

	-- See enemies.lua
	function game:loadEnemies() 
		self.enemies, self.chaserList = enemies.loadEnemies( self )
	end

	-- MAIN ENTRY POINT FOR INITIALIZATION 
	-- (must be called from the current level).
	-- Triggers all the -game.load- functions.
	function game.loadGame( map, spawn, lvl )
		-- Locally stores the current level map and spawn coordinates
		game.map = map
		game.spawnPoint = spawn
		game.currentLevel= lvl
		print("livello"..game.currentLevel)
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

	-- non serve più, lasciato ancora per precauzione, verrà tolto nella prossima iterazione se tutto funziona bene 
	-- if (game.nextScene == "highscores") then
	-- 	-- Switches scene (from "levelX" to "highscores").
	-- 	composer.setVariable( "finalScore", game.score )
	-- 	composer.removeScene( "menu.highscores" )
	-- 	composer.gotoScene( "menu.highscores", { time=1500, effect="crossFade" } )
	if (game.nextScene == "mainMenu") then
		composer.removeScene( "menu.mainMenu" )
		composer.gotoScene( "menu.mainMenu", { effect="fade", time=280 } )
	elseif (game.nextScene == "level"..game.currentLevel) then
		composer.removeScene( "levels.level"..game.currentLevel )
		composer.gotoScene( "levels.level"..game.currentLevel, { effect="fade", time=280 } )
	-- da aggiungere un'altra if nel caso il player voglia andare al livello successivo
	end
	game.nextScene = nil


	package.loaded[controller] = nil
	package.loaded[collisions] = nil
	package.loaded[composer] = nil
end

return game


