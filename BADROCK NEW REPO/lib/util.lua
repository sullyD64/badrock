local platforms = require ("lib.movingPlatform")
local entity = require ("lib.entity")

util = {}

-- LUA TABLE UTILITIES -------------------------------------------------------------
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

	-- Prints the table and its first order of children
	-- Optionally prints also the value of one given attribute
	function util.print ( t, n, a )
		local name = n or tostring(t)
		print("v-----------------------------------------v")
		print(" > Table "..tostring(name).." [size:"..util.sizeof(t).."]")
		for k,v in pairs(t) do
			if (a and v[a]) then
				print ("    "..k,v,a..":yes "..tostring(v[a])) --tostring(v[a])
			else
				print ("    "..k,v)
			end
		end
		print("^-----------------------------------------^")
	end

	-- Prints the table and its first two orders of children
	-- Optionally prints also the value of one given attribute
	function util.print2( t, n, a )
		local name = n or tostring(t)
		print("v-------------------------------------------------v")
			print(" > Table "..tostring(name).." [size:"..util.sizeof(t).."]")
			for k,v in pairs(t) do
				util.print(v, k, a)
			end
		print("^-------------------------------------------------^")
	end

	-- Returns the size of a table regardless the type of the key
	function util.sizeof (t)
	  local count = 0
	  for i in pairs(t) do count = count + 1 end
	  return count
	end

	-- Adds all the elements of the first table into the second table.
	function util.copy( t1, t2 )
		for k, v in pairs(t1) do
			table.insert(t2, v)
		end
	end

	-- Adds all the elements of a table into a new table
	function util.copyNew( t )
		local tCopy = {}
		for k, v in pairs(t) do
			table.insert(tCopy, v)
		end
		return tCopy
	end

	-- Given a table, creates a subset of entries having an attribute whose value
	-- corresponds to a given value. The subset is returned in a table
	function util.subtable( t, attribute, value )
		local sub = {}
		for k, v in pairs(t) do
			if util.contains(v, attribute, value) then
				table.insert(sub, v)
			end
		end
		return sub
	end

	-- Checks if a table has an attribute specified by its name.
	-- Optionally it can also check if the attribute corresponds to a value.
	function util.contains( t, attributeName, value )
		local ris = false
		for k, v in pairs(t) do
			if k == attributeName then
				if not value 
					then ris = true break
				elseif (v == value) 
					then ris = true break
				end
			end
		end
		return ris
	end

	-- Transforms a table in a keyMap by substituting the index of each entry with a key. 
	-- Each entry must contain a field named after the parameter keyName. 
	-- WARNING: each value per entry in the field keyName must be UNIQUE.
	-- The key is parametric and is extracted from the entry's value for that field name.
		-- Example:
		-- (we can't have foo[1].name = "life" and foo[2].name = "life")
		-- (we can have foo[1].name = "life1" and foo[2].name = "life2")
		-- 
		-- toKeyMap(foo, "name")
		--     Before:                | After:
		--     foo = {                | foo = {
		--       1   table: 0AC48418  |   life1   table: 0AC48418
		--       2   table: 0AC48FF8  |   life2   table: 0AC48FF8
		--       3   table: 0AC48404  |   gun1    table: 0AC48404
		--     }                      | }
	function util.toKeyMap( t, keyName )
		if (not keyName) then
			error ("You must specify the name of the key")
		end
		for k, v in pairs(t) do
			if (not t[k][keyName]) then
				error ("Element "..k.." of " ..tostring(t).. " does not have a field \"" ..keyName.."\"")
			end
		end
		for k, v in ipairs(t) do
			local key = v[keyName]
			t[key] = v
			t[k] = nil
		end
	end
------------------------------------------------------------------------------------

-- MAP UTILITIES -------------------------------------------------------------------
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
		
		walls:hide()
		end
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

		function sensors:destroy()
			display.remove(self.leftSensor)
			display.remove(self.rightSensor)
			self.leftSensor = nil
			self.rightSensor = nil
		end

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
------------------------------------------------------------------------------------
return util