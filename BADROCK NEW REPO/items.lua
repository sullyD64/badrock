-----------------------------------------------------------------------------------------
--
-- items.lua
--
-----------------------------------------------------------------------------------------

local items = {}

items.list = {

	-- 1 LIFE
	{
		name = "life",
		type = "bonus",
		image = "ui/life2.png",
		width = 25,
		heigth = 25
		--effect = items.lifeEffect()
	},
	-- 2 STAR
	{
		name = "gun",
		type = "bonus",
		image = "ICON/H.png",
		width = 25,
		heigth = 25
		--effect = items.lifeEffect()
	}

}

function items.findItemByName( name )
	
	local item = nil
	for k, v in pairs(items.list) do
		if (v.name == name) then
			item = v
			break
		end
	end
	return item
end

--local function items.lifeEffect()
--	entity.speed = value
--end


function items.createItem( name )
	--Create a new Life Item that is returned when this function is called
	local i = items.findItemByName(name)
	local item = display.newImageRect(i.image , i.width, i.heigth)
	item.name = i.name
	item.type = i.type
	return item
end




function addDropTo( enemy , itemName )
	--Add an item drop to an enemy (MAX 1 Drop per Enemy, for "now" )

	local item = items.findItemByName (itemName)
	enemy.drop = item
end

return items