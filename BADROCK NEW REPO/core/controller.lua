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
local physics = require ( "physics"   )
local ui      = require ( "core.newUi"   )
local pauseMenu  = require ( "menu.pauseMenu"   )

local controller = {}

local game = {}
local steve = {}
local gState = {}
local sState = {}

-- CONTROLS HANDLERS ---------------------------------------------------------------

-- Inputs movement on the y-axis.
local function onJumpEvent(event)
	if (game.state == gState.RUNNING) then
		if (event.phase == "began") then
			display.currentStage:setFocus( event.target, event.id )
			if (steve.canJump == true) then
				--sfx.playSound( sfx.jumpSound, { channel = 2 } )
				steve.state = sState.JUMPING

				SSVType = "jump"
				Runtime:addEventListener("enterFrame", setSteveVelocity)
				steve.jumpForce = -200
				steve.actualSpeed = game.steve.jumpForce

				i = 0
				j = 18

				steve.canJump = false
				letMeJump = false
			end

		elseif (event.phase == "ended" or "cancelled" == event.phase) then
			display.currentStage:setFocus( event.target, nil )
			steve.state = sState.IDLE
			steve.jumpForce = 0
			steve.sprite:setSequence("idle")
			Runtime:removeEventListener("enterFrame", setSteveVelocity)	
		end
	end

	return true
end

-- Inputs game pause (and opens the pause panel) if game is running 
-- and resume if paused, switching visibility between the two buttons.
local function onPauseResumeEvent(event)
	local target = event.target

	if (event.phase == "began") then
		display.currentStage:setFocus( target, event.id )
		if (event.target.id == "pauseBtn") then
			game.state = gState.PAUSED
			ui:setEnabled( false )
			ui.buttons.resume:setEnabled( true )
			ui.buttons.pause.isVisible = false
			ui.buttons.resume.isVisible = true
			-----------------------------------------------------
			pauseMenu.panel:show({y = display.screenOriginY+225})
			-----------------------------------------------------
		elseif (event.target.id == "resumeBtn") then
			ui.buttons.pause.isVisible = true
			ui.buttons.resume.isVisible = false
			ui.buttons.pause:setEnabled( true )
			ui.buttons.resume:setEnabled( false )
			-----------------------------------------------------
			pauseMenu.panel:hide()
			-----------------------------------------------------
			game.state = gState.RESUMED
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

	ui.buttons.pause:addEventListener( "touch", onPauseResumeEvent )
	ui.buttons.resume:addEventListener( "touch", onPauseResumeEvent )

	ui.buttons.action.active = true
	ui.buttons.resume.isVisible = false
	ui.buttons.scoreUp.isVisible = false
end

-- Called by -game.start()-.
function controller:start()
	game.state = gState.RUNNING
	steve.state = sState.IDLE
	steve.sprite:play()
	ui:setEnabled( true )
end

function controller:pause()
	game.state = gState.PAUSED
	steve.sprite:pause()
	ui:setEnabled( false )
end

local SSVEnabled
local SSVLaunched, SSVType
local letMeJump


return controller