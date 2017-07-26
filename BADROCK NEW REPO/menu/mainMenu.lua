-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-- Cose da fare:ss
-- se premo da qualche parte che non è il panel menu, non funziona oppure esce dal menu 
-- (scegliere tra le due)
-- quando si torna dalla partita al menu, la musica di fondo rimane quella della partita, 
-- rimediare in qualche modo
-----------------------------------------------------------------------------------------

local composer = require ( "composer"         )
local widget   = require ( "widget"           )
local utility  = require ( "menu.utilityMenu" )
local genMenu  = require ( "menu.generalMenu" )
local sfx      = require ( "audio.sfx"        )
-- local myData = require( "myData" ) 

local scene = composer.newScene()

-- forward declarations and other locals
local playBtn, optionBtn

-- Menu Buttons ----------------------------------------------------------------------

	local function onPlayBtnRelease(event)
		--go to levelSelect.lua scene
		if event.phase == "began" then
		utility.pressButton()
		end
		if event.phase == "ended" then
		genMenu.panel:hide({
			speed = 250,
			transition = easing.outElastic
		})
		composer.removeScene( "menu.levelSelect" )
		composer.gotoScene( "menu.levelSelect", "fade", 280 )
	end
		return true
	end

	local function onOptionBtnRelease()
		-- open options panel
		genMenu.passVariables(optionBtn, playBtn)
		optionBtn:setEnabled(false)
		playBtn:setEnabled(false)
		genMenu.panel:show({
			y = display.actualContentHeight - 30,})
		return true
	end

	-- Create the buttons --------------------------------------------------------------   
		-- Option button (clockwork in the upper-right corner)
		optionBtn = widget.newButton
			{
				id = "optionBtn",
				onRelease = onOptionBtnRelease,
				width = 43,
				height = 40,
				defaultFile = visual.optionButtonDefault,
				overFile = visual.optionButtonOver,
			}
			optionBtn.anchorX = 0
			optionBtn.anchorY = 0
			optionBtn.x =  display.screenOriginX + 3 
			optionBtn.y = display.screenOriginY + 3 

		-- Play button (go to level select)
		playBtn = widget.newButton 
			{
				width = 135,
				height = 38,
				defaultFile = visual.menuButtonDefault,
				overFile = visual.menuButtonOver,

				label = "Play",
				font = utility.font,
				fontSize = 20,
				labelColor = { default={1}, over={128} },
				onEvent = onPlayBtnRelease
				--onPress = onPlayBtnPress,
				--onRelease = onPlayBtnRelease    
			}
			playBtn.anchorX = 0.5
			playBtn.anchorY = 0.5
			playBtn.x =  display.contentCenterX --display.screenOriginX -20 
			playBtn.y = display.contentHeight - 40 --90


	-- -------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------
	-- create()
	function scene:create( event )
		local sceneGroup = self.view
		-- backgroundMusic = audio.loadStream( "audio/Undertale - Bonetrousle.mp3" )     -- AUDIO (ovviamente cambiare il brano)     
		-- Load the background
		local background = display.newImageRect (visual.menuBackground, display.actualContentWidth, display.actualContentHeight )
		background.anchorX = 0
		background.anchorY = 0
		background.x = 0 + display.screenOriginX 
		background.y = 0 + display.screenOriginY

		-- Load the logo
		local titleLogo = display.newImageRect( visual.titleLogo, 343, 123 )
		titleLogo.x = display.contentCenterX
		titleLogo.y = 70

		-- Load menuSteveImage 																	!!!!!!!!!!!
		local steveImage = display.newImageRect( visual.menuSteveImage, display.actualContentWidth/4.4, display.actualContentWidth/4.3)--115, 113)
		steveImage.x = display.contentCenterX
		steveImage.y = display.contentCenterY +10
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

		-- all display objects must be inserted into group
		sceneGroup:insert( background )
		sceneGroup:insert( titleLogo )
		sceneGroup:insert( playBtn )
		sceneGroup:insert( optionBtn )
		sceneGroup:insert( steveImage )
		
	end


	-- show()
	function scene:show( event )
		local sceneGroup = self.view
		local phase = event.phase
		--audio.play(backgroundMusic, {channel = 1 , loops=-1})
		if ( phase == "will" ) then
			if not audio.isChannelActive( 1 ) then
			sfx.playMusic(sfx.bgMenuMusic, {channel = 1 , loops=-1} )
			end
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
		audio.dispose()
		playBtn:removeSelf()    -- widgets must be manually removed
		playBtn = nil
		optionBtn:removeSelf()
		optionBtn = nil

		-----------------------------------------------------------------------------
		-- The reason to prefer the latter here is because, while having the the same
		-- outcome, display.remove() tries to remove the object if it isn't nil, while
		-- object:removeSelf() can throw an error if the object doesn't exist.
		--steveImage:removeSelf()
		display.remove(steveImage)
		------------------------------------------------------------------------------
	end

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTION LISTENERS
-- -----------------------------------------------------------------------------------
	scene:addEventListener( "create", scene )
	scene:addEventListener( "show", scene )
	scene:addEventListener( "hide", scene )
	scene:addEventListener( "destroy", scene )


return scene