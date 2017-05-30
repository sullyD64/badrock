-----------------------------------------------------------------------------------------
--
-- items.lua
--
-----------------------------------------------------------------------------------------
local entity = require ( "lib.entity" )

local items = {
	descriptions = {
		-- {	
		-- 	type = "bonus",
		-- 	itemName = "coin",
		-- 	filePath = visual.itemCoin,
		-- 	width = 25,
		-- 	height = 25
		-- },
		-- 1 LIFE
		{
			type = "bonus",
			itemName = "life",
			filePath = visual.itemLife,
			width = 25,
			height = 25
		},
		-- 2 GUN
		{
			type = "powerup",
			itemName = "gun",
			filePath = visual.itemGun,
			width = 25,
			height = 25
		},
		-- -- 3 IMMUNITY
		-- {
		-- 	type = "powerup",
		-- 	itemName = "immunity",
		-- 	filePath = visual.itemImmunity,
		-- 	width = 25,
		-- 	height = 25
		-- },
		-- -- 4 METHEORS RAIN
		-- {
		-- 	type = "powerup",
		-- 	itemName = "metheors",
		-- 	filePath = visual.itemMetheor,
		-- 	width = 25,
		-- 	height = 25
		-- },
		-- -- 5 SUMMON GUARDIAN
		-- {
		-- 	type = "powerup",
		-- 	itemName = "summon",
		-- 	filePath = visual.itemGun,
		-- 	width = 25,
		-- 	height = 25
		-- }
	}
}

function items.createItem( name )
	--Create a new Item that is returned when this function is called
	local desc
	for i, v in pairs(items.descriptions) do
		if (v.itemName == name) then
			desc = v
			break
		end
	end

	if (desc == nil ) then
		error(name .. ": Item not found in the ItemDescriptions")
	end

	desc.physicsParams = { filter = filters.itemFilter }
	desc.eName = "item"
	local item = entity.newEntity( desc )
	item.type = desc.type
	item.itemName = desc.itemName
	return item
end

--------------------------------------------------------------------------------------

-- local function findItemByName( name )
-- 	local item = nil
-- 	for k, v in pairs(items.list) do
-- 		if (v.name == name) then
-- 			item = v
-- 			break
-- 		end
-- 	end
-- 	return item
-- end

-- function addDropTo( enemy, itemName )
-- 	--Add an item drop to an enemy (MAX 1 Drop per Enemy, for now )
-- 	local item = items.findItemByName (itemName)
-- 	enemy.drop = item
-- end

return items