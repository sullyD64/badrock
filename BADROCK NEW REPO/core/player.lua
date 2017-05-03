-----------------------------------------------------------------------------------------
--
-- player.lua
--
-- The player is visually represented by an animated Entity (see entity.lua for more).
-- It is composed of three parts:
-- 1) The hitbox (an invisible image), which state is modified by the controller,
-- 2) A Sprite sequence (for the visual animations),
-- 3) A Sensor (to be used with the npcs' sensors and other entities).
-----------------------------------------------------------------------------------------
local entity = require ( "lib.entity" )

local player = {}
local settings = {

	walkForce = 150,
	maxJumpForce = -20,

	sensorOpts = {
		radius = 50,
		alpha = 0.5,
		color = {20, 50, 200},
	},

	sheetData = {
		height = 50,
		width = 30,
		numFrames = 4,
		sheetContentWidth = 120,--120,
		sheetContentHeight = 50 --40
	},

	sequenceData = {
		{name = "walking", start= 1, count =4, time = 300, loopCount=0},
		{name = "idle", start= 1, count =1, time = 300, loopCount=0},
		{name = "falling", start= 1, count =1, time = 300, loopCount=0},
		{name = "jumping", start= 1, count =1, time = 300, loopCount=0 }
	},
}

-- Loads the player's image, animations and sensor and initializes its attributes.
-- Visually istantiates the player in the current game's map.
-- @return player, sprite, sensorD (three Entities)
function player.loadPlayer( currentGame )
	-- Loads the Main Entity ("hitbox")
		local player = entity.newEntity{
			graphicType = "static",
			filePath = visual.steveImage,
			width = 30,
			height = 30,
			bodyType = "dynamic",
			physicsParams = { density=1.0, friction=0.7, bounce=0.01 },
			alpha = 0,
			isFixedRotation = true,
			eName = "steve"
		}

	-- Loads Sprite and animation sequences
		local sprite = entity.newEntity{
			graphicType = "animated",
			filePath = visual.steveSheetWalking,
			spriteOptions = settings.sheetData,
			spriteSequence = settings.sequenceData,
			bodyType = "static",
			physicsParams = { isSensor = true },
			eName = "steveSprite"
		}

	-- Loads the sensor, used to extend the player's "collision box"
		local sensorD = entity.newEntity{
			graphicType = "sensor",
			parentX = player.x,
			parentY = player.y,
			radius = settings.sensorOpts.radius,
			color = settings.sensorOpts.color,
			alpha = settings.sensorOpts.alpha,
			sensorName = "D"
		}

	-- Binds the player to the starting spawn point in the current game.
		local currentSpawn = currentGame.spawn
		player.x, player.y = currentSpawn.x, currentSpawn.y

		player.walkForce = settings.walkForce
		player.maxJumpForce = settings.maxJumpForce

	-- Insert the player's hitbox and sprite in the current map
		local currentMap = currentGame.map
		player:addOnMap ( currentMap )
		sprite:addOnMap ( currentMap )
		sensorD:addOnMap(currentMap)

		return player, sprite, sensorD
end


return player