-----------------------------------------------------------------------------------------
--
-- entity.lua
--
-- An Entity is an object that is represented on the game's current map by a Corona Display Object, 
-- whether it is a static image or an animated sprite or a shape. 
-- An Entity is first positioned on the map by a Tiled Object representing its "spawn point", and it
-- is istantiated on a select Tile Level depending by one of the entities attributes.
-- All Entities are Physical Objects (static or dynamic), can move on the map and
-- interact with each other.
--
-- All Entities have an unique identifier called "eName":
-- Use it for collision detection when needed
--
-- Examples of Entity: Steve, an Enemy, an NPC, a Boss, an Item, a Parcticle (e.g. bolts, rocks, ..)
-- # WIP: Sensors are also entities
-----------------------------------------------------------------------------------------

local physics = require ( "physics")

local entity = {}

-- Create a new entity. Some options must always be specified, like the image/sheet file path,
-- others are required depending on the type of entity.
function entity.newEntity( options )
	local customOptions = options or {}
	local opt = {}

	-- by leaving this field blank, overrides default with static (most frequent)
	opt.graphicType = customOptions.graphicType or "static"

	-- always required (except for sensors)
	opt.filePath = customOptions.filePath

	-- required if graphicType is "static"
	opt.width = customOptions.width
	opt.height = customOptions.height

	-- required if graphicType is "dynamic"
	opt.spriteOptions = customOptions.spriteOptions
	opt.spriteSequence = customOptions.spriteSequence

	-- required if graphicType is "sensor"
	opt.parentX = customOptions.parentX
	opt.parentY = customOptions.parentY
	opt.radius = customOptions.radius
	opt.color = customOptions.color or {200, 200, 200} 

	opt.bodyType = customOptions.bodyType or "dynamic"
	opt.physicsParams = customOptions.physicsParams

	if (opt.graphicType == "sensor") then 
		opt.filePath = "bypassed"
		opt.physicsParams = {isSensor = true, radius = opt.radius}
	end

	local ent = {}
	if (opt.filePath or opt.filePath == "bypassed") then 
		if     (opt.graphicType == "static"  ) then
			if (opt.width and opt.height) then
				ent = display.newImageRect( opt.filePath, opt.width, opt.height )
			else
				error ("no width or height specified for the new image")
			end
		elseif (opt.graphicType == "animated") then
			if (opt.spriteOptions and opt.spriteSequence) then
				local sheet = graphics.newImageSheet( opt.filePath, opt.spriteOptions )
				ent = display.newSprite(sheet, opt.spriteSequence)
			else
				error ("invalid sprite options or sequence data for the new sprite")
			end
		elseif (opt.graphicType == "sensor"  ) then
			if (opt.radius) then
				ent = display.newCircle( opt.parentX, opt.parentY, opt.radius )
				ent:setFillColor( opt.color[1], opt.color[2], opt.color[3] )
				ent.sensorName = customOptions.sensorName
			else
				error ("no parent position or radius length specified for the new sensor")
			end
		end
		physics.addBody(ent, opt.bodyType, opt.physicsParams)
	else
		error( "invalid source file specified for the new entity" )
	end

	ent.alpha = customOptions.alpha or 1
	ent.rotation = customOptions.rotation or 0
	ent.isFixedRotation = customOptions.isFixedRotation or false
	ent.eName = customOptions.eName

	if (ent.sensorName) then ent.eName = "sensor" end

	-- Each Entity has an unique name specified by the attribute "eName": this is used to determine
	-- in which Tile Layer it will be added.
	function ent:addOnMap( map )
		local name = self.eName
		if (map) then
			if 	 (name == "steve" or "steveSprite") then
				map:getTileLayer("playerObject"):addObject(self)
			elseif (name == "item") then
				map:getTileLayer("items"):addObject(self)
			elseif (name == "sensor") then
				map:getTileLayer("sensors"):addObject(self)
			else --default
				map:getTileLayer("entities"):addObject(self)
			end
		else
			error("invalid or non-existent map")
		end
	end

	ent.__index = ent
	return ent
end

-- function entity:isOnMap()

-- function entity:removeFromMap()

return entity