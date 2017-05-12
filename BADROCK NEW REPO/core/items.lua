-----------------------------------------------------------------------------------------
--
-- items.lua
--
-----------------------------------------------------------------------------------------
local physics 	 = require ( "physics"      )
local sfx     	 = require ( "audio.sfx"    )
local entity 	= require ( "lib.entity" )
local collisions = require ( "core.collisions" )

local items = {}

items.list = {
	{	
		name = "coin",
		filePath = visual.itemCoin,
		width = 25,
		height = 25
	},
	-- 1 LIFE
	{
		name = "life",
		filePath = visual.itemLife,
		width = 25,
		height = 25
	},
	-- 2 GUN
	{
		name = "gun",
		filePath = visual.itemGun,
		width = 25,
		height = 25
	},
	-- 3 IMMUNITY
	{
		name = "immunity",
		filePath = visual.itemImmunity,
		width = 25,
		height = 25
	},
	-- 4 METHEORS RAIN
	{
		name = "metheors",
		filePath = visual.itemMetheor,
		width = 25,
		height = 25
	},
	-- 5 SUMMON GUARDIAN
	{
		name = "summon",
		filePath = visual.itemGun,
		width = 25,
		height = 25
	}
}

local function findItemByName( name )
	local item = nil
	for k, v in pairs(items.list) do
		if (v.name == name) then
			item = v
			break
		end
	end
	return item
end


function items.createItem( name )
	--Create a new Item that is returned when this function is called
	local i = findItemByName(name)
	i.eName = "item"
	local item
	
	item = entity.newEntity( i )
	
	item.name = i.name
	item.collision = collisions.itemCollision
	item:addEventListener("collision")
	return item
end

--------------------------------------------------------------------------------------
--[[
function addDropTo( enemy, itemName )
	--Add an item drop to an enemy (MAX 1 Drop per Enemy, for now )
	local item = items.findItemByName (itemName)
	enemy.drop = item
end
]]

return items