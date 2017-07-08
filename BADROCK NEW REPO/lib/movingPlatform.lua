-----------------------------------------------------------------------------------------
--
-- movingPlatform.lua
--
-----------------------------------------------------------------------------------------
local physics = require ( "physics" )
physics.setDrawMode( "debug" )

local platforms = {}

-- If the platform is correctly drawn (clockwise starting from the top left corner)
-- the entries in obj.points will be enumerated as follows: 
--  		1,2 ____________ 3,4
--  		|                  | 		(1,2 are always x=0, y=0)
--  		|                  |
--  		7,8 ____________ 5,6
-- Entries are coupled as shown, and the first member of each couple has the x-value, 
-- the second the y-value. Therefore, good way to get width and height of the platform
-- is to access call points[5] for width and points[6] for height.

-- Loads the platforms and kicks them off moving.
function platforms.loadPlatforms( currentMap ) 
	local map = currentMap
	local platformList = map:getObjectLayer("movingPlatforms").objects

	if not (platformList) then return end

	-- Creates the platform body
	local createBody = function(obj)
		local body = display.newRect(obj.x, obj.y, obj.points[5], obj.points[6])
		body:setFillColor(0.5,0,0)
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

	-- Creates the platform's sensors used to delimit the platform's moving area.
	local createSensors = function(obj)
		local sensors = {}

		local leftSensor, rightSensor
		
		if (obj.direction == "horizontal") then
			leftSensor = display.newRect( obj.x, obj.y, 10, obj.points[6])
			rightSensor = display.newRect( obj.x, obj.y, 10, obj.points[6])
			leftSensor.x = obj.x - obj.travelDistance * 0.5
			rightSensor.x = obj.x  + obj.travelDistance * 0.5
		elseif (obj.direction == "vertical") then
			leftSensor = display.newRect( obj.x, obj.y, obj.points[5], 10)
			rightSensor = display.newRect( obj.x, obj.y, obj.points[5], 10)
			leftSensor.y = obj.y - obj.travelDistance * 0.5
			rightSensor.y = obj.y  + obj.travelDistance * 0.5
		end
	
	 	physics.addBody( leftSensor, "dynamic", { isSensor = true } )
	 	physics.addBody( rightSensor, "dynamic", { isSensor = true } )
	 	leftSensor.isVisible = false
	 	rightSensor.isVisible = false
	 	leftSensor.gravityScale = 0
	 	rightSensor.gravityScale = 0
	 	leftSensor.id = obj.id
	 	rightSensor.id = obj.id	 	
		map:getTileLayer("entities"):addObject(leftSensor)
		map:getTileLayer("entities"):addObject(rightSensor)

		sensors.leftSensor = leftSensor
		sensors.rightSensor = rightSensor
		return sensors
	end

	-- Iterates the list of platforms declared on the map
	for k, platformObj in pairs(platformList) do
		platformObj.travelDistance = 200
		platformObj.speed = 80

		platformObj.body = createBody(platformObj)
		platformObj.sensors = createSensors(platformObj)
		
		-- Starts moving the platform. It can be paused when physics is paused.
		if (platformObj.direction == "horizontal") then
			platformObj.body:setLinearVelocity( platformObj.speed, 0 )
		elseif (platformObj.direction == "vertical") then
			platformObj.body:setLinearVelocity( 0, platformObj.speed )
		end
	end
end

return platforms