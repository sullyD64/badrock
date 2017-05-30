-----------------------------------------------------------------------------------------
--
-- controller.lua
--
-- This module handles all the #TOUCH# events registered by the UI module; this means
-- that controller handles all the event, caused by the user's inputs during a LevelX scene.
-- These methods can access and modify the Game's current state, aswell as the Player's
-- current state, position on the map, sprite sequence and other properties, and they
-- are only enabled under certain circumstances.
-- Each handler is private and should not be accessed outside the module.
-- Controller also comunicates directly with the game's UI; for this reason, it offers
-- some methods to visually manipulate the UI, like visualizing the score or other 
-- 'system' responses for the uses.
-----------------------------------------------------------------------------------------
local ui         = require ( "core.ui"         )
local sfx        = require ( "audio.sfx"       )
local pauseMenu  = require ( "menu.pauseMenu"  )
local gameResult = require ( "menu.gameResult" )

local controller = {
	controlsEnabled,
	pauseEnabled,
	SSVEnabled,					-- SSV: "Set Steve Velocity"
	SSVLaunched,
	i, j, 						-- both are needed for the variable jump height
	endGameOccurring,	
	deathBeingHandled,
	noMovementDetected,		-- needed for resetting the player's state to IDLE
}

local game = {}
local steve = {}
local gState = {}
local sState = {}

-- PLAYER MOVEMENT -----------------------------------------------------------------
	-- Code in this whole block cooperates strictly with the two movement handlers. 
		-- Names are self-explanatory, while all that it's done is applying forces and 
		-- modifying the linear velocity of the Player's "hitbox" entity.
		-- Those two functions are runtime functions, which are toggled depending on the
		-- movement handlers' event phases; there can be cases in which those functions
		-- are launched, but never stop executing (i.e. when endGame is triggered):
		-- this is known to cause multiple errors.
		-- For this reason, controller needs to store a local variable which indicates if
		-- those methods are launched and are calculating stuff.
		-- [Remember that before changing scene, those two methods MUST be stopped! Else
		--  they will keep running even in other scenes].

	local function makeSteveJump()
		-----------------------------
		controller.SSVLaunched = true
		-----------------------------
		local steveXV, steveYV = steve:getLinearVelocity()
			
		if (steve.jumpForce > -400 and controller.j ~= 0) then
			-- In both cases (x-movement or y-movement), we set the character's linear velocity 
			-- at each frame, overriding one of the two linear velocities when a movement is input.
			if (steve.actualspeedX ~= 0) then
				steve:setLinearVelocity(steve.actualSpeedX, steve.jumpForce )
			else
				steve:setLinearVelocity(steveXV, steve.jumpForce )
			end
			steve:applyForce(0, steve.jumpForce, steve.x, steve.y)

			-- jumpForce starts with a low value and is incremented for a select number of frames.
			controller.j = controller.j - 1
			controller.i = controller.i + 1

			local maths = - controller.i
			-- maths = - math.exp( controller.i/2 ) + 1
			-- maths - steve.jumpForce*math.exp(-controller.i/100000000)
			steve.jumpForce = steve.jumpForce + maths

			--print("i:" ..controller.i.. "| j:" ..controller.j.. "	| jumpForce:" .. steve.jumpForce)
		else
			steve.jumpForce = 0
		end
	end

	local function makeSteveMove()
		-----------------------------
		controller.SSVLaunched = true
		-----------------------------
		local steveXV, steveYV = steve:getLinearVelocity()
		-- In both cases (x-movement or y-movement), we set the character's linear velocity at each
		-- frame, overriding one of the two linear velocities when a movement is input.
		if (steve.jumpForce and steve.jumpForce ~= 0) then
			steve:setLinearVelocity(steve.actualSpeedX, steve.jumpForce )
		else
			steve:setLinearVelocity(steve.actualSpeedX, steveYV )
		end
	end
------------------------------------------------------------------------------------

-- CONTROLS HANDLERS ---------------------------------------------------------------
	-- Inputs movement on the y-axis.
	local function onJumpEvent(event)
		local target = event.target
		if (controller.controlsEnabled) then
			if (event.phase == "began" and steve.canJump == true) then
				display.currentStage:setFocus( target, event.id )
				-- audio --------------------------------------
				audio.stop(2)
				sfx.playSound( sfx.jumpSound, { channel = 2 } )
				-----------------------------------------------
				steve.state = sState.MOVING

				-- animation ------------------------------------------
					if (steve.sprite.sequence == "idle") then
						steve.sprite:setSequence("jumping")
						steve.sprite:play()
					end
				--------------------------------------------------------

				-- physics ---------------------------------------------
					steve.jumpForce = - 200
					Runtime:addEventListener("enterFrame", makeSteveJump)
					controller.i = 0
					controller.j = 16
					steve.canJump = false
					steve.isAirborne = true
					steve.hasTouchedGround = false
				--------------------------------------------------------		
			
			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				-- physics ---------------------------------------------
				steve.jumpForce = 0
				Runtime:removeEventListener("enterFrame", makeSteveJump)
				-- permissions -----------------------------------------
				controller.SSVLaunched = false
				--------------------------------------------------------
				display.currentStage:setFocus( target, nil )	
			end
		end
		return true
	end

	-- Inputs movement on the x-axis.
	local function onDpadEvent(event)
		local target = event.target
		if (controller.controlsEnabled) then
			if (event.phase == "began") then
				display.currentStage:setFocus( target, event.id )
				steve.state = sState.MOVING 

				-- animation ----------------------------------------------
					if (steve.sprite.sequence == "idle") then
						steve.sprite:setSequence("walking")
						steve.sprite:play()
					end
				-----------------------------------------------------------

				-- Visually simulate the button press
				-- target.alpha = 0.8
				-- physics ----------------------------------------------
					if (target.id == "dpadLeft") then
						steve.direction = -1
					elseif (target.id == "dpadRight") then
						steve.direction = 1
					end
					--controller.SSVEnabled = true
					steve.walkForce = 150
					controller.SSVType = "walk"
					Runtime:addEventListener("enterFrame", makeSteveMove)
					steve.actualSpeedX = steve.direction * steve.walkForce
					steve.xScale = steve.direction
				---------------------------------------------------------

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				--target.alpha = 0.1
				-- physics ---------------------------------------------
				steve.actualspeedX = 0
				Runtime:removeEventListener("enterFrame", makeSteveMove)	
				-- permissions -----------------------------------------
				controller.SSVLaunched = false
				--------------------------------------------------------
				display.currentStage:setFocus( target, nil )
			end
		end
		return true
	end

	-- Inputs attack, depending on the current weapon equipped or other circumstances.
	local function onAttackEvent(event)
		local button = event.target
		if (controller.controlsEnabled) then
			if (event.phase == "began" and button.active == true) then
				display.currentStage:setFocus( button, event.id )
				-- audio ----------------------------------------
				sfx.playSound( sfx.attackSound, { channel = 4 } )
				-------------------------------------------------
				
				-- Button becomes temporairly inactive
				button.active = false
				button.alpha = 0.5

				-- The action to perform is decided depending on the
				-- equipped powerup (see player), while the action itself
				-- is performed in the combat module.
				steve:performAttack()

				local searchingFlag = true 	-- flag is used to call cancelAttack only once
				local attackValidityCheck = function()
					if (searchingFlag) then
						-- print("sto controllando...")
						if (steve.state == sState.DEAD) or controller.deathBeingHandled then
							steve:cancelAttack()
							searchingFlag = false
							-- print("steve è morto :(")
						end
					end
				end
				Runtime:addEventListener("enterFrame", attackValidityCheck)

				timer.performWithDelay(steve.attack.duration,
					function()
						button.active = true
						button.alpha = 1
						Runtime:removeEventListener("enterFrame", attackValidityCheck)
						searchingFlag = false
						-- print("fine controllo")
					end
				)

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				display.currentStage:setFocus( button, nil )
			end
			return true
		end
	end

	-- Inputs game pause (and opens the pause panel) if game is running 
	-- and resume if paused, switching visibility between the two buttons.
	local function onPauseResumeEvent(event)
		local target = event.target

		if (controller.pauseEnabled) then
			if (event.phase == "began") then
				display.currentStage:setFocus( target, event.id )
				if (event.target.id == "pauseBtn") then
					game.state = gState.PAUSED
					ui.buttons.resume.isEnabled = false
					ui.buttons.pause.isVisible = false
					ui.buttons.resume.isVisible = true
					-----------------------------------------------------
					pauseMenu.panel:show({y = display.screenOriginY+225})
					-----------------------------------------------------
				elseif (event.target.id == "resumeBtn") then
					game.state = gState.RESUMED
					ui.buttons.pause.isVisible = true
					ui.buttons.resume.isVisible = false
					ui.buttons.pause.isEnabled = true
					ui.buttons.resume.isEnabled = false
					-----------------------------------------------------
					pauseMenu.panel:hide()
					-----------------------------------------------------
				end

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				display.currentStage:setFocus( target, nil )
			end

			return true
		end
	end
------------------------------------------------------------------------------------

-- SPECIAL EVENTS ------------------------------------------------------------------
	-- For now, the special events are the player's death and the end of the current
	-- game. Those events must be handled by the controller.

	-- Lasciata come reference durante la modifica (può ancora servire, non si sa mai) 
	-- da eliminare alla fine di questa iterazione
	-- function controller.onGameOver(outcome)
		-- 	controller.endGameOccurring = true
		-- 	ui.showOutcome(outcome)
		-- 	-- Prevents pressing the action button in this phase: if not, any access 
		-- 	-- to the player's state inside onAttack will throw a runtime error
		-- 	ui.buttons.action.active = false
		-- 	controller.pauseEnabled = false
		-- 	---------------------------------------
		-- 	-- If GameOver was triggered by onDeath
		-- 	if (controller.deathBeingHandled == true) then
		-- 		steve.isBodyActive = false
		-- 		steve.sensorD.isBodyActive = false
		-- 		steve.sensorD.isVisible = false
		-- 		steve.sprite.alpha = 0
		-- 	end
		-- 	---------------------------------------
		-- 	timer.performWithDelay( 1500,
		-- 		function()

		-- 			controller:pause()
		-- 			game.map:setFocus( nil )
		-- 			game:removeAllEntities()
		-- 			controller.destroyUI()
		
		-- 			game.nextScene = "highscores"
		-- 			if (game.state == gState.TERMINATED) then
		-- 				game.nextScene = "mainmenu"
		-- 			end

		-- 			-- The declaration below triggers the final call in the game loop
		-- 			game.state = gState.ENDED
		-- 		end
		-- 	)
		-- end

	-- At this point, it's game over. 
	-- This displays the outcome of the game (good or bad depending from where this function is
	-- being called) and triggers the end procedure of the current game (Main exit point)

	function controller.onGameOver(outcome)
		-- controller.endGameOccurring = true 	--? probabilmente non più utile e da togliere, ulteriori controlli da fare

		-- Prevents pressing the action button in this phase: if not, any access 
		-- to the player's state inside onAttack will throw a runtime error
		ui.buttons.action.active = false
		controller.pauseEnabled = false

		if (steve.state == sState.ATTACKING) then 
			steve:cancelAttack()
		end

		---------------------------------------
		-- If GameOver was triggered by onDeath
		if (controller.deathBeingHandled == true) then
			steve.isBodyActive = false
			steve.sensorD.isBodyActive = false
			steve.sensorD.isVisible = false
			steve.sprite.alpha = 0
		end
		---------------------------------------
		game.map:setFocus( nil )
		controller:pause()
		controller.destroyUI()
		-- game:removeAllEntities()	-- Disabled (causes bugs)

		timer.performWithDelay( 250, 
			function()
				-- Mostra il menu di fine livello
				-- gState.Terminated accade quando l'utente decide di interrompere il gioco dal menu di pausa,
				-- quindi il menu di fine livello non deve essere mostrato, ma la partita deve essere conclusa
				if (game.state ~= gState.TERMINATED) then
					gameResult.setGame(game, gState, outcome)
					gameResult.panel:show({ y = display.actualContentHeight,})
				else
					-- The declaration below triggers the final call in the game loop
					game.state = gState.ENDED
				end 
			end
		)
		
	end

	-- Restores the player at the current spawn point in the current game 
	-- (called from onDeath if lives are > 0).
	local function handleRespawn()
		local respawnPlayer = function()
			local spawn = game.spawnPoint
			steve.x, steve.y = spawn.x, spawn.y
			steve.sprite.x, steve.sprite.y = steve.x, steve.y
			game.map:fadeToPosition(spawn.x, spawn.y, 250)

			controller.destroyUI()
			controller.prepareUI()

			steve:setLinearVelocity( 0, 0 )
			steve.canJump = false
			transition.to( steve.sprite, { alpha = 1, time = 1000,
				--transition = easing.outExpo,
				onStart = function()
					-- Steve falls to the ground
					steve.isBodyActive = true
					steve.sensorD.isBodyActive = true
					steve.sensorD.isVisible = true
				end
			})
			transition.to( steve.sprite, { time = 500,
				onComplete = function()
					-- Controls are active again
					steve.state = sState.IDLE
					controller:start()
					controller.pauseEnabled = true
					controller.deathBeingHandled = false
				end
			})
		end
		steve.isBodyActive = false
		steve.sensorD.isBodyActive = false
		steve.sensorD.isVisible = false
		steve.sprite.alpha = 0
		steve.sprite:setSequence("idle")
		steve.sprite:pause()
		transition.to(steve, { time = 2000, 
			onComplete = function()
				respawnPlayer()
			end
		})
	end

	-- Handles the player's death event.
	-- (called from game inside the game loop)
	function controller.onDeath()
		-- This flag is needed to break the loop where onDeath has been called 
		-- from launching it again until the handling is completed.
		controller.deathBeingHandled = true
		-- audio ----------------------------------------
		sfx.playSound( sfx.dangerSound, { channel = 5 } )
		-- animation ------------------------------------
		steve.deathAnimation(game, steve.x , steve.y)
		-------------------------------------------------

		-- Removes the runtime event listeners if death was triggered
		-- while still inputing a movement.
		if (controller.SSVLaunched == true) then
			Runtime:removeEventListener( "enterFrame", makeSteveJump )
			Runtime:removeEventListener( "enterFrame", makeSteveMove )
		end
		
		controller:pause()
		controller.pauseEnabled = false

		game.lives = game.lives - 1
		ui.updateLifeIcons(game.lives)

		if (game.lives == 0) then
			controller.onGameOver("Failed")
		elseif ( game.lives > 0 ) then
			handleRespawn()
		end
	end
------------------------------------------------------------------------------------

-- AUXILIARY FUNCTIONS -------------------------------------------------------------
	-- They call the UI for showing informations

	-- Adds specified points to the score
	function controller.addScore(points)
		game.score = game.score + points
		ui.buttons.score:setLabel("Score: "..game.score)
		local textTimer = 250
		local scoreUp = ui.buttons.scoreUp

		if (scoreUp.isVisible == false) then
			scoreUp:setLabel("+" .. points)
			scoreUp.isVisible = true 
		end

		-- Visually animates the scoreUp text element
		timer.performWithDelay(textTimer, ui.textFade(scoreUp, 250))
	end

	-- Adds a life to the lives and visually updates the lifeIcons array
	function controller.addOneLife()
		if(game.lives < game.MAX_LIVES ) then
			game.lives = game.lives + 1
			ui.updateLifeIcons(game.lives)
			local textTimer = 250
			local lifeUp = ui.buttons.lifeUp

			if (lifeUp.isVisible == false) then
				lifeUp:setLabel("1 up")
				lifeUp.isVisible = true 
			end

		-- Visually animates the lifeUp text element
		timer.performWithDelay(textTimer, ui.textFade(lifeUp, 750))
		end
	end

	-- Called from onUpdate in game. Waits for a brief time, after which
	-- resets the player's state to Idle. If during this time any movement 
	-- is input again, the check will prematurely exit.
	function controller.toIdle()
		if (steve.state == sState.MOVING) then
			if (controller.noMovementDetected == true) then
				timer.performWithDelay( 2000, 
					function()
						-- Inside onUpdate, the player's sprite sequence is set to 
						-- idle when its xv and yv are 0. After 2 seconds, if the
						-- current sequence is still idle, then the player's state
						-- is set to IDLE and this loop is disabled.
						if (steve.sprite.sequence == "idle") then
							steve.sprite:setSequence("idle")
							steve.sprite:play()
							steve.state = sState.IDLE
							controller.noMovementDetected = false
							return
						else 	-- player has moved again.
							controller.noMovementDetected = false
							return
						end
					end
				)
			end
		end
	end
------------------------------------------------------------------------------------

-- Main entry point for Controller (accessed from -game.loadGame-).
function controller.setGame ( currentGame, gameStateList, playerStateList )
	game = currentGame
	if (game) then 
		steve = currentGame.steve 
	end
	gState = gameStateList
	sState = playerStateList
end

-- Calls the UI initialization and prepares the event listeners
function controller.prepareUI()
	timer.performWithDelay(1000, ui.loadUI())
	game.map:getTileLayer("JUMPSCREEN"):addObject(ui.buttons.jump)
	------------------------------
	ui.createLifeIcons(game.lives)	-- Prone to refactoring (see ui)
	------------------------------
	ui.buttons.jump:  addEventListener( "touch", onJumpEvent )
	ui.buttons.dleft: addEventListener( "touch", onDpadEvent )
	ui.buttons.dright:addEventListener( "touch", onDpadEvent )
	ui.buttons.action:addEventListener( "touch", onAttackEvent )
	ui.buttons.pause: addEventListener( "touch", onPauseResumeEvent )
	ui.buttons.resume:addEventListener( "touch", onPauseResumeEvent )

	ui.buttons.action.active = true
	ui.buttons.resume.isVisible = false
	ui.buttons.scoreUp.isVisible = false
	ui.buttons.lifeUp.isVisible = false
	-------------------------------
	pauseMenu.setGame(game, gState)
	-------------------------------
end

-- Destroys the UI
function controller.destroyUI()
	if (ui.buttons and ui.buttonGroup) then
		ui.buttons.scoreUp:setLabel("")
		ui.buttons.lifeUp:setLabel("")
		ui.buttons = nil
		ui.emptyLifeIcons()
		ui.destroyLifeIcons()
		pauseMenu.setGame(nil)
		display.remove(ui.buttonGroup)

	end
end

function controller:start()
	game.state = gState.RUNNING
	steve.state = sState.IDLE
	steve.sprite:play()
	ui:setEnabled( true )

	controller.controlsEnabled = true
	controller.pauseEnabled = true
	controller.SSVEnabled = true
	controller.SSVLaunched = false
	controller.noMovementDetected = false
end

function controller:pause()
	steve.state = sState.IDLE
	steve.sprite:pause()
	ui:setEnabled( false )

	if (controller.SSVLaunched == true) then
		Runtime:removeEventListener( "enterFrame", makeSteveJump )
		Runtime:removeEventListener( "enterFrame", makeSteveMove )
	end

	controller.controlsEnabled = false
	controller.SSVEnabled = false
	controller.SSVLaunched = false
end

return controller