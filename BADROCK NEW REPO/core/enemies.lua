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
	descriptions = {
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

-- ENEMY-SPECIFIC FUNCTIONS -------------------------------------------------------
	-- (must be self-contained and not call anything outside this module)

	function follow(currentGame, object, player)
		local currentMap = currentGame.map
		if ( (object.x ~= nil and object.y ~= nil) and (player.x ~= nil and player.y ~= nil) 
			and currentGame.state ~= "Paused" ) then

			--il problema è che poi non richiama la transizione del disaggro
			--per colpa del game.paused quando steve muore
			object.isFixedRotation = true
			object.speed = 1 --quello sopra continua a essere flash

			if( math.abs(object.x-player.x) <= 400 ) then

				-- work out angle between target and missile
				local angle = math.atan2 (player.y - object.y, player.x - object.x) 
				-- update x pos in relation to angle
				object.x = object.x + ( math.cos(angle) * object.speed ) 
				
				if(player.x > object.x) then
					object.xScale = -1
				else 
					object.xScale = 1
				end
				
				-- se steve è sopra una piattaforma non lontana dal nemico allora il nemico salta, non funziona
				local vuoto = nil
				local vuotoList = currentMap:getObjectLayer("cadutaVuoto").objects

				for k, v in pairs(vuotoList) do
					vuoto = vuotoList[k]
				end

				local direzione = math.abs( object.x - vuoto.x )
				local distanzab = math.abs( direzione )
				local distanzaverticalebordo = math.abs( object.y - vuoto.y )

				--saltano continuamente a prescindere
				local salto = false
				if( distanzab <= 100 and distanzaverticalebordo <= 100 and object.lives ~= 0 ) then

					if( object.xScale == -1 and salto == false ) then
						object:applyLinearImpulse( 5, -15, object.x, object.y )
						salto = true
					elseif( object.xScale == 1 and salto == false) then
						object:applyLinearImpulse( -5, -15, object.x, object.y )
						salto = true
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

local i = 0
	local function salta(object,player)
		-- i = i + 1
		-- print("Salta " .. i)
		if (object.y ~= nil and object.x ~= nil ) then
			if (object.y > player.y and math.abs(object.x-player.x)<=150) then
				local distanza = object.y - player.y
				if (distanza <= 100) then
					object:applyLinearImpulse( 0, -30, object.x, object.y )
				 elseif (distanza <= 150 and distanza >= 100) then
					object:applyLinearImpulse( 0, -40, object.x, object.y )
				 end
					--transition.to( object, { time=1500, y=object.y-20 } )
			end
		end
	end
------------------------------------------------------------------------------------


local function loadChaser( enemy, currentGame )
	enemy.preCollision = collisions.enemyPreCollision
	enemy:addEventListener( "preCollision", enemy)

	--deadcode, indagare malfunzionamento
	enemy.towerCollision = collisions.enemyFormazioneATorre
	enemy:addEventListener( "towerCollision", enemy)

	local vuotoList = currentGame.map:getObjectLayer("cadutaVuoto").objects
	-- local player = currentGame.player

	-- chase
	function enemy:move()
		follow(currentGame, self, currentGame.steve) -- vuotolist come parametro
	end

	local listener = {}
	function listener:timer( event )
		salta( enemy, currentGame.steve )
	end

	-- jumpTimerClock
	-- function s()
	-- 	i = i + 1
	-- 	print("s is running " .. i)
	-- 	timer.performWithDelay( 3000, listener )
	-- end
	

	-- jumpTimerClock
	-----------------------------------------------------
	timer.performWithDelay(2000, listener, -1) -- [MEMORY LEAK!]
	-----------------------------------------------------
end

-- Loads the enemies's images (and sprites) and initializes their attributes.
-- Visually instantiates the enemies in the current game's map.
-- @return enemyList (a table of Enemies)
function enemies.loadEnemies( currentGame ) 
	local currentMap = currentGame.map
	local enemyList = currentMap:getObjectLayer("enemySpawn"):getObjects("enemy")

	local chaserList = {}
	local walkerList = {}

	--FABIO TEST ANIMAZIONE PAPER ------------------(Funziona, ma va smistato, ovvero ogni riga di codice al suo posto)------
		-- local paper = entity.newEntity{
		-- 		graphicType = "animated",
		-- 		filePath = visual.enemyPaperAnim,
		-- 		--width = 40,
		-- 		--height = 40,
		-- 		spriteOptions={
		-- 			height = 45,
		-- 			width = 40,
		-- 			numFrames = 9,
		-- 			sheetContentWidth = 120,
		-- 			sheetContentHeight = 135 
		-- 		},
		-- 		spriteSequence={
		-- 			{name="walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
		-- 			{name="running", start=4, count=5, time=600, loopCount=0},
		-- 			{name="dead", frames={9}, time=500, loopCount=1}
		-- 		},
		-- 		physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
		-- 		eName = "enemy"
		-- }
		-- paper.species = "paper"
		-- paper.lives = 1
		-- paper.isChaser = true

		-- paper.isFixedRotation=true
		-- paper.isTargettable= true
		-- paper.x , paper.y = 519, 357
		-- paper:addOnMap(currentMap)
		-- paper:setSequence("walking")
		-- paper:play()
			

	---------------------------------------------------------------------------------------------------------------

	-- Loads the main Entity.
	local loadEnemyEntity = function( enemy )
		local desc
		for i, v in ipairs(enemies.descriptions) do
			if (v.species == enemy.type) then
				desc = v
				break
			end
		end

		if (desc == nil ) then
			error(enemy.type .. ": Enemy species not found in the EnemyDescriptions")
		end
		
	--	local staticImage = entity.newEntity(desc.options)
		local staticImage = entity.newEntity{
				graphicType = "animated",
				filePath = visual.enemyPaperAnim,
				--width = 40,
				--height = 40,
				spriteOptions={
					height = 45,
					width = 40,
					numFrames = 9,
					sheetContentWidth = 120,
					sheetContentHeight = 135 
				},
				spriteSequence={
					{name="walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
					{name="running", start=4, count=5, time=600, loopCount=0},
					{name="dead", frames={9}, time=500, loopCount=1}
				},
				physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
				eName = "enemy"
		}
		staticImage.species = "paper"
		staticImage.lives = 1
		staticImage.isChaser = true

		staticImage.isFixedRotation=true

		--staticImage.species = desc.species
		--staticImage.lives = desc.lives or 1

		if( enemy.drop ) then
			staticImage.drop = enemy.drop
		end

		staticImage.isTargettable = true

		staticImage.posIniziale={}

		staticImage.x, staticImage.y =  enemy.x, enemy.y

		--WORK IN PROGRESS PER IL RITORNO AL RESPAWN POINT
		-- table.insert(staticImage.posIniziale,enemy.x )
		-- table.insert(staticImage.posIniziale, enemy.y )
		-- print(staticImage.posIniziale)
		staticImage:addOnMap( currentMap )
		staticImage:setSequence("walking")
		staticImage:play()
		---------------------------------------------------------------
		-- Temporary: assuming the species DOES determine the behavior,
		-- this is specified in the description list.
		if (desc.isChaser) then
			loadChaser(staticImage, currentGame)
			table.insert(chaserList, staticImage)
		end
		---------------------------------------------------------------

		return staticImage
	end

	for i, v in ipairs(enemyList) do
		enemyList[i].staticImage = loadEnemyEntity(enemyList[i])
		---------------------------------------------------------------
		-- Temporary: assuming the species DOES NOT determine the 
		--	behavior, this is specified in the enemy object in the map,
		-- so appears in enemyList as an attribute.
		-- if (enemyList[i].isChaser) then
		-- 	loadChaser(enemyList[i].staticImage, currentGame)	
		-- 	table.insert(chaserList, staticImage)
		-- end
		---------------------------------------------------------------	
	end

	return enemyList, chaserList, walkerList
end

return enemies
