local platforms = require ("lib.movingPlatform")
local entity = require ("lib.entity")

util = {}

function util.print_r ( t )  
	 local print_r_cache={}
	 local function sub_print_r(t,indent)
		  if (print_r_cache[tostring(t)]) then
				print(indent.."*"..tostring(t))
		  else
				print_r_cache[tostring(t)]=true
				if (type(t)=="table") then
					 for pos,val in pairs(t) do
						  if (type(val)=="table") then
								print(indent.."["..pos.."] => "..tostring(t).." {")
								sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
								print(indent..string.rep(" ",string.len(pos)+6).."}")
						  elseif (type(val)=="string") then
								print(indent.."["..pos..'] => "'..val..'"')
						  else
								print(indent.."["..pos.."] => "..tostring(val))
						  end
					 end
				else
					 print(indent..tostring(t))
				end
		  end
	 end
	 if (type(t)=="table") then
		  print(tostring(t).." {")
		  sub_print_r(t,"  ")
		  print("}")
	 else
		  sub_print_r(t,"  ")
	 end
	 print()
end

-- Returns True if an object has an attribute specified by its name 
-- (attributeName must be a string).
function util.hasAttribute( obj , attributeName )
	 local ris = false
	 for k, v in pairs(obj) do
		  if k == attributeName then
				ris =true
				break
		  end
	 end
	 return ris
end

function util.prepareMap(currentMap)
	local map = currentMap
	if not map then return end

	local props = map:getProperties()

	map:setScale(0.6)

	local bounds = {
		xMin = 0,
		yMin = 0,
		xMax = props.tilewidth:getValue() * props.width:getValue() - display.viewableContentWidth + display.contentCenterX * 1.25,
		yMax = props.tileheight:getValue() * props.height:getValue() - display.viewableContentHeight + display.contentCenterY * 0.70,
	}
	map:setClampingBounds( bounds.xMin, bounds.yMin, bounds.xMax, bounds.yMax )

	local walls = map:getTileLayer("blockingWalls")
	if (walls) then 
		walls:hide()
	end

	for k, tile in pairs(map:getTileLayer("environment"):getTilesWithProperty("tName")) do
		tName = tile:getProperty("tName"):getValue()

		tile:addProperty(Property:new("HasBody", ""))

		if (tName ~= "dynamicEnv") then
			if not tile:hasProperty("isMoving") then
				tile:addProperty(Property:new("bodyType", "static"))
			else
				tile:addProperty(Property:new("bodyType", "kinematic"))
			end
			tile:addProperty(Property:new("categoryBits", filters.envFilter.categoryBits))
			tile:addProperty(Property:new("maskBits", filters.envFilter.maskBits))
			if not tile:hasProperty("isSlippery") and tile:hasProperty("isGround") then
				tile:addProperty(Property:new("friction", 1))
			else
				tile:addProperty(Property:new("friction", 0))
			end
		else
			tile:addProperty(Property:new("bodyType", "dynamic"))
			tile:addProperty(Property:new("friction", "0.08"))
			tile:addProperty(Property:new("categoryBits", filters.dynamicEnvFilter.categoryBits))
			tile:addProperty(Property:new("maskBits", filters.dynamicEnvFilter.maskBits))
		end	
	end

	platforms.loadPlatforms(map)
end

function util.getBossTrigger(currentMap)
	local map = currentMap
	if not map then return end

	local events = map:getObjectLayer("events")
	if (events) then
		return events:getObject("bossTrigger")
	end
end

function util.createWalls(currentMap)
	local map = currentMap
	if not map then return end

	local walls = map:getTileLayer("blockingWalls")
	local tiles = walls:getTilesWithProperty("tName")

	for k, tile in pairs(tiles) do
		if(tile:hasProperty("isSensor"))then
			tile:removeProperty("isSensor")
		end
		tile:addProperty(Property:new("HasBody", ""))
		tile:addProperty(Property:new("bodyType", "static"))
		tile:addProperty(Property:new("categoryBits", filters.envFilter.categoryBits))
		tile:addProperty(Property:new("maskBits", filters.envFilter.maskBits))
		tile:addProperty(Property:new("friction", 0))
		transition.to(tile, {time = 0,
			onComplete = function()
				tile:build()
			end
		})
	end
	walls:show()
end

function util.destroyWalls(currentMap)
	local map = currentMap
	if not map then return end

	local walls = map:getTileLayer("blockingWalls")
	
	if(walls.tiles)then
		local tiles = walls:getTilesWithProperty("tName")
		for k, tile in pairs(tiles) do
			transition.to(tile, {time = 0,
				onComplete = function()
				tile:addProperty(Property:new("isSensor", true))
					tile:build()
				end
			})
		end
	end
	walls:hide()
end

-- Creates an object's sensors used to delimit the object's moving area.
	-- If the object is a platform:
	-- If the platform is correctly drawn (clockwise starting from the top left corner)
	-- the entries in obj.points will be enumerated as follows: 
	--  		1,2 ____________ 3,4
	--  		|                  | 		(1,2 are always x=0, y=0)
	--  		|                  |
	--  		7,8 ____________ 5,6
	-- Entries are coupled as shown, and the first member of each couple has the x-value, 
	-- the second the y-value. Therefore, good way to get width and height of the platform
	-- is to access call points[5] for width and points[6] for height.
function util.createObjectSensors(currentMap, obj)
	local map = currentMap
	if not map then return end

	local sensors = {}
	local direction = obj.direction or "horizontal"

	local leftSensor, rightSensor
	
	if (direction == "horizontal") then
		if (obj.points) then
			leftSensor = display.newRect( obj.x, obj.y, 10, obj.points[6])
			rightSensor = display.newRect( obj.x, obj.y, 10, obj.points[6])
		else
			leftSensor = display.newRect( obj.x, obj.y, 10, obj.width)
			rightSensor = display.newRect( obj.x, obj.y, 10, obj.width)
		end
		leftSensor.x = obj.x - obj.travelDistance * 0.5
		rightSensor.x = obj.x  + obj.travelDistance * 0.5
	elseif (direction == "vertical") then
		leftSensor = display.newRect( obj.x, obj.y, obj.points[5], 10)
		rightSensor = display.newRect( obj.x, obj.y, obj.points[5], 10)
		leftSensor.y = obj.y - obj.travelDistance * 0.5
		rightSensor.y = obj.y  + obj.travelDistance * 0.5
	end

 	physics.addBody( leftSensor, "dynamic", { isSensor = true } )
 	physics.addBody( rightSensor, "dynamic", { isSensor = true } )
 	leftSensor.isVisible = false
 	rightSensor.isVisible = false
 	leftSensor.gravityScale = 0
 	rightSensor.gravityScale = 0
 	leftSensor.id = obj.id
 	rightSensor.id = obj.id	 	
	map:getTileLayer("entities"):addObject(leftSensor)
	map:getTileLayer("entities"):addObject(rightSensor)

	sensors.leftSensor = leftSensor
	sensors.rightSensor = rightSensor
	return sensors
end

function util.generateParticles( currentGame, obj )
		display.remove(obj)
		local fragments = {}
		local fragmentGroup = display.newGroup()
		local numRocks = 5
		
		for i = 1, numRocks, 1 do
			local dim = math.random (4, 20)
			local directionX = math.random(-2, 2)
			local directionY = math.random(-2, 2)
			local frag = entity.newEntity{
				filePath = visual.lifeIcon,
				width = dim,
				height = dim,
				physicsParams = {density = 1, friction = 1, bounce = 0.5, filter = filters.parcticleFilter},
				eName = "particle"
			}	
			frag.x , frag.y = obj.x, obj.y
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
					if(currentGame.state ~= "Ended") then fragments[i]:removeSelf() end
				end
				if(currentGame.state ~= "Ended") then display.remove( fragmentGroup ) end
			end
		})
	end

-- Use to display the center of the screen
-- display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, 1)
-- display.newRect(display.contentCenterX, display.contentCenterY, 1, display.contentHeight)
-- rc = display.newRect(display.contentCenterX, display.contentCenterY, 1, 1)
-- rc:setFillColor( 1,0,0 )

return util