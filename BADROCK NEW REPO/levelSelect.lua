local composer = require( "composer" )
local scene = composer.newScene()
 
local widget = require( "widget" )
local utility = require("utilityMenu")
local skinPanel = require ("skinMenu")
-- Require "global" data table (http://coronalabs.com/blog/2013/05/28/tutorial-goodbye-globals/)
-- This will contain relevant data like the current level, max levels etc.
local myData = require( "mydata" )




-- Button handler to cancel the level selection and return to the menu
local function handleCancelButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.gotoScene( "menu", { effect="fade", time=333 } )
    end
end

local function handleSkinsButtonEvent( event )
    if ( "ended" == event.phase ) then
        --composer.gotoScene( "menu", { effect="fade", time=333 } )
        skinPanel:show()
    end
end
 
-- Button handler to go to the selected level
local function handleLevelSelect( event )
    if ( "ended" == event.phase ) then
        -- 'event.target' is the button and '.id' is a number indicating which level to go to.  
        -- The 'game' scene will use this setting to determine which level to load.
        -- This could be done via passed parameters as well.
        myData.settings.currentLevel = event.target.id
 
        -- Purge the game scene so we have a fresh start
        composer.removeScene( "game", false )
 
        -- Go to the game scene
        composer.gotoScene( "level" .. tostring(event.target.id), { effect="crossFade", time=333 } )
    end
end
 
-- Declare the Composer event handlers
-- On scene create...
function scene:create( event )
    local sceneGroup = self.view
 
    -- Create background
    -- local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
    -- background:setFillColor( 0,44,73 )
    -- background.x = display.contentCenterX
    -- background.y = display.contentCenterY
    
    local background = display.newImageRect( "misc/LevelBG.png", display.actualContentWidth, display.actualContentHeight )
    background.anchorX = 0
    background.anchorY = 0
    background.x = 0 + display.screenOriginX 
    background.y = 0 + display.screenOriginY

    sceneGroup:insert( background )
 
    -- Use a scrollView to contain the level buttons (for support of more than one full screen).
    -- Since this will only scroll vertically, lock horizontal scrolling.
    local levelSelectGroup = widget.newScrollView({
        width = 460,
        height = 260,
        scrollWidth = 460,
        scrollHeight = 800,
        hideBackground = true,
        verticalScrollDisabled = true
    })
 
    -- 'xOffset', 'yOffset' and 'cellCount' are used to position the buttons in the grid.
    local xOffset = display.screenOriginX + 20 --64
    local yOffset = display.contentCenterY - 30
    local cellCount = 1
 
    -- Define the array to hold the buttons
    local buttons = {}
 
    -- Read 'maxLevels' from the 'myData' table. Loop over them and generating one button for each.
    for i = 1, myData.maxLevels do
        -- Create a button
        buttons[i] = widget.newButton({
            label = tostring( i ),
            id = tostring( i ),
            onEvent = handleLevelSelect,
            emboss = false,
            --shape="roundedRect",
            width = display.contentWidth - 350,
            height = display.contentHeight - 200,
            defaultFile = "misc/lvl1select.png",
            overFile= "misc/lvl1select.png",
            font = native.systemFontBold,
            fontSize = 30,
            labelColor = { default = { 1, 1, 1 }, over = { 0.5, 0.5, 0.5 } },
            --cornerRadius = 8,
            labelYOffset = 0, 
            --fillColor = { default={ 0, 0, 1, 1 }, over={ 0.5, 0.75, 1, 1 } },
            --strokeColor = { default={255,253,48,0.5}, over={0} },
            --strokeWidth = 2
        })
        -- Position the button in the grid and add it to the scrollView
        buttons[i].anchorX = 0
        buttons[i].anchorY = 0.5
        buttons[i].x = xOffset
        buttons[i].y = yOffset
        levelSelectGroup:insert( buttons[i] )
 
        -- Check to see if the player has achieved (completed) this level.
        -- The '.unlockedLevels' value tracks the maximum unlocked level.
        -- First, however, check to make sure that this value has been set.
        -- If not set (new user), this value should be 1.
 
        -- If the level is locked, disable the button and fade it out.
        if ( myData.settings.unlockedLevels == nil ) then
            myData.settings.unlockedLevels = 1
        end
        if ( i <= myData.settings.unlockedLevels ) then
            buttons[i]:setEnabled( true )
            buttons[i].alpha = 1.0
        else 
            buttons[i]:setEnabled( false ) 
            buttons[i].alpha = 0.5 
        end 
 
 
        -- Compute the position of the next button.
        -- This tutorial draws 5 buttons across.
        -- It also spaces based on the button width and height + initial offset from the left.
        xOffset = xOffset + buttons[i].width+20
        cellCount = cellCount + 1
        -- if ( cellCount > 5 ) then
        --     cellCount = 1
        --     xOffset = 64
        --     yOffset = yOffset + 45
        -- end
    end
 
    -- Place the scrollView into the scene and center it.
    sceneGroup:insert( levelSelectGroup )
    levelSelectGroup.x = display.contentCenterX
    levelSelectGroup.y = display.contentCenterY
 
    -- Create a cancel button for return to the menu scene.
    local backButton = widget.newButton({
        width = 40,
        height = 38,
        sheet = utility.buttonSheet,
        topLeftFrame = 1,
        topMiddleFrame = 2,
        topRightFrame = 3,
        middleLeftFrame = 4,
        bottomLeftFrame = 5,
        bottomMiddleFrame = 6,
        bottomRightFrame = 7,
        middleRightFrame = 8,
        middleFrame = 9,
        topLeftOverFrame = 10,
        topMiddleOverFrame = 11,
        topRightOverFrame = 12,
        middleLeftOverFrame = 13,
        middleOverFrame = 14,
        middleRightOverFrame = 15,
        bottomLeftOverFrame = 16,
        bottomMiddleOverFrame = 17,
        bottomRightOverFrame = 18,
        id = "back",
        label = "B",
        labelColor = { default={1}, over={128} },
        onEvent = handleCancelButtonEvent
    })
    backButton.x = display.contentWidth - 30
    backButton.y = display.contentHeight - 50

    local skinButton = widget.newButton({
        width = 170,
        height = 38,
        sheet = utility.buttonSheet,
        topLeftFrame = 1,
        topMiddleFrame = 2,
        topRightFrame = 3,
        middleLeftFrame = 4,
        bottomLeftFrame = 5,
        bottomMiddleFrame = 6,
        bottomRightFrame = 7,
        middleRightFrame = 8,
        middleFrame = 9,
        topLeftOverFrame = 10,
        topMiddleOverFrame = 11,
        topRightOverFrame = 12,
        middleLeftOverFrame = 13,
        middleOverFrame = 14,
        middleRightOverFrame = 15,
        bottomLeftOverFrame = 16,
        bottomMiddleOverFrame = 17,
        bottomRightOverFrame = 18,
        id = "skins",
        label = "Skins",
        labelColor = { default={1}, over={128} },
        onEvent = handleSkinsButtonEvent
    })
    skinButton.x = display.contentCenterX
    skinButton.y = display.contentHeight - 50


    sceneGroup:insert( backButton )
    sceneGroup:insert( skinButton )
end
 
-- On scene show...
function scene:show( event )
    local sceneGroup = self.view
 
    if ( event.phase == "did" ) then
    end
end
 
-- On scene hide...
function scene:hide( event )
    local sceneGroup = self.view
 
    if ( event.phase == "will" ) then
    end
end
 
-- On scene destroy...
function scene:destroy( event )
    local sceneGroup = self.view   
end
 
-- Composer scene listeners
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene