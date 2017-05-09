-----------------------------------------------------------------------------------------
--
-- items.lua
--
-----------------------------------------------------------------------------------------
local physics  = require ( "physics"      )
local sfx      = require ( "audio.sfx"    )

local items = {}

items.list = {
	{
		name = "coin",
		type = "bonus",
		image = visual.itemCoin,
		width = 25,
		heigth = 25


	},
	-- 1 LIFE
	{
		name = "life",
		type = "bonus",
		image = visual.itemLife,
		width = 25,
		heigth = 25
		--effect = items.lifeEffect()
	},
	-- 2 STAR
	{
		name = "gun",
		type = "bonus",
		image = visual.itemGun,
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
	--entity.speed = value
--end

function items.createItem( name )
	--Create a new Life Item that is returned when this function is called
	local i = items.findItemByName(name)
	local item = display.newImageRect(i.image , i.width, i.heigth)
	item.name = i.name
	item.type = i.type
	item.myName = "item"
	transition.to(item, {time = 0, onComplete= function()
	physics.addBody(item )
	
	end})
	item.isSensor = true

	return item
end

-- ITEMS COLLISION HANDLERS ------------------------------------------------------------

	function items.itemCollision( game , event, item )
		--item.alpha = 0
		-- inserire qui eventuali suoni di collisione con gli item
		--display.remove( item )
		--game.map:getTileLayer("items"):removeObject( item )
		
		--List of all items with relative collision handler
		if (item.name == "coin") then
			coinCollision(game, event, item)
		elseif (item.name == "life") then
			lifeCollision(game, event, item)
		end
		item = nil -- Distruzione dell'item
	end

	function coinCollision( game , event, coin )
		if ( event.phase == "began" ) then
			sfx.playSound( sfx.coinSound, { channel = 3 } )
			coin.BodyType = "dynamic"
			display.remove( coin )
			game.addScore(100)

		elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		end
	end

	function lifeCollision( game, event, life )
		if ( event.phase == "began" ) then
			display.remove(life)
			--life.BodyType = "dynamic"
			game.addOneLife()
			
		elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		end
	end
----------------------------------------------------------------------------------------

function addDropTo( enemy, itemName )
	--Add an item drop to an enemy (MAX 1 Drop per Enemy, for now )
	local item = items.findItemByName (itemName)
	enemy.drop = item
end

return items