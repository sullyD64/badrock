-----------------------------------------------------------------------------------------
--
-- generalMenu.lua
--
-----------------------------------------------------------------------------------------

local widget    = require ( "widget"           )
-- local myData    = require ( "myData"           )
local utility   = require ( "menu.utilityMenu" )
local sfxMenu   = require ( "menu.sfxMenu"     )
local aboutMenu = require ( "menu.aboutMenu"   )
local resetMenu = require ( "menu.resetMenu"   )
local sfx = require ("audio.sfx")

local optBtn, playBtn
local bgm = sfx.bgMenuMusic

local opt = {}

-- Options menu ------------------------------------------------------------------
	--prende i bottoni dal main menu per poi riabilitarli alla chiusura del menu
	function opt.passVariables(optButton, playButton)
		optBtn = optButton
		playBtn = playButton
	end

	local function onOptReturnMenuBtnRelease()
		opt.panel:hide()
		optBtn:setEnabled(true)
		playBtn:setEnabled(true)
		return true
	end

	local function onAboutBtnRelease()  
		--transition.fadeOut( opt.panel, { time=100 } )
		aboutMenu.passVariables(opt.panel.soundMenuBtn, opt.panel.resetBtn)
		opt.panel.soundMenuBtn:setEnabled(false)
		opt.panel.resetBtn:setEnabled(false)
		aboutMenu.panel:show({
		y = display.actualContentHeight-30,
		time =250})
		return true
	end

	local function onSoundMenuBtnRelease()  
	    --transition.fadeOut( opt.panel, { time=100 } )
		sfxMenu.passVariablesMainMenu(opt.panel.aboutBtn, opt.panel.resetBtn, bgm)
		opt.panel.aboutBtn:setEnabled(false)
		opt.panel.resetBtn:setEnabled(false)
		sfxMenu.panel:show({
			y = display.actualContentHeight-30,
			time =250})
		return true
	end

	local function onResetBtnRelease()
		resetMenu.passVariables(opt.panel.soundMenuBtn, opt.panel.aboutBtn)
		resetMenu.panel:show({
			y = display.actualContentHeight-30,
			time =250})
		opt.panel.soundMenuBtn:setEnabled(false)
		opt.panel.aboutBtn:setEnabled(false)
	end

	-- Create the options panel (shown when the clockwork is pressed/released)
	opt.panel = utility.newPanel{
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

	opt.panel.background = display.newImageRect(visual.panel,opt.panel.width, opt.panel.height-20)
	--optPanel.background = display.newRoundedRect( 0, 0, optPanel.width-10, optPanel.height-50, 10 )
	--optPanel.background:setFillColor( 0.5, 0.28, 0.6)--0, 0.25, 0.5 )
	opt.panel:insert( opt.panel.background )

	opt.panel.titleShadow = display.newText( "Settings", 5, -93, utility.font, 20 )
	opt.panel.titleShadow:setFillColor( 0, 0, 0 )
	opt.panel:insert( opt.panel.titleShadow )
	opt.panel.title = display.newText( "Settings", 5, -93, utility.font, 21 )
	opt.panel.title:setFillColor( 1, 1, 1 )
	opt.panel:insert( opt.panel.title )

-- Create the buttons ------------------------------------------------------------

	-- Create the button to exit the options menu
		opt.panel.returnMenuBtn = widget.newButton {
			--label = "Return",
			onRelease = onOptReturnMenuBtnRelease,
			width = 25,--15,
			height = 25,--15,
			defaultFile = visual.exitOptionMenu,
			--overFile = "buttonOver.png",
			}
		opt.panel.returnMenuBtn.x= 112
		opt.panel.returnMenuBtn.y = -80---75
		opt.panel:insert(opt.panel.returnMenuBtn)

	-- Create the about button
		opt.panel.aboutBtn = widget.newButton {
			label = "About",
			fontSize = 14,
			onRelease = onAboutBtnRelease,
			width = 55,--65,
			height = 35,--42,
			defaultFile = visual.blankButtonMenu,
			font = utility.font,
			emboss = false,
			labelColor = { default={1} },--over={1} },
		}
		opt.panel.aboutBtn.x= -23--3
		opt.panel.aboutBtn.y = -30--opt.panel.contentCenterY
		opt.panel:insert(opt.panel.aboutBtn)

		-- Create the about button
		opt.panel.soundMenuBtn = widget.newButton {
			width = 37,--45,
			height = 35,--42,
			onRelease = onSoundMenuBtnRelease,		
			defaultFile = visual.audioSettingsImg,	
			}
		opt.panel.soundMenuBtn.x= -72---63
		opt.panel.soundMenuBtn.y = -30--opt.panel.contentCenterY
		opt.panel:insert(opt.panel.soundMenuBtn)

		-- Create the button to reset the saves
		opt.panel.resetBtn = widget.newButton {
			label = "Delete saves",
			fontSize = 13,
			onRelease = onResetBtnRelease,
			width = 90,--15,
			height = 35,--15,
			defaultFile = visual.blankButtonMenu,
			--overFile = "buttonOver.png",
			font = utility.font,
			labelColor = { default={1} },
			}
		opt.panel.resetBtn.x= 52
		opt.panel.resetBtn.y = -30---75
		opt.panel:insert(opt.panel.resetBtn)
-- -------------------------------------------------------------------------------
opt.group = display.newGroup()
opt.group:insert(opt.panel)
opt.group:insert(aboutMenu.panel)
opt.group:insert(sfxMenu.panel)
opt.group:insert(resetMenu.panel)
assert(opt.group[1] == opt.panel) -- do1 is on the bottom
assert(opt.group[2] == aboutMenu.panel) -- do2 is on the top (front)
assert(opt.group[3] == sfxMenu.panel)
assert(opt.group[4] == resetMenu.panel)
-- -----------------------------------------------------------------------------------
return opt