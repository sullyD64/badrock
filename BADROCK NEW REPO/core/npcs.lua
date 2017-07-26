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
		radius = 80,
		alpha = 0,	-- 0.5
		color = {100, 100, 0},
	},
	options = {
		graphicType = "animated",
		filePath = visual.npcSprite,
		notPhysical = true,
		spriteOptions = {
			height = 152,
			width = 110,
			numFrames = 3,
			sheetContentWidth = 330,
			sheetContentHeight = 152,
		},
		spriteSequence = {
			{name = "idle",  frames={1}, time=650, loopCount=0},
			{name = "happy", frames={2}, time=300, loopCount=0},
			{name = "sad",   frames={3}, time=300, loopCount=0},
		},
	},
}

-- Loads the npcs's images, speech balloons and initializes their attributes.
-- Visually instantiates the npcs in the current game's map.
-- @return npcList (a table of NPCS)
function npcs.loadNPCs( currentGame ) 
	local currentMap = currentGame.map
	local npcList = currentGame.npcsGen

	-- Loads the main animated Entity.
		local loadEntity = function( npcObj )
			local nSprite = entity.newEntity(settings.options)
			nSprite.score = 400
			nSprite.x, nSprite.y = npcObj.x, npcObj.y
			nSprite:addOnMap( currentMap )

				-- Destroys the visual attributes of an npc
				function nSprite:destroy()
					local oName = self.oName
					local npcObj = currentGame.loadedNPCs[oName]
					display.remove(npcObj.self)
					display.remove(npcObj.balloon)
					display.remove(npcObj.sensorN)
					currentGame.loadedNPCs[oName].entity = nil
					currentGame.loadedNPCs[oName].balloon = nil
					currentGame.loadedNPCs[oName].sensorN = nil
				end

			return nSprite
		end

	-- Loads the speech balloon, the text and the buttons.
		local loadBalloon = function( npcObj )
			-- Handler ---------------------------------------------------------------
			local onBalloonButtonEvent = function(event)
				local target = event.target
				local choice

				if (event.phase == "began") then
					-- Status check prevents from pressing the button when pause menu is overlaying.
					if (currentGame.state == "Running" and target.active) then
						display.currentStage:setFocus( target, event.id )
						target.active = false

						-- Good/bad action conditional behavior --
						if (target.id == "npcButton1") then
							-- audio ----------------------------------------
							audio.stop(7)
							sfx.playSound( sfx.npcGoodSound, { channel = 7 } )
							-------------------------------------------------
							choice = "good"
							npcObj.entity:setSequence("happy")
							npcObj.entity:play()
						elseif (target.id == "npcButton2") then
							-- audio ----------------------------------------
							audio.stop(7)
							sfx.playSound( sfx.npcEvilSound, { channel = 7 } )
							-------------------------------------------------
							choice = "evil"

							npcObj.entity:setSequence("sad")
							npcObj.entity:play()
						end
						-------------------------------------------
						currentGame.addScore(npcObj.entity.score)
						currentGame.addSpecialPoints(5, choice)
						-------------------------------------------

						-- Removes the associated npc entity, sensorN and balloon from the current game
						npcObj.balloon:hide()
						display.remove(npcObj.sensorN)

						-- Resets the switch on the npcDetect
						if (collisions.releaseEnabled) then
							collisions.releaseEnabled = false
						end

						-- Animation: npc flies up in the sky
						if (choice == "good") then
							transition.to(npcObj.entity, { time = 1000, 
								y = npcObj.y - 1000, alpha = 0, transition = easing.inQuart,
								onComplete = function()
									npcObj.entity:destroy()
								end
							})
						-- Animation: npc falls off the map
						elseif (choice == "evil") then
							transition.to(npcObj.entity, { time = 0,
								onComplete = function()
									physics.addBody( npcObj.entity, "dynamic", {isSensor = true, density = 0.1} )
									npcObj.entity:applyLinearImpulse( 0, -40, npcObj.entity.x, npcObj.entity.y )
									npcObj.entity:applyTorque( - 2000 )
								end
							})
							transition.to(npcObj.entity, { time = 1000, 
								onComplete = function()
									npcObj.entity:destroy()
								end
							})
						end
					end
				elseif (event.phase == "ended" or "cancelled" == event.phase) then
					display.currentStage:setFocus( target, nil )
				end

				return true
			end
			--------------------------------------------------------------------------
			-- balloon status check for debug
				-- local panelTransDone = function( target )
				-- 	if ( target.completeState ) then
				-- 		print( "Panel state is: "..target.completeState )
				-- 	end
				-- end

			local balloon = panel.newPanel{
				location = "static",
				-- onComplete = panelTransDone,
				speed = 200,
				x = npcObj.x - 60,
				y = npcObj.y - 20,
				width = npcObj.entity.width * 4,
				height = npcObj.entity.height * 4,
			}

			local background = display.newImageRect( visual.npcBalloonBackground, 279, 197 )
			background:scale(1.1, 1.2)
			background.anchorY = 1
			background.alpha = 0.7
			balloon:insert(background)

			local text = display.newImageRect( visual.npcBalloonText, 245, 101 )
			text:scale(0.9,0.9)
			text.anchorY = 1
			text.x = background.x - 10
			text.y = background.y - background.height + 70
			balloon:insert(text)

			local button1 = widget.newButton{
				id = "npcButton1",
				defaultFile = visual.npcBalloonButton1,
				--overFile = visual.npcBalloonButton1_over,
				width = 70,
				height = 70,
				x = background.x - background.width/9 - 20,
				y = background.y -90,
			}
			local button2 = widget.newButton{
				id = "npcButton2",
				defaultFile = visual.npcBalloonButton2,
				--overFile = visual.npcBalloonButton2_over,
				width = 70,
				height = 70,
				x = background.x + background.width/9 + 20,
				y = background.y -90,
			}

			button1.active = true
			button2.active = true
			button1:addEventListener( "touch", onBalloonButtonEvent )
			button2:addEventListener( "touch", onBalloonButtonEvent )

			balloon.button1 = button1
			balloon.button2 = button2
			balloon:insert(button1)
			balloon:insert(button2)
			balloon.x, balloon.y = npcObj.x, npcObj.y -20
			balloon.alpha = 0
			balloon:hide()

			-- Handles the showing/hiding event for one npc's balloon.
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
		local loadSensor = function(npcObj)
			local sensorN = entity.newEntity{
				graphicType = "sensor",
				parentX = npcObj.x,
				parentY = npcObj.y,
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
			sensorN.collision = collisions.npcDetectByCollision
			sensorN:addEventListener( "collision", sensorN )
			sensorN:addOnMap(currentMap)

			return sensorN
		end

	-- Iterates the objects in ncpList and loads the visual attributes of all objects
	for k, obj in pairs(npcList) do
		-- To avoid creating a duplicate entity for the object
		-- if one already exists and is on the map, it is destroyed
		if (not obj.entity) then
			obj.entity = loadEntity(obj)
			obj.balloon = loadBalloon(obj)
			obj.sensorN = loadSensor(obj)
			obj.entity.oName = obj.name
			-- obj.balloon.oName = obj.name  	--not used
			obj.sensorN.oName = obj.name
		end
	end

	return npcList
end

return npcs