-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------
local composer = require ( "composer"  )
local tutorial = require ( "tutorial"  )
local sfx      = require ( "audio.sfx" )
local game     = require ( "core.game" )
lime           = require ( "lime.lime" )
lime.disableScreenCulling()

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- SCENE-ACCESSIBLE CODE
-- -----------------------------------------------------------------------------------

local map, visual, physical

local function startTutorial()
	game.state = "Paused"
	tutorial.start()
end

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	if myData.settings.musicOn == false then
		audio.play(sfx.bgLvlMusic, {channel = 1 , loops=-1})
		-- sfx.playMusic(sfx.bgLvlMusic, {channel = 1, loops = -1}) ?
		audio.pause(1)
	end

	-- map = lime.loadMap("bossTest_HD.tmx")
	-- map = lime.loadMap("mapTest_HD.tmx")
	map = lime.loadMap("level1_DEF.tmx")
	print(os.clock() .. " \t| loaded map" )
	visual = lime.createVisual(map)
	print(os.clock() .. " \t| loaded visual")
	sceneGroup:insert( visual )

	util.prepareMap(map)
	physical = lime.buildPhysical(map)
	print(os.clock() .. " \t| built physical")

	-- La mappa caricata deve SEMPRE avere un layer di OGGETTI chiamato
	-- checkPoints contenente ALMENO un oggetto "check0" (primo checkPoint)
	game.loadGame( map, map:getObjectLayer("checkPoints"):getObject("check0"))

	--------------------------------------------------------------------------------
	-- Commento: in fase di produzione (skippo il mainMenu) può capitare che, se
	-- completiamo il livello e lo rigiochiamo, il currentLevel sarà aggiornato al 
	-- livello 2. Quando andrò a fare retry da livello 1, il gioco proverà a caricare
	-- level2 invece che ricaricare level1.
	-- Qui sotto forzo myData a level1, andrà tolto prima del deploy dell'app.
	-- if (myData.settings.currentLevel ~= 1) then myData.settings.currentLevel = 1 end
	--------------------------------------------------------------------------------

	if (myData.firstStart) then
		tutorial.create(game)
	end
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if (phase == "will") then
		sfx.playMusic(sfx.bgLvlMusic, {channel = 1 , loops=-1})
		-- A second audio source is started too but with no volume.
		-- (needed for syncing the two when we want to swap them)
		sfx.playMusic(sfx.bgLvlMusicUP, {channel = 8, loops=-1})
	elseif (phase == "did") then
		game.start()
		if myData.firstStart then
			timer.performWithDelay(400, startTutorial)
		end
	end

end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if (phase == "will") then
		audio.fadeOut(1,10)
	elseif (phase == "did") then
	end
end

-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view
	audio.dispose()
	package.loaded[game] = nil
end

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTION LISTENERS
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
--------------------------------------------------------------------------------------

return scene