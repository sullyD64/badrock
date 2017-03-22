-----------------------------------------------------------------------------------------
--
-- menu.lua
--
--Cose da fare:
--se premo da qualche parte che non è il panel menu, non funziona oppure esce dal menu (scegliere)
--non so perché, se metto come volume di partenza
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local widget = require ("widget")
local utility = require ("utilityMenu")

-- forward declarations and other locals
local playBtn, optionBtn, shopBtn, exitBtn, optPanel, bgVolume, bgMuteBtn, fxVolume, fxMuteBtn, volumeText

-- Option menu
-- -----------------------------------------------------------------------------------

    local function onOptReturnBtnRelease()  
        optPanel:hide()
        return true
    end

    local function onAboutBtnRelease()  
        optPanel:hide()
        return true
    end

    -- Backgroun Volume slider listener
    local function bgVolumeListener( event )
        print( "Slider at " .. event.value .. "%" )
        audio.setVolume( event.value/100, { channel=1 } )
    end

    -- Effects Volume slider listener
    local function fxVolumeListener( event )
        print( "Slider at " .. event.value .. "%" )
        audio.setVolume( event.value/100, { channel=2 } )
    end

    -- Handle press events for the mute background music checkbox (attualmente funziona con pause-resume)
    local function onBgMuteSwitchPress( event )
        local switch = event.target
        print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
        if (switch.isOn) then 
            --audio.setVolume( 0, { channel=1 } )
            --else audio.setVolume (optPanel.bgVolume.value)
            audio.pause({channel =1})
            else audio.resume({channel =1})
         end
    end

    -- Handle press events for the mute effects checkbox (attualmente funziona con pause-resume)
    local function onFxMuteSwitchPress( event )
        local switch = event.target
        print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
        if (switch.isOn) then 
            --audio.setVolume( 0, { channel=1 } )
            --else audio.setVolume (optPanel.bgVolume.value)
            audio.pause({channel =2})
            else audio.resume({channel =2})
         end
    end
  
  
    -- Create the options panel (shown when the clockwork is pressed/released)
    optPanel = utility.newPanel{
        location = "top",
        onComplete = panelTransDone,
        width = display.contentWidth * 0.52,
        height = display.contentHeight * 0.7,
        speed = 250,
        inEasing = easing.outBack,
        outEasing = easing.outCubic
        }
        optPanel.background = display.newRoundedRect( 0, 0, optPanel.width-100, optPanel.height-100, 10 )
        optPanel.background:setFillColor( 0.5, 0.28, 0.6)--0, 0.25, 0.5 )
        optPanel:insert( optPanel.background )
         
        optPanel.title = display.newText( "~Settings~", 0, -70, native.systemFontBold, 15 )
        optPanel.title:setFillColor( 1, 1, 1 )
        optPanel:insert( optPanel.title )

    -- Create the background music volume slider
    optPanel.bgVolume = widget.newSlider
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
        optPanel.bgVolume.x= -15
        optPanel.bgVolume.y = -30
        optPanel:insert(optPanel.bgVolume)

    -- Create the effects volume slider
    optPanel.fxVolume = widget.newSlider
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
        optPanel.fxVolume.x= -15
        optPanel.fxVolume.y = 5
        optPanel:insert(optPanel.fxVolume)

    optPanel.volumeText = display.newText( "Music", -20, -45, native.systemFont, 15 )
    optPanel.volumeText:setFillColor( 1, 0, 0 )
    optPanel:insert(optPanel.volumeText)

    optPanel.volumeText = display.newText( "Sound Effects", -20, -12, native.systemFont, 15 )
    optPanel.volumeText:setFillColor( 1, 0, 0 )
    optPanel:insert(optPanel.volumeText)

    -- Create the background mute checkbox
    optPanel.bgMuteBtn = widget.newSwitch
        {
            left = 0,
            top = 100,
            style = "checkbox",
            id = "Checkbox",
            onPress = onBgMuteSwitchPress,
            height = 15,
            width = 15
        }
        optPanel.bgMuteBtn.x= 55
        optPanel.bgMuteBtn.y = -30
        optPanel:insert(optPanel.bgMuteBtn)

    -- Create the effects mute checkbox
    optPanel.fxMuteBtn = widget.newSwitch
        {
            left = 0,
            top = 100,
            style = "checkbox",
            id = "Checkbox",
            onPress = onFxMuteSwitchPress,
            height = 15,
            width = 15
        }
        optPanel.fxMuteBtn.x= 55
        optPanel.fxMuteBtn.y = 5
        optPanel:insert(optPanel.fxMuteBtn)
    
    -- Create the button to exit the options menu
    optPanel.returnBtn = widget.newButton {
        --label = "Return",
        onEvent = onOptReturnBtnRelease,
        -- emboss = false,
        -- shape = "roundedRect",
        width = 10,
        height = 10,
        -- cornerRadius = 2,
        -- fillColor = { default={0.26,0.17,0.53,1}, over={1,0.1,0.7,0.4} },--{ default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        -- strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        -- strokeWidth = 1,
        defaultFile = "misc/exitOptionMenu.png",
        --overFile = "buttonOver.png",
        }
        optPanel.returnBtn.x= 70
        optPanel.returnBtn.y = -58
        optPanel:insert(optPanel.returnBtn)

    -- Create the about button
    optPanel.aboutBtn = widget.newButton {
        --label = "About",
        onEvent = onAboutBtnRelease,
        emboss = false,
        shape = "roundedRect",
        width = 15,
        height = 15,
        cornerRadius = 2,
        fillColor = { default={0.26,0.17,0.53,1}, over={1,0.1,0.7,0.4} },--{ default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        strokeWidth = 1,
        }
        optPanel.aboutBtn.x= 0
        optPanel.aboutBtn.y = 0
        --optPanel:insert(optPanel.aboutBtn)
-- -----------------------------------------------------------------------------------

-- Button functions
-- -----------------------------------------------------------------------------------

    local function onPlayBtnRelease()
    	--go to levelSelect.lua scene
        optPanel:hide({
            speed = 250,
            transition = easing.outElastic
            --alpha = 0
        })
    	composer.gotoScene( "levelSelect", "fade", 280 )

    	return true
    end

    local function onShopBtnRelease()
    	-- go to level1.lua scene
        audio.stop()
        composer.removeScene( "level1" )
    	composer.gotoScene( "level1", "fade", 280 )
    	return true
    end

    local function onOptionBtnRelease()
        -- open options panel
        optPanel:show()
        return true
    end
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------

    -- create()
    function scene:create( event )
    	local sceneGroup = self.view
        

        backgroundMusic = audio.loadStream( "audio/heartbeat.mp3" )     -- AUDIO (probabilmente da cambiare)
        
        
        


    	-- Load the background
    	local background = display.newImageRect( "misc/MenuBackground.jpg", display.actualContentWidth, display.actualContentHeight )
    	background.anchorX = 0
    	background.anchorY = 0
    	background.x = 0 + display.screenOriginX 
    	background.y = 0 + display.screenOriginY
    	
    	-- Load the logo
    	local titleLogo = display.newImageRect( "misc/logoShadow.png", 343, 123 )
    	titleLogo.x = display.contentCenterX
    	titleLogo.y = 100

    	-- Load steve
    	local steveImage = display.newImageRect( "misc/MenuSteve.png", 115, 113 )
    	steveImage.x = display.contentCenterX
    	steveImage.y = display.contentCenterY + 25
        steveImage.direction = 1

        -- Loop Steve image    
        local function functionLoop()
            if (steveImage.direction == 1) then
                steveImage.xScale = -1
                steveImage.direction = -1
            else
                steveImage.direction = 1
                steveImage.xScale = 1
            end
        end
        timer.performWithDelay( 2000, functionLoop, 0 )
    	
        -- Load the widgets    
        -- -----------------------------------------------------------------------------------
            -- Option button (clockwork in the upper-right corner)
            optionBtn = widget.newButton
                {
                    id = "optionBtn",
                    onEvent = onOptionBtnRelease,
                    width = 25,
                    height = 25,
                    defaultFile = "misc/ingranaggio.png",
                    overFile = "misc/ingranaggio.png",
                }
                optionBtn.anchorX = 0
                optionBtn.anchorY = 0
                optionBtn.x =  display.screenOriginX + 3 
                optionBtn.y = display.screenOriginY + 3 

            -- Play button (go to level select)
            playBtn = widget.newButton 
                {
                    width = 150,
                    height = 38,
                    sheet = utility.buttonSheet,
                    topLeftFrame = 1,
                    topMiddleFrame = 2,
                    topRightFrame = 3,
                    middleLeftFrame = 4,
                    bottomLeftFrame = 5,
                    bottomMiddleFrame = 6,
                    bottomRightFrame = 7,
                    middleRightFrame = 8,
                    middleFrame = 9,
        			topLeftOverFrame = 10,
        	        topMiddleOverFrame = 11,
        	        topRightOverFrame = 12,
        	        middleLeftOverFrame = 13,
        	        middleOverFrame = 14,
        	        middleRightOverFrame = 15,
        	        bottomLeftOverFrame = 16,
        	        bottomMiddleOverFrame = 17,
        	        bottomRightOverFrame = 18,

                    label = "Play",
                    font = native.systemFontBold,
                    labelColor = { default={1}, over={128} },
                    onRelease = onPlayBtnRelease    
                }
                playBtn.anchorX = 0
                playBtn.anchorY = 0
                playBtn.x =  display.screenOriginX -20 
                playBtn.y = display.contentHeight - 90

            -- Shop button, go to the shop scene, for now it goes to the test level
            shopBtn = widget.newButton 
                {
                    width = 150,
                    height = 38,
                    sheet = utility.buttonSheet,
                    topLeftFrame = 1,
                    topMiddleFrame = 2,
                    topRightFrame = 3,
                    middleLeftFrame = 4,
                    bottomLeftFrame = 5,
                    bottomMiddleFrame = 6,
                    bottomRightFrame = 7,
                    middleRightFrame = 8,
                    middleFrame = 9,
                    topLeftOverFrame = 10,
                    topMiddleOverFrame = 11,
                    topRightOverFrame = 12,
                    middleLeftOverFrame = 13,
                    middleOverFrame = 14,
                    middleRightOverFrame = 15,
                    bottomLeftOverFrame = 16,
                    bottomMiddleOverFrame = 17,
                    bottomRightOverFrame = 18,
                    label = "Test",
                    font = native.systemFontBold,
                    labelColor = { default={1}, over={128} },
                    onRelease = onShopBtnRelease                -- !!!!TO DO!!!!
                }

                shopBtn.anchorX = 0
                shopBtn.anchorY = 0
                shopBtn.x =  display.contentWidth -130
                shopBtn.y = display.contentHeight - 90
        -- -----------------------------------------------------------------------------------

    	-- all display objects must be inserted into group
    	sceneGroup:insert( background )
    	sceneGroup:insert( titleLogo )
    	sceneGroup:insert( playBtn )
    	sceneGroup:insert( optionBtn )
    	sceneGroup:insert( shopBtn )
    	sceneGroup:insert( steveImage )
    end

    -- show()
    function scene:show( event )
    	local sceneGroup = self.view
    	local phase = event.phase
    	audio.play(backgroundMusic, {channel = 1 , loops=-1})
        if ( phase == "will" ) then

    	elseif ( phase == "did" ) then
    	
    	end	
    end

    -- hide()
    function scene:hide( event )
    	local sceneGroup = self.view
    	local phase = event.phase
    	
        if ( event.phase == "will" ) then
    		
    	elseif ( phase == "did" ) then
    	
    	end	
    end

    -- destroy()
    function scene:destroy( event )
    	local sceneGroup = self.view
    	if playBtn or shopBtn then
            audio.dispose()
            playBtn:removeSelf()	-- widgets must be manually removed
    		playBtn = nil
    		optionBtn:removeSelf()
    		shopBtn:removeSelf()
    		steveImage:removeSelf()
    	end	
    end

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTION LISTENERS
-- -----------------------------------------------------------------------------------
    scene:addEventListener( "create", scene )
    scene:addEventListener( "show", scene )
    scene:addEventListener( "hide", scene )
    scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene