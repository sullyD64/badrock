local widget    = require ( "widget"           )
-- local myData    = require ( "myData"           )
local utility   = require ( "menu.utilityMenu" )

local buttonId = 0
local skinType
local price
local skinBtn, transpBtn, backBtn
local buyBtns, skins
local goodText, evilText

local buy = {}
    
    function buy.setToEnableButtons( backButton, skinsButtons, buyButtons, gText, eText  )
        backBtn = backButton
        skins = skinsButtons
        buyBtns = buyButtons
        goodText = gText 
        evilText = eText

    end
    
    -- cambia il menu nel caso non si abbiano abbastanza punti (disabilita tasto d'acquisto e mostra testo)
    local function cantBuy()
        --buy.panel.priceText:setFillColor (1,0,0)
        buy.panel.cantBuyText.text = "You can't buy this skin!"
        buy.panel.buyBtn:setEnabled(false)
        buy.panel.buyBtn.alpha = 0.5
    end   

    -- ripristina il menu nel caso si possa acquistare
    local function canBuy()
        buy.panel.cantBuyText.text = ""
        buy.panel.buyBtn:setEnabled(true)
        buy.panel.buyBtn.alpha = 1
    end   

    -- prende i dati necessari dal menu delle skin e li utilizza per impostare le variabili del menu 
    function buy.setSkin(id, transpButton, skinButton)
        skinBtn = skinButton 
        transpBtn = transpButton
        skinType = myData.settings.skins[id].type
        price = myData.settings.skins[id].price
        buttonId = id
        buy.panel.priceText.text = price
        if (skinType == "good") then
            buy.panel.priceText:setFillColor (0,0.7,0)
            if (myData.settings.goodPoints < price) then cantBuy()
            else canBuy()
            end
        elseif (skinType == "evil") then
            buy.panel.priceText:setFillColor (0.8,0,0)
            if (myData.settings.evilPoints < price) then cantBuy()
            else canBuy()
            end
        end
        return true
    end

    -- torna al menu delle skin
    local function onReturnBtnRelease()  
        backBtn:setEnabled(true)
        -- for i=1, myData.settings.skinNumber do
        --     --skins[i]:setEnabled(true)
        --     if myData.settings.skins[i].unlocked == false then
        --         buyBtns[i]:setEnabled(true)
        --     end
        -- end
        buy.panel:hide()
        return true
    end

    -- effettua l'acquisto: scala i punti buono o cattivo, imposta la skin come acquistata,
    --  rimuove il tasto trasparente e rimette l'alpha del tasto per selezionarla a 1
    -- poi rimuove il pannello
    local function onSkinBuy(event)
        if (skinType == "good") then
            myData.settings.goodPoints = myData.settings.goodPoints - price
            goodText.text = "Good: "..myData.settings.goodPoints
        elseif (skinType == "evil") then
            myData.settings.evilPoints = myData.settings.evilPoints - price
            evilText.text = "Evil: "..myData.settings.evilPoints
            print ("saldo punti cattivi "..myData.settings.evilPoints)
        end
        myData.settings.skins[buttonId].unlocked = true
        print ("Ho sbloccato la skin "..buttonId.."?")
        print (myData.settings.skins[buttonId].unlocked)

        -- SERVICE -------
        service.saveData()
        ------------------

        transpBtn:removeSelf()
        backBtn:setEnabled(true)
        skinBtn.alpha = 1
        buy.panel:hide()
        return true
    end

    -- 
    buy.panel = utility.newPanel{
        location = "custom",
        onComplete = panelTransDone,
        speed = 200,
        x = display.contentCenterX,
        y = display.contentCenterY-500,
        width = 175,--display.contentWidth * 0.30,
        height = 190,--display.contentHeight * 0.45,
        -- speed = 220,
        -- anchorX = 1.0,
        -- anchorY = 0.5,
         inEasing = easing.linear,
         outEasing = easing.outCubic
    }
    buy.panel.background = display.newImageRect( visual.bgMenuBuy, buy.panel.width, buy.panel.height-20 )--display.newRoundedRect( 0, 0, buy.panel.width, buy.panel.height-20, 10 )
    --buy.panel.background:setFillColor( 0.5, 0.28, 0.6)
    buy.panel:insert( buy.panel.background )

    buy.panel.title = display.newText( "Want to buy?", 0, -60, utility.font, 17 )
    buy.panel.title:setFillColor( 1, 0.3, 0.24 )
    buy.panel:insert( buy.panel.title )

    buy.panel.cantBuyText = display.newText( "", 5, -43, utility.font, 15 )
    buy.panel.cantBuyText:setFillColor( 1, 0, 0 )
    buy.panel:insert( buy.panel.cantBuyText )

    buy.panel.priceText = display.newText( "", 0, -25, utility.font, 15 )
    buy.panel.priceText:setFillColor( 1, 1, 1 )
    buy.panel:insert( buy.panel.priceText )

    buy.panel.steve = display.newImageRect(visual.steveMenuSkin, 60, 60)
    buy.panel.steve.x = 45
    buy.panel.steve.y = 35
    buy.panel:insert(buy.panel.steve)


    -- Create the button to exit the options menu
    buy.panel.returnBtn = widget.newButton {
        onRelease = onReturnBtnRelease,
        width = 30,
        height = 30,
        defaultFile = visual.cancelImg,
        }
    buy.panel.returnBtn.x= 30
    buy.panel.returnBtn.y = 10
    buy.panel:insert(buy.panel.returnBtn)

    buy.panel.buyBtn = widget.newButton {
        onRelease = onSkinBuy,
        width = 30,
        height = 30,
        defaultFile = visual.confirmImg,
        }
    buy.panel.buyBtn.x= -30
    buy.panel.buyBtn.y = 10
    buy.panel:insert(buy.panel.buyBtn)

return buy