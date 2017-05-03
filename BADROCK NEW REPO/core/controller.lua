-----------------------------------------------------------------------------------------
--
-- controller.lua
--
-- This class handles all the #TOUCH# events occurring on the game's User Interface.
-- This means it handles every input by the user INSIDE a LevelX scene.
-- These methods can access and modify the game's current state, aswell as the Player's
-- current state, position on the map, sprite sequence and other actions.
-- These methods are only enabled under certain circumstances.
-----------------------------------------------------------------------------------------
local physics = require ( "physics"   )
local ui      = require ( "core.ui"   )
-- more imports??

local controller = {}

local game, player

function controller.setGame ( currentGame, player )
	game = currentGame
	player = player
end


local SSVEnabled
local SSVLaunched, SSVType
local letMeJump














return controller