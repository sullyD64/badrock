-----------------------------------------------------------------------------------------
--
-- movingPlatform.lua
--
-----------------------------------------------------------------------------------------
local physics = require ( "physics" )

local platforms = {}

-- Loads the platforms and kicks them off moving.
function platforms.loadPlatforms( currentMap ) 
	local map = currentMap
	local platformList = map:getObjectLayer("movingPlatforms").objects

	if not (platformList) then return end

	-- Creates the platform body
	local createBody = function(obj)
		local body = display.newImageRect(visual.platform, obj.points[5], obj.points[6])
		body.x, body.y = obj.x, obj.y
		physics.addBody( body, "kinematic", { friction = 1, filter = filters.envFilter })
		body.id = obj.id
		body.isGround = true
		body.isPlatform = true
		body.isMovingPlatform = true
		body.tName = "env"

		-- Handles the collision only when a platform collides with one of its sensors.
		-- When that happens, bounces the platform in the opposite direction.
		body.collision = function( self, event )
			if ( event.phase == "began" and self.id == event.other.id) then
				local vx,vy = self:getLinearVelocity()
				self:setLinearVelocity( -vx, -vy )
			end
		end
		body:addEventListener( "collision", body )

		map:getTileLayer("entities"):addObject(body)
		return body
	end

	-- Iterates the list of platforms declared on the map
	for k, platformObj in pairs(platformList) do

		platformObj.body = createBody(platformObj)
		platformObj.sensors = util.createObjectSensors(map, platformObj)
		
		-- Starts moving the platform. It can be paused when physics is paused.
		if (platformObj.direction == "horizontal") then
			platformObj.body:setLinearVelocity( platformObj.speed, 0 )
		elseif (platformObj.direction == "vertical") then
			platformObj.body:setLinearVelocity( 0, platformObj.speed )
		end
	end
end

return platforms