-----------------------------------------------------------------------------------------
--
-- newUi.lua
--
-- Here are declared all the visual aspects regarding the game's UI buttons.
-- This module is tied to the controller which is the only class that uses it, while
-- additional functions provide easy shortcuts for toggling the enablement for the whole ui.
-----------------------------------------------------------------------------------------
local widget = require ( "widget" )

local ui = {
	buttons = {},
	buttonGroup = {}
}

-- Stores the data tables for the -widget.newButton- calls.
local buttonData = {
	-- Touchable area (invisible button)
		--1
		jumpScreen = {
			options = {
				id = "jumpScreen",
				width = 10000,
				height = 10000,
			},
		},

	-- Touchable buttons
		--2
		dpadLeft = {
			options = {
				id = "dpadLeft",
				defaultFile = visual.dpadLeft,
				overFile = visual.dpadLeft_over,
				width = 50,
				height = 52,
				x = 10,
				y = display.contentHeight - 52 / 2 - 10,
			},
			aX = 0,
			aY = 1,
		},
		--3
		dpadRight = {
			options = {
				id = "dpadRight",
				defaultFile = visual.dpadRight,
				overFile = visual.dpadRight_over,
				width = 50,
				height = 52,
				x = 60,	-- (dpadLeft.x + dpadRight.width)
				y = display.contentHeight - 52 / 2 - 10,
			},
			aX = 0,
			aY = 1,
		},
		--4
		actionBtn = {
			options = {
				id = "actionBtn",
				defaultFile = visual.actionBtn,
				overFile = visual.actionBtn_over,
				width = 51,
				height = 51,
				x = display.contentWidth - 10,
				y = display.contentHeight - 10 - 51 / 2, --REWORK ME!
			},
			aX = 1,
			aY = 1,
		},
		--5
		pauseBtn = {
			options = {
				id = "pauseBtn",
				defaultFile = visual.pauseBtn,
				width = 35,
				height = 35,
				x = display.contentWidth - 10,
				y = 30,
			},
			aX = 1,
			aY = 0,
		},
		--6
		resumeBtn = {
			options = {
				id = "resumeBtn",
				defaultFile = visual.resumeBtn,
				width = 35,
				height = 35,
				x = display.contentWidth - 10,
				y = 30,
			},
			aX = 1,
			aY = 0,
		},

	-- Untouchable text-only buttons
		--7
	 	scoreText = {
			options = {
				id = "scoreText",
				textOnly = true,
				label = "Score: 0",
				font = "micolas.ttf",
				fontSize = 20,
				labelColor = {
					default = { 0,220,255 },
					over = { 0,220,255 },
				},
				x = display.contentWidth - 55,
				y = 30,
			},
			aX = 1,
			aY = 0,
		},
		--8
		scoreUpText = {
			options = {
				id = "scoreUpText",
				textOnly = true,
				label = "",
				font = "micolas.ttf",
				fontSize = 14,
				labelColor = {
					default = { 0,210,255 },
					over = { 0,210,255 },
				},
				x = display.contentWidth - 80,
				y = 60,
			},
			aX = 0.5,
			aY = 0.5,
		},
		--9
		livesText = {
			options = {
				id = "livesText",
				textOnly = true,
				label = "",
				font = "micolas.ttf",
				fontSize = 14,
				labelColor = {
					default = { 255,210,0 },
					over = { 255,210,0 },
				},
				x = display.contentWidth - 80,
				y = 60,
			},
			aX = 0,
			aY = 0,
		},
		--10
		lifeUpText = {
			options = {
				id = "lifeUpText",
				textOnly = true,
				label = "",
				font = "micolas.ttf",
				fontSize = 20,
				labelColor = {
					default = { 0,210,255 },
					over = { 0,210,255 },
				},
				x = 80,
				y = 60,
			},
			aX = 0.5,
			aY = 0.5,
		},
}


---------------------------------------------------------------------------------
-- [This section will be likely modified in the future, we will decide next meet 
-- if it's worth keeping an icon for every life or a simpler single-icon counter].
	ui.lifeIcons = {}

	-- Updates the lifeIcon array, either if a life is added or removed
	function ui.updateLifeIcons( currentLivesNumber )
		for i = 1, #ui.lifeIcons do
			if( i <= currentLivesNumber ) then
				ui.lifeIcons[i].isVisible = true
			else
				ui.lifeIcons[i].isVisible = false
			end
		end
	end

	-- Creates the lifeIcon array initialized to the current game's max lives allowed.
	function ui.createLifeIcons( maxLivesNumber )
		for i = 1, maxLivesNumber do
			local	lifeIcon = display.newImageRect(ui.buttonGroup, visual.lifeIcon, 30, 30 )
		    lifeIcon.anchorX, lifeIcon.anchorY = 0, 0
		    lifeIcon.x = 10 + (lifeIcon.contentWidth * (i - 1))
		    lifeIcon.y = 10 + lifeIcon.contentHeight / 2
		    lifeIcon.isVisible = true
		    table.insert(ui.lifeIcons,lifeIcon) 
		end
	end

	-- Empties the lifeIcon array
	function ui.emptyLifeIcons()
		--print("Before: ".. #ui.lifeIcons)
		for i in pairs (ui.lifeIcons) do
			ui.lifeIcons[i] = nil
		end
		--print("After: ".. #ui.lifeIcons)
	end
---------------------------------------------------------------------------------

-- Contains all the calls to -widget.newButton- and adds selected buttons to the UI Group.
local function createButtons()
	local buttonGroup = display.newGroup()

	local jumpScreen = widget.newButton ( buttonData.jumpScreen.options  )
		jumpScreen:setFillColor( 0, 255, 0 )
		jumpScreen.isVisible = false
		jumpScreen.isHitTestable = true
		-- buttonGroup:insert( jumpScreen )		-- NO!

	local dpadLeft    = widget.newButton ( buttonData.dpadLeft.options    )
		dpadLeft.anchorX, dpadLeft.anchorY = buttonData.dpadLeft.aX, buttonData.dpadLeft.aY
		buttonGroup:insert( dpadLeft )

	local dpadRight   = widget.newButton ( buttonData.dpadRight.options   )
		dpadRight.anchorX, dpadRight.anchorY = buttonData.dpadRight.aX, buttonData.dpadRight.aY
		buttonGroup:insert( dpadRight )

	local actionBtn   = widget.newButton ( buttonData.actionBtn.options   )
		actionBtn.anchorX, actionBtn.anchorY = buttonData.actionBtn.aX, buttonData.actionBtn.aY
		buttonGroup:insert( actionBtn )

	local pauseBtn    = widget.newButton ( buttonData.pauseBtn.options    )
		pauseBtn.anchorX, pauseBtn.anchorY = buttonData.pauseBtn.aX, buttonData.pauseBtn.aY
		buttonGroup:insert( pauseBtn )

	local resumeBtn   = widget.newButton ( buttonData.resumeBtn.options   )
		resumeBtn.anchorX, resumeBtn.anchorY = buttonData.resumeBtn.aX, buttonData.resumeBtn.aY
		buttonGroup:insert( resumeBtn )

	local scoreText   = widget.newButton ( buttonData.scoreText.options   )
		scoreText.anchorX, scoreText.anchorY = buttonData.scoreText.aX, buttonData.scoreText.aY
		buttonGroup:insert( scoreText )

	local scoreUpText = widget.newButton ( buttonData.scoreUpText.options )
		scoreUpText.anchorX, scoreUpText.anchorY = buttonData.scoreUpText.aX, buttonData.scoreUpText.aY
		buttonGroup:insert( scoreUpText )

	local livesText   = widget.newButton ( buttonData.livesText.options   )
		livesText.anchorX, livesText.anchorY = buttonData.livesText.aX, buttonData.livesText.aY
		buttonGroup:insert( livesText )

	local lifeUpText = widget.newButton ( buttonData.lifeUpText.options )
		lifeUpText.anchorX, lifeUpText.anchorY = buttonData.lifeUpText.aX, buttonData.lifeUpText.aY
		buttonGroup:insert( lifeUpText )

	local buttons = {
		jump = jumpScreen,
		dleft = dpadLeft,
		dright = dpadRight,
		action = actionBtn,
		pause = pauseBtn,
		resume = resumeBtn,
		---------------------
		score = scoreText,
		scoreUp = scoreUpText,
		lives = livesText,
		lifeUp = lifeUpText
	}

	buttonGroup:toFront()
	return buttons, buttonGroup
end

-- This function is called by the controller.
-- (Important: THIS causes the UI to appear on the screen!)
-- The only exception is the jumpScreen, which has to be manually istantiated on the map.
function ui.loadUI()
	-- Buttons refers to the WHOLE UI (including jumpScreen), use it for drastical changes
	-- ButtonGroup refers to every button that goes BEFORE the map.
	ui.buttons, ui.buttonGroup = createButtons()
end

-- Shortcut which allows to toggle enablement to the whole UI
function ui:setEnabled( boolean )
	for i in pairs (ui.buttons) do
		ui.buttons[i]:setEnabled( boolean )
	end
end


-- Animates one of the two <x>UpTexts
	function ui.textFade( textWidget, duration )	
		transition.to( textWidget, { 
			alpha = 0,
			time = duration,
			effect = "crossfade", 
			onComplete = function() 
				textWidget.isVisible = false
				textWidget.alpha = 1
			end
		})
	end

-- Shows and animates the final text when game ends.
function ui.showOutcome( outcome )
		local finalText = display.newText ("",	display.contentCenterX, display.contentCenterY, native.systemFontBold, 34)
		ui.buttonGroup:insert(finalText)
		if (outcome == "Completed") then
			finalText.text = "Level Completed ;)"
			finalText:setFillColor( 0.75, 0.8, 1 )
		elseif (outcome == "Failed") then
			finalText.text = "Level Failed :("
			finalText:setFillColor( 1, 0, 0 )
		elseif (outcome == "Terminated") then
			finalText.text = "See you soon!"
			finalText:setFillColor( 0, 1, 0)
		end
		transition.to(finalText, { alpha = 0, time = 1000,
			onComplete = function()
				display.remove( finalText )
			end
		})
	end

	
return ui