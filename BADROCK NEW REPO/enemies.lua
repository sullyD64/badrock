-----------------------------------------------------------------------------------------
--
-- enemies.lua
--
-----------------------------------------------------------------------------------------
local physics =  require ( "physics" )
local items = require ( "items" )

local enemies = {}

	enemies.list = {
	--1
		{
		type = "paper",
		lives = 1,
		bounce = 0.1,
		friction = 1.0,
		density = 1.0,
		image = "sprites/paper.png",
		height = 40,
		width = 40,
		speed=0
		},
	--2
		{
		type = "sedia",
		lives = 5,
		bounce = 0.1,
		friction = 1.0,
		density = 1.0,
		image = "sprites/sedia.png",
		height = 113,
		width = 70,
		speed=0
		}

}

-- Create a new Enemy with his attributes and image if we pass (as a parameter) an object from Tiled
function enemies.createEnemy( enemy , type )
		local en = nil
		for k, v in pairs(enemies.list) do
			if (v.type == type) then
				en = v
				break
			end
		end
		enemy = display.newImageRect (en.image , en.width, en.height)
		enemy.type = type
		enemy.lives = en.lives
		enemy.isEnemy = true
		enemy.isTargettable = true
		physics.addBody( enemy, { density = en.density, friction = en.friction, bounce = en.bounce} )
		return enemy
end



return enemies