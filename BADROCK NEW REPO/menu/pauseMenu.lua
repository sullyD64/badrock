-----------------------------------------------------------------------------------------
--
-- pauseMenu.lua
--
-----------------------------------------------------------------------------------------
--local composer = require ( "composer"       )
local widget   = require ( "widget"           )
local sfxMenu  = require ( "menu.sfxMenu"     )
local utility  = require ( "menu.utilityMenu" )
-- local myData   = require ( "myData" )

local pause = {}
-- pause.psbutton = nil
-- pause.rsbutton = nil

------------------------------------------------
-- This is required for triggering a change in
-- game's state (see onMenuBtnRelease)
local game = {}
local stateList = {}

function pause.setGame( currentGame, gameStates)
	game = currentGame
	stateList = gameStates
end


-------------------------------------------------

-- PAUSE MENU ---------------------------------------------------------------------
	local function onSoundMenuBtnRelease()  
		--transition.fadeOut( pause.panel, { time=100 } )
		sfxMenu.panel:show({
			 y = display.actualContentHeight - 30,--y = display.screenOriginY+225,
			 time =250})
		return true
	end

	-- Return to the main Menu
	local function onMenuBtnRelease()  
		pause.panel:hide({
			speed = 250,
			transition = easing.outElastic
		})
		-- pause.psbutton.isVisible = true
		-- pause.rsbutton.isVisible = false
		audio.fadeOut(1,100)
		audio.stop(1)
		-- --------------------------------------------------------------------
		-- Instead of directly triggering composer from here (which is known
		-- to cause problems destroying the game's packages), pauseMenu simply
		-- changes the current game's state to "Terminated", so that core/game
		-- itself can invoke the controller to "shut down" the game.
		-- (see game -> onUpdate and controller -> onGameOver)
			game.state = stateList.TERMINATED
		-- composer.gotoScene( "menu.mainMenu", { effect="fade", time=280 } )
		--------------------------------------------------------------------
		return true
	end

	-- Try again the same level
	local function onRetryBtnRelease()  
		pause.panel:hide({
			speed = 250,
			transition = easing.outElastic
		})
		audio.fadeOut(1,100)
		audio.stop(1)

		-- cambiare il game state per andare di nuovo al livello
		game.nextScene = "level"..myData.settings.currentLevel
		game.state = stateList.TERMINATED
		return true
	end

	-- Create the pause panel
	pause.panel = utility.newPanel{
			location = "custom",
			onComplete = panelTransDone,
			width = 250,--display.contentWidth * 0.35,
			height = 260,--display.contentHeight * 0.65,
			speed = 250,
			anchorX = 0.5,
			anchorY = 1.0,
			x = display.contentCenterX,
			y = display.screenOriginY,
			inEasing = easing.outBack,
			outEasing = easing.outCubic
			}
			pause.panel.background = display.newImageRect(visual.panel,pause.panel.width, pause.panel.height-20)
			pause.panel:insert( pause.panel.background )
			
			pause.panel.title = display.newText( "Pause", 5, -93, utility.font, 20 )
			pause.panel.title:setFillColor( 0, 0, 0 )
			pause.panel:insert( pause.panel.title )			 
			pause.panel.title = display.newText( "Pause", 5, -93, utility.font, 21 )
			pause.panel.title:setFillColor( 1, 1, 1 )
			pause.panel:insert( pause.panel.title )

	-- Create the buttons ------------------------------------------------------------

		pause.panel.soundMenuBtn = widget.newButton {
			width = 45,
			height = 42,
			onRelease = onSoundMenuBtnRelease,		
			defaultFile = visual.audioSettingsImg,	
			}
			pause.panel.soundMenuBtn.x= 53---47
			pause.panel.soundMenuBtn.y = -20--pause.panel.contentCenterY
			pause.panel:insert(pause.panel.soundMenuBtn)

		-- Create the return to menu button
		pause.panel.menuBtn = widget.newButton {
			onRelease = onMenuBtnRelease,
			defaultFile = visual.backToMenuImg,
			width = 45,--40,
			height = 42,--38,
			}
			pause.panel.menuBtn.x= -53--47
			pause.panel.menuBtn.y = -20--pause.panel.contentCenterY
			pause.panel:insert(pause.panel.menuBtn)


		pause.panel.retryBtn = widget.newButton {
			onRelease = onRetryBtnRelease,
			defaultFile = visual.retryImg,
			width = 45,
			height = 42,
			}
			pause.panel.retryBtn.x= 0
			pause.panel.retryBtn.y = -20 --pause.panel.contentCenterY
			pause.panel:insert(pause.panel.retryBtn)
	-- -------------------------------------------------------------------------------

	pause.group = display.newGroup()
	pause.group:insert(pause.panel)
	pause.group:insert(sfxMenu.panel)
	assert(pause.group[1] == pause.panel) -- do1 is on the bottom
	assert(pause.group[2] == sfxMenu.panel) -- do2 is on the top (front)

-- ---------------------------------------------------------------------------------

return pause