-----------------------------------------------------------------------------------------
--
-- ui.lua
--
-----------------------------------------------------------------------------------------

local ui={}

ui.uiGroup = nil
local jumpScreen, dpadLeft, dpadRight, actionBtn, pauseBtn, resumeBtn
local lifeIcons = {}

function ui.loadUi()
	ui.uiGroup = display.newGroup()
	ui.uiGroup:insert( ui.createJumpScreen() )
	ui.uiGroup:insert( ui.createDpadLeft() )
	ui.uiGroup:insert( ui.createDpadRight() )
	ui.uiGroup:insert( ui.createActionBtn() )
	ui.uiGroup:insert( ui.createPauseBtn() )
	ui.uiGroup:insert( ui.createResumeBtn() )
	ui.uiGroup:insert( ui.createScoreText() )
	ui.uiGroup:insert( ui.createPointsText() )
	--ui.uiGroup:insert( ui.createLivesText() )

	return ui.uiGroup
end

function ui.getButtonByName( name )
	for i = 1, ui.uiGroup.numChildren do
		if (ui.uiGroup[i].myName == name) then
			return ui.uiGroup[i]
		end 
	end
end


function ui.createJumpScreen()
	jumpScreen = display.newImageRect( "ui/emptyScreen.png", display.contentWidth, display.contentHeight )
	jumpScreen.x, jumpScreen.y = display.contentCenterX , display.contentCenterY
	jumpScreen.myName = "jumpScreen"

	return jumpScreen
end

function ui.createDpadLeft()
	dpadLeft = display.newImageRect( "ui/dpadLeft.png", 50, 52 )
	dpadLeft.anchorX, dpadLeft.anchorY = 0, 1
	dpadLeft.x, dpadLeft.y =  10, display.contentHeight - dpadLeft.height / 2 - 10
	dpadLeft.myName = "dpadLeft"

	return dpadLeft
end

function ui.createDpadRight()
	dpadRight = display.newImageRect( "ui/dpadRight.png", 50, 52 )
	dpadRight.anchorX, dpadRight.anchorY = 0, 1
	dpadRight.x, dpadRight.y = dpadLeft.x + dpadRight.width, dpadLeft.y
	dpadRight.myName = "dpadRight"

	return dpadRight
end

function ui.createActionBtn()
	actionBtn = display.newImageRect( "ui/actionbtn.png", 51, 51 )
	actionBtn.anchorX, actionBtn.anchorY = 1, 1
	actionBtn.x, actionBtn.y = display.contentWidth - 10, display.contentHeight -10 - actionBtn.height / 2
	actionBtn.myName = "actionBtn"
	actionBtn.active = true -- to avoid Action spam

	return actionBtn
end

function ui.createPauseBtn()
    pauseBtn = display.newImageRect( "ui/pause.png", 35, 35 )
	pauseBtn.anchorX, pauseBtn.anchorY = 1, 0
	pauseBtn.x, pauseBtn.y = display.contentWidth -10, 30
    pauseBtn.myName = "pauseBtn"

    return pauseBtn
end

function ui.createResumeBtn()
    resumeBtn = display.newImageRect( "ui/resume.png", 35, 35 )
    resumeBtn.anchorX, resumeBtn.anchorY = 1, 0
    resumeBtn.x, resumeBtn.y = display.contentWidth -10, 30
    resumeBtn.myName = "resumeBtn"
    resumeBtn.isVisible = false

    return resumeBtn
end

function ui.createScoreText()
	scoreText = display.newText( "Score: 0", 0, 0, native.systemFont, 24 )
	scoreText.anchorX, scoreText. anchorY = 1, 0
	scoreText.x, scoreText.y = display.contentWidth -55, 30
	scoreText:setFillColor( 0,0,255 )
	scoreText.myName = "scoreText"

	return scoreText
end

function ui.createPointsText()
	pointsText = display.newText( "", display.contentWidth - 80, 60, native.systemFont, 14)
	pointsText:setFillColor( 0,0,255 )
	pointsText.isVisible = false
	pointsText.myName = "pointsText"

	return pointsText
end

function ui.createLivesText()
	livesText = display.newText("Lives: ", 0, 0, native.systemFont, 24 )
	livesText.anchorX, livesText. anchorY = 0, 0
	livesText.x, livesText.y = 10, 50
	livesText:setFillColor( 255,0,0 )
	livesText.myName = "livesText"

	return livesText
end

-- Create all the images for the max lives
function ui.createLifeIcons( maxLives )
	for i = 1, maxLives do
		local	currIcon = display.newImageRect(ui.uiGroup, "ui/life.png", 30, 30 )
	    currIcon.anchorX, currIcon.anchorY = 0, 0
	    currIcon.x = 10 + (currIcon.contentWidth * (i - 1))
	    currIcon.y = 10 + currIcon.contentHeight / 2
	    currIcon.isVisible = true
	    table.insert(lifeIcons,currIcon) 
	end

	return lifeIcons
end

function ui.createBalloon()
	balloon = display.newGroup()

	local background = display.newImageRect( "sprites/balloons.png", 134, 107 )
	background.anchorY = 1

	balloon.button = display.newImageRect( "sprites/bottonefanculo.png", 58, 40 )
	balloon.button.x = background.x
	balloon.button.y = background.y -50

	balloon:insert(background)
	balloon:insert(balloon.button)

	return balloon
end

return ui