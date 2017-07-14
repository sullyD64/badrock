local widget    = require ( "widget"           )
-- local myData    = require ( "defaultData"           )
local utility   = require ( "menu.utilityMenu" )
local buy       = require ( "menu.buyMenu"     )
local sfx      = require ( "audio.sfx"        )

local skinBtn
local backBtn
local btns
local skin = {}
	
	function skin.setToEnableButtons(skinButton, backButton, buttons)
		skinBtn = skinButton
		backBtn = backButton
		btns = buttons
	end

	local function onReturnBtnRelease()  
		skin.panel:hide()
		skin.pointsPanel:hide()
		skinBtn:setEnabled(true)
		backBtn:setEnabled(true)
		for i=1, myData.maxLevels do
			btns[i]:setEnabled(true)
		end
		return true
	end

	-- Risponde al tocco di una delle skin, la seleziona se è sbloccata,
	-- richiama la finestra di acquisto se non è sbloccata
	local function onSkinSelect(event)
		idSkin=tonumber(event.target.id)
		if (event.target.isOn) then
			if (myData.settings.skins[idSkin].unlocked == true) then
				audio.stop(9)
				sfx.playSound( sfx.clickSound, { channel = 9 } )
				myData.settings.selectedSkin = idSkin   
				-- SERVICE -------
				service.saveData()
				------------------
				print ("Selezionata skin "..myData.settings.selectedSkin)      
			end 
		end
		if (myData.settings.skins[idSkin].unlocked == false) then
				buy.setSkin(idSkin, skin.panel.buyButtons[idSkin], skin.panel.skins[idSkin] ) 
				buy.setToEnableButtons( skin.panel.returnBtn, skin.panel.skins,skin.panel.buyButtons, skin.pointsPanel.goodPointsText, skin.pointsPanel.evilPointsText  )
				skin.panel.returnBtn:setEnabled(false)
					-- for i=1, myData.settings.skinNumber do
					--     --skin.panel.skins[i]:setEnabled(false)
					--     if myData.settings.skins[i].unlocked == false then
					--        print (i)
					--        print ("controllo")
					--        print(myData.settings.skins[i].unlocked)
					--        print (skin.panel.buyButtons[i].id)
					--        skin.panel.buyButtons[i]:setEnabled(false)
					--     end
					-- end
				buy.panel:show({
				y = display.contentCenterY})
				print ("Aperto pannello per skin "..idSkin)
		end      
		return true
	end


	skin.panel = utility.newPanel{
		location = "custom",
		onComplete = panelTransDone,
		width = display.contentWidth * 0.95,
		height =display.contentHeight * 0.70,
		speed = 220,
		anchorX = 1.0,
		anchorY = 0.5,
		--x = display.screenOriginX, --attivando questo entra da sinistra
		x =  display.contentWidth * 2,
		y = display.contentCenterY +35 ,
		inEasing = easing.linear,
		outEasing = easing.outCubic
	}
	--skin.panel.backgroundprova = display.newRoundedRect(0,0, skin.panel.width, skin.panel.height, 10)---20)--display.newRoundedRect( 0, 0, skin.panel.width, skin.panel.height-20, 10 )
	--skin.panel.backgroundprova:setFillColor( 0.5, 0.28, 0.6)--0, 0.25, 0.5 )
	--skin.panel:insert( skin.panel.backgroundprova )

	skin.panel.background = display.newImageRect(visual.bgMenuSkin, skin.panel.width, skin.panel.height-40)---20)--display.newRoundedRect( 0, 0, skin.panel.width, skin.panel.height-20, 10 )
	skin.panel.background.y= -10
	--skin.panel.background:setFillColor( 0.5, 0.28, 0.6)--0, 0.25, 0.5 )
	skin.panel:insert( skin.panel.background )

	skin.panel.title = display.newText( "Wardrobe", 0, -100, utility.font, 20 ) ---70,  utility.font, 15 )
	skin.panel.title:setFillColor( 1, 1, 1 )
	skin.panel:insert( skin.panel.title )

	skin.panel.steve = display.newImageRect(visual.steveMenuSkin, 80, 80)
	skin.panel.steve.x = 210
	skin.panel.steve.y = 30
	skin.panel:insert(skin.panel.steve)

	-- Create the button to exit the skin menu
	skin.panel.returnBtn = widget.newButton {
		onRelease = onReturnBtnRelease,
		width = 30,
		height = 30,
		defaultFile = visual.exitOptionMenu,
		}
	skin.panel.returnBtn.x= 240
	skin.panel.returnBtn.y = -95
	skin.panel:insert(skin.panel.returnBtn)

	skin.panel.skinGroup = widget.newScrollView({
		width = skin.panel.width-50,
		height = skin.panel.height-50,
		scrollWidth = skin.panel.width,
		scrollHeight = skin.panel.height,
		hideBackground = true,
		verticalScrollDisabled = true,
		x=display.screenOriginX,
		y=0
	})

	local xOffset = 0
	local yOffset = display.screenOriginX + 10
	local checkboxOptions = {
		width = 190,
		height = 168,
		numFrames = 2,
		sheetContentWidth = 380,
		sheetContentHeight = 168
	}

	-- Define the array to hold the buttons
	skin.panel.skins = {}
	skin.panel.buyButtons = {}

	-- Read the nuber of skins from the 'myData' table. Loop over them and generating one button for each.   
	for i, skinC in pairs(myData.settings.skins) do 
	--for i = 1, myData.settings.skinNumber do

		checkboxSheet = graphics.newImageSheet( "visual/misc/sheetskin"..tostring( i )..".png", checkboxOptions )

		skin.panel.skins[i] = widget.newSwitch({  
			sheet = checkboxSheet,
			frameOff = 1,
			frameOn = 2,
			style = "radio",
			id = tostring(i),
			onPress = onSkinSelect,
			width = skin.panel.width/4.35,--display.contentWidth - 350,
			height = skin.panel.height*0.55,---60,--display.contentHeight - 200,
			--initialSwitchState = 
		})

		-- Position the button in the grid and add it to the scrollView
		skin.panel.skins[i].anchorX = 0
		skin.panel.skins[i].anchorY = 0
		skin.panel.skins[i].x = xOffset
		skin.panel.skins[i].y = yOffset
		skin.panel.skinGroup:insert( skin.panel.skins[i] )
		
		-- If the skin is locked, create a new transparent button and fade the other out.      
		if ( myData.settings.skins[i].unlocked==false ) then
			skin.panel.buyButtons[i] = widget.newButton({
				id = tostring( i ),
				onRelease = onSkinSelect,
				width = skin.panel.skins[i].width,
				height = skin.panel.skins[i].height,
				defaultFile = "visual/misc/transparent.png",            
			})  

			skin.panel.skins[i].alpha = 0.5
			skin.panel.buyButtons[i].anchorX = 0
			skin.panel.buyButtons[i].anchorY = 0
			skin.panel.buyButtons[i].x = xOffset
			skin.panel.buyButtons[i].y = yOffset
			skin.panel.skinGroup:insert( skin.panel.buyButtons[i] )
		end
		
		xOffset = xOffset + skin.panel.skins[i].width*1.2--+20
	end


	skin.panel.skins[myData.settings.selectedSkin]:setState({isOn=true})
	skin.panel:insert( skin.panel.skinGroup )

	skin.panel.freccia = display.newImageRect(visual.frecciaSkin, 190, 70)
	--skin.panel.freccia.x 
	skin.panel.freccia.y = 65
	skin.panel:insert(skin.panel.freccia)



	skin.group = display.newGroup()
	skin.group:insert(skin.panel)
	skin.group:insert(buy.panel)
	assert(skin.group[1] == skin.panel) -- bottom
	assert(skin.group[2] == buy.panel) -- front




	skin.pointsPanel = utility.newPanel{
		location = "custom",
		onComplete = panelTransDone,
		width = 100,
		height = 100,
		speed = 220,
		anchorX = 0,
		anchorY = 0,
		x =  display.contentWidth + 300,
		y = display.screenOriginY + 5 ,
		inEasing = easing.linear,
		outEasing = easing.outCubic
	}	
	--skin.pointsPanel.background = display.newRoundedRect( 0, 0, skin.pointsPanel.width, skin.pointsPanel.height, 10 )
	--skin.pointsPanel.background:setFillColor( 0,0,0)
	--skin.pointsPanel:insert( skin.pointsPanel.background )

	skin.pointsPanel.title = display.newText( "Points", -20, -35,  utility.font, 15 )
	skin.pointsPanel.title:setFillColor( 1, 1, 1 )
	skin.pointsPanel:insert(skin.pointsPanel.title)

	skin.pointsPanel.goodPointsText = display.newText( "Good: "..myData.settings.goodPoints, -18, -20,  utility.font, 15 )
	skin.pointsPanel.goodPointsText:setFillColor(0, 0.7, 0)
	skin.pointsPanel:insert(skin.pointsPanel.goodPointsText)

	skin.pointsPanel.evilPointsText = display.newText( "Evil: "..myData.settings.evilPoints, -18, -5,  utility.font, 15 )
	skin.pointsPanel.evilPointsText:setFillColor( 0.8,0,0 )
	skin.pointsPanel:insert(skin.pointsPanel.evilPointsText)


return skin