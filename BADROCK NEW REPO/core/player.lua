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
local entity  = require ( "lib.entity"   )
local combat = require ( "core.combat" )

local player = {}
local settings = {

	mainSensorOpts = {
		radius = 50,
		alpha = 0, --0.5
		color = {20, 50, 200},
	},

	mainSheetData = {
		height = 50,
		width = 30,
		numFrames = 10,
		sheetContentWidth = 300,
		sheetContentHeight = 50 
	},

	mainSequenceData = {
		{name = "walking", start=1, count=5, time=300, loopCount=0},
		{name = "idle",    start=1, count=1, time=300, loopCount=0},
		{name = "falling", start=9, count=2, time=200, loopCount=0},
		{name = "jumping", start=6, count=3, time=100, loopCount=1}
	},
}


-- PLAYER-SPECIFIC FUNCTIONS -------------------------------------------------------
	-- (must be self-contained and not call anything outside this module)

	-- Animation on Steve's death: he explodes in small rock particles.
	-- (The particles are Entities)
	local function defaultPlayerDeathAnimation(currentGame, playerX, playerY)
		local fragments = {}
		local fragmentGroup = display.newGroup()
		local numRocks = 10
		
		for i = 1, numRocks, 1 do
			local dim = math.random (2, 10)
			local directionX = math.random(-1, 1)
			local directionY = math.random(-1, 1)
			local frag = entity.newEntity{
				filePath = visual.lifeIcon,
				width = dim,
				height = dim,
				physicsParams = {density = 1, friction = 1, bounce = 0.5, filter = filters.parcticleFilter},
				eName = "particle"
			}	
			frag.x , frag.y = playerX, playerY
			frag:addOnMap(currentGame.map)
			fragmentGroup:insert(frag)

			-- Transition here is needed because we need to wait newEntity to finish
			-- its transition to the entities' physical bodies.
			transition.to(frag, {time = 0,
				onComplete = function()
					frag:applyLinearImpulse(directionX, directionY, frag.x , frag.y)
					end
				})
			table.insert(fragments, frag)
		end

		currentGame.map:getTileLayer("entities"):addObject(fragmentGroup)

		-- Removes physics to the rock fragments after a brief delay.
		transition.to(fragmentGroup, {alpha = 0, time = 3000, transition = easing.inExpo, 
			onComplete = function()
				for i=1, #fragments, 1 do
					fragments[i].isBodyActive = false
					fragments[i].alpha = 0
					if(gameStateList ~= ENDED) then fragments[i]:removeSelf() end
				end
				if (gameStateList ~= ENDED) then display.remove( fragmentGroup ) end
			end
		})
	end
------------------------------------------------------------------------------------

-- Loads the player's image, animations and sensor and initializes its attributes.
-- Visually istantiates the player in the current game's map.
-- @return player, player.sprite, player.sensorD (three Entities)
function player.loadPlayer( currentGame )
	-- Loads the Main Entity ("hitbox")
		local player = entity.newEntity{
			graphicType = "static",
			filePath = visual.steveImage,
			width = 30,
			height = 30,
			bodyType = "dynamic",
			physicsParams = { density=1.0, friction=0.7, bounce=0.01, },
			alpha = 0,
			isFixedRotation = true,
			eName = "steve"
		}
	-- Loads Sprite and animation sequences
		local sprite = entity.newEntity{
			graphicType = "animated",
			filePath = visual.steveSheetWalking,
			spriteOptions = settings.mainSheetData,
			spriteSequence = settings.mainSequenceData,
			notPhysical = true,
			eName = "steveSprite"
		}
	-- Loads the sensor, used to extend the player's "collision box"
		local sensorD = entity.newEntity{
			graphicType = "sensor",
			parentX = player.x,
			parentY = player.y,
			radius = settings.mainSensorOpts.radius,
			color = settings.mainSensorOpts.color,
			alpha = settings.mainSensorOpts.alpha,
			physicsParams = { filter = filters.sensorDFilter },
			sensorName = "D"
		}
	-- Binds the player to the starting spawn point in the current game.
		local spawn = currentGame.spawnPoint
		player.x, player.y = spawn.x, spawn.y
		player.deathAnimation = defaultPlayerDeathAnimation
	-- Inserts the player's hitbox and sprite in the current map
		local currentMap = currentGame.map
		player:addOnMap ( currentMap )
		sprite:addOnMap ( currentMap )
		sensorD:addOnMap ( currentMap )

		player.sprite = sprite
		player.sensorD = sensorD

	combat.setMap(currentMap)
	combat.setPlayer(player)

	function player:performAttack()
		player.state = "Attacking"
		if (player.hasPowerUp) then 
			---------------------------------------------------------------
			---[specificare i diversi metodi di combat per ciascun powerup]
			---------------------------------------------------------------
		else
			combat.performMelee()
		end
	end

	function player:cancelAttack()
		combat.cancel()
	end

	return player
end

return player