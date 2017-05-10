-----------------------------------------------------------------------------------------
--
-- enemies.lua
--
-- An enemy is an hostile Entity capable of moving on the map and performing other actions 
-- which can kill Steve in several ways. 
-- There are several "species" of enemy, which differ in aspect, size and other aspects.
-- Enemies will also behave differently depending on other parameters. For now, there are 
-- two types of behavior [in the short future will become three]:
-- 1) If no additional property is specified, an Enemy will stay still and will only 
-- 	hurt the Player passively if this collides with him;
-- 2) If the property isChaser is true, the Enemy will be a Chaser.
-- 	A Chaser will stay still and have an "aggro" zone surrounding him; if the Player
--    gets inside this aggro zone, the Chaser will start "chasing" the Player; if the Player
-- 	dies (by any cause), the Chaser will return to the center of his aggro zone and wait 
-- 	for the Player to come closer again;
-- 	There is also a "safe zone" located around the Player's spawn point, which will make
-- 	the Chaser stop chasing the Player.
-- 3) [If the property isWalker is true, the Enemy will be a Walker.
-- 	 A Walker moves on the map following a pre-established route].
-- 
-- Every Enemy species and type is guessed from the properties of the objects declared in
-- the game's current map, all of which indicate the spawn point for that selected Enemy.
----------------------------------------------------------------------------------------
local entity     = require ( "lib.entity"      )
local collisions = require ( "core.collisions" )

local enemies = {
	list = {
		-- 1 Paper
			-- For now, ALL paper guys in the map (and only them) are Chasers, and therefore will 
			-- try to follow the Player if he gets too close to their "aggro" sensor.
			-- In a future implementation this property (as the isWalker property) will be 
			-- appliable to single, select Enemies directly from the map file. 
		{
			species = "paper",
			lives = 1,
			isChaser = true,
			options = {
				filePath = visual.enemyPaper,
				width = 40,
				height = 40,
				physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
				eName = "enemy",
			},
		},
		-- 2 Chair
		{
			species = "chair",
			lives = 2,
			options = {
				filePath = visual.enemySedia,
				width = 70,
				height = 113,
				physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
				eName = "enemy",
			},
		},
	}
}

function follow(currentGame,object,player)
	--print("running")
		local currentMap = currentGame.map
		if((object.x~=nil and object.y~=nil) and(player.x~=nil and player.y~=nil) and currentGame.state ~= "Paused") then
		--il problema è che poi non richiama la transizione del disaggro
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
					
			
				local vuoto = nil
				local vuotoList = currentMap:getObjectLayer("cadutaVuoto").objects

					for k, v in pairs(vuotoList) do
						vuoto = vuotoList[k]

					end
				local direzione=math.abs(object.x-vuoto.x)
				local distanzab= math.abs(direzione)
				local distanzaverticalebordo= math.abs(object.y-vuoto.y)


				--i nemici disaggrano steve alla morte, bisogna sistemare il momento in cui lo considerano morto? sgommata se si rimane fermi...
					if(((player.state == "Dead" and currentGame.state == "Running"))) then --and (math.abs(object.x-player.x)<=100 and math.abs(object.y-player.y)<=100)) ) then

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
	]]

	local function salta(object,player)
		  if(object.y~=nil) then
				if(object.y>player.y) then
					 local distanza= (object.y-player.y)
					 if(distanza<=100) then
						  object:applyLinearImpulse( 0, -30, object.x, object.y )
					 elseif(distanza<=150 and distanza>=100) then
						  object:applyLinearImpulse( 0, -40, object.x, object.y )
					 end
					 --transition.to( object, { time=1500, y=object.y-20 } )
				end
		end
	 end
------------------------------------------------------------------------------------


-- Loads the enemies's images (and sprites) and initializes their attributes.
-- Visually instantiates the enemies in the current game's map.
-- @return enemyList (a table of Enemies)
function enemies.loadEnemies( currentGame ) 
	local currentMap = currentGame.map
	local enemyList = currentMap:getObjectLayer("enemySpawn"):getObjects("enemy")
	local player = currentGame.steve

	--elenco delle staticImage delle paper
	local paperStaticImageList={}

	-- Loads the main Entity.
	local loadenemyEntity = function( enemy )
		for i, v in ipairs(enemyList) do
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
				staticImage.type= "paper"
				staticImage.x, staticImage.y = enemyList[i].x, enemyList[i].y
								
				table.insert(paperStaticImageList , staticImage)

				function staticImage:move()
					follow(currentGame,self,player)
				end

				local listener = {}
				function listener:timer( event )
					salta(staticImage,player)
				end

				function s(object,player)
					timer.performWithDelay( 3000, listener )
				end

				timer.performWithDelay(2000,s,-1)

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

	-- for i=1,2,1 do
	-- print (paperStaticImageList[i].type)
	-- end
	
	return enemyList,paperStaticImageList

end

return enemies