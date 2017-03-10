local widget = require ("widget")
local utility = require ("utilityMenu")

--non va bene perche panel è la variabile del menu non quella che sta qui (probabilmente)

    local function onReturnBtnRelease()  
        skinPanel:hide()
        return true
    end


 -- options panel
    local skinPanel = utility.newPanel{
        location = "top",
        -- x = screenOriginX,
        -- y = screenOriginY,
        onComplete = panelTransDone,
        width = display.contentWidth,
        height = display.contentHeight * 0.8,
        
        speed = 250,
        inEasing = easing.outBack,
        outEasing = easing.outCubic
    }
    skinPanel.background = display.newRoundedRect( 0, 0, skinPanel.width-100, skinPanel.height-100, 10 )
    skinPanel.background:setFillColor( 0.5, 0.28, 0.6)--0, 0.25, 0.5 )
    skinPanel:insert( skinPanel.background )
     
    skinPanel.title = display.newText( "menu", 0, 0, native.systemFontBold, 18 )
    skinPanel.title:setFillColor( 1, 1, 1 )
    skinPanel:insert( skinPanel.title )

    skinPanel.returnBtn = widget.newButton {
        --label = "Return",
        onEvent = onReturnBtnRelease,
        emboss = false,
        shape = "roundedRect",
        width = 20,
        height = 20,
        cornerRadius = 2,
        fillColor = { default={0.26,0.17,0.53,1}, over={1,0.1,0.7,0.4} },--{ default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        strokeWidth = 1,
        --x = ,
        --y = 
        }

    skinPanel:insert(skinPanel.returnBtn)






return skinPanel