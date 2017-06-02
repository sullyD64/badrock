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

	--il boss si presenta

	function presentati()

	end

	-- lanciatore spara un oggettoLanciato contro target
	function spara(lanciatore,oggettoLanciato,target)

	end

	--spara un laser in posizione x e y -- FABIO
	function sparaLaser(orientamento,posizioneX, posizioneY)

	end

	--le mani inseguono steve
	function insegui(oggetto, target)
	transition.to(oggetto,{})
	end

	function alzaSchiaccia(oggetto,target)

	end

	return boss