local widget = require ("widget")
local utility = require ("menu.utilityMenu")
local sfx = require( "audio.sfx" )
local myData = require( "myData" ) 


local opt = {}

    
    local function onOptReturnMenuBtnRelease()
        --transition.fadeIn( menuPanel, { time=100 } )  --RISOLVERE@@@@@@@@
        opt.panel:hide()
        return true
    end
    
    --Background Volume slider listener
    local function bgVolumeListener( event )
        print( "Slider at " .. event.value .. "%" )
        audio.setVolume( event.value/100, { channel=1 } )
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
            -- --audio.setVolume( 0, { channel=1 } )
            -- --else audio.setVolume (opt.panel.bgVolume.value)
            -- audio.pause({channel =1})
            -- else audio.resume({channel =1})
         else myData.settings.musicOn=true
              audio.resume({channel =1})
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
        width = display.contentWidth * 0.35,
        height = display.contentHeight * 0.65,
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
         
    opt.panel.title = display.newText( "Settings", 0, -70, "Micolas.ttf", 15 )
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
                frameWidth = 18,
                frameHeight = 16,
                handleFrame = 5,
                handleWidth = 18,
                handleHeight = 18,
                top = 100,
                left= 50,
                orientation = "horizontal",
                width = 140,
                value = 40,  -- Start slider at 40%
                listener = bgVolumeListener
            }
            opt.panel.bgVolume.x= -10
            opt.panel.bgVolume.y = -30
            opt.panel:insert(opt.panel.bgVolume)

        -- Create the effects volume slider
        opt.panel.fxVolume = widget.newSlider
            {   sheet = utility.sliderSheet,
                leftFrame = 1,
                middleFrame = 2,
                rightFrame = 3,
                fillFrame = 4,
                frameWidth = 18,
                frameHeight = 16,
                handleFrame = 5,
                handleWidth = 18,
                handleHeight = 18,
                top = 100,
                left= 50,
                orientation = "horizontal",
                width = 140,
                value = 40,  -- Start slider at 40%
                listener = fxVolumeListener
            }
            opt.panel.fxVolume.x= -10
            opt.panel.fxVolume.y = 5
            opt.panel:insert(opt.panel.fxVolume)

        opt.panel.bgVolumeText = display.newText( "Music", -20, -48,  "Micolas.ttf", 15 )
        opt.panel.bgVolumeText:setFillColor( 0, 0, 0 )
        opt.panel:insert(opt.panel.bgVolumeText)

        opt.panel.fxVolumeText = display.newText( "Sound Effects", -20, -12, "Micolas.ttf", 15 )
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
            opt.panel.bgMuteBtn.x= 64
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
            opt.panel.fxMuteBtn.x= 64
            opt.panel.fxMuteBtn.y = 5
            opt.panel:insert(opt.panel.fxMuteBtn)
        
        -- Create the button to exit the options menu
        opt.panel.returnMenuBtn = widget.newButton {
            --label = "Return",
            onRelease = onOptReturnMenuBtnRelease,
            width = 15,
            height = 15,
            defaultFile = visual.exitOptionMenu,
            --overFile = "buttonOver.png",
            }
            opt.panel.returnMenuBtn.x= 75
            opt.panel.returnMenuBtn.y = -83
            opt.panel:insert(opt.panel.returnMenuBtn)

    -- -------------------------------------------------------------------------------

return opt