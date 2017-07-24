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
local entity     = require ( "lib.entity"      )
local collisions = require ( "core.collisions" )

local items = {
	descriptions = {
		-- 1 LIFE
		{
			type = "life",
			itemName = "life",
			filePath = visual.itemLife,
			width = 50,
			height = 50
		},
		-- 2 GUN
		{
			type = "powerup",
			itemName = "gun",
			filePath = visual.itemGun,
			width = 60,
			height = 60
		},
		-- -- 3 IMMUNITY
		{
			type = "bonus",
			itemName = "immunity",
			filePath = visual.itemImmunity,
			width = 60,
			height = 60
		},
	}
}

-- Loads one item
local function loadItem (currentGame, obj)
	local desc, item
	for i, v in pairs(items.descriptions) do
		if (v.itemName == obj.drop) then
			desc = v
			break
		end
	end

	if (desc == nil ) then
		error(obj.drop .. ": Item not found in the ItemDescriptions")
	end

	desc.physicsParams = { filter = filters.itemFilterOff }
	desc.eName = "item"
	desc.isFixedRotation = true

	item = entity.newEntity( desc )
	item.type = desc.type
	item.itemName = desc.itemName

	item.alpha = 0.2
	item.isPickable = false

	function item:enable()
		transition.to(self, { time = 1000, alpha = 1,
			onComplete = function()
				physics.removeBody( self )
				physics.addBody( self, "static", {filter = filters.selfFilterOn, isSensor = true} )
				self:addEventListener("collision", self)
				self.isPickable = true
			end
		})
	end

	function item:destroy()
		-- If the item is bound to a generator, nulls the entity to allow respawn
		if (self.oName) then
			currentGame.loadedItems[self.oName].entity = nil
		else
			self = nil
		end
	end

	item:addOnMap(currentGame.map)
	item.x, item.y = obj.x, obj.y
	item.collision = collisions.itemCollision
	item:enable()

	return item
end

-- Drops an item held from an enemy
function items.dropItemFrom( currentGame, enemy )
	table.insert(currentGame.loadedDrops, loadItem(currentGame, enemy))
end

-- Removes (sweeps) all the items on the map dropped by enemies.
function items.removeDrops( currentGame )
	local drops = currentGame.loadedDrops
	for k, item in pairs(drops) do
		display.remove(item)
		drops[k] = nil
	end
	return drops
end

-- Loads all the items which aren't held by enemies
function items.loadItems( currentGame ) 
	local itemList = currentGame.itemsGen

	-- Iterates the objects in itemList and loads the visual attributes of all objects
	for k, obj in pairs(itemList) do
		-- Avoids creating a duplicate entity for the object
		-- if one already exists and is on the map
		if (not obj.entity) then
			obj.entity = loadItem(currentGame, obj)
			obj.entity.oName = obj.name
		end
	end

	return itemList 
end

return items