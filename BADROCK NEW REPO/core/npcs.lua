-----------------------------------------------------------------------------------------
--
-- npcs.lua
--
-- An NPC (non-playable character) is an animated Entity (see entity.lua for more) 
-- with whom the Player can interact.
-- Every NPC is composed of three parts:
-- 1) The NPC Entity (a physical sensor always visible on the map);
-- 2) A Balloon (a "sliding" panel visible only when the player gets in range of the NPC);
-- 3) A Sensor (to be used with the player's sensor for detecting proximity for showing or
--    hiding the balloon).
-----------------------------------------------------------------------------------------
local entity = require ( "lib.entity"       )
local panel  = require ( "menu.utilityMenu" )

local npcs = {}

local settings = {
	sensorOpts = {
		radius = 60,
		alpha = 0.5,
		color = {100, 100, 0},
	},
}

-- Loads the npcs's images, speech balloons and initializes their attributes.
-- Visually instantiates the npcs in the current game's map.
-- @return npcs (a table of NPCS)
function npcs.loadNPCs( currentGame ) 
	local currentMap = currentGame.map
	local npcList = currentMap:getObjectLayer("npcSpawn"):getObjects("npc")

	-- Loads the main Entity.
		local loadNPCEntity = function( npc )
			local staticImage = entity.newEntity{
				graphicType = "static",
				filePath = visual.npcImage,
				width = 51,
				height = 128,
				bodyType = "static",
				physicsParams = { isSensor = true },
				eName = "npc"
			}		
			staticImage.x, staticImage.y = npc.x, npc.y
			staticImage:addOnMap( currentMap )

			return staticImage
		end

	-- Loads the speech balloon, the text and the buttons.
		local loadBalloon = function( npc )
			-- Panel status check for debug
				--[[
					local panelTransDone = function( target )
						if ( target.completeState ) then
							print( "PANEL STATE IS: "..target.completeState )
						end
					end
				]]

			local balloon = panel.newPanel{
				location = "static",
				-- onComplete = panelTransDone,
				speed = 200,
				x = npc.x,
				y = npc.y,
				-- anchorX = 0.5,
				-- anchorY = 0.5
			}

			local background = display.newImageRect( visual.npcBalloonBackground, 134, 107 )
			background.anchorY = 1
			balloon:insert(background)

			local button = display.newImageRect( visual.npcBalloonButton1, 58, 40 )
			button.x, button.y = background.x, background.y -50
			balloon:insert(button)

			balloon.x, balloon.y = npc.x, npc.y -20
			balloon.alpha = 0
			balloon:hide()

			-----------------------------------------------------------------
			balloon.button = button -- wip for control handler, will be removed soon
			-----------------------------------------------------------------

			-- Handles the showing/hiding event for one npc's balloon.
			-- Params: a NPC from the NPCs list and a flag string.
			-- The flag is calculated by the type of collision detected.
			function balloon:toggle ( flag )
				if (flag == "show") then
					self:show()
				elseif (flag == "hide") then
					self:hide()
				end
			end

			currentMap:getTileLayer("balloons"):addObject(balloon)

			return balloon
		end

	-- Loads the sensor for -npcDetectByCollision-.
		local loadSensor = function(npc)
			local sensorN = entity.newEntity{
				graphicType = "sensor",
				parentX = npc.x,
				parentY = npc.y,
				radius = settings.sensorOpts.radius,
				color = settings.sensorOpts.color,
				alpha = settings.sensorOpts.alpha,
				sensorName = "N"
			}
			-- Needed for sticking the sensor to the npc
			sensorN.gravityScale = 0

			sensorN:addOnMap(currentMap)

			return sensorN
		end

	for i, v in ipairs(npcList) do
			npcList[i].staticImage = loadNPCEntity(npcList[i])
			npcList[i].balloon = loadBalloon(npcList[i])
			npcList[i].sensorN = loadSensor(npcList[i])
	end

	return npcList
end

return npcs