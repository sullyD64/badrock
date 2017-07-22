local collisions = require ( "core.collisions" )

local behavior = {}

-- WALKER-SPECIFIC FUNCTIONS -------------------------------------------------------
------------------------------------------------------------------------------------

-- MAIN -------------------------------------------------------------------------
	function behavior.loadWalkerBehavior( enemyObj, currentGame )
		local walker = enemyObj.entity
		walker.id = enemyObj.id
		walker.speed = enemyObj.speed
		walker.travelDistance = enemyObj.travelDistance
		walker.sensors = util.createObjectSensors(currentGame.map, walker)

		-- Handles the collision when a walker collides with one of its sensors.
		-- When that happens, bounces the walker in the opposite direction.
		-- Used also when the walker collides with the player
		walker.collision = function( self, event )
			if ( event.phase == "began") then
				if ( self.id == event.other.id) then
					local vx,vy = self:getLinearVelocity()
					self:setLinearVelocity( -vx, -vy )
					self.xScale = - self.xScale
				end
			end
		end
		walker:addEventListener( "collision", walker )

		transition.to(walker, {time = 500,
			onComplete = function()
				walker.bodyType = "kinematic"
				walker:setLinearVelocity( -walker.speed, 0 )
				walker:setSequence("walking")
				walker:play()
			end
		})

		return walker
	end
	---------------------------------------------------------------------------------

return behavior