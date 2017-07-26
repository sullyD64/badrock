-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------
local composer = require ( "composer"  )
local sfx      = require ( "audio.sfx" )
local game     = require ( "core.game" )
local loader   = require ( "lib.mapLoader" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- SCENE-ACCESSIBLE CODE
-- -----------------------------------------------------------------------------------

local mapName, map
local loadingText

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

	local blackScreen = display.newRect(display.contentCenterX, display.contentCenterY, 500, 500)
	blackScreen:setFillColor( 0, 0, 0 ) 
	sceneGroup:insert(blackScreen)

	loadingText = display.newImageRect( visual.loading, 279, 58 )
	loadingText.x, loadingText.y = display.contentCenterX, display.contentCenterY
	sceneGroup:insert(loadingText)

	-- mapName = "bossTest_HD.tmx" 
	 mapName = "level2.tmx" 
	--mapName = "level1_DEF.tmx" 
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
		timer.performWithDelay(250, 
			function()
				loadingText:toFront()
				map = loader.loadMap(mapName, sceneGroup, "doNotSetBounds")
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

				game.start()

			end
		)
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