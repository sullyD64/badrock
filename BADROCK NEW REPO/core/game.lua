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

local composer   = require ( "composer"        )
local myData     = require ( "myData"          )
local physics    = require ( "physics"         )
local player     = require ( "core.player"     )
local enemies    = require ( "core.enemies"    )
local npcs       = require ( "core.npcs"       )
local items      = require ( "core.items"      )
local controller = require ( "core.controller" )
local collisions = require ( "core.collisions" )

local game = {}

physics.start()
physics.setGravity( 0, 50 )

--===========================================-- 
	-------------------------------
	game.MAX_LIVES             =  3
	-------------------------------

	local gameStateList = {
		RUNNING    = "Running",
		PAUSED     = "Paused",
		RESUMED    = "Resumed",
		COMPLETED  = "Completed",
		TERMINATED = "Terminated",
		ENDED      = "Ended",
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

		-- if (game.steve.attack) then print(game.steve.attack) else print("nil") end

		-- if (controller.controlsEnabled == true) then print("Controls: enabled") 
		-- elseif (controller.controlsEnabled == false) then print ("Controls: disabled") end
		-- if (controller.SSVLaunched == true) then print("SSV is: launched") 
		-- elseif (controller.SSVLaunched == false) then print ("SSV is: stopped") end
		-- print("Death being handled in controller.onDeath:")
		-- print(controller.deathBeingHandled)
		-- print("Endgame being handled in controller.onGameOver:")
		-- print(controller.endGameOccurring)

		-- local nextCh
		-- for i, chaser in pairs (game.chaserList) do
		-- 	if(chaser) then
		-- 		print (chaser.species .. " ["..i.."] is " .. chaser.sequence)
		-- 		nextCh = next(game.chaserList)
		-- 	end
		-- end
		-- if nextCh == nil then print("nobody is following steve") end

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

				-- Jump activation is modified depending on the isAirborne flag.
					-- Thus, if the player can jump, but starts falling (although he hasn't jumped),
					-- a jump cannot occur ("jumping in mid air").
					if (game.steve.isAirborne == true) then 
						game.steve.canJump = false
					elseif (game.steve.isAirborne == false and 
						game.steve.hasTouchedGround == true) then
						game.steve.canJump = true 
					end
			end
		end
		
		-- Entity animation: handles the chasers behavior
		if (game.enemiesLoaded == true and game.lives ~= 0) then
			-- Iterates the chaser list
			for i, chaser in pairs(game.chaserList) do
				-- Chasing is disabled when the player dies. It is then re-enabled only when
				-- the respawn is complete AND the chaser has successfully returned to his 
				-- spawn point. In this phase, even if the player comes in short range with the
				-- chaser, it won't turn back to the player because it isn't targeting him.
				if( chaser and chaser.x and not controller.deathBeingHandled and chaser.hasReturnedHome ~= false) then
					local xDelta = math.abs(game.steve.x-chaser.x)
					local yDelta = math.abs(game.steve.y-chaser.y)
					-- Context: the player is alive and in range for aggro, chase him!
					if( chaser and xDelta <= 230 and yDelta <= 150 ) then
						------------------------
						chaser:chase(game.steve)
						------------------------
						if(chaser and chaser.sequence ~= "running") then
							chaser:setSequence("running")
							chaser:play()							
						end
					-- Context: the player is alive but out of aggro range, remain still and wait.
					else 	
						if(chaser.sequence ~= "idle") then
							chaser:setSequence("idle")
							chaser:play()
						end
					end
				-- Context: the player is dead, nothing to do, return to spawn position.
				else
					-- Each entry in enemies contains the original spawn coordinates,
					-- while each enemySprite contains the current coordinates.
					for k, enemy in pairs(game.enemies) do
						if (chaser == enemy.enemySprite) then
							------------------------------
							chaser:chase(enemy)
							chaser.hasReturnedHome = false
							------------------------------
						end
						if(chaser.sequence ~= nil and chaser.sequence ~= "walking") then
							chaser:setSequence("walking")
							chaser:play()
						end
					end
				end
			end
		end
	
		-- Listener for the "player has died" event.
			-- [Observation: de facto, the player spends very little time being 'DEAD'. Don't use this
			-- state for any control, instead adopt controller.deathBeingHandled!]
		if ((game.steve.state == playerStateList.DEAD) and 
			(controller.deathBeingHandled ~= true) and
			(controller.endGameOccurring ~= true)) then
			controller.deathBeingHandled = true
			controller.onDeath()
		end
	end

	-- funzione che calcola il punteggio massimo del game corrente
	function maxScore()
	score=0
		for k,v in ipairs(game.enemies) do
			score= score + game.enemies[k].enemySprite.score
		end
			score= score + #game.npcs * 1000
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
				game.updateScoreAndStars()
				controller.onGameOver("Completed")
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
	
	-- Updates the current level's final score if the attempt's final score is higher
	-- than the one stored in myData associated to that level
	function game.updateScoreAndStars()
		if (game.score > myData.settings.levels[game.currentLevel].score) then
			myData.settings.levels[game.currentLevel].score = game.score
			print("punteggio "..game.score)
		end

		local perc = game.score/game.maxPoints*100
		if (perc == 100 ) then 
			game.stars = 3
		elseif (perc >= 65) then
			game.stars = 2
		elseif (perc >= 35 ) then
			game.stars = 1
		end

		if (game.stars > myData.settings.levels[game.currentLevel].stars) then
			myData.settings.levels[game.currentLevel].stars = game.stars
		end
	end

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
		self.steve.sprite:setSequence("idle")
		self.steve.sprite:play()

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
		game.enemiesLoaded = true
	end

	-- MAIN ENTRY POINT FOR INITIALIZATION 
	-- (must be called from the current level).
	-- Triggers all the -game.load- functions.
	function game.loadGame( map, spawn, lvl, maxP )
		-- Locally stores the current level map and spawn coordinates
		game.map = map
		game.spawnPoint = spawn
		game.currentLevel= lvl
		print("livello"..game.currentLevel)
		game.maxPoints = maxP

		-- Instance parameters ----
		game.score = 0
		game.stars = 0
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
	self.map:getTileLayer("entities"):destroy()
	self.map:getTileLayer("MAP_BUTTONS"):destroy()
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

	--------------------------------------
	-- for i in pairs(game.walkerList) do
	-- 	game.walkerList[i]:move()
	-- end
	--------------------------------------
end

function game.pause()
	physics.pause()
	controller:pause()
	for i in pairs(game.chaserList) do
		transition.pause(game.chaserList[i])
		game.chaserList[i]:pause()
	end
end

function game.resume()
	physics.start()
	controller:start()
	for i in pairs(game.chaserList) do
		transition.resume(game.chaserList[i])
	end
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

	if (game.nextScene == "mainMenu") then
		composer.removeScene( "menu.mainMenu" )
		composer.gotoScene( "menu.mainMenu", { effect="fade", time=280 } )
		-- Checks if nextScene has a substring containing "level", then concatenates
		-- the number representing the next scene.
	elseif (string.find( game.nextScene, "level" )) then 
		composer.removeScene( "levels.level"..string.sub( game.nextScene, 6 ) )
		composer.gotoScene( "levels.level"..string.sub( game.nextScene, 6 ), { effect="fade", time=280 } )
		-- [da tenere per precauzione (per ora)]
		-- elseif (game.nextScene == "level"..game.currentLevel) then
		-- 	composer.removeScene( "levels.level"..game.currentLevel )
		-- 	composer.gotoScene( "levels.level"..game.currentLevel, { effect="fade", time=280 } )

	end
	game.nextScene = nil

	package.loaded[controller] = nil
	package.loaded[collisions] = nil
	package.loaded[composer] = nil
end

return game


