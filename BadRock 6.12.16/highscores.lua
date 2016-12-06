-----------------------------------------------------------------------------------------
--
-- highscores.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- SCENE-ACCESSIBLE CODE
-- -----------------------------------------------------------------------------------

-- forward declarations and other locals
    local json = require( "json" )
    local scoresTable = {}
    local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )


local function loadScores()

    local file = io.open( filePath, "r" )

    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
    end

    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end
end

local function saveScores()

    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end

    local file = io.open( filePath, "w" )

    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

local function gotoMenu(event)
	if (event.phase == "ended") then 
    	composer.gotoScene( "menu", { time=1500, effect="crossFade" } )
    end
end

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Load the previous scores
    loadScores()

    -- Insert the saved score from the last game into the table, then reset it
    table.insert( scoresTable, composer.getVariable( "finalScore" ) )
    composer.setVariable( "finalScore", 0 )

    -- Sort the table entries from highest to lowest
    local function compare( a, b )
        return a > b
    end
    table.sort( scoresTable, compare )

    -- Save the scores
    saveScores()

    local background = display.newImageRect( sceneGroup, "misc/background.png", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX-20, 60, native.systemFontBold, 22 )
    highScoresHeader:setFillColor(0,0,255)
    for i = 1, 10 do
        if ( scoresTable[i] ) then
            local yPos = 70 + ( i * 26 )

            local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.systemFont, 16 )
            rankNum:setFillColor( 0.8 )
            rankNum.anchorX = 1

            local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 16 )
            thisScore.anchorX = 0
        end
    end

    local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX+150, 250, native.systemFont, 44 )
    menuButton:setFillColor( 0.75, 0.78, 1 )
    menuButton:addEventListener( "touch", gotoMenu )
end

-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
       
    end
end


-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        
    elseif ( phase == "did" ) then
        
    end
end


-- destroy()
function scene:destroy( event )
    local sceneGroup = self.view
    
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
