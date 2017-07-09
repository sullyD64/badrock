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

	abt.panel.titleShadow = display.newText( "About", 5, -93, utility.font, 20 )
	abt.panel.titleShadow:setFillColor( 0, 0, 0 )
	abt.panel:insert( abt.panel.titleShadow )
	abt.panel.title = display.newText( "About",  5, -93, utility.font, 21)
	abt.panel.title:setFillColor( 1, 1, 1 )
	abt.panel:insert( abt.panel.title )

	abt.panel.title = display.newText( "Creato da:", 0, -40, utility.font, 15 ) --che scriviamo qui?
	abt.panel.title:setFillColor( 1, 1, 1 )
	abt.panel:insert( abt.panel.title )

	-- Create the button to exit the about menu
	abt.panel.aboutReturnBtn = widget.newButton {
		onRelease = onAboutReturnBtnRelease,
		width = 25,
		height = 25,
		defaultFile = visual.exitOptionMenu,
		}
		abt.panel.aboutReturnBtn.x= 112
		abt.panel.aboutReturnBtn.y = -80
		abt.panel:insert(abt.panel.aboutReturnBtn)
-- -----------------------------------------------------------------------------------
return abt