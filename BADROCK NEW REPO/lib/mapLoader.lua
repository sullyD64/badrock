lime = require ( "lime.lime" )
lime.disableScreenCulling()

local loader = {}

-- Loads a map, given its source, on a given scene group.
function loader.loadMap(mapName, sceneGroup, doNotSetBounds)
	local map, visual, physical

	map = lime.loadMap(mapName)
	print(os.clock() .. " \t| loaded map" )
	visual = lime.createVisual(map)
	print(os.clock() .. " \t| loaded visual")
	sceneGroup:insert( visual )

	util.prepareMap(map, doNotSetBounds)
	physical = lime.buildPhysical(map)
	print(os.clock() .. " \t| built physical")

	return map
end

return loader