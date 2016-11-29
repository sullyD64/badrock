-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require ("widget")

-- -----------------------------------------------------------------------------------
-- SCENE-ACCESSIBLE CODE
-- -----------------------------------------------------------------------------------

    -- forward declarations and other locals
    local options =
    {
        frames =
        {
            {   -- frame 1 = UpperSX Corner
                x = 0, y = 0, width = 20, height = 16 },
            {   -- frame 2 = Upper Side
                x = 20, y = 0, width = 110 , height = 16 },
            {	-- frame 3 = UpperDX Corner 
            	x = 130, y = 0, width = 20, height = 16 },
        	{	-- frame 4 = Left Side 
            	x = 0, y = 16, width = 20, height = 10 },
        	{	-- frame 5 = LowerSX Corner 
            	x = 0, y = 26, width = 20, height = 20 },
        	{	-- frame 6 = Lower Side 
            	x = 20, y = 26, width = 110, height = 20 },
        	{	-- frame 7 = LowerDX Corner 
            	x = 130, y = 26, width = 20, height = 20 },
        	{	-- frame 8 = Right Side 
            	x = 130, y = 16, width = 20, height = 10 },
        	{	-- frame 9 = Center
        		x = 20, y = 16, width = 110, height = 10 },
        	{   -- frame 10 = UpperSX Corner Over
                x = 150, y = 0, width = 16 , height = 16 },
            {   -- frame 11 = Upper Side Over
                x = 166, y = 0, width = 114, height = 16 },
            {	-- frame 12 = UpperDX Corner Over
            	x = 280, y = 0, width = 20, height = 16 },
        	{	-- frame 13 = SX Side Over
            	x = 150, y = 16, width = 16, height = 10 },
        	{	-- frame 14 = LowerSX Corner Over 
            	x = 150, y = 30, width = 16 , height = 20 },
        	{	-- frame 15 = Lower Side Over
            	x = 166, y = 30, width = 114, height = 20 },
        	{	-- frame 16 = LowerDX Corner Over
            	x = 280 , y = 30, width = 20, height = 20 },
        	{	-- frame 17 = DX Side Over
            	x = 280, y = 16, width = 20, height = 10 },
        	{	-- frame 18 = Center Over
        		x = 166, y = 16, width = 114, height = 10 }
        },
        sheetContentWidth = 297,
        sheetContentHeight = 46
    }
    local buttonSheet = graphics.newImageSheet( "Button.png", options )

    local playBtn, optionBtn, scoreBtn, exitBtn


    local function onPlayBtnRelease()
    	-- go to levelSelect.lua scene
    	composer.gotoScene( "levelSelect", "fade", 500 )
    	return true
    end

    local function onScoreBtnRelease()
    	-- go to level1.lua scene
        composer.removeScene( "level1" )
    	composer.gotoScene( "level1", "fade", 500 )
    	return true
    end

    local function onExitBtnRelease()
    	-- exit the game
    	native.requestExit()  -- ONLY WORKS FOR ANDROID
    	return true
    end


-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Load the background
	local background = display.newImageRect( "MenuBackground.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	-- Load the logo
	local titleLogo = display.newImageRect( "logo.png", 343, 123 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 100

	-- Load steve
	local steveImage = display.newImageRect( "rock_original.png", 115, 113 )
	steveImage.x = display.contentCenterX
	steveImage.y = display.contentCenterY + 25
	
    -- Load the buttons
    playBtn = widget.newButton 
        {
            width = 150,
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
            label = "Play",
            labelColor = { default={0}, over={128} },
            onRelease = onPlayBtnRelease    -- event listener function
        }
        playBtn.anchorX = 0
        playBtn.anchorY = 0
        playBtn.x =  display.screenOriginX -20 
        playBtn.y = display.contentHeight - 130

    optionBtn = widget.newButton 
        {
            width = 150,
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
            label = "Options",
            labelColor = { default={0}, over={128} },
            onRelease = onPlayBtnRelease    -- event listener function  !!!!TO DO!!!!
        }

        optionBtn.anchorX = 0
        optionBtn.anchorY = 0
        optionBtn.x =  display.screenOriginX -20 
        optionBtn.y = display.contentHeight - 80

    scoreBtn = widget.newButton 
        {
            width = 150,
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
            label = "Test",
            labelColor = { default={0}, over={128} },
            onRelease = onScoreBtnRelease    -- event listener function  !!!!TO DO!!!!
        }

        scoreBtn.anchorX = 0
        scoreBtn.anchorY = 0
        scoreBtn.x =  display.contentWidth -130
        scoreBtn.y = display.contentHeight - 130

    exitBtn = widget.newButton 
        {
            width = 150,
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
            label = "Exit",
            labelColor = { default={0}, over={128} },
            onRelease = onExitBtnRelease    -- event listener function  !!!!TO DO!!!!
        }

        exitBtn.anchorX = 0
        exitBtn.anchorY = 0
        exitBtn.x =  display.contentWidth - 130
        exitBtn.y = display.contentHeight - 80

    	-- all display objects must be inserted into group
    	sceneGroup:insert( background )
    	sceneGroup:insert( titleLogo )
    	sceneGroup:insert( playBtn )
    	sceneGroup:insert( optionBtn )
    	sceneGroup:insert( scoreBtn )
    	sceneGroup:insert( exitBtn )
    	sceneGroup:insert( steveImage )
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
	
	if ( event.phase == "will" ) then
		
	elseif ( phase == "did" ) then
	
	end	
end

-- destroy()
function scene:destroy( event )
	local sceneGroup = self.view
	
	if playBtn or scoreBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
		optionBtn:removeSelf()
		scoreBtn:removeSelf()
		exitBtn:removeSelf()
		steveImage:removeSelf()
	end	
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