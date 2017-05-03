-----------------------------------------------------------------------------------------
--
-- ui.lua
--
-----------------------------------------------------------------------------------------

local ui={}

ui.uiGroup = nil
ui.jumpScreen = nil
ui.dpadLeft = nil
ui.dpadRight = nil
ui.actionbtn = nil
ui.pauseBtn = nil
ui.resumeBtn = nil
ui.scoreText = nil
ui.pointsText = nil
ui.lifeIcons = {}

-- this is STILL used by pauseMenu
function ui.getButtonByName( name )
	for i = 1, ui.uiGroup.numChildren do
		if (ui.uiGroup[i].myName == name) then
			return ui.uiGroup[i]
		end 
	end
end

local function createJumpScreen()
		-- Se va nello uiGroup
	-- jumpScreen = display.newImageRect( "ui/emptyScreen.png", display.contentWidth, display.contentHeight )
	-- jumpScreen.x, jumpScreen.y = display.contentCenterX , display.contentCenterY
		-- Come sopra ma migliore (non usa immagini)
	-- jumpScreen = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
		-- Se create viene chiamata esternamente
	ui.jumpScreen = display.newRect( display.contentCenterX, display.contentCenterY, 10000,10000)
	ui.jumpScreen.myName = "jumpScreen"
	ui.jumpScreen.isVisible = false
	ui.jumpScreen.isHitTestable = true
	ui.jumpScreen:setFillColor( 0, 255, 0 )
end

local function createDpadLeft()
	ui.dpadLeft = display.newImageRect( visual.dpadLeft, 50, 52 )
	ui.dpadLeft.anchorX, ui.dpadLeft.anchorY = 0, 1
	ui.dpadLeft.x, ui.dpadLeft.y =  10, display.contentHeight - ui.dpadLeft.height / 2 - 10
	ui.dpadLeft.myName = "dpadLeft"
end

local function createDpadRight()
	ui.dpadRight = display.newImageRect( visual.dpadRight, 50, 52 )
	ui.dpadRight.anchorX, ui.dpadRight.anchorY = 0, 1
	ui.dpadRight.x, ui.dpadRight.y = ui.dpadLeft.x + ui.dpadRight.width, ui.dpadLeft.y
	ui.dpadRight.myName = "dpadRight"
end

local function createActionBtn()
	ui.actionBtn = display.newImageRect( visual.actionBtn, 51, 51 )
	ui.actionBtn.anchorX, ui.actionBtn.anchorY = 1, 1
	ui.actionBtn.x, ui.actionBtn.y = display.contentWidth - 10, display.contentHeight -10 - ui.actionBtn.height / 2
	ui.actionBtn.myName = "actionBtn"
	ui.actionBtn.active = true -- to avoid Action spam
end

local function createPauseBtn()
	ui.pauseBtn = display.newImageRect( visual.pauseButton, 35, 35 )
	ui.pauseBtn.anchorX, ui.pauseBtn.anchorY = 1, 0
	ui.pauseBtn.x, ui.pauseBtn.y = display.contentWidth -10, 30
	ui.pauseBtn.myName = "pauseBtn"
end

local function createResumeBtn()
	ui.resumeBtn = display.newImageRect( visual.resumeButton, 35, 35 )
	ui.resumeBtn.anchorX, ui.resumeBtn.anchorY = 1, 0
	ui.resumeBtn.x, ui.resumeBtn.y = display.contentWidth -10, 30
	ui.resumeBtn.myName = "resumeBtn"
	ui.resumeBtn.isVisible = false
end

local function createScoreText()
	ui.scoreText = display.newText( "Score: 0", 0, 0, native.systemFont, 24 )
	ui.scoreText.anchorX, ui.scoreText. anchorY = 1, 0
	ui.scoreText.x, ui.scoreText.y = display.contentWidth -55, 30
	ui.scoreText:setFillColor( 0,0,255 )
	ui.scoreText.myName = "scoreText"
end

local function createPointsText()
	ui.pointsText = display.newText( "", display.contentWidth - 80, 60, native.systemFont, 14)
	ui.pointsText:setFillColor( 0,0,255 )
	ui.pointsText.isVisible = false
	ui.pointsText.myName = "pointsText"
end

local function createLivesText()
	ui.livesText = display.newText("Lives: ", 0, 0, native.systemFont, 24 )
	ui.livesText.anchorX, ui.livesText. anchorY = 0, 0
	ui.livesText.x, livesText.y = 10, 50
	ui.livesText:setFillColor( 255,0,0 )
	ui.livesText.myName = "livesText"
end

-- Create all the images for the max lives
local function createLifeIcons( maxLives )
	for i = 1, maxLives do
		local	currIcon = display.newImageRect(ui.uiGroup, visual.lifeIcon, 30, 30 )
	    currIcon.anchorX, currIcon.anchorY = 0, 0
	    currIcon.x = 10 + (currIcon.contentWidth * (i - 1))
	    currIcon.y = 10 + currIcon.contentHeight / 2
	    currIcon.isVisible = true
	    table.insert(ui.lifeIcons,currIcon) 
	end
end

function ui.loadUi(game)
	ui.uiGroup = display.newGroup()
	-- --ui.uiGroup:insert( ui.createJumpScreen() )
	-- --ui.uiGroup:insert( ui.createLivesText() )
	createDpadLeft()
	createDpadRight()
	createActionBtn()
	createPauseBtn()
	createResumeBtn()
	createScoreText()
	createPointsText()
	createJumpScreen()
	createLifeIcons(game.lives)

	ui.uiGroup:insert( ui.dpadLeft )
	ui.uiGroup:insert( ui.dpadRight )
	ui.uiGroup:insert( ui.actionBtn )
	ui.uiGroup:insert( ui.pauseBtn )
	ui.uiGroup:insert( ui.resumeBtn )
	ui.uiGroup:insert( ui.scoreText )
	ui.uiGroup:insert( ui.pointsText )
	ui.uiGroup:insert( ui.jumpScreen )
	--ui.uiGroup:insert( ui.lifeIcons )

	return ui.uiGroup
end

--Update Life Icons: Works if we Lose or if we Get Lives
function ui.updateLifeIcons(lives)
	for i=1, #ui.lifeIcons do
		if( i <= lives) then
			ui.lifeIcons[i].isVisible = true
		else
			ui.lifeIcons[i].isVisible = false
		end
	end
end

return ui