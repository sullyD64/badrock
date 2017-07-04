-----------------------------------------------------------------------------------------
--
-- items.lua
--
-- This class describes the items that are placed on the map when specified events occur,
-- the most common being death of enemies. Enemies can carry one item and drop it when 
-- they die. 
-- Items are divided in two categories, plus pickable lives which are on their own:
-- 1) Powerups: they are usable items and act as weapons. They modify the action performed
-- 	by the press of the Action Button (see combat for more)
-- 2) Bonuses: they are immediatly consumed by the player and produce varying effects.
-----------------------------------------------------------------------------------------
local entity = require ( "lib.entity" )

local items = {
	descriptions = {
		-- 1 LIFE
		{
			type = "life",
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
		{
			type = "bonus",
			itemName = "immunity",
			filePath = visual.itemImmunity,
			width = 25,
			height = 25
		},
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

	desc.physicsParams = { filter = filters.itemFilterOff }
	desc.eName = "item"
	local item = entity.newEntity( desc )
	item.type = desc.type
	item.itemName = desc.itemName

	item.alpha = 0.2
	item.isPickable = false

	return item
end

function items.enableItem ( item )
	transition.to(item, { time = 1000, alpha = 1,
		onComplete = function()
			physics.removeBody( item )
			physics.addBody( item, "static", {filter = filters.itemFilterOn, isSensor = true} )
			item:addEventListener("collision", item)
			item.isPickable = true
			print("Item "..item.itemName.." is pickable")
		end
	})
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