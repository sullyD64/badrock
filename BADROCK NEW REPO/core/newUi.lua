-----------------------------------------------------------------------------------------
--
-- newUi.lua
--
-- This module is tied to the controller which is the only class that uses it.
-- Although UI is mainly "passive", it requires the controller for storing in a table its
-- "listeners" function; in that way each button can reference one of the controller methods
-- when the button is created.
-- Additional functions provide easy shortcuts for toggling the enablement for the whole ui.
-----------------------------------------------------------------------------------------
local widget     = require ( "widget"     )
local controller = require ( "controller" )

local ui = {}

-- Locally stores the list of references to the controller's listener functions
local listeners = controller.listeners

-- Stores the data tables for the -widget.newButton- calls.
local buttonData = {
	-- Touchable area (invisible button)
	--1
	jumpScreen = {
		options = {
			id = "jumpScreen",
			width = 10000,
			heigth = 10000,
			onPress = listeners.onJumpTouch
		}
	}

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
			y = display.contentHeight - ui.dpadLeft.height / 2 - 10,
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
			y = display.contentHeight - ui.dpadLeft.height / 2 - 10,
		},
		aX = 0,
		aY = 1,
	},
	--4
	actionBtn = {
		options = {
			id = "actionBtn",
			defaultFile = visual.actionBtn,
			--overFile = visual.actionBtn_over,
			width = 51,
			height = 51,
			x = display.contentWidth - 10
			y = display.contentHeight -10 - ui.actionBtn.height / 2, --REWORK ME!
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
			fontSize = 24,
			labelColor = {
				default = { 0,0,255 },
				over = { 0,0,255 },
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
				default = { 0,0,255 },
				over = { 0,0,255 },
			},
			x = display.contentWidth - 80
			y = 60,
		},
		aX = 0.5,
		aY = 0.5,
		isVisible = false,
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
				default = { 255,0,0 },
				over = { 255,0,0 },
			},
			x = display.contentWidth - 80
			y = 60,
		},
		aX = 0,
		aY = 0,
		isVisible = false,
	},
}

-- Contains all the calls to -widget.newButton- and adds selected buttons to the UI Group.
local function createButtons()
	local buttonGroup = display.newGroup()

	local jumpScreen  = widget.newButton ( buttonData.jumpScreen.options  )
		jumpScreen:setFillColor( 0, 255, 0 )
		jumpScreen.isVisible = false
		jumpScreen.isHitTestable = true
		--	buttonGroup:insert( jumpScreen )		-- NO!

	local dpadLeft    = widget.newButton ( buttonData.dpadLeft.options    )
		dpadLeft.anchorX, dpadLeft.anchorY = buttonData.dpadLeft.aX, buttonData.dpadLeft.ay
		buttonGroup:insert( dpadLeft )

	local dpadRight   = widget.newButton ( buttonData.dpadRight.options   )
		dpadRight.anchorX, dpadRight.anchorY = buttonData.dpadRight.aX, buttonData.dpadRight.ay
		buttonGroup:insert( dpadRight )

	local actionBtn   = widget.newButton ( buttonData.actionBtn.options   )
		actionBtn.anchorX, actionBtn.anchorY = buttonData.actionBtn.aX, buttonData.actionBtn.ay
		buttonGroup:insert( actionBtn )

	local pauseBtn    = widget.newButton ( buttonData.pauseBtn.options    )
		pauseBtn.anchorX, pauseBtn.anchorY = buttonData.pauseBtn.aX, buttonData.pauseBtn.ay
		buttonGroup:insert( pauseBtn )
		----------------------
		pauseBtn.active = true -- Controller (avoid action spam)
		----------------------

	local resumeBtn   = widget.newButton ( buttonData.resumeBtn.options   )
		resumeBtn.anchorX, resumeBtn.anchorY = buttonData.resumeBtn.aX, buttonData.resumeBtn.ay
		buttonGroup:insert( resumeBtn )
		----------------------
		resumeBtn.isVisible = false -- Controller
		----------------------

	local scoreText   = widget.newButton ( buttonData.scoreText.options   )
		scoreText.anchorX, scoreText.anchorY = buttonData.scoreText.aX, buttonData.scoreText.ay
		buttonGroup:insert( scoreText )

	local scoreUpText = widget.newButton ( buttonData.scoreUpText.options )
		scoreUpText.anchorX, scoreUpText.anchorY = buttonData.scoreUpText.aX, buttonData.scoreUpText.ay
		buttonGroup:insert( scoreUpText )
		----------------------
		scoreUpText.isVisible = false -- Controller
		----------------------

	local livesText   = widget.newButton ( buttonData.livesText.options   )
		livesText.anchorX, livesText.anchorY = buttonData.livesText.aX, buttonData.livesText.ay
		buttonGroup:insert( livesText )

	local buttons = {
		jumpScreen, 
		dpadLeft, dpadRight, actionBtn, 
		pauseBtn, resumeBtn, 
		scoreText, scoreUpText, livesText
	}

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

	
return ui