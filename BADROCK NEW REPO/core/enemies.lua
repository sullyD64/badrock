-----------------------------------------------------------------------------------------
--
-- enemies.lua
--
-- An enemy is an animated Entity capable of moving on the map and performing other actions 
-- which can kill Steve in several ways.
-----------------------------------------------------------------------------------------
local entity = require ( "lib.entity"       )
local panel  = require ( "menu.utilityMenu" )

local enemies = {}

-- Loads the enemies's images (and sprites) and initializes their attributes.
-- Visually instantiates the enemies in the current game's map.
-- @return enemies (a table of enemies)
function enemies.loadEnemies( currentGame ) 
	local currentMap = currentGame.map
	local enemyList = currentMap:getObjectLayer("enemySpawn"):getObjects("enemy")
	local imageList= {}

	-- Loads the main Entity.
		local loadenemyEntity = function( enemy )
		 	for i, v in pairs(enemyList) do
				local staticImage
				--print(enemyList[i].type)
				if (v.type == "paper") then
					staticImage = entity.newEntity{
						graphicType = "static",
						filePath = visual.enemyPaper,
						width = 40,
						height = 40,
						bodyType = "dynamic",
						physicsParams = { bounce=0,friction = 1.0, density = 1.0, },
						eName = "enemy"
					}
					staticImage.lives=1
					staticImage.x, staticImage.y = enemyList[i].x, enemyList[i].y
						
				elseif (v.type == "sedia") then
					staticImage = entity.newEntity{
						graphicType = "static",
						filePath = visual.enemySedia,
						width = 70,
						height = 113,
						bodyType = "dynamic",
						physicsParams = { bounce=0,friction = 1.0, density = 1.0, },
						eName = "enemy"
					}
					staticImage.lives=5
					staticImage.x, staticImage.y = enemyList[i].x, enemyList[i].y
						
				end
				staticImage.isTargettable=true
				staticImage.isEnemy=true

				if(enemyList[i].drop ~=nil) then
					staticImage.drop = enemyList[i].drop
				end

				staticImage:addOnMap( currentMap )
			end

			return staticImage
		end

	--la scansione del ciclo dei nemici in tutta la mappa è fatta all'interno di loadenemy
	enemyList[1].staticImage = loadenemyEntity(enemyList[1])
	return enemyList
end

return enemies