-----------------------------------------------------------------------------------------
--
-- resetMenu.lua
--
-----------------------------------------------------------------------------------------

local widget  = require ( "widget"           )
local utility = require ( "menu.utilityMenu" )

local soundBtn, aboutBtn

local reset = {}

-- About Menu ------------------------------------------------------------------------
	
	function reset.passVariables(sndBtn, abtBtn)
		soundBtn = sndBtn
		aboutBtn = abtBtn
	end


	local function onReturnBtnRelease()
		--transition.fadeIn( menuPanel, { time=100 } )
		reset.panel:hide()
		soundBtn:setEnabled(true)
		aboutBtn:setEnabled(true)
		return true
	end

	local function onConfirmReset()
		service.resetData()
		myData = service.loadData()
		reset.panel:hide()
		soundBtn:setEnabled(true)
		aboutBtn:setEnabled(true)
	end

	-- Create the about panel
	reset.panel = utility.newPanel{
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
		reset.panel.background = display.newImageRect(visual.panel,reset.panel.width, reset.panel.height-20)
		reset.panel:insert( reset.panel.background )

	reset.panel.titleShadow = display.newText( "Reset", 5, -93, utility.font, 20 )
	reset.panel.titleShadow:setFillColor( 0, 0, 0 )
	reset.panel:insert( reset.panel.titleShadow )
	reset.panel.title = display.newText( "Reset",  5, -93, utility.font, 21)
	reset.panel.title:setFillColor( 1, 1, 1 )
	reset.panel:insert( reset.panel.title )

	reset.panel.title = display.newText( "       Are you sure you \n want to cancel your saves?", 0, -37, utility.font, 15 ) --che scriviamo qui?
	reset.panel.title:setFillColor( 1, 1, 1 )
	reset.panel:insert( reset.panel.title )

	reset.panel.returnBtn = widget.newButton {
        onRelease = onReturnBtnRelease,
        width = 30,
        height = 30,
        defaultFile = visual.cancelImg,
        }
    reset.panel.returnBtn.x= 30
    reset.panel.returnBtn.y = 3
    reset.panel:insert(reset.panel.returnBtn)

    reset.panel.resetBtn = widget.newButton {
        onRelease = onConfirmReset,
        width = 30,
        height = 30,
        defaultFile = visual.confirmImg,
        }
    reset.panel.resetBtn.x= -30
    reset.panel.resetBtn.y = 3
    reset.panel:insert(reset.panel.resetBtn)

-- -----------------------------------------------------------------------------------
return reset