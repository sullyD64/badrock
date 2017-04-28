local widget = require ("widget")
local utility = require ("menu.utilityMenu")
local myData = require( "myData" )
local sfxMenu = require( "menu.sfxMenu" ) 
local aboutMenu = require( "menu.aboutMenu" ) 

local opt = {}

-- Options menu -----------------------------------------------------------------------


    local function onOptReturnMenuBtnRelease()  
        opt.panel:hide()
        return true
    end

    local function onAboutBtnRelease()  
        --transition.fadeOut( opt.panel, { time=100 } )
        aboutMenu.panel:show({
            y = display.screenOriginY+225,
            time =250})
        return true
    end

    local function onSoundMenuBtnRelease()  
        --transition.fadeOut( opt.panel, { time=100 } )
        sfxMenu.panel:show({
             y = display.screenOriginY+225,
             time =250})
        return true
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
        opt.panel.background = display.newImageRect(visual.panel,opt.panel.width, opt.panel.height-20)
        --optPanel.background = display.newRoundedRect( 0, 0, optPanel.width-10, optPanel.height-50, 10 )
        --optPanel.background:setFillColor( 0.5, 0.28, 0.6)--0, 0.25, 0.5 )
        opt.panel:insert( opt.panel.background )
         
    opt.panel.title = display.newText( "Settings", 0, -70, "Micolas.ttf", 15 )
    opt.panel.title:setFillColor( 1, 1, 1 )
    opt.panel:insert( opt.panel.title )

    -- Create the buttons ------------------------------------------------------------
        
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

        -- Create the about button
        opt.panel.aboutBtn = widget.newButton {
            label = "About",
            fontSize = 10,
            labelColor = { default={0}, over={1} },
            onRelease = onAboutBtnRelease,
            emboss = false,
            shape = "roundedRect",
            width = 30,
            height = 15,
            cornerRadius = 2,
            fillColor = { default={0.78,0.79,0.78,1}, over={0.2,0.2,0.3,0.4} },--default={0.26,0.17,0.53,1}, over={1,0.1,0.7,0.4} },--{ default={1,0,0,1}, over={1,0.1,0.7,0.4} },
            strokeColor = { default={0,0,0,1}, over={1,1,1,1} },--default={1,0.4,0,1}, over={0.8,0.8,1,1} },
            strokeWidth = 1,
            }
            opt.panel.aboutBtn.x= -60
            opt.panel.aboutBtn.y = 39
            opt.panel:insert(opt.panel.aboutBtn)

         -- Create the about button
        opt.panel.soundMenuBtn = widget.newButton {
            label = "Sounds",
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
            opt.panel.soundMenuBtn.x= -20
            opt.panel.soundMenuBtn.y = 39
            opt.panel:insert(opt.panel.soundMenuBtn)
    -- -------------------------------------------------------------------------------
    opt.group = display.newGroup()
    opt.group:insert(opt.panel)
    opt.group:insert(aboutMenu.panel)
    opt.group:insert(sfxMenu.panel)
    assert(opt.group[1] == opt.panel) -- do1 is on the bottom
    assert(opt.group[2] == aboutMenu.panel) -- do2 is on the top (front)
    assert(opt.group[3] == sfxMenu.panel)
-- -----------------------------------------------------------------------------------
return opt