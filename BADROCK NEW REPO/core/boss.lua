-----------------------------------------------------------------------------------------
-- BOSS is a class used to store any Boss actions and methods, can create a boss with specified actions and variables

-----------------------------------------------------------------------------------------
local filters= require ("lib.filters")
--local game = require ("core.game")
local entity = require ("lib.entity")

local game = {}
local steve = {}
local gState = {}
local sState = {}



local boss = {

 descriptions = {
		--commento
		{	type = "manoDx",
			species = "manoDx",
			lives = 2,--3
			points = 0,
			options = {
			-- 	graphicType = "animated",
				filePath = visual.bossHand,
				width = 40,
				height = 65,
			 	physicsParams = { bounce = 1, friction = 1.0, density = 1.0, },
			--	sarà un sensor
				eName = "enemy"
			}
		},
		{	
			type ="manoSx",
			species = "manoSx",
			lives = 2,--3
			points= 0,
			options = {
			-- 	graphicType = "animated",
				filePath = visual.bossHand,
				width = 40,
				height = 65,
			 	physicsParams = { bounce = 1, friction = 1.0, density = 1.0, },
			--	sarà un sensor
				eName = "enemy"
			}
		},
		{	
			type ="spallaDx",
			species = "spallaDx",
			bodyType="static",
			lives = 2,
			points= 0,
			options = {
			-- 	graphicType = "animated",
				filePath = visual.bossSpalla,
				width = 50,
				height = 65,
			 	physicsParams = {  },
			--	sarà un sensor
				eName = "enemy"
			}
		},
		{	
			type ="spallaSx",
			species = "spallaSx",
			bodyType="static",
			lives = 2,
			points= 0,
			options = {
			-- 	graphicType = "animated",
				filePath = visual.bossSpalla,
				width = 50,
				height = 65,
			 	physicsParams = { },
			--	sarà un sensor
				eName = "enemy"
			}
		},
		{	
			type ="testa",
			species = "testa",
			bodyType="static",
			lives = 2,
			points= 0,
			options = {
			-- 	graphicType = "animated",
				filePath = visual.bossTesta,
				width = 80,
				height = 100,
			 	physicsParams = { },
			--	sarà un sensor
				eName = "enemy"
			}
		},{	
			type ="corpo",
			species = "corpo",
			bodyType="dynamic",
			lives = 2,
			points= 0,
			options = {
			-- 	graphicType = "animated",
				filePath = visual.bossCorpo,
				width = 200,
				height = 250,
			 	physicsParams = { isSensor = true },
				eName = "visual"
			}
		},
		
	}
		
}



	function boss.setGame ( currentGame, gameStateList, playerStateList )
		game = currentGame
		if (game) then 
			steve = currentGame.steve 
		end
		gState = gameStateList
		sState = playerStateList
	end


	--crea il boss
	function boss.loadBoss(bossName)

		local desc={options={physicsParams={}}}
		for i, v in pairs(boss.descriptions) do
			if (v.type == bossName) then
				desc = v
				break
			end
		end
			
		if (desc == nil ) then
			error( ": Boss not found in the BossDescriptions")
		end
			
		desc.options.physicsParams.filter = filters.enemyHitboxFilter
		desc.options.isFixedRotation = true
		local bossSprite = entity.newEntity(desc.options)

		bossSprite.lives = desc.lives or 1
		bossSprite.isTargettable = true
			
		local spawn = game.map:getObjectLayer("bossSpawn"):getObject("spawn00")
		bossSprite.x, bossSprite.y =  spawn.x, spawn.y

		bossSprite:addOnMap( game.map )
		bossSprite.name= desc.type
		return bossSprite
	end

	--il boss ha n vite
	function gestisciVita(n)
		local lifeBar = {}
		local lives = n
		local x=10

		for i=1,n do
			lifeBar[i] = display.newImage("nomeImmagine.png")
			lifeBar[i].x = x+10
			lifeBar[i].y = 30
			lifeBar[i].isVisible = true
		end


		--aggiorna
		if lives>0 then
		    lifeBar[lives].isVisible = false
		    lives = lives - 1
		end
	end

	-- local function textListener( event )
	 
	--     if ( event.phase == "began" ) then
	        
	 
	--     elseif ( event.phase == "ended" or event.phase == "submitted" ) then
	            
	--     end
	-- end

	--inizia un breve dialogo con il nemico, testo da mettere in un array per poterne scorrere gli elementi


	function presentati()
		-- defaultBox = native.newTextBox( display.contentCenterX, display.contentCenterY, 280, 140 )
		-- defaultBox.text = "Well.. I didn't expect you would have survived"
		local textField = native.newTextField( display.contentCenterX, display.contentCenterY, 260, 100 )
		textField:setTextColor( 0.8, 0.8, 0.8 )
		textField.size=15
		textField.text="Well.. I didn't expect you would have survived"
		--background del textbox trasparente, non supportato da emulatore su windows
		textField.hasBackground = false
		--cliccando si scorre il testo più velocemente
		--defaultBox:addEventListener( "touch", textListener )
	end


	-- lanciatore spara un objectToThrow contro target
	function boss.spara(lanciatore,target)
	
		local carota = entity.newEntity{
			filePath = visual.npcImage,
			width = 15,
			height = 40,
		 	physicsParams = { bounce = 1, friction = 1.0, density = 1.0 , filter = filters.enemyHitboxFilter},
			eName = "enemy"
		}
		carota.lives=1
		carota.isTargettable=true
		carota.points=0
		carota.isProjectile = true
		--creazione.gravityScale=0.025
		carota.x, carota.y = lanciatore.x, lanciatore.y
		
			
		carota:addOnMap(game.map)
		table.insert(lanciatore.proiettili, carota)

		if(target.x and lanciatore.x and target.y and lanciatore.y) then
			transition.moveTo(carota,{time=3000, x= target.x, y=target.y , onComplete=function()
				if(carota)then
					carota.isFixedRotation=true
					transition.to(carota,{time=0, alpha=0,onComplete=function()
					display.remove(carota)
					carota=nil end})
				end
			end})
			
		end
	end

	--spara un laser in posizione x e y -- FABIO
	function sparaLaser(generatore, strategy)

		local laser= entity.newEntity{
			graphicType="animated",
			bodyType="static",
			filePath = visual.bossLaser,
			spriteOptions={
				height = 40,
				width = 600,
				numFrames = 4,
				sheetContentWidth = 600,
				sheetContentHeight = 160 
			},
			spriteSequence= {
				{name = "laser",  frame={4}, time=2000, loopCount=1},
				{name = "ending",    frames = {4,3,2,1,2,1,2,1,2,1,2,3,4}, time=1000, loopCount=1}
			},
		 	physicsParams = { density = 1.0 , isSensor=true, filter = filters.enemyHitboxFilter},
			eName = "enemy"
		}

		if(generatore.name == "manoDx") then
		--la mano DX si occupa di fare i laser Verticali
			posizioneX = 0
			posizioneY = 0
		elseif(generatore.name == "manoSx")then
		--la mano DX si occupa di fare i laser Verticali
			posizioneX = 0
			posizioneY = 0
		end

		laser.isBodyActive = false
		laser.lives=1
		laser.fixedX = posizioneX
		laser.fixedY = posizioneY

		table.insert(generatore.lasers, laser)
		carota:addOnMap(game.map)

		laser:setSequence("laser")
		laser:play()

		local function deleteLaser(event)
			local sprite = event.target
			if(event.phase == "ended") then
				display.remove(sprite)
				table.remove(generatore.lasers, sprite)
				sprite=nil
			end
		end 

		--Dopo che il laser è stato puntato, faccio fuoco
		local t = timer.performWithDelay(2000,function() 
			transition.to(laser,{time=20, isBodyActive=true})
			laser:setSequence("fire")
			laser:play()
			laser:addEventListener("sprite",deleteLaser)

		end)
		table.insert(s.timers, t)
		

		
	end

	--le mani: 1. si alzano in volo, 2. cercano steve, 3. schiacciano; ripetono i passi 1, 2, 3


	function boss.alzaSchiaccia(oggetto,target,strategy)
		local funzioni={}

		local function removePhysicBody(oggetto)
			oggetto.isBodyActive=false
		end
		local function addPhysicBody(oggetto)
			oggetto.isBodyActive=true
		end

		local function schiaccia(targetX)
			if( oggetto and target and strategy.state == "Running" and oggetto.lives ==2) then

				local t = timer.performWithDelay(10,addPhysicBody(oggetto))
				table.insert(strategy.timers, t)
			
				transition.to(oggetto,{time=500, x=targetX, y=target.y})
				local t1 = timer.performWithDelay(3000,funzioni.alzati)
				table.insert(strategy.timers, t1)
			end
		end

		local function insegui()
			if( oggetto and target and strategy.state == "Running" and oggetto.lives ==2) then

				transition.to(oggetto,{ x = target.x ,onComplete=function()
					local x = oggetto.x
					local t = timer.performWithDelay(500,funzioni.schiaccia(x))
					table.insert(strategy.timers, t)
				end})
			end
			
		end
		local function alzati()
			if( oggetto and target  and strategy.state == "Running" and oggetto.lives ==2) then

				local t =timer.performWithDelay(10,removePhysicBody(oggetto))
				table.insert(strategy.timers, t)
				transition.to(oggetto,{time=1500, y=target.y - 150, onComplete= function() funzioni.insegui() end})
			end
		end
		

		funzioni.alzati = alzati
		funzioni.insegui = insegui
		funzioni.schiaccia = schiaccia
		funzioni.ricerca = ricerca
		alzati()
	end

	return boss