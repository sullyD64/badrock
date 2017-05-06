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

-- local game, steve
-- local gState, sState


-----------------------------------------
-- Prototype of control handler function
local onJumpTouch = function(event)
end
-----------------------------------------


-- CONTROLS HANDLERS ---------------------------------------------------------------
	-- -- Inputs game pause (and opens the pause panel) if game is running and resume if paused.
	-- local function pauseResume(event)
	-- 	local target = event.target

	-- 	if (event.phase == "began") then
	-- 		display.currentStage:setFocus( target )

	-- 	elseif (event.phase == "ended" or "cancelled" == event.phase) then
	-- 		if (target.myName == "pauseBtn") then
	-- 			game.state = game.GAME_PAUSED
	-- 			ui.pauseBtn.isVisible = false
	-- 			ui.resumeBtn.isVisible = true
	-- 			pauseMenu.psbutton = ui.getButtonByName("pauseBtn")
	-- 			pauseMenu.rsbutton = ui.getButtonByName("resumeBtn")
	-- 	        pauseMenu.panel:show({ y = display.screenOriginY+225,})
	-- 		elseif (target.myName == "resumeBtn") then
	-- 			game.state = game.GAME_RESUMED
	-- 			ui.pauseBtn.isVisible = true
	-- 			ui.resumeBtn.isVisible = false
	-- 			pauseMenu.panel:hide()
	-- 		end
	-- 		display.currentStage:setFocus( nil )
	-- 	end

	-- 	return true --Prevents touch propagation to underlying objects
	-- end
------------------------------------------------------------------------------------



-- This table should be accessed ONLY by the UI when declaring each widget's handler.
controller.listeners = {
	--onJumpTouch,
	-- ...
}

-- This function is accessed from -game.loadGame-.
function controller.setGame ( currentGame )
	game = currentGame
	steve = game.steve

	gState = game.states
	sState = steve.states
end

function controller.prepareUI()
	ui.setListeners( controller )
	ui.loadUI()
	game.map:getTileLayer("JUMPSCREEN"):addObject(ui.buttons.jumpScreen)
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