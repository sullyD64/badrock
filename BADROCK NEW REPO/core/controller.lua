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
local ui      = require ( "core.ui"   )

local controller = {}

local game   = {}
local player = {}

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

-- This table should be accessed ONLY by the UI.
controller.listeners = {
	onJumpTouch,
	-- ...
}


local function launchUIListeners()
	game.map:getTileLayer("JUMPSCREEN"):addObject(ui.buttons.jumpScreen)

end

-- This function is accessed by Game inside -game.loadGame-.
function controller.load ( currentGame )
	game = currentGame
	player = currentGame.steve

	ui.loadUI()
	launchUIListeners()
end

local SSVEnabled
local SSVLaunched, SSVType
local letMeJump


return controller