local composer = require( "composer" )
local scene = composer.newScene()
 
local widget = require( "widget" )
 
-- Require "global" data table (http://coronalabs.com/blog/2013/05/28/tutorial-goodbye-globals/)
-- This will contain relevant data like the current level, max levels etc.
local myData = require( "mydata" )

local options =
{
    frames =
    {
        {   -- frame 1 = UpperSX Corner
            x = 0, y = 0, width = 20, height = 16 },
        {   -- frame 2 = Upper Side
            x = 20, y = 0, width = 110 , height = 16 },
        {   -- frame 3 = UpperDX Corner 
            x = 130, y = 0, width = 20, height = 16 },
        {   -- frame 4 = Left Side 
            x = 0, y = 16, width = 20, height = 10 },
        {   -- frame 5 = LowerSX Corner 
            x = 0, y = 26, width = 20, height = 20 },
        {   -- frame 6 = Lower Side 
            x = 20, y = 26, width = 110, height = 20 },
        {   -- frame 7 = LowerDX Corner 
            x = 130, y = 26, width = 20, height = 20 },
        {   -- frame 8 = Right Side 
            x = 130, y = 16, width = 20, height = 10 },
        {   -- frame 9 = Center
            x = 20, y = 16, width = 110, height = 10 },
        {   -- frame 10 = UpperSX Corner Over
            x = 150, y = 0, width = 16 , height = 16 },
        {   -- frame 11 = Upper Side Over
            x = 166, y = 0, width = 114, height = 16 },
        {   -- frame 12 = UpperDX Corner Over
            x = 280, y = 0, width = 20, height = 16 },
        {   -- frame 13 = SX Side Over
            x = 150, y = 16, width = 16, height = 10 },
        {   -- frame 14 = LowerSX Corner Over 
            x = 150, y = 30, width = 16 , height = 20 },
        {   -- frame 15 = Lower Side Over
            x = 166, y = 30, width = 114, height = 20 },
        {   -- frame 16 = LowerDX Corner Over
            x = 280 , y = 30, width = 20, height = 20 },
        {   -- frame 17 = DX Side Over
            x = 280, y = 16, width = 20, height = 10 },
        {   -- frame 18 = Center Over
            x = 166, y = 16, width = 114, height = 10 }
    },
    sheetContentWidth = 297,
    sheetContentHeight = 46

}
local buttonSheet = graphics.newImageSheet( "Button.png", options )



-- Button handler to cancel the level selection and return to the menu
local function handleCancelButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.gotoScene( "menu", { effect="crossFade", time=333 } )
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
        composer.gotoScene( "game", { effect="crossFade", time=333 } )
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
    
    local background = display.newImageRect( "LevelBG.png", display.actualContentWidth, display.actualContentHeight )
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
            shape="roundedRect",
            width = display.contentWidth - 350,
            height = display.contentHeight - 200,
            font = native.systemFontBold,
            fontSize = 18,
            labelColor = { default = { 1, 1, 1 }, over = { 0.5, 0.5, 0.5 } },
            cornerRadius = 8,
            labelYOffset = -6, 
            fillColor = { default={ 0, 0, 1, 1 }, over={ 0.5, 0.75, 1, 1 } },
            strokeColor = { default={255,253,48,0.5}, over={0} },
            strokeWidth = 2
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
        width = 90,
        height = 38,
        sheet = buttonSheet,
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
        bottomLeftOverFrame = 14,
        bottomMiddleOverFrame = 15,
        bottomRightOverFrame = 16,
        middleRightOverFrame = 17,
        middleOverFrame = 18,
        id = "button1",
        label = "Back",
        onEvent = handleCancelButtonEvent
    })
    backButton.x = display.contentCenterX
    backButton.y = display.contentHeight - 60
    sceneGroup:insert( backButton )
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