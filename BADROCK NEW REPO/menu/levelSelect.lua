-----------------------------------------------------------------------------------------
--
-- levelSelect.lua
--
-----------------------------------------------------------------------------------------

local composer = require ( "composer"         )
local widget   = require ( "widget"           )
local myData   = require ( "myData"           )
local utility  = require ( "menu.utilityMenu" )
local skin = require ("menu.skinMenu")

local scene    = composer.newScene()




-- -----------------------------------------------------------------------------------
-- Buttons
-- -----------------------------------------------------------------------------------

	-- Button handler to cancel the level selection and return to the menu
	local function handleCancelButtonEvent( event )
		if ( "ended" == event.phase ) then
			composer.gotoScene( "menu.mainMenu", { effect="fade", time=280 } )
		end
	end

	local function handleSkinsButtonEvent( event )
		if ( "ended" == event.phase ) then
			
			skin.panel:show({
			x = display.contentWidth-12,
			})
		end
	end

	-- Button handler to go to the selected level
	local function handleLevelSelect( event )
		if ( "ended" == event.phase ) then
			myData.settings.currentLevel = event.target.id
			composer.removeScene( "levels.level" .. tostring(event.target.id), false )
			audio.stop()
			-- Go to the game scene
			composer.gotoScene( "levels.level" .. tostring(event.target.id), { effect="crossFade", time=280 } )
		end
	end

	-- Create buttons-----------------------------------------------------------------
		-- Create a cancel button for return to the menu scene.
		local backButton = widget.newButton({
			width = 40,
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
			id = "back",
			label = "B",
			labelColor = { default={1}, over={128} },
			onEvent = handleCancelButtonEvent
		})
		backButton.anchorX = 0
		backButton.anchorY = 0
		backButton.x = display.screenOriginX +10 --contentWidth - 30
		backButton.y = display.screenOriginY +10 --contentHeight - 50

		local skinButton = widget.newButton({
			width = 70,
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
			id = "skins",
			label = "Skins",
			labelColor = { default={1}, over={128} },
			onEvent = handleSkinsButtonEvent
		})

		skinButton.anchorX = 1
		skinButton.anchorY = 0
		skinButton.x = display.contentWidth - 10
		skinButton.y = display.screenOriginY +10 --contentHeight - 50
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- ----------------------------------------------------------------------------------- 

	function scene:create( event )
		local sceneGroup = self.view

		-- Create background
		-- local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
		-- background:setFillColor( 0,44,73 )
		-- background.x = display.contentCenterX
		-- background.y = display.contentCenterY
		
		local background = display.newImageRect( visual.levelSelectBackground, display.actualContentWidth, display.actualContentHeight )
		--local background = display.newImageRect( "misc/LevelBG.png", display.actualContentWidth, display.actualContentHeight )
		background.anchorX = 0
		background.anchorY = 0
		background.x = 0 + display.screenOriginX 
		background.y = 0 + display.screenOriginY

		sceneGroup:insert( background )

		local title = display.newText( "Select a level", display.contentCenterX, display.screenOriginY + 40, "Micolas.ttf", 20 )
		title:setFillColor( 1, 1, 1 )
    	sceneGroup:insert( title )

		-- Use a scrollView to contain the level buttons (for support of more than one full screen).
		-- Since this will only scroll horizontally, lock vertical scrolling.
		local levelSelectGroup = widget.newScrollView({
			width = display.actualContentWidth,--460,
			height = display.actualContentHeight/1.2,--260,
			scrollWidth = display.actualContentWidth,--460,
			scrollHeight = display.actualContentHeight/1.2,--800,
			hideBackground = true,
			verticalScrollDisabled = true
		})

		-- 'xOffset', 'yOffset' and 'cellCount' are used to position the buttons in the grid.
		local xOffset = 0 + display.viewableContentWidth/30--display.screenOriginX + display.viewableContentWidth/20 --64
		local yOffset = display.contentCenterY
		local cellCount = 1

		-- Define the array to hold the buttons
		local buttons = {}

		-- Read 'maxLevels' from the 'myData' table. Loop over them and generating one button for each.
		for i = 1, myData.maxLevels do
			-- Create a button
			buttons[i] = widget.newButton({
				label = tostring( i ),
				id = tostring( i ),
				onRelease = handleLevelSelect,
				emboss = false,
				--shape="roundedRect",
				width = display.viewableContentWidth/3.5,--display.contentWidth - 350,
				height = display.viewableContentWidth/3.5,--display.contentHeight - 200,
				defaultFile = "visual/misc/levelIcon"..tostring( i )..".png",--visual.levelIconBg, --defaultFile = "misc/"..tostring(i).."select.png",
				--overFile= visual.levelIconBg,
				font = native.systemFontBold,
				fontSize = 30,
				labelColor = { default = { 1, 1, 1 }, over = { 0.5, 0.5, 0.5 } },
				--cornerRadius = 8,
				labelYOffset = 0, 
				--fillColor = { default={ 0, 0, 1, 1 }, over={ 0.5, 0.75, 1, 1 } },
				--strokeColor = { default={255,253,48,0.5}, over={0} },
				--strokeWidth = 2
			})
			-- Position the button in the grid and add it to the scrollView
			buttons[i].anchorX = 0
			buttons[i].anchorY = 0.8
			buttons[i].x = xOffset
			buttons[i].y = yOffset
			levelSelectGroup:insert( buttons[i] )

			-- Check to see if the player has achieved (completed) this level.
			-- The '.unlockedLevels' value tracks the maximum unlocked level.
			-- First, however, check to make sure that this value has been set.
			-- If not set (new user), this value should be 1.

			-- If the level is locked, disable the button and fade it out.
			if ( myData.settings.unlockedLevels == nil ) then
				myData.settings.unlockedLevels = 1
			end
			if ( i <= myData.settings.unlockedLevels ) then
				buttons[i]:setEnabled( true )
				buttons[i].alpha = 1.0
			else 
				buttons[i]:setEnabled( false ) 
				buttons[i].alpha = 0.5 
			end 

			-- Generate the star and position it relative to the button it goes with.
			local star = {}
			if myData.settings.levels[i] and myData.settings.levels[i].stars then --and myData.settings.levels[i].stars > 0 then
					for j = 1, 3 do --myData.settings.levels[i].stars do
						star[j] = display.newImageRect(visual.levelSelectStar , buttons[i].width/6, buttons[i].width/5.97)--display.newPolygon( 0, 0, starVertices )
						if j>myData.settings.levels[i].stars then
							star[j].alpha = 0.2
						end
						star[j].x = buttons[i].x + (j * buttons[i].width/5) + buttons[i].width/10
						star[j].y = buttons[i].y + buttons[i].height/3.5
						levelSelectGroup:insert(star[j])
					end
			end
			-- Compute the position of the next button.
			-- This tutorial draws 5 buttons across.
			-- It also spaces based on the button width and height + initial offset from the left.
			xOffset = xOffset + buttons[i].width*1.2--+20
			cellCount = cellCount + 1
			-- if ( cellCount > 5 ) then --righe da 5 ognuna
			--     cellCount = 1
			--     xOffset = 64
			--     yOffset = yOffset + 45
			-- end
		end

		-- Place the scrollView into the scene and center it.
		sceneGroup:insert( levelSelectGroup )
		levelSelectGroup.x = display.contentCenterX 
		levelSelectGroup.y = display.contentCenterY + 20


		sceneGroup:insert( backButton )
		sceneGroup:insert( skinButton )
	end

	-- On scene show...
	function scene:show( event )
		local sceneGroup = self.view
		if ( event.phase == "did" ) then
		end
	end

	function scene:hide( event )
		local sceneGroup = self.view
		if ( event.phase == "will" ) then
		end
	end

	function scene:destroy( event )
		local sceneGroup = self.view   
	end

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTION LISTENERS
-- -----------------------------------------------------------------------------------
	scene:addEventListener( "create", scene )
	scene:addEventListener( "show", scene )
	scene:addEventListener( "hide", scene )
	scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene