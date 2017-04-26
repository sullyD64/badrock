local utility  = require ( "utilityMenu"  )
local widget   = require ( "widget"		  )
local myData   = require ( "myData"       )
local soundMenu= require ( "sfxMenu"      ) 


local pause = {}

-- PAUSE MENU ---------------------------------------------------------------------

    local function onSoundMenuBtnRelease()  
        transition.fadeOut( pause.panel, { time=100 } )
        soundMenu.panel:show({
             y = display.screenOriginY+225,
             time =250})
        return true
    end

    -- Return to the main Menu
    local function onMenuBtnRelease()  
        local psbutton = ui.getButtonByName("pauseBtn")
		local rsbutton = ui.getButtonByName("resumeBtn")
        pause.panel:hide({
            speed = 250,
            transition = easing.outElastic
        })
		psbutton.isVisible = true
		rsbutton.isVisible = false
		audio.fadeOut(1,100)
		audio.stop(1)
		--composer.removeScene( "level1" )
        composer.gotoScene( "menu", { effect="fade", time=280 } )
        return true
    end
  
	-- Create the pause panel
	pause.panel = utility.newPanel{
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
	        pause.panel.background = display.newImageRect("misc/panel.png",pause.panel.width, pause.panel.height-20)
	        pause.panel:insert( pause.panel.background )
	         
	        pause.panel.title = display.newText( "Pause", 0, -70, "Micolas.ttf", 15 )
	        pause.panel.title:setFillColor( 1, 1, 1 )
	        pause.panel:insert( pause.panel.title )

	-- Create the buttons ------------------------------------------------------------

	    pause.panel.soundMenuBtn = widget.newButton {
            label = "Options",
            fontSize = 10,
            labelColor = { default={0}, over={1} },
            onRelease = onSoundMenuBtnRelease,
            emboss = false,
            shape = "roundedRect",
            width = 30,
            height = 15,
            cornerRadius = 2,
            fillColor = { default={0.78,0.79,0.78,1}, over={0.2,0.2,0.3,0.4} },--default={0.26,0.17,0.53,1}, over={1,0.1,0.7,0.4} },--{ default={1,0,0,1}, over={1,0.1,0.7,0.4} },
            strokeColor = { default={0,0,0,1}, over={1,1,1,1} },--default={1,0.4,0,1}, over={0.8,0.8,1,1} },
            strokeWidth = 1,
            }
            pause.panel.soundMenuBtn.x= -20
            pause.panel.soundMenuBtn.y = 39
            pause.panel:insert(pause.panel.soundMenuBtn)

	    -- Create the return to menu button
	    pause.panel.menuBtn = widget.newButton {
	        label = "Menu",
	        onRelease = onMenuBtnRelease,
	        emboss = false,
	        shape = "roundedRect",
	        width = 40,
	        height = 15,
	        cornerRadius = 2,
	        fillColor = { default={0.78,0.79,0.78,1}, over={1,0.1,0.7,0.4} },
	        strokeColor = { default={0,0,0,1}, over={0.8,0.8,1,1} },
	        strokeWidth = 1,
	        }
	        pause.panel.menuBtn.x= -60
	        pause.panel.menuBtn.y = 39
	        pause.panel:insert(pause.panel.menuBtn)
	-- -------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------

return pause