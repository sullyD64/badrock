-----------------------------------------------------------------------------------------
--
-- newUi.lua
--
-----------------------------------------------------------------------------------------
local widget     = require ( "widget"     )
local controller = require ( "controller" )

local ui = {}

local buttonData = {
	-- #1 dpadLeft
	{
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

	-- #2 dpadRight
	{
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

	-- #3 actionBtn
	{
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

	-- #4 pauseBtn
	{
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

	-- #5 resumeBtn
	{
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

	-- #6 scoreText
	{	
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

	-- #7 scoreUpText
	{	
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

	-- #8 livesText
	{	
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

ui.buttons = display.newGroup()

local function createButtons()
	-- Special case for the jumpScreen
	local jumpScreen = display.newRect( display.contentCenterX, display.contentCenterY, 10000,10000)
		-- jumpScreen:setFillColor( 0, 255, 0 )
		jumpScreen.id = "jumpScreen"
		jumpScreen.isVisible = false
		jumpScreen.isHitTestable = true
		buttons:insert( jumpScreen )

	local dpadLeft = widget.newButton( buttonData[1].options )
		dpadLeft.anchorX, dpadLeft.anchorY = button[1].aX, button[1].ay
		buttons:insert( dpadLeft )

	local dpadRight = widget.newButton( buttonData[2].options )
		dpadRight.anchorX, dpadRight.anchorY = button[2].aX, button[2].ay
		buttons:insert( dpadRight )

	local actionBtn = widget.newButton( buttonData[3].options )
		actionBtn.anchorX, actionBtn.anchorY = button[3].aX, button[3].ay
		buttons:insert( actionBtn )

	local pauseBtn = widget.newButton( buttonData[4].options )
		pauseBtn.anchorX, pauseBtn.anchorY = button[4].aX, button[4].ay
		buttons:insert( pauseBtn )
		----------------------
		pauseBtn.active = true -- Controller (avoid action spam)
		----------------------

	local resumeBtn = widget.newButton( buttonData[5].options )
		resumeBtn.anchorX, resumeBtn.anchorY = button[5].aX, button[5].ay
		buttons:insert( resumeBtn )
		----------------------
		resumeBtn.isVisible = false -- Controller
		----------------------

	local scoreText = widget.newButton( buttonData[6].options )
		scoreText.anchorX, scoreText.anchorY = button[6].aX, button[6].ay
		buttons:insert( scoreText )

	local scoreUpText = widget.newButton( buttonData[7].options )
		scoreUpText.anchorX, scoreUpText.anchorY = button[7].aX, button[7].ay
		buttons:insert( scoreUpText )
		----------------------
		scoreUpText.isVisible = false -- Controller
		----------------------
	
	local livesText = widget.newButton( buttonData[8].options )
		livesText.anchorX, livesText.anchorY = button[8].aX, button[8].ay
		buttons:insert( livesText )
end


function ui:setEnabled( boolean )
	-- skips the jumpScreen
	for 2, #ui.buttons, 1 do
		ui.buttons[i]:setEnabled( boolean )
	end

	ui.buttons[1].isEnabled = boolean
end

	
return ui