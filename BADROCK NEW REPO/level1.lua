-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

lime = require("lime.lime")
lime.disableScreenCulling() 
local game = require ( "game" )


-- -----------------------------------------------------------------------------------
-- SCENE-ACCESSIBLE CODE
-- -----------------------------------------------------------------------------------

local mappa, visual, physical

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	mappa = lime.loadMap("testmap_new.tmx")
	--map = lime.loadMap("longMapTest.tmx")
	visual = lime.createVisual(mappa)
	sceneGroup:insert( visual )

	physical = lime.buildPhysical(mappa)

	--[[	-- ATTENZIONE -- 
	La mappa caricata deve SEMPRE avere un layer di OGGETTI chiamato
	playerSpawn contenente un oggetto "spawn0" (primo checkpoint)
	e due layer di TILE playerObject e playerEffects


	/////////////////DA RICONTROLLARE////////////////////////////
	]]
	local layer = mappa:getObjectLayer("playerSpawn")	
	local spawn = layer:getObject("spawn0")
	game.loadGame( mappa, spawn )
	--game.level = map
	mainGroup = display.newGroup()
	local steve = game.steve

	mainGroup:insert( steve )
	sceneGroup:insert( mainGroup )

	mappa:getTileLayer("playerObject"):addObject( steve )
	mappa:setFocus( steve )

	sceneGroup:insert( game.ui )

-- --GIGGI PATHFIND
-- --let’s do some basic setup by declaring local variables and drawing a background to the screen
-- local Grid = require ("jumper.jumper.grid")
-- local Pathfinder = require ("jumper.jumper.pathfinder")

-- local map = {}       -- table representing each grid position 
-- local walkable = 0   -- used by Jumper to mark obstacles
-- local startx = 0     -- start x grid coordinate
-- local starty = 0     -- start y grid coordinate
-- local endx = 0       -- end x grid coordinate
-- local endy = 0       -- end y grid coordinate 

-- -- draw a background
-- local bg = display.newRect( display.screenOriginX,
--                             display.screenOriginY, 
--                             display.actualContentWidth, 
--                             display.actualContentHeight)
 
-- bg.x = display.contentCenterX
-- bg.y = display.contentCenterY
-- bg:setFillColor( 000/255, 168/255, 254/255 )
-- bg:toBack() --questo l'ho messo io quando ho visto lo schermo azzuro per spostare il rettangolo dietro

-- --[[And now that all the basics are set up, we’ll draw a grid, make a map, and set our start and end positions with the following function:
-- This function is responsible for a few things. First, it draws a square grid made up of 100 tiles with each tile being 48 pixels wide.

-- You’ll see that some tiles have gridRow[col] set to either a 1 or a 0, and that is how we create obstacles, or un-walkable tiles for the Jumper library.
-- When we declared local variables, walkable was set to 0, which means any value other than 0 makes a tile un-walkable.

-- Secondly, the function populates the local map {} table with those 1 and 0 values. When the function is finished running, the map table will contain 10
-- nested tables, with each nested table consisting of 10 values. The map is a direct representation of the grid drawn to the screen and this table is what
-- Jumper needs in order to know how many rows and columns make up the grid and which positions are walkable or un-walkable. For example, if you were to
-- print out the contents of map[4], you’d see a table like {0,0,1,1,1,1,1,1,0,0}.]]
-- function drawGrid()
--    for row = 1, 10 do
--       local gridRow = {}
--       for col = 1, 10 do
--          -- draw a tile
--          local tile = display.newRect((col * 50) - 25, (row * 50) - 25, 48, 48)
         
--          -- make some tiles un-walkable
--          if ((row == 4 or row == 6) and (col >2 and col < 9))  then
--             tile.alpha = 1
--             gridRow[col] = 1    
--          else
--             tile.alpha = .5
--             gridRow[col] = 0
--          end
         
--          -- set the tile's pixel coordinates
--          tile.xyPixelCoordinate = {x=tile.x, y=tile.y}
--          -- set the tile's grid coordinates
--          tile.xyGridCoordinate = {x=col, y=row}
        

--          -- draw the start position
--          if(row  == 3 and col == 4) then 
--          	drawStart(tile.xyPixelCoordinate, tile.xyGridCoordinate)
--          end

--          -- draw the end position
--          if(row  == 5 and col == 6) then 
--          	drawEnd(tile.xyPixelCoordinate, tile.xyGridCoordinate)
--          end
         
--       end
--       -- add gridRow table to the map table
--       map[row] = gridRow
--    end
-- end

-- --Finally, the function calls the drawStart and drawEnd functions, which look like:
-- -- draw start position by using the pixel coordinates
-- -- set the startx and starty grid coordinates
-- function drawStart(xyPixelCoordinate, xyGridCoordinate)
--    local myText = display.newText( "A", xyPixelCoordinate.x, xyPixelCoordinate.y, native.systemFont, 34 )
--    myText:setFillColor( 255, 255, 255 )
--    startx = xyGridCoordinate.x
--    starty = xyGridCoordinate.y
-- end

-- -- draw end position by using the pixel coordinates
-- -- set the endx and endy grid coordinates
-- function drawEnd(xyPixelCoordinate, xyGridCoordinate)
--    local myText = display.newText( "B", xyPixelCoordinate.x, xyPixelCoordinate.y, native.systemFont, 34 )
--    myText:setFillColor(255, 255, 255 )
--    endx = xyGridCoordinate.x
--    endy = xyGridCoordinate.y
-- end

-- --[[These two functions draw the A and B values on the screen, but they also set the start and end grid coordinates, which the Jumper library will need in order to create a path.

-- So now that we have our grid, obstacles, and start/end positions, we can figure out the correct path by running the getPath function.]]

-- -- find the path from point A to point B
-- function getPath()
--    -- create a Jumper Grid object by passing in our map table
--    local grid = Grid(map)

--    -- Creates a pathfinder object using Jump Point Search
--    local pather = Pathfinder(grid, 'JPS', walkable)
--    pather:setMode("ORTHOGONAL") 
   
--    -- Calculates the path, and its length
--    local path = pather:getPath(startx,starty, endx,endy)

--    if path then
--     for node, count in path:nodes() do
--       print(('Step: %d - x: %d - y: %d'):format(count, node.x, node.y))
--     end
--  end
-- end
-- drawGrid()
-- getPath()

--[[DA CONTROLLARE
Making Tiled Use Easier – Utility Function
0

I finally got tired of manually making walkable maps from Tiled files and created a quick little function that does it for me.

Create your walkable are in Tiled and make sure it’s the first layer (the one at the bottom of the Layer list in Tiled). Export your level as Lua and then use that file as seen here:

local level01 = require("level01") -- load the exported Tiled level

--=======================================================================
-- pass in the table that holds the level info from: local level01 = require("level01")
-- get back a table that can be used as a map for Pathfinder
--=======================================================================
local function walkableMapFromTMX(lvl)
	local t = {}
	local idx = 1
	for h = 1, lvl.layers[1].height do
		t[h] = {}
		for w = 1, lvl.layers[1].width do
			t[h][w] = lvl.layers[1].data[idx]
			idx = idx + 1
		end
	end
	return t
end

map = walkableMapFromTMX(level01)

You’ll end up with the map variable holding the walkable map that Jumper needs.

This makes tweaking walk maps so much easier.

It would be pretty easy to grab the data based on layer name instead of hardcoding the first layer. That way you could name the layer something like “Walkable” inside Tiled and grab that no matter whether it’s the first, last, or middle layer.]]

	--////////////////////////////////////////////////////////////
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if 	   ( phase == "will" ) then
		
	elseif ( phase == "did" )  then
		game.start()
		
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if 	   ( phase == "will" ) then
	
	elseif ( phase == "did" )  then
		--game.pause()
	end		
end

-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view

	--game.stop()
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