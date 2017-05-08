-----------------------------------------------------------------------------------------
--
-- enemies.lua
--
-- An enemy is an animated Entity capable of moving on the map and performing other actions 
-- which can kill Steve in several ways.
-----------------------------------------------------------------------------------------
local entity = require ( "lib.entity"       )
local panel  = require ( "menu.utilityMenu" )
local collisions = require ( "core.collisions"  )

local enemies = {}


	function follow(currentGame,object,player)
			local currentMap = currentGame.map
			if((object.x~=nil and object.y~=nil) and(player.x~=nil and player.y~=nil) and currentGame.state~="Paused") then--il problema è che poi non richiama la transizione del disaggro
																										--per colpa del game.paused quando steve muore
				object.isFixedRotation=true
				object.speed=1--quello sopra continua a essere flash
				if(math.abs(object.x-player.x)<=400) then
					local angle= math.atan2(player.y - object.y, player.x - object.x) -- work out angle between target and missile
					object.x = object.x + (math.cos(angle) * object.speed) -- update x pos in relation to angle
						if(player.x>object.x) then
						object.xScale=-1
						else object.xScale=1
						end
						--se steve è sopra una piattaforma non lontana dal nemico allora il nemico salta, non funziona
						if(((object.y-player.y)>0 and (object.y-player.y)<1000) and (math.abs(player.x-object.x)<40) ) then
							local impulso= (player.y-object.y)
							object:applyLinearImpulse( 0, -impulso*4, object.x, object.y )
						end
				
					local vuoto = nil
					local vuotoList = currentMap:getObjectLayer("cadutaVuoto").objects

						for k, v in pairs(vuotoList) do
							vuoto = vuotoList[k]

						end
					local direzione=math.abs(object.x-vuoto.x)
					local distanzab= math.abs(direzione)
					local distanzaverticalebordo= math.abs(object.y-vuoto.y)


					--i nemici disaggrano steve alla morte, bisogna sistemare il momento in cui lo considerano morto? sgommata se si rimane fermi...
						if(((player.state == STATE_DIED and currentGame.state=="Running"))) then --and (math.abs(object.x-player.x)<=100 and math.abs(object.y-player.y)<=100)) ) then

							object.xScale=-1
							
							local transition= transition.to(object,{time=3500,xScale=-1,x=(object.x+280)})--onPause= function() print ("transition paused")end})
						end
						--dovrebbe disaggrare anche se si trova nei pressi dello spawn point, per evitare che steve spawni dove c'è un nemico
						-- if (math.abs(currentGame.spawn.x-object.x)<=150 and (currentGame.spawn.y==object.y)) then
						-- 	object.xScale=-1
							
						-- 	local transition= transition.to(object,{time=3500,xScale=-1,x=(object.x+280)})
						-- end

						--saltano continuamente a prescindere
						local salto=false
						if(distanzab<=100 and distanzaverticalebordo<=100 and object.lives~=0 ) then
							
							if(object.xScale==-1 and salto==false) then
							object:applyLinearImpulse( 5, -15, object.x, object.y )
							salto=true
							elseif(object.xScale==1 and salto==false) then
							object:applyLinearImpulse( -5, -15, object.x, object.y )
							salto=true
							end

						end
					
					
				end
			end
	end



------------------------------------------------------------------------------------

-- GIGI WIP-------------------------------------------------------------------------
	--[[
		function prova()
		for k,v in ipairs(game.enemyLevelList) do
		transition.to(game.enemyLevelList[k], {
				time=1500,
				x=(game.enemyLevelList[k].x - 120),
				onComplete=prova()
			})
		end
	]]


	function salta(object,player)
		if(object.y>player.y) then
		local impulso= (object.y-player.y)
		if(impulso<=150) then
		object:applyLinearImpulse( 0, -impulso/3, object.x, object.y )
		end
		--transition.to( object, { time=1500, y=object.y-20 } )
		end
	end



	

  


	function f(object)
		local angle= math.atan2(game.steve.x - object.y, game.steve.y - object.x) -- work out angle between target and missile
		object.x = object.x + (math.cos(angle) * object.speed) -- update x pos in relation to angle
		object.y = object.y + (math.sin(angle) * object.speed) -- update y pos in relation to angle
	end


	-- i nemici si muovono a destra e sinistra, lista
	function muovi(object)
		object.isFixedRotation=true
		function goLeft ()
		transition.to( object, { time=1500, x=(object.x - 120), onComplete=goRight } )
		object.xScale=1
		end

		function goRight ()
		transition.to( object, { time=1500, x=(object.x + 120), onComplete=goLeft } )
		object.xScale=-1
		end

		goLeft()
	end



	-- i nemici dovrebbero seguire steve, per alcuni, liste
	function segui(steve)
		for i = 1, #enemiesList do
			local distanceX = steve.x - enemiesList[i].x
			local distanceY = steve.y - enemiesList[i].y

			local angleRadians = math.atan2(distanceY, distanceX)
			local angleDegrees = math.deg(angleRadians)

			local enemySpeed = 5

			local enemyMoveDistanceX = enemySpeed*math.cos(angleDegrees)
			local enemyMoveDistanceY = enemySpeed*math.sin(angleDegrees)

			enemy.x = enemy.x + enemyMoveDistanceX
			enemy.y = enemy.y + enemyMoveDistanceY
		end
	end

	
-- Loads the enemies's images, speech balloons and initializes their attributes.

-- Loads the enemies's images (and sprites) and initializes their attributes.

-- Visually instantiates the enemies in the current game's map.
-- @return enemies (a table of enemies)
function enemies.loadEnemies( currentGame ) 
	local currentMap = currentGame.map
	local enemyList = currentMap:getObjectLayer("enemySpawn"):getObjects("enemy")
	local player= currentGame.steve

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
				

				local function move()
    			follow(currentGame,staticImage,player)
				end
		

				local listener = {}
				function listener:timer( event )
   				salta(staticImage,player)
   				print("no")
				end


				function s(object,player)
					timer.performWithDelay( 3000, listener )
				end

				Runtime:addEventListener( "enterFrame", move )	--inseguono steve
 				timer.performWithDelay(2000,s,-1)				--saltano se steve è sopra le piattaforme (restringere range)

 				staticImage.preCollision = collisions.enemyPreCollision
				staticImage:addEventListener( "preCollision", staticImage)

				--deadcode, indagare malfunzionamento
				staticImage.towerCollision = collisions.enemyFormazioneATorre
				staticImage:addEventListener( "towerCollision", staticImage)


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