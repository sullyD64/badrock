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

local composer     = require ( "composer"          )
local myData       = require ( "myData"            )
local physics      = require ( "physics"           )
local player       = require ( "core.player"       )
local combat       = require ( "core.combat"       )
local enemies      = require ( "core.enemies"      )
local npcs         = require ( "core.npcs"         )
local items        = require ( "core.items"        )
local controller   = require ( "core.controller"   )
local collisions   = require ( "core.collisions"   )
local bossStrategy = require ( "core.bossStrategy" )

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
--__________________________________________________________________________________________________ 	
--|                                                                                                | 
--|                                                                                                | 
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
						-- if (chaser.targetName) then
						-- 	print(chaser.species.." ["..i.."] (target:"..chaser.targetName
						-- 		..") (sequence:"..chaser.sequence..")")
						-- else
						-- 	print(chaser.species.." ["..i..
						-- 		"] (target: none) (sequence:"..chaser.sequence..")")
						-- end
				-- 	end
				-- 	nextCh = next(game.chaserList)
				-- end
				-- if nextCh == nil then print("there are no chasers alive") end

				-- for i, walker in pairs (game.walkerList) do
				-- 	if (walker) then
				-- 		print(walker.species.."["..i.."] xScale: "..walker.xScale)
				-- 	end
				-- end

				-- print("-----------------------------") -- android debugging
				-- print("") -- normal debugging
			end
--|                                                                                                | 
--|                                                                                                | 
--\________________________________________________________________________________________________/


-- RUNTIME FUNCTIONS ---------------------------------------------------------------
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
		
		-- Entity animation: handles the chasers' and walkers' behavior
		if (game.enemiesLoaded == true and game.lives ~= 0) then
			-- Iterates the chaser list
			for i, chaser in pairs(game.chaserList) do
				-- Chasing is disabled when the player dies. It is then re-enabled only when
				-- the respawn is complete AND the chaser has successfully returned to his 
				-- spawn point. In this phase, even if the player comes in short range with the
				-- chaser, it won't turn back to the player because it isn't targeting him.
				if (chaser.lives > 0) then
					if not(controller.deathBeingHandled) then
						if( chaser and chaser.x ) then
							local xDelta = math.abs(game.steve.x-chaser.x)
							local yDelta = math.abs(game.steve.y-chaser.y)
							-- Context: the player is alive and in range for aggro, chase him!
							-- (also, the chaser has completed repositioning)
							if( chaser and xDelta <= 230 and yDelta <= 150
								and chaser.hasReturnedHome ~= false ) then
								------------------------
								chaser:chase(game.steve)
								------------------------
								if (chaser.isChasingPlayer ~= true) then
									chaser.isChasingPlayer = true
								end
								if(chaser and chaser.sequence ~= "running") then
									chaser:setSequence("running")
									chaser:play()							
								end
							-- Context: the player is alive but out of aggro range, remain still and wait.
							else
								if (chaser.isChasingPlayer ~= false) then
									chaser.isChasingPlayer = false
									if ((chaser.isIdleAwayFromHome ~= true)
										and (math.abs(chaser.x-chaser.home.x) > 0)
										and (math.abs(chaser.y-chaser.home.y) > 0)) then
										chaser.isIdleAwayFromHome = true
									end
								end
								if(chaser and chaser.sequence ~= "idle") then
									chaser:setSequence("idle")
									chaser:play()
								end
								-- If the chaser is "idle and away from home" (has disaggroed), launch a timer:
								-- if after the timer ends he hasn't aggroed again, he will return home.
								
								if (chaser.isIdleAwayFromHome == true) then
									if (chaser.isCheckingIdleTime ~= true) then
										chaser.isCheckingIdleTime = true
										chaser:checkIfIdleTimeExceeded()
									end
								end
							end
						end
					else
						if (chaser.isChasingPlayer ~= false) then
							chaser.isChasingPlayer = false
						end
						if (chaser.hasReturnedHome ~= false) then
							chaser.hasReturnedHome = false
						end
					end
					-- Context: either the player is dead or chaser has been idle for too long:
					-- return to spawn position ("home").
					if (chaser.isChasingPlayer == false) then
						if (chaser.hasReturnedHome == false) then
							-------------------------
							chaser:chase(chaser.home)
							-------------------------
							if(chaser and chaser.sequence ~= "walking") then
								chaser:setSequence("walking")
								chaser:play()
							end
						end
					end
				end
			end

			-- Iterates the walker list
			for i, walker in pairs(game.walkerList) do
				if (walker.xScale == 1) then
					walker:walkTo( walker.leftBound )
				elseif (walker.xScale == -1) then
					walker:walkTo( walker.rightBound )
				end
			end			
		end
		-- Handles the runtime events associated with the boss fight
		-- (if the current level has a boss).
		if(game.bossFight and bossStrategy.activeStrategy ~= 0) then
			-- Gestione Boss Strategy in caso di interruzione del fight
			if(game.steve.state == playerStateList.DEAD and game.bossFight.state ~= "Terminated") then 	
				game.bossFight:terminateFight() 				
			end
			-----------------------------------
			game.bossFight:executeRuntimeLoop()
			-----------------------------------
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

		-- See controller.addSpecialPoints, needed for linking popup texts to steve
		if (controller.alertVisible) then
			controller.alert.x, controller.alert.y = game.steve.x, game.steve.y - 30
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

			-- Keeps the player's attack joined with the player.
			if (game.steve.attack) then
				local attack = game.steve.attack
				-- Default type is the melee attack or other bonuses
				if (attack.type == "default" and attack.sprite) then
					attack.x, attack.y = game.steve.x, game.steve.y	
					attack.sprite.x, attack.sprite.y = game.steve.x, game.steve.y
					attack.sprite.xScale = game.steve.direction
				end
			end

			-- Keeps the player's attacks joined with the player.
			if(game.steve.attacks) then
				local attacks = game.steve.attacks
				for k, bullet in pairs(attacks) do
					if (not bullet.hasBeenShot) then
						bullet.x, bullet.y = game.steve.powerUp.x, game.steve.powerUp.y
						bullet.sprite.xScale = game.steve.powerUp.xScale
					end
					bullet.sprite.x, bullet.sprite.y = bullet.x, bullet.y
				end
			end

			-- Keeps the player's equipped powerUp joined with the player.
			if (game.steve.powerUp and game.steve.hasPowerUp) then
				local powerUp = game.steve.powerUp
				powerUp.x, powerUp.y = game.steve.x + (game.steve.direction * 20), game.steve.y
				powerUp.xScale = game.steve.direction
			end
		end

		-- If the game's state is changed by any event or trigger, 
		-- this invokes the corresponding method (for unification purposes).
		local state = game.state

		if (state == gameStateList.RUNNING) then
			gameRunningLoop()
		elseif (state == gameStateList.RESUMED) then
			game.resume()
			controller.pauseBeingHandled = false
			if (game.steve.sprite.sequence ~= "idle") then
				game.steve.sprite:setSequence("idle")
				game.steve.sprite:play()
			end
		elseif (state == gameStateList.PAUSED and controller.pauseBeingHandled == false) then
			game.pause()
			controller.pauseBeingHandled = true
		elseif (state == gameStateList.ENDED) then
			game.stop()
		elseif (state == gameStateList.COMPLETED) then
			if(controller.endGameOccurring ~= true) then
				game.maxPoints = game.getMaxScore()
				controller.endGameOccurring = true
				game.levelHasBeenCompleted = true
				game.updateMyData()
				controller.onGameOver("Completed")
			end
		elseif (state == gameStateList.TERMINATED) then
			if(controller.endGameOccurring ~= true) then
				controller.endGameOccurring = true
				controller.onGameOver("Terminated")
				if(game.bossFight and game.bossFight.state ~= "Terminated" and bossStrategy.activeStrategy ~= 0)then
					print("GAME TERMINATO Da Motivi diversi dalla morte di Steve")
					game.bossFight:terminateFight()
				end

				-- Prevents overriding the nextScene if replay level has been requested.
				if (not game.nextScene) then
					game.nextScene = "mainMenu"
				end
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
	-- than the one stored in myData associated to that level and set the numer of stars to display
	function game.updateMyData()
		local level = tonumber(myData.settings.currentLevel)

		if (game.score > myData.settings.levels[level].score) then
			myData.settings.levels[level].score = game.score
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

		if (game.stars > myData.settings.levels[level].stars) then
			myData.settings.levels[level].stars = game.stars
		end

		if level == myData.settings.unlockedLevels then 
			myData.settings.unlockedLevels = myData.settings.unlockedLevels + 1
		end

		myData.settings.goodPoints = myData.settings.goodPoints + game.goodPoints
		myData.settings.evilPoints = myData.settings.evilPoints + game.evilPoints 

		myData.settings.currentLevel = myData.settings.currentLevel + 1
	end

	-- Calculates the maximum score obtainable in the current level.
	function game.getMaxScore()
		local score = 0
		for k, enemy in pairs(game.enemies) do
			score = score + enemy.enemySprite.score
		end
		score = score + #game.npcs * 1000

		return score
	end

	-- Adds points to the current game's score (points are fixed for now).
	function game.addScore(points)
		-- [the purpose of this function being in Game is because 
		-- collisions should not comunicate directly with controller.
		-- Also, the reason why the function is implemented in game is
		-- because it comunicates with the UI.]
		controller.addScore(points)
	end

	-- Adds points to the current game's special points, depending on the type ("good" or "evil")
	function game.addSpecialPoints(points, type)
		controller.addSpecialPoints(points, type)
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
		item.collision = collisions.itemCollision
		items.enableItem(item)
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
		if (#(self.npcs) == 0) then 
			game.npcsLoaded = false
			return
		else 
			game.npcsLoaded = true
		end

		for i in pairs(self.npcs) do
			self.npcs[i].sensorN.collision = collisions.npcDetectByCollision
			self.npcs[i].sensorN:addEventListener( "collision", self.npcs[i].sensorN )
		end
	end

	-- See enemies.lua
	function game:loadEnemies() 
		self.enemies, self.chaserList, self.walkerList = enemies.loadEnemies( self )
		if (#(self.enemies) == 0) then 
			game.enemiesLoaded = false
			return
		else 
			game.enemiesLoaded = true
		end

		-- Assigns the home to each chaser
		enemies.assignChaserHomes(self.enemies, self.chaserList)

		-- Assigns the route to each walker
		local routes = self.map:getObjectLayer("walkerRoutes").objects
		enemies.assignWalkerRoutes(self.enemies, self.walkerList, routes)
	end

	-- See bossStrategy.lua
	function game:loadBoss( trigger )
		if (not trigger) then return end
		self.bossFight = bossStrategy.loadBoss(trigger)
	end

	-- MAIN ENTRY POINT FOR INITIALIZATION (called from the current level).
	function game.loadGame( map, spawn )
		-- Locally stores the current level map and spawn coordinates
		game.map = map
		game.spawnPoint = spawn

		-- Instance parameters ----
		game.score = 0
		game.goodPoints = 0
		game.evilPoints = 0
		game.stars = 0
		game.lives = game.MAX_LIVES - 1 
		game.levelHasBeenCompleted = false
		---------------------------
		
		-- Entity initialization --
		game:loadPlayer()
		game:loadEnemies()
		game:loadNPCS()
		---------------------------

		-- Logic, controls and UI initialization -----------------
		collisions.setGame( game, gameStateList, playerStateList  )
		controller.setGame( game, gameStateList, playerStateList  )
		bossStrategy.setGame(game, gameStateList, playerStateList )
		controller.prepareUI()
		-----------------------------------------------------------

		game:loadBoss(util.getBossTrigger(game.map))
		-- util.preparePlatforms(game.map)

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

-- MAIN SIMULATION ENTRY POINT (called from the current level after -game.loadGame-).
function game.start()
	physics.start()
	controller:start()
	Runtime:addEventListener("enterFrame", moveCamera)
	Runtime:addEventListener("collision", collisions.onCollision)
	Runtime:addEventListener("enterFrame", onUpdate)
	dbtimer = timer.performWithDelay(200, debug, 0)
	-- util.movePlatforms(game.map, "on")

	-- local pippo = {
	-- 	x = game.spawnPoint.x + 50,
	-- 	y = game.spawnPoint.y,
	-- 	drop = "gun"}
	-- game.dropItemFrom(pippo)
	-- local pluto = {
	-- 	x = game.spawnPoint.x + 100,
	-- 	y = game.spawnPoint.y,
	-- 	drop = "immunity"}
	-- game.dropItemFrom(pluto)
end

function game.pause()
	physics.pause()
	controller:pause()
	-- util.movePlatforms(game.map, "off")

	if (game.steve.attack and game.steve.attack.sprite) then
		game.steve.attack.sprite:pause()
	end
	if (game.steve.powerUp and game.steve.powerUp.sprite) then
		game.steve.powerUp.sprite:pause()
	end

	if (combat.timers) then
		for k, combatTimer in pairs(combat.timers) do
		 	if (not combatTimer._expired) then
				timer.pause(combatTimer)
			end
		end
	end

	if (game.chaserList) then
		for k, chaser in pairs(game.chaserList) do chaser:pause() end
	end
	if (game.walkerList) then
		-- [uncomment when walkers will have animated sprites]
		-- for k, walker in pairs(game.walkerList) do walker:pause() end
	end

	if(game.bossFight and game.bossFight.state ~= "Paused" and bossStrategy.activeStrategy ~= 0) then
		game.bossFight:pauseFight()
	end
end

function game.resume()
	physics.start()
	controller:start()
	-- util.movePlatforms(game.map, "on")

	if (game.steve.attack and game.steve.attack.sprite) then
		game.steve.attack.sprite:play()
	end
	if (game.steve.powerUp and game.steve.powerUp.sprite) then
		game.steve.powerUp.sprite:play()
	end

	if (combat.timers) then
		for k, combatTimer in pairs(combat.timers) do
			if (not combatTimer._expired) then
				timer.resume(combatTimer)
			end
		end
	end

	if (game.chaserList) then
		for k, chaser in pairs(game.chaserList) do
		-- if(chaser and chaser.sequence ) then
			chaser:play()
		-- end
		end
	end

	if (game.walkerList) then
		-- for k, walker in pairs(game.walkerList) do
			-- if(walker and walker.sequence ) then
				-- walker:play()
			-- end	
		-- end
	end

	if(game.bossFight and game.bossFight.state ~= "Running" and bossStrategy.activeStrategy ~= 0)then
		game.bossFight:resumeFight()
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
	package.loaded[bossStrategy] = nil
	collisions.setGame(nil)
	controller.setGame(nil)
	controller.deathBeingHandled = nil
	controller.endGameOccurring = nil


	if (game.nextScene == "mainMenu") then
		composer.removeScene( "menu.mainMenu" )
		composer.gotoScene( "menu.mainMenu", { effect="fade", time=280 } )
		-- Checks if nextScene has a substring containing "level", then
		-- go to the next scene.
	elseif (string.find( game.nextScene, "level" )) then 
		composer.removeScene( "levels."..game.nextScene )
		composer.gotoScene( "levels."..game.nextScene , { effect="fade", time=280 } )
	end
	game.nextScene = nil

	package.loaded[controller] = nil
	package.loaded[collisions] = nil
	package.loaded[composer] = nil
end

return game


