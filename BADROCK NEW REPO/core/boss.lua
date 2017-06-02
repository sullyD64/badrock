-----------------------------------------------------------------------------------------
-- BOSS is a class used to store any Boss actions and methods, can create a boss with specified actions and variables

-----------------------------------------------------------------------------------------
local enemies= require ("core.enemies")

local boss = {}
local enemies = {
	descriptions = {
		--commento
		{	
			species = "manoDx",
			lives = 2,
			bounce=1
			-- options = {
			-- 	graphicType = "animated",
			-- 	filePath = visual.enemyPaperAnim,
			-- 	spriteOptions = {
			-- 		height = 45,
			-- 		width = 40,
			-- 		numFrames = 9,
			-- 		sheetContentWidth = 120,
			-- 		sheetContentHeight = 135 
			-- 	},
			-- 	spriteSequence = {
			-- 		{name = "idle",    frames={1,2},         time=650, loopCount=0},
			-- 		{name = "walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
			-- 		{name = "running", start =4, count=5,    time=600, loopCount=0},
			-- 		{name = "dead",    frames={9},           time=500, loopCount=1}
			-- 	},
			-- 	physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
			--	sarà un sensor
			--	eName = "enemy"
			--}
			},
			{	
			species = "manoSx",
			lives = 2,
			bounce=1
			-- options = {
			-- 	graphicType = "animated",
			-- 	filePath = visual.enemyPaperAnim,
			-- 	spriteOptions = {
			-- 		height = 45,
			-- 		width = 40,
			-- 		numFrames = 9,
			-- 		sheetContentWidth = 120,
			-- 		sheetContentHeight = 135 
			-- 	},
			-- 	spriteSequence = {
			-- 		{name = "idle",    frames={1,2},         time=650, loopCount=0},
			-- 		{name = "walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
			-- 		{name = "running", start =4, count=5,    time=600, loopCount=0},
			-- 		{name = "dead",    frames={9},           time=500, loopCount=1}
			-- 	},
			-- 	physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
			--	sarà un sensor
			--	eName = "enemy"
			--}
			},
			{	
			species = "spallaDx",
			lives = 2,
			-- options = {
			-- 	graphicType = "animated",
			-- 	filePath = visual.enemyPaperAnim,
			-- 	spriteOptions = {
			-- 		height = 45,
			-- 		width = 40,
			-- 		numFrames = 9,
			-- 		sheetContentWidth = 120,
			-- 		sheetContentHeight = 135 
			-- 	},
			-- 	spriteSequence = {
			-- 		{name = "idle",    frames={1,2},         time=650, loopCount=0},
			-- 		{name = "walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
			-- 		{name = "running", start =4, count=5,    time=600, loopCount=0},
			-- 		{name = "dead",    frames={9},           time=500, loopCount=1}
			-- 	},
			-- 	physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
			--	sarà un sensor
			--	eName = "enemy"
			--}
			},
			{	
			species = "spallaSx",
			lives = 2,
			-- options = {
			-- 	graphicType = "animated",
			-- 	filePath = visual.enemyPaperAnim,
			-- 	spriteOptions = {
			-- 		height = 45,
			-- 		width = 40,
			-- 		numFrames = 9,
			-- 		sheetContentWidth = 120,
			-- 		sheetContentHeight = 135 
			-- 	},
			-- 	spriteSequence = {
			-- 		{name = "idle",    frames={1,2},         time=650, loopCount=0},
			-- 		{name = "walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
			-- 		{name = "running", start =4, count=5,    time=600, loopCount=0},
			-- 		{name = "dead",    frames={9},           time=500, loopCount=1}
			-- 	},
			-- 	physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
			--	sarà un sensor
			--	eName = "enemy"
			--}
			},
			{	
			species = "testa",
			lives = 2,
			-- options = {
			-- 	graphicType = "animated",
			-- 	filePath = visual.enemyPaperAnim,
			-- 	spriteOptions = {
			-- 		height = 45,
			-- 		width = 40,
			-- 		numFrames = 9,
			-- 		sheetContentWidth = 120,
			-- 		sheetContentHeight = 135 
			-- 	},
			-- 	spriteSequence = {
			-- 		{name = "idle",    frames={1,2},         time=650, loopCount=0},
			-- 		{name = "walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
			-- 		{name = "running", start =4, count=5,    time=600, loopCount=0},
			-- 		{name = "dead",    frames={9},           time=500, loopCount=1}
			-- 	},
			-- 	physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
			--	sarà un sensor
			--	eName = "enemy"
			--}
			}
		}
		
	}

	--crea il boss
	function boss.loadBoss(currentGame)
			local loadBossEntity = function( enemy )

			end
	return bossEntity
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
	function spara(lanciatore,objectToThrow,target)

	local function creaOggetto(creazione,lanciatore)
					creazione = entity.newEntity{
					graphicType = "static",
					filePath = visual.npcImage,
					--width = 50,
					--height = 37,
					bodyType = "dynamic",
					physicsParams = { isSensor=true },
					--eName = "creazione"
				}
				creazione.isEnemy=true
				--creazione.xScale=-1
				--creazione.yScale=-1
				--creazione.rotation=90
				--creazione.gravityScale=0.025
				creazione.x, creazione.y = lanciatore.x, lanciatore.y
				creazione.isBreakable= true
				return creazione
	end
	if(target.x and lanciatore.x and target.y and lanciatore.y) then
	local fx= target.x-lanciatore.x
	local fy= target.y-lanciatore.y
	local d=100
	local den= 80*d
	creazione= creaOggetto(objectToThrow,lanciatore)
	creazione.x= creazione.x-100
	creazione:applyLinearImpulse(fx/den,fy/den,creazione.x,creazione.y)
	-- if (creazione.y== target.y) then print("fireball e target stessa x") creazione.isSensor=false creazione.bounce=1 else print("no fireball") print(target.y) end
	-- end
	end

	--spara un laser in posizione x e y -- FABIO
	function sparaLaser(orientamento,posizioneX, posizioneY)

	end

	--le mani: 1. si alzano in volo, 2. cercano steve, 3. schiacciano; ripetono i passi 1, 2, 3


	function boss.alzaSchiaccia(oggetto,target)

		local function alzati()
		transition.to(oggetto,{time=1500, y=oggetto.y + 100, onComplete= function() insegui() end})
		end

		function ricerca()
			oggetto.x=game.steve.x
		end
		local function insegui()
		Runtime:addEventlListener("enterframe",ricerca)
		timer.performWithDelay(5000,schiaccia)
		end

		local function schiaccia()
		Runtime:removeEventListener("enterframe", ricerca)
		transition.to(oggetto,{time=500, y=target.y)
		timer.performWithDelay(2000,alzati)
		end
		alzati()
	end

	return boss