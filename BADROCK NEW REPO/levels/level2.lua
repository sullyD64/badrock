-----------------------------------------------------------------------------------------
--
-- level2.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

lime = require("lime.lime")
local game = require ( "game" )


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

	map = lime.loadMap("map_level2.tmx")
	visual = lime.createVisual(map)
	sceneGroup:insert( visual )

	physical = lime.buildPhysical(map)

	-- ATTENZIONE --
	-- La mappa caricata deve SEMPRE avere un layer di oggetti chiamato
	-- playerSpawn contenente un oggetto "spawn0" (primo checkpoint)
	-- e due layer di TILE playerObject e playerEffects
	local layer = map:getObjectLayer("playerSpawn")
	local spawn = layer:getObject("spawn0")
	game.create( spawn )
	mainGroup = display.newGroup()
	local steve = game.steve
	mainGroup:insert( steve )
	sceneGroup:insert( mainGroup )

	map:getTileLayer("playerObject"):addObject( steve )
	map:setFocus( steve )

end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if 	   ( phase == "will" ) then
		
	elseif ( phase == "did" )  then
		game.start(map)
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if 	   ( phase == "will" ) then
	
	elseif ( phase == "did" )  then
		game.stop()
	end		
end

-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view

	package.loaded[game] = nil
end

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTION LISTENERS
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene