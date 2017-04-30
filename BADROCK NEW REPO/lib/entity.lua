-----------------------------------------------------------------------------------------
--
-- entity.lua
--
-- An Entity is an object that is represented on the game's current map by a Corona Display Object, 
-- whether it is a static image or an animated sprite. 
-- An Entity is first positioned on the map by a Tiled Object representing its "spawn point", and it
-- is istantiated on a select Tile Level depending by one of the entities attributes.
-- All Entities are Physical Objects (static or dynamic), can move on the map and
-- interact with each other.
--
-- All Entities have an unique identifier called "eName":
-- Use it for collision detection when needed
--
-- Examples of Entity: Steve, an Enemy, an NPC, a Boss, an Item, a Parcticle (e.g. bolts, rocks, ..)
-----------------------------------------------------------------------------------------

local physics = require ( "physics")

local entity = {}

-- Create a new entity. Some options must always be specified, like the image/sheet file path,
-- others are required depending on the type of entity.
function entity.newEntity( options )
	local customOptions = options or {}
	local opt = {}

	opt.graphicType = customOptions.graphicType or "static"
	opt.filePath = customOptions.filePath	--required

	-- required if graphicType is "static"
	opt.width = customOptions.width
	opt.height = customOptions.height

	-- required if graphicType is "dynamic"
	opt.spriteOptions = customOptions.spriteOptions
	opt.spriteSequence = customOptions.spriteSequence

	opt.bodyType = customOptions.bodyType or "dynamic"
	opt.physicsParams = customOptions.physicsParams

	local ent = {}
	if (opt.filePath) then 
		if (opt.graphicType == "static") then
			if (opt.width and opt.height) then
				ent = display.newImageRect( opt.filePath, opt.width, opt.height )
			else
				error ("no width or heigth specified for the new entity's image")
			end
		elseif (opt.graphicType == "animated") then
			if (opt.spriteOptions and opt.spriteSequence) then
				local sheet = graphics.newImageSheet( opt.filePath, opt.spriteOptions )
				ent = display.newSprite(sheet, opt.spriteSequence)
			else
				error ("invalid sprite options or sequence data")
			end
		end
		physics.addBody(ent, opt.bodyType, opt.physicsParams)
	else
		error( "invalid source file specified for the new entity's image" )
	end

	ent.alpha = customOptions.alpha or 1
	ent.rotation = customOptions or 0
	ent.isFixedRotation = customOptions or false
	ent.eName = customOptions.eName 

	-- Each Entity has an unique name specified by the attribute "eName": this is used to determine
	-- in which Tile Layer it will be added.
	function ent:addOnMap( map )
		local name = self.eName
		if (map) then
			if 	 (name == "steve" or "steveSprite") then
				map:getTileLayer("playerObject"):addObject(self)
			elseif (name == "item") then
				map:getTileLayer("items"):addObject(self)
			else
				map:getTileLayer("entities"):addObject(self)
			end
		else
			error("invalid or non-existent map")
		end
	end

	function ent:setPosition( pos )
		if (pos) then
			ent.position = pos
			ent.x, ent.y =ent.position:unpack()
		else
			error ("invalid or non-existent position")
		end
	end

	ent.__index = ent
	return ent
end

-- function entity:isOnMap()

-- function entity:removeFromMap()

return entity