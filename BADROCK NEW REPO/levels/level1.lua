-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require ( "composer"  )
local myData   = require ( "myData"    )
local sfx      = require ( "audio.sfx" )
local game     = require ( "core.game" )
lime           = require ( "lime.lime" )
lime.enableScreenCulling()

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- SCENE-ACCESSIBLE CODE
-- -----------------------------------------------------------------------------------

local map, visual, physical

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	if myData.settings.musicOn == false then
		audio.play(sfx.bgLvlMusic, {channel = 1 , loops=-1})
		audio.pause(1)
	end

	--map = lime.loadMap("ultimate_map.tmx")
	map = lime.loadMap("testmap_new.tmx")
	visual = lime.createVisual(map)
	sceneGroup:insert( visual )

	util.prepareMap(map)
	physical = lime.buildPhysical(map)

	-- La mappa caricata deve SEMPRE avere un layer di OGGETTI chiamato
	-- playerSpawn contenente un oggetto "spawn0" (primo checkpoint)
	-- e due Tile Layer -vuoti-  playerObject e playerEffects.
	game.loadGame( map, map:getObjectLayer("playerSpawn"):getObject("spawn0") )
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if (phase == "will") then
		sfx.playMusic(sfx.bgLvlMusic, {channel = 1 , loops=-1})
	elseif (phase == "did") then
		game.start()	
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