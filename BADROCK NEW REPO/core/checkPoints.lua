-----------------------------------------------------------------------------------------
--
-- checkPoints.lua
--
-----------------------------------------------------------------------------------------
local entity = require ( "lib.entity" )

local checkPoints = {}

function checkPoints.loadCheckPoints( currentGame ) 
	local currentMap = currentGame.map
	local checkPointList = currentMap:getObjectLayer("checkPoints").objects
	if not (checkPointList) then return end

	local loadCheckPointEntity = function( cObj )
		local cEntity = entity.newEntity{
			width = 60,
			height = 60,
			filePath = visual.checkPointImage,
			bodyType = "static",
			physicsParams = {isSensor = true},
			eName = "checkPoint",
		}
		cEntity.x, cEntity.y = cObj.x, cObj.y

		cEntity.checkID = cObj.checkID
		cEntity:addOnMap(currentMap)

		local checkPointCollision = function( self, event )
			if (event.other.eName == "steve") then
				-- audio ----------------------------------------
				sfx.playSound( sfx.levelEndSound, { channel = 7 } )
				-------------------------------------------------
				display.remove(self)
				currentGame.setCheckPoint(cObj)
			end
		end

		if (not cObj.isStart) then
			cEntity.collision = checkPointCollision
			cEntity:addEventListener( "collision", cEntity )
		end
		return cEntity
	end

	for k, cPoint in pairs(checkPointList) do
		if (not cPoint.isStart) then
			cPoint.entity = loadCheckPointEntity(cPoint)
		end
	end
end


return checkPoints