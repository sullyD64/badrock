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

	for k, tile in pairs(map:getTileLayer("environment"):getTilesWithProperty("tName")) do
		tName = tile:getProperty("tName"):getValue()

		tile:addProperty(Property:new("HasBody", ""))

		if (tName ~= "dynamicEnv") then
			tile:addProperty(Property:new("bodyType", "static"))
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


return util