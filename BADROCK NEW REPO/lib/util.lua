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

	local bounds = {
		xMin = 0,
		yMin = 0,
		xMax = props.tilewidth:getValue() * props.width:getValue() + display.contentCenterX,
		yMax = props.tileheight:getValue() * props.height:getValue(),
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
			tile:addProperty(Property:new("categoryBits", filters.dynamicEnvFilter.categoryBits))
			tile:addProperty(Property:new("maskBits", filters.dynamicEnvFilter.maskBits))
		end	
	end
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
	local tiles = walls:getTilesWithProperty("tName")

	for k, tile in pairs(tiles) do
		transition.to(tile, {time = 0,
			onComplete = function()
				tile.isSensor = true
			end
		})
	end
	walls:hide()
end


local movingTiles = {}
function util.preparePlatforms(currentMap)
	for k, tile in pairs(map:getTileLayer("environment"):getTilesWithProperty("isMoving")) do
		table.insert(movingTiles, tile)
		tile.tx, tile.ty = tile:getWorldPosition()

		tile.movePath = {
			{x = tile.tx +20, y = tile.ty},
			{x = tile.tx -20, y = tile.ty},
		}
		tile.standPath = {
			{x = tile.tx, y = tile.ty},
			{x = tile.tx, y = tile.ty},
		}
	end
end

function util.movePlatforms(currentMap, flag)
	for k, tile in pairs(movingTiles) do
		if not flag then return end

		if (flag == "on") then
			tile:slideAlongPath(tile.movePath, 1000)
		elseif(flag == "off") then
			tile:slideAlongPath(tile.standPath, 10000)
		end
	end
end
 
-- -- 2) Create the platform
-- local platform = display.newRect( display.contentCenterX, 250, 100, 25 )
-- platform:setFillColor( 1,0,0 )
-- physics.addBody( platform, "kinematic" )
-- platform.travelDistance = 200  -- Set the total travel distance
-- platform.speed = 40  -- Set the speed for the platform
-- platform.id = 1  -- Set platform ID for collision detection with sensors (see below)
 
-- -- 3) Create the sensor objects
-- local leftSensor = display.newRect( 0, platform.y, 10, platform.height )
-- leftSensor.isVisible = false
-- physics.addBody( leftSensor, "dynamic", { isSensor=true } )
-- leftSensor.gravityScale = 0  -- Make the sensor float (no effect from gravity)
-- leftSensor.id = 1  -- Set sensor ID for collision detection with respective platform
-- leftSensor.x = platform.x - ( platform.travelDistance * 0.5 )
 
-- local rightSensor = display.newRect( 0, platform.y, 10, platform.height )
-- rightSensor.isVisible = false
-- physics.addBody( rightSensor, "dynamic", { isSensor=true } )
-- rightSensor.gravityScale = 0  -- Make the sensor float (no effect from gravity)
-- rightSensor.id = 1  -- Set sensor ID for collision detection with respective platform
-- rightSensor.x = platform.x + ( platform.travelDistance * 0.5 )
 
-- -- 4) Set up the collision handler function/listener
-- local function onCollision( self, event )
--     if ( "began" == event.phase and self.id == event.other.id ) then
--         local vx,vy = self:getLinearVelocity()
--         self:setLinearVelocity( -vx, -vy )
--     end
-- end
-- platform.collision = onCollision
-- platform:addEventListener( "collision", platform )
 
-- -- 5) Set the platform in motion
-- platform:setLinearVelocity( platform.speed, 0 )

return util