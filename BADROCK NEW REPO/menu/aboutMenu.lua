-----------------------------------------------------------------------------------------
--
-- aboutMenu.lua
--
-----------------------------------------------------------------------------------------

local widget  = require ( "widget"           )
local myData  = require ( "myData"           )
local utility = require ( "menu.utilityMenu" )


local abt = {}

-- About Menu ------------------------------------------------------------------------
	local function onAboutReturnBtnRelease()
		--transition.fadeIn( menuPanel, { time=100 } )
		abt.panel:hide()
		return true
	end

	-- Create the about panel
	abt.panel = utility.newPanel{
		location = "custom",
		onComplete = panelTransDone,
		width = 250,--display.contentWidth * 0.35,
		height = 260,--display.contentHeight * 0.65,
		speed = 250,
		anchorX = 0.5,
		anchorY = 1.0,
		x = display.contentCenterX,
		y = display.screenOriginY,
		inEasing = easing.outBack,
		outEasing = easing.outCubic
		}
		abt.panel.background = display.newImageRect(visual.panel,abt.panel.width, abt.panel.height-20)
		abt.panel:insert( abt.panel.background )

	abt.panel.title = display.newText( "About", 0, -70, utility.font, 15 )
	abt.panel.title:setFillColor( 1, 1, 1 )
	abt.panel:insert( abt.panel.title )

	abt.panel.title = display.newText( "Creato da:", 0, -40, utility.font, 15 ) --che scriviamo qui?
	abt.panel.title:setFillColor( 1, 1, 1 )
	abt.panel:insert( abt.panel.title )

	-- Create the button to exit the about menu
	abt.panel.aboutReturnBtn = widget.newButton {
		--label = "Return",
		onRelease = onAboutReturnBtnRelease,
		emboss = false,
		shape = "roundedRect",
		width = 15,
		height = 15,
		cornerRadius = 2,
		fillColor = { default={0.78,0.79,0.78,1}, over={1,0.1,0.7,0.4} },--default={0.26,0.17,0.53,1}, over={1,0.1,0.7,0.4} },--{ default={1,0,0,1}, over={1,0.1,0.7,0.4} },
		strokeColor = { default={0,0,0,1}, over={0.8,0.8,1,1} },--default={1,0.4,0,1}, over={0.8,0.8,1,1} },
		strokeWidth = 1,
		}
		abt.panel.aboutReturnBtn.x= -60
		abt.panel.aboutReturnBtn.y = 39
		abt.panel:insert(abt.panel.aboutReturnBtn)
-- -----------------------------------------------------------------------------------
return abt