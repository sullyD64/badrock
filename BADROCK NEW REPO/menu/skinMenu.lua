local widget    = require ( "widget"           )
local myData    = require ( "myData"           )
local utility   = require ( "menu.utilityMenu" )


local skin = {}


    local function onReturnBtnRelease()  
        skin.panel:hide()
        return true
    end

    local function onSelectSkin()

    end

    skin.panel = utility.newPanel{
        location = "custom",
        onComplete = panelTransDone,
        width = display.contentWidth * 0.95,
        height = display.contentHeight * 0.50,
        speed = 220,
        anchorX = 1.0,
        anchorY = 0.5,
        --x = display.screenOriginX, --attivando questo entra da sinistra
        x =  display.contentWidth * 2,
        y = display.contentCenterY +5 ,
        inEasing = easing.linear,
        outEasing = easing.outCubic
    }
    skin.panel.background = display.newRoundedRect( 0, 0, skin.panel.width, skin.panel.height-20, 10 )
    skin.panel.background:setFillColor( 0.5, 0.28, 0.6)--0, 0.25, 0.5 )
    skin.panel:insert( skin.panel.background )

    skin.panel.title = display.newText( "Wardrobe", 0, -70, "Micolas.ttf", 15 )
    skin.panel.title:setFillColor( 1, 1, 1 )
    skin.panel:insert( skin.panel.title )

    -- Create the button to exit the options menu
    skin.panel.returnBtn = widget.newButton {
        --label = "Return",
        onRelease = onReturnBtnRelease,
        width = 15,
        height = 15,
        defaultFile = visual.exitOptionMenu,
        --overFile = "buttonOver.png",
        }
    skin.panel.returnBtn.x= 75
    skin.panel.returnBtn.y = -70
    skin.panel:insert(skin.panel.returnBtn)

    skin.panel.skinGroup = widget.newScrollView({
        --width = display.actualContentWidth,--460,
        --height = display.actualContentHeight/1.2,--260,
        width = skin.panel.width-50,--display.contentWidth*0.95,
        height = skin.panel.height-50,--display.contentHeight * 0.75,
        scrollWidth = skin.panel.width,--460,
        scrollHeight = skin.panel.height,--800,
        hideBackground = true,
        verticalScrollDisabled = true,
        x=display.screenOriginX,
        y=0
    })

    local xOffset = 0
    local yOffset = display.screenOriginX + 10
    -- Define the array to hold the buttons
    skin.panel.skins = {}

    -- Read the nuber of skins from the 'myData' table. Loop over them and generating one button for each.
    
    
    for i = 1, myData.settings.skinNumber do
        -- Create a button
        skin.panel.skins[i] = widget.newButton({
            
            id = tostring( i ),
            onRelease = onSkinSelect,
            emboss = false,
            --shape="roundedRect",
            width = skin.panel.width/4.50,--display.contentWidth - 350,
            height = skin.panel.height-60,--display.contentHeight - 200,

            defaultFile = "visual/misc/skin"..tostring( i )..".png"
            --visual.levelIconBg, --defaultFile = "misc/"..tostring(i).."select.png",
            --overFile= visual.levelIconBg,
            --cornerRadius = 8,
            --fillColor = { default={ 0, 0, 1, 1 }, over={ 0.5, 0.75, 1, 1 } },
            --strokeColor = { default={255,253,48,0.5}, over={0} },
            --strokeWidth = 2
        })
        -- Position the button in the grid and add it to the scrollView
        

        skin.panel.skins[i].anchorX = 0
        skin.panel.skins[i].anchorY = 0
        skin.panel.skins[i].x = xOffset
        skin.panel.skins[i].y = yOffset
        skin.panel.skinGroup:insert( skin.panel.skins[i] )

        -- If the level is locked, disable the button and fade it out.      

        if ( myData.settings.skins[i]==true ) then
            skin.panel.skins[i]:setEnabled( true )
            skin.panel.skins[i].alpha = 1.0
        else 
            skin.panel.skins[i]:setEnabled( false ) 
            skin.panel.skins[i].alpha = 0.5 
        end 

        xOffset = xOffset + skin.panel.skins[i].width*1.2--+20
    end
    
    
    -- TROVARE MODO PER METTERE IMMAGINE SELEZIONATA!!!!!!
    -- local selectedN= myData.settings.selectedSkin
    -- local selected  = widget.newButton({
    --         id = tostring( selectedN ),
    --         onRelease = onSkinSelect,
    --         emboss = false,
    --         width = skin.panel.width/4.50,
    --         height = skin.panel.height-60,
    --         defaultFile = "visual/misc/skinselected"..tostring( selectedN )..".png",
    --         anchorX = skin.panel.skins[selectedN],
    --         anchorY = skin.panel.skins[selectedN],
    --         x = skin.panel.skins[selectedN],
    --         y = skin.panel.skins[selectedN],
    --     })
    -- skin.panel.skins[selectedN]:removeSelf()
    -- skin.panel.skins[selectedN] = selected
    -- skin.panel.skinGroup:insert( selected )

    skin.panel:insert( skin.panel.skinGroup )
    --skin.panel.skinGroup.x = skin.panel.x
    --skin.panel.skinGroup.y = 0

return skin