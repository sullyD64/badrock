local physics =  require ( "physics" )
local items = require ( "items" )

local platforms = {}
platforms.list = {
	--1
		{
		type = "elevator",
		bounce = 0,
		friction = 1.0,
		density = 1.0,
		image = "sprites/rock-platform2.png",
		height = 50,
		width = 150,
		speed=0
		}
}

function platforms.createPlatform( platform, type )
		local p = nil
			for k, v in pairs(platforms.list) do
			if (v.type == type) then
				p = v
				break
			end
		end
		platform = display.newImageRect (p.image , p.width, p.height)
		platform.type = type
		platform.isGround = true
		--platform.isFixedRotation=true
		--platform.xScale=1
		p.rotation=90
		p.isFixedRotation=true
		--platform.yScale=1
		physics.addBody( platform, { density = p.density, friction = p.friction, bounce = p.bounce} )
		platform.bodyType="static"
		platform.HasBody=true
		return platform
end

return platforms