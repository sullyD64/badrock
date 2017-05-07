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
-----------------------------------------------------------------------------------------
local physics   = require ( "physics"        )		-- serve?
local ui        = require ( "core.newUi"     )
local sfx       = require ( "audio.sfx"      )
local pauseMenu = require ( "menu.pauseMenu" )

local controller = {
	controlsEnabled, SSVEnabled, SSVLaunched, letMeJump, i, j,
}

local SSVEnabled
local SSVLaunched, SSVType
local letMeJump

local game = {}
local steve = {}
local gState = {}
local sState = {}


-- PLAYER MOVEMENT -----------------------------------------------------------------
	local function makeSteveJump()
		local steveXV, steveYV = steve:getLinearVelocity()
			
		if (steve.jumpForce > -400 and controller.j ~= 0) then
			-- In both cases (x-movement or y-movement), we set the character's linear velocity at each
			-- frame, overriding one of the two linear velocities when a movement is input.
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

			print("i:" ..controller.i.. "| j:" ..controller.j.. "	| jumpForce:" .. steve.jumpForce)
		else
			steve.jumpForce = 0
		end
	end

	local function makeSteveMove()
		local steveXV, steveYV = steve:getLinearVelocity()
		-- In both cases (x-movement or y-movement), we set the character's linear velocity at each
		-- frame, overriding one of the two linear velocities when a movement is input.
		if (steve.jumpForce ~= 0) then
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
			steve.state = sState.JUMPING
			sfx.playSound( sfx.jumpSound, { channel = 2 } )

			----------------------------------------------------
			steve.jumpForce = - 200
			Runtime:addEventListener("enterFrame", makeSteveJump)
			controller.i = 0
			controller.j = 16
			steve.canJump = false
			letMeJump = false
			----------------------------------------------------		
		
		elseif (event.phase == "ended" or "cancelled" == event.phase) then
			steve.state = sState.IDLE
			steve.sprite:setSequence("idle")
			-------------------------------------------------------
			steve.jumpForce = 0
			Runtime:removeEventListener("enterFrame", makeSteveJump)
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
			steve.state = sState.WALKING

			--Avoid walking animation in mid air
			if(steve.airState == "Idle" or steve.airState == nil) then
				steve.sprite:setSequence("walking")
				steve.sprite:play()
			end

			-- Visually simulate the button press (depending on which is pressed).
			-- target.alpha = 0.8
			--------------------------------------------------------------
			-- Determines the direction based on wich button is pressed
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
			--------------------------------------------------------------

		elseif (event.phase == "ended" or "cancelled" == event.phase) then
			steve.state = sState.IDLE
			steve.sprite:setSequence("idle")
			--target.alpha = 0.1
			--------------------------------------------------------
			steve.actualspeedX = 0
			Runtime:removeEventListener("enterFrame", makeSteveMove)	
			--------------------------------------------------------
			display.currentStage:setFocus( target, nil )
		end
	end
	return true
end

-- Inputs action, depending on the current weapon equipped or other circumstances.
	-- local function actionTouch( event )
	-- 	local attackDuration = 500
	-- 	local target = event.target

	-- 	--if (game.state == gState.RUNNING) then
	-- 		if (event.phase=="began" and target.active == true) then
	-- 			display.currentStage:setFocus( target, event.id )

	-- 			if (game.controlsEnabled) then
	-- 				sfx.playSound( sfx.attackSound, { channel = 4 } )

	-- 				-- Visually simulate the button press
	-- 				actionBtn.active = false
	-- 				actionBtn.alpha = 0.5

	-- 				game.steve.state = game.STEVE_STATE_ATTACKING
	-- 				steveAttack = display.newCircle( game.steve.x, game.steve.y, 40)
	-- 				physics.addBody(steveAttack, {isSensor = true})
	-- 				steveAttack.myName = "steveAttack"
	-- 				steveAttack:setFillColor(0,0,255)
	-- 				steveAttack.alpha=0.6
	-- 				game.map:getTileLayer("playerEffects"):addObject( steveAttack )
	-- 				game.steveSprite.alpha=0

	-- 				-- Steve dashes forward
	-- 				game.steve:applyLinearImpulse( game.steve.direction * 8, 0, game.steve.x, game.steve.y )

	-- 				-- Visually links the SteveAttack to Steve
	-- 				local steveAttackFollowingSteve = function ()
	-- 					steveAttack.x, steveAttack.y = game.steve.x, game.steve.y
	-- 				end

	-- 				-- Handles the end of the attack phase
	-- 				local steveAttackStop = function ()
	-- 					display.remove(steveAttack)
	-- 					game.steve.state = game.STEVE_STATE_IDLE
	-- 					Runtime:removeEventListener("enterFrame" , steveAttackFollowingSteve)
	-- 					actionBtn.active = true
	-- 					actionBtn.alpha = 1
	-- 					game.steveSprite.alpha = 1
	-- 				end

	-- 				Runtime:addEventListener("enterFrame", steveAttackFollowingSteve)
	-- 				timer.performWithDelay(attackDuration, steveAttackStop)
	-- 			end
	-- 		elseif (event.phase == "ended" or "cancelled" == event.phase) then
	-- 			display.currentStage:setFocus( nil )
	-- 		end
	-- 	--end

	-- 	return true
	-- end


-- Inputs game pause (and opens the pause panel) if game is running 
-- and resume if paused, switching visibility between the two buttons.
local function onPauseResumeEvent(event)
	local target = event.target

	if (event.phase == "began") then
		display.currentStage:setFocus( target, event.id )
		if (event.target.id == "pauseBtn") then
			game.state = gState.PAUSED
			ui.buttons.resume:setEnabled( true )
			ui.buttons.pause.isVisible = false
			ui.buttons.resume.isVisible = true
			-----------------------------------------------------
			pauseMenu.panel:show({y = display.screenOriginY+225})
			-----------------------------------------------------
		elseif (event.target.id == "resumeBtn") then
			game.state = gState.RESUMED
			ui.buttons.pause.isVisible = true
			ui.buttons.resume.isVisible = false
			ui.buttons.pause:setEnabled( true )
			ui.buttons.resume:setEnabled( false )
			-----------------------------------------------------
			pauseMenu.panel:hide()
			-----------------------------------------------------
		end

	elseif (event.phase == "ended" or "cancelled" == event.phase) then
		display.currentStage:setFocus( nil )
	end
	
	return true
end
------------------------------------------------------------------------------------

-- This function is accessed from -game.loadGame-.
function controller.setGame ( currentGame, gameStateList, playerStateList )
	game = currentGame
	steve = currentGame.steve

	gState = gameStateList
	sState = playerStateList
end

function controller.prepareUI()
	ui.loadUI()
	game.map:getTileLayer("JUMPSCREEN"):addObject(ui.buttons.jump)

	ui.buttons.jump:  addEventListener( "touch", onJumpEvent )
	ui.buttons.dleft: addEventListener( "touch", onDpadEvent )	
	ui.buttons.dright:addEventListener( "touch", onDpadEvent )
	-- ui.buttons.action:addEventListener( "touch", onActionEvent )
	ui.buttons.pause: addEventListener( "touch", onPauseResumeEvent )
	ui.buttons.resume:addEventListener( "touch", onPauseResumeEvent )

	ui.buttons.action.active = true
	ui.buttons.resume.isVisible = false
	ui.buttons.scoreUp.isVisible = false
end

-- Called by -game.start and game.resume-.
function controller:start()
	game.state = gState.RUNNING
	steve.state = sState.IDLE
	steve.sprite:play()
	ui:setEnabled( true )


	controller.controlsEnabled = true
	controller.SSVEnabled = true
end

function controller:pause()
	steve.state = sState.IDLE
	steve.sprite:pause()
	ui:setEnabled( false )

	controller.controlsEnabled = false
end

return controller