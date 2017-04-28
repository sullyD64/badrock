-----------------------------------------------------------------------------------------
--
-- player.lua
--
-- The player is an Entity, see entity.lua for more
-----------------------------------------------------------------------------------------

local entity = require ("lib.entity")

local player = {}
local settings = {

	walkForce = 150,
	maxJumpForce = -20,

	sensor1Radius = 50,	-- wip
	sensor1Alpha = 0.5,

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

-- Loads the player's image, animations and initializes its attributes.
-- Visually istantiates the player in the current game's map.
-- @return player, sprite (two Entities)
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

	-- Binds the player to the starting spawn point in the current game.
		local currentSpawn = currentGame.spawn
		player.x, player.y = currentSpawn.x, currentSpawn.y

		player.walkForce = settings.walkForce
		player.maxJumpForce = settings.maxJumpForce

	-- Insert the player's hitbox and sprite in the current map
		local currentMap = currentGame.map
		player:addOnMap ( currentMap )
		sprite:addOnMap ( currentMap )

		return player, sprite
end

-- Loads invisible sensor(s) surrounding the player.
-- A Sensor is used to extend an entity's "collision box"
-- Visually istantiates the sensor(s) in the current game's map.
-- @return sensorD
function player.loadSensors( currentGame )
	local player = currentGame.steve
	local currentMap = currentGame.map

	local sensorD
	sensorD = display.newCircle( player.x, player.y, settings.sensor1Radius )
	physics.addBody( sensorD, {isSensor = true, radius = settings.sensor1Radius} )
	sensorD.sensorName = "D"
	sensorD:setFillColor( 100, 50, 0 )
	sensorD.alpha = settings.sensor1Alpha

	currentMap:getTileLayer("sensors"):addObject(sensorD)

	return sensorD

	-- local sensorE
		-- sensorE = display.newCircle( player..x, player..y, 40)
		-- physics.addBody(sensorE, {isSensor = true, radius = 40})
		-- sensorE.sensorName = "E"
		-- sensorE.setFillColor( 0, 200, 255)
		-- sensorE.alpha=0.4

		-- currentMap:getTileLayer("sensors"):addObject(sensorE)
		
		-- return sensorD, sensorE
end


return player