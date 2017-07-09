-----------------------------------------------------------------------------------------
--
-- sfxMenu.lua
--
-----------------------------------------------------------------------------------------

local widget  = require ( "widget"           )
local myData  = require ( "myData"           )
local utility = require ( "menu.utilityMenu" )

local opt = {}

local function onOptReturnMenuBtnRelease()
	--transition.fadeIn( menuPanel, { time=100 } )  --RISOLVERE@@@@@@@@
	opt.panel:hide()
	return true
end

--Background Volume slider listener
local function bgVolumeListener( event )
	print( "Slider at " .. event.value .. "%" )

	if (sfx.altBgmIsPlaying) then
		audio.setVolume( event.value/100, { channel=8 } )
	else
		audio.setVolume( event.value/100, { channel=1 } )
	end
end

-- Effects Volume slider listener
local function fxVolumeListener( event )
	print( "Slider at " .. event.value .. "%" )
	sfx.setVolumeSound(event.value/100)
end

-- Handle press events for the mute background music checkbox
local function onBgMuteSwitchPress( event )
	local switch = event.target
	print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
	if (switch.isOn) then 
		myData.settings.musicOn=false
		audio.pause({channel =1})
		audio.pause({channel =8})
		-- --audio.setVolume( 0, { channel=1 } )
		-- --else audio.setVolume (opt.panel.bgVolume.value)
		-- audio.pause({channel =1})
		-- else audio.resume({channel =1})
	 else myData.settings.musicOn=true
		  audio.resume({channel =1})
		  audio.resume({channel =8})
	end
	
end

-- Handle press events for the mute effects checkbox
local function onFxMuteSwitchPress( event )
	local switch = event.target
	print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
	if (switch.isOn) then 
		myData.settings.soundOn=false
		sfx.pauseSound()
	 else myData.settings.soundOn=true
		sfx.setVolumeSound( opt.panel.fxVolume.value)
	end
end

-- Create the options panel (shown when the clockwork is pressed/released)
opt.panel = utility.newPanel{
	location = "custom",
	onComplete = panelTransDone,
	width = 250,--display.contentWidth * 0.35,
	height = 260, --display.contentHeight * 0.65,
	speed = 250,
	anchorX = 0.5,
	anchorY = 1.0,
	x = display.contentCenterX,
	y = display.screenOriginY,
	inEasing = easing.outBack,
	outEasing = easing.outCubic
	}
	opt.panel.background = display.newImageRect("visual/misc/panel.png",opt.panel.width, opt.panel.height-20)
	--opt.panel.background = display.newRoundedRect( 0, 0, opt.panel.width-10, opt.panel.height-50, 10 )
	--opt.panel.background:setFillColor( 0.5, 0.28, 0.6)--0, 0.25, 0.5 )
	opt.panel:insert( opt.panel.background )

opt.panel.titleShadow = display.newText( "Audio", 5, -93, utility.font, 20 )
opt.panel.titleShadow:setFillColor( 0, 0, 0 )
opt.panel:insert( opt.panel.titleShadow )	 
opt.panel.title = display.newText( "Audio", 5, -93, utility.font, 21 )
opt.panel.title:setFillColor( 1, 1, 1 )
opt.panel:insert( opt.panel.title )

-- Create the buttons ------------------------------------------------------------

	-- Create the background music volume slider
	opt.panel.bgVolume = widget.newSlider
		{   sheet = utility.sliderSheet,
			leftFrame = 1,
			middleFrame = 2,
			rightFrame = 3,
			fillFrame = 4,
			frameWidth = 10,
			frameHeight = 20,
			handleFrame = 5,
			handleWidth = 22,
			handleHeight = 22,
			--top = 100,
			--left= 50,
			orientation = "horizontal",
			width = 130,
			value = 40,  -- Start slider at 40%
			listener = bgVolumeListener
		}
		opt.panel.bgVolume.x= -85
		opt.panel.bgVolume.y = -40
		opt.panel:insert(opt.panel.bgVolume)

	-- Create the effects volume slider
	opt.panel.fxVolume = widget.newSlider
		{   sheet = utility.sliderSheet,
			leftFrame = 1,
			middleFrame = 2,
			rightFrame = 3,
			fillFrame = 4,
			frameWidth = 10,
			frameHeight = 20,
			handleFrame = 5,
			handleWidth = 22,
			handleHeight = 22,
			--top = 300,--100,
			--left= 50,
			orientation = "horizontal",
			width = 130,
			value = 40,  -- Start slider at 40%
			listener = fxVolumeListener
		}
		opt.panel.fxVolume.x= -85
		opt.panel.fxVolume.y = -3
		opt.panel:insert(opt.panel.fxVolume)

	opt.panel.bgVolumeText = display.newText( "Music", -20, -48,   utility.font, 15 )
	opt.panel.bgVolumeText:setFillColor( 0, 0, 0 )
	opt.panel:insert(opt.panel.bgVolumeText)

	opt.panel.fxVolumeText = display.newText( "Sound Effects", -20, -12,  utility.font, 15 )
	opt.panel.fxVolumeText:setFillColor( 0, 0, 0 )
	opt.panel:insert(opt.panel.fxVolumeText)

	-- Create the background mute checkbox
	opt.panel.bgMuteBtn = widget.newSwitch
		{   sheet = utility.checkboxSheet,
			frameOff = 1,
			frameOn = 2,
			left = 0,
			top = 100,
			style = "checkbox",
			id = "Checkbox",
			onPress = onBgMuteSwitchPress,
			height = 15,
			width = 15,
			initialSwitchState = not myData.settings.musicOn
		}
		opt.panel.bgMuteBtn.x= 60
		opt.panel.bgMuteBtn.y = -30
		opt.panel:insert(opt.panel.bgMuteBtn)

	-- Create the effects mute checkbox
	opt.panel.fxMuteBtn = widget.newSwitch
		{   sheet = utility.checkboxSheet,
			frameOff = 1,
			frameOn = 2,
			left = 0,
			top = 100,
			style = "checkbox",
			id = "Checkbox",
			onPress = onFxMuteSwitchPress,
			height = 15,
			width = 15,
			initialSwitchState = not myData.settings.soundOn
		}
		opt.panel.fxMuteBtn.x= 60
		opt.panel.fxMuteBtn.y = 5
		opt.panel:insert(opt.panel.fxMuteBtn)

	-- Create the button to exit the options menu
	opt.panel.returnMenuBtn = widget.newButton {
		onRelease = onOptReturnMenuBtnRelease,
		width = 25,
		height = 25,
		defaultFile = visual.exitOptionMenu,
		}
		opt.panel.returnMenuBtn.x= 112--98
		opt.panel.returnMenuBtn.y = -80
		opt.panel:insert(opt.panel.returnMenuBtn)
-- -------------------------------------------------------------------------------

return opt