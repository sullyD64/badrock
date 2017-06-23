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
local entity     = require ( "lib.entity"       )
local widget     = require ( "widget"           )
local panel      = require ( "menu.utilityMenu" )
local collisions = require ( "core.collisions"  )

local npcs = {}

local settings = {
	sensorOpts = {
		radius = 40,
		alpha = 0,	-- 0.5
		color = {100, 100, 0},
	},
}

-- Loads the npcs's images, speech balloons and initializes their attributes.
-- Visually instantiates the npcs in the current game's map.
-- @return npcList (a table of NPCS)
function npcs.loadNPCs( currentGame ) 
	local currentMap = currentGame.map
	local npcList = currentMap:getObjectLayer("npcSpawn"):getObjects("npc")

	-- Loads the main Entity.
		local loadNPCEntity = function( npc )
			local staticImage = entity.newEntity{
				graphicType = "static",
				filePath = visual.npcImage,
				width = 90,
				height = 108,
				notPhysical = true,
				eName = "npc"
			}		
			staticImage.x, staticImage.y = npc.x, npc.y
			staticImage:addOnMap( currentMap )

			return staticImage
		end

	-- Loads the speech balloon, the text and the buttons.
		local loadBalloon = function( npc )
			-- Panel status check for debug
				-- local panelTransDone = function( target )
				-- 	if ( target.completeState ) then
				-- 		print( "Panel state is: "..target.completeState )
				-- 	end
				-- end

			local balloon = panel.newPanel{
				location = "static",
				-- onComplete = panelTransDone,
				speed = 200,
				x = npc.x + 60,
				y = npc.y - 20,
				-- anchorX = 0.5,
				-- anchorY = 0.5
			}

			local background = display.newImageRect( visual.npcBalloonBackground, 182, 174 )
			background.anchorY = 1
			balloon:insert(background)

			local text = display.newImageRect( visual.npcBalloonText, 81, 33 )
			text.anchorY = 1
			text.y = -100
			balloon:insert(text)

			--------------------------------------------------------------------------
			local onBalloonButtonEvent = function(event)
				local target = event.target
				local scoreToAdd

				-- Status check prevents from pressing the button when pause menu is overlaying.
				if (currentGame.state == "Running") then
					if (event.phase == "began") then
						display.currentStage:setFocus( target, event.id )

						-- Good/bad action conditional behavior --
						if (target.id == "npcButton1") then
							scoreToAdd = 1000
						elseif (target.id == "npcButton2") then
							scoreToAdd = -1000
						end
						currentGame.addScore(scoreToAdd)
						-------------------------------------------

						-- Removes the associated npc from the current game
						for i, npc in pairs(currentGame.npcs) do
							if (npc.balloon.button1 == target or npc.balloon.button2 == target) then
								npc.balloon:hide()
								display.remove(npc.sensorN)

								-- Resets the switch on the npcDetect
								if (collisions.releaseEnabled) then
									collisions.releaseEnabled = false
								end

								-- Animation: npc flies up in the sky
								transition.to(npc.staticImage, { time = 1000, 
									y = npc.y - 1000, alpha = 0, transition = easing.inCubic,
									onComplete = function()
										display.remove(npc.staticImage)
										display.remove(npc.balloon)
										npc:destroy()
										table.remove(currentGame.npcs, i)		
										npc = nil
									end
								})
							end
						end
					elseif (event.phase == "ended" or "cancelled" == event.phase) then
						display.currentStage:setFocus( target, nil )
					end
				end
				return true
			end
			--------------------------------------------------------------------------

			local button1 = widget.newButton{
				id = "npcButton1",
				defaultFile = visual.npcBalloonButton1,
				--overFile = visual.npcBalloonButton1_over,
				width = 40,
				height = 40,
				x = background.x - background.width/9 - 10,
				y = background.y -80,
			}
			local button2 = widget.newButton{
				id = "npcButton2",
				defaultFile = visual.npcBalloonButton2,
				--overFile = visual.npcBalloonButton2_over,
				width = 40,
				height = 40,
				x = background.x + background.width/9 + 10,
				y = background.y -80,
			}

			button1:addEventListener( "touch", onBalloonButtonEvent )
			button2:addEventListener( "touch", onBalloonButtonEvent )

			balloon.button1 = button1
			balloon.button2 = button2

			balloon:insert(button1)
			balloon:insert(button2)

			balloon.x, balloon.y = npc.x, npc.y -20
			balloon.alpha = 0
			balloon:hide()

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

			currentMap:getTileLayer("MAP_BUTTONS"):addObject(balloon)

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
				physicsParams = { filter = filters.sensorNFilter },
				sensorName = "N"
			}
			-- Needed for sticking the sensor to the npc
			transition.to(sensorN, {time = 0, 
				onComplete = function()
					sensorN.gravityScale = 0
				end
			})

			sensorN:addOnMap(currentMap)

			return sensorN
		end

	for k, npc in pairs(npcList) do
			npc.staticImage = loadNPCEntity(npc)
			npc.balloon = loadBalloon(npc)
			npc.sensorN = loadSensor(npc)
	end

	return npcList
end

return npcs