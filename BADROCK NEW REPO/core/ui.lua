-----------------------------------------------------------------------------------------
--
-- newUi.lua
--
-- Here are declared all the visual aspects regarding the game's UI buttons.
-- This module is tied to the controller which is the only class that uses it, while
-- additional functions provide easy shortcuts for toggling the enablement for the whole ui.
-----------------------------------------------------------------------------------------
local widget  = require ( "widget"           )
local utility = require ( "menu.utilityMenu" )

local ui = {
	buttons = {},
	buttonGroup = {}
}

-- Stores the data tables for the -widget.newButton- calls.
local buttonData = {
	-- Touchable area (invisible button)
		--1
		jumpScreen = {
			options = {
				id = "jumpScreen",
				width = 10000,
				height = 10000,
			},
		},

	-- Touchable buttons
		--2
		dpadLeft = {
			options = {
				id = "dpadLeft",
				defaultFile = visual.dpadLeft,
				overFile = visual.dpadLeft_over,
				width = 64,
				height = 64,
				x = 10,
				y = display.contentHeight - 10,
			},
			aX = 0,
			aY = 1,
		},
		--3
		dpadRight = {
			options = {
				id = "dpadRight",
				defaultFile = visual.dpadRight,
				overFile = visual.dpadRight_over,
				width = 64,
				height = 64,
				x = 74,
				y = display.contentHeight - 10,
			},
			aX = 0,
			aY = 1,
		},
		--4
		actionBtn = {
			options = {
				id = "actionBtn",
				defaultFile = visual.actionBtn,
				overFile = visual.actionBtn_over,
				width = 64,
				height = 64,
				x = display.contentWidth - 10,
				y = display.contentHeight - 7
			},
			aX = 1,
			aY = 1,
		},
		--5
		pauseBtn = {
			options = {
				id = "pauseBtn",
				defaultFile = visual.pauseBtnDefault,
				overFile = visual.pauseBtnOver,
				width = 50,
				height = 47,
				x = display.contentWidth -8,
				y = 18,
			},
			aX = 1,
			aY = 0,
		},
		--6
		resumeBtn = {
			options = {
				id = "resumeBtn",
				defaultFile = visual.resumeBtnDefault,
				overFile = visual.resumeBtnOver,
				width = 50,
				height = 47,
				x = display.contentWidth - 8,
				y = 18,
			},
			aX = 1,
			aY = 0,
		},

	-- Untouchable text-only buttons
		--7
	 	scoreText = {
			options = {
				id = "scoreText",
				textOnly = true,
				label = "Score: 0",
				font = utility.font,
				fontSize = 30,
				labelColor = {
					default = { 0,220,255 },
					over = { 0,220,255 },
				},
				x = display.contentWidth - 80,
				y = 18,
			},
			aX = 1,
			aY = 0,
		},
		--8
		scoreUpText = {
			options = {
				id = "scoreUpText",
				textOnly = true,
				label = "",
				font = utility.font,
				fontSize = 14,
				labelColor = {
					default = { 0,210,255 },
					over = { 0,210,255 },
				},
				x = display.contentWidth - 80,
				y = 50,
			},
			aX = 0.5,
			aY = 0.5,
		},
		--9
		livesText = {
			options = {
				id = "livesText",
				textOnly = true,
				label = "",
				font = utility.font,
				fontSize = 14,
				labelColor = {
					default = { 255,210,0 },
					over = { 255,210,0 },
				},
				x = display.contentWidth - 80,
				y = 60,
			},
			aX = 0,
			aY = 0,
		},
		--10
		lifeUpText = {
			options = {
				id = "lifeUpText",
				textOnly = true,
				label = "",
				font = utility.font,
				fontSize = 20,
				labelColor = {
					default = { 0,210,255 },
					over = { 0,210,255 },
				},
				x = 80,
				y = 60,
			},
			aX = 0.5,
			aY = 0.5,
		},
		--11
		specialUpText = {
			options = {
				id = "specialUpText",
				textOnly = true,
				label = "",
				font = utility.font,
				fontSize = 35,
				labelColor = {
					default = { 255,255,255 },
					over = { 255,255,255 },
				},
				x = 0,
				y = 0,
			},
			aX = 0.5,
			aY = 0.5,
		},
}


-- LIVES ------------------------------------------------------------------------
-- [This section will be likely modified in the future, we will decide next meet 
-- if it's worth keeping an icon for every life or a simpler single-icon counter].
	ui.lifeIcons = {}
	

	local function createLifeIconAt( index )
		local	lifeIcon = display.newImageRect(ui.buttonGroup, visual.lifeIcon, 30, 30 )
		lifeIcon.anchorX, lifeIcon.anchorY = 0, 0
		lifeIcon.x = 10 + (lifeIcon.contentWidth * (index - 1))
		lifeIcon.y = 10 + lifeIcon.contentHeight / 2
		lifeIcon.isVisible = true
		table.insert(ui.lifeIcons,lifeIcon)
	end

	-- Creates the lifeIcon array initialized to the current game's max lives allowed.
	function ui.createLifeIcons( maxLivesNumber )
		for i = 1, maxLivesNumber do
			createLifeIconAt( i )
		end
	end

	-- Updates the lifeIcon array, either if a life is added or removed
	function ui.updateLifeIcons( currentLivesNumber )
		for i, v in pairs(ui.lifeIcons) do
			if (i > currentLivesNumber) then
				display.remove(v)
				ui.lifeIcons[i] = nil
				print ("Steve lost one life. Total lives: "..#ui.lifeIcons)
			end
		end
		if (currentLivesNumber - #ui.lifeIcons == 1) then
			createLifeIconAt(currentLivesNumber)
			print ("Steve gained one life. Current lives: "..#ui.lifeIcons)
		end
	end

	-- Empties the lifeIcon array
	function ui.emptyLifeIcons()
		--print("Before: ".. #ui.lifeIcons)
		for i in pairs (ui.lifeIcons) do
			ui.lifeIcons[i] = nil
		end
		--print("After: ".. #ui.lifeIcons)
	end

	function ui.destroyLifeIcons()
		for i in pairs (ui.lifeIcons) do
			display.remove(ui.lifeIcons[i])
		end
	end

	--bossLives
	ui.bossLife = {}
	
	local function createBossLifeAt( index )
		local	bossLife = display.newImageRect(ui.buttonGroup, visual.bossLifeIcon, 30, 30 )
		bossLife.anchorX, bossLife.anchorY = 0, 0
		bossLife.x = 10 + (bossLife.contentWidth * (index - 1))
		bossLife.y = -15 + bossLife.contentHeight / 2
		bossLife.isVisible = true
		table.insert(ui.bossLife,bossLife)
	end

	-- Creates the bossLife array initialized to the current game's max lives allowed.
	function ui.createBossLife( maxLivesNumber )
		for i = 1, maxLivesNumber do
			createBossLifeAt( i )
		end
	end

	-- Updates the bossLife array, either if a life is added or removed
	function ui.updateBossLife( currentLivesNumber )
		for i, v in pairs(ui.bossLife) do
			if (i > currentLivesNumber) then
				display.remove(v)
				ui.bossLife[i] = nil
				print ("Boss lost one life. Total lives: "..#ui.bossLife)
			end
		end
		
	end

	-- Empties the bossLife array
	function ui.emptyBossLife()
		for i in pairs (ui.bossLife) do
			ui.bossLife[i] = nil
		end
	end

	function ui.destroyBossLife()
		for i in pairs (ui.bossLife) do
			display.remove(ui.bossLife[i])
		end
	end
---------------------------------------------------------------------------------

-- AMMO -------------------------------------------------------------------------
	ui.ammunitions = {}

	local function createAmmoIconAt( index )
		local	ammo = display.newImageRect(ui.buttonGroup, visual.bullet, 23,10 )
		ammo.rotation = -90
		ammo.anchorX, ammo.anchorY = 1, 1
		ammo.x = ui.buttons.action.x - ui.buttons.action.contentWidth - (ammo.contentWidth  * (index - 1))
		ammo.y = ui.buttons.action.y - ui.buttons.action.contentHeight/2 -  ammo.contentHeight / 2
		ammo.isVisible = true
		table.insert(ui.ammunitions, ammo)
	end

	-- Creates the Ammunitions array initialized the powerup's ammo number.
	function ui.createAmmoIcons( maxAmmoNumber )
		for i = 1, maxAmmoNumber do
			createAmmoIconAt( i )
		end
	end

	-- Updates the Ammunitions array, either if ammo is added or removed
	function ui.updateAmmoIcons( currentAmmoNumber )
		for i, v in pairs(ui.ammunitions) do
			if (i > currentAmmoNumber) then
				display.remove(v)
				ui.ammunitions[i] = nil
				-- print ("Ammo reduced by 1. Remaining "..#ui.ammunitions)
			end
		end
		-- if (currentAmmoNumber - #ui.ammunitions == 1) then
		-- 	createAmmoIconAt(currentAmmoNumber)
		-- 	print ("Ammo increaded by 1. Remaining "..#ui.ammunitions)
		-- end
	end

	-- Empties the Ammunitions array
	function ui.emptyAmmoIcons()
		--print("Before: ".. #ui.ammunitions)
		for i in pairs (ui.ammunitions) do
			ui.ammunitions[i] = nil
		end
		--print("After: ".. #ui.ammunitions)
	end

	function ui.destroyAmmoIcons()
		for i in pairs (ui.ammunitions) do
			display.remove(ui.ammunitions[i])
		end
	end
---------------------------------------------------------------------------------


-- Contains all the calls to -widget.newButton- and adds selected buttons to the UI Group.
local function createButtons()
	local buttonGroup = display.newGroup()

	local jumpScreen    = widget.newButton ( buttonData.jumpScreen.options    )
		jumpScreen:setFillColor( 0, 255, 0 )
		jumpScreen.isVisible = false
		jumpScreen.isHitTestable = true
		-- buttonGroup:insert( jumpScreen )		-- NO!

	local dpadLeft      = widget.newButton ( buttonData.dpadLeft.options      )
		dpadLeft.anchorX, dpadLeft.anchorY = buttonData.dpadLeft.aX, buttonData.dpadLeft.aY
		buttonGroup:insert( dpadLeft )

	local dpadRight     = widget.newButton ( buttonData.dpadRight.options     )
		dpadRight.anchorX, dpadRight.anchorY = buttonData.dpadRight.aX, buttonData.dpadRight.aY
		buttonGroup:insert( dpadRight )

	local actionBtn     = widget.newButton ( buttonData.actionBtn.options     )
		actionBtn.anchorX, actionBtn.anchorY = buttonData.actionBtn.aX, buttonData.actionBtn.aY
		buttonGroup:insert( actionBtn )

	local pauseBtn      = widget.newButton ( buttonData.pauseBtn.options      )
		pauseBtn.anchorX, pauseBtn.anchorY = buttonData.pauseBtn.aX, buttonData.pauseBtn.aY
		buttonGroup:insert( pauseBtn )

	local resumeBtn     = widget.newButton ( buttonData.resumeBtn.options     )
		resumeBtn.anchorX, resumeBtn.anchorY = buttonData.resumeBtn.aX, buttonData.resumeBtn.aY
		buttonGroup:insert( resumeBtn )

	local scoreText     = widget.newButton ( buttonData.scoreText.options     )
		scoreText.anchorX, scoreText.anchorY = buttonData.scoreText.aX, buttonData.scoreText.aY
		buttonGroup:insert( scoreText )

	local scoreUpText   = widget.newButton ( buttonData.scoreUpText.options   )
		scoreUpText.anchorX, scoreUpText.anchorY = buttonData.scoreUpText.aX, buttonData.scoreUpText.aY
		buttonGroup:insert( scoreUpText )

	local livesText     = widget.newButton ( buttonData.livesText.options     )
		livesText.anchorX, livesText.anchorY = buttonData.livesText.aX, buttonData.livesText.aY
		buttonGroup:insert( livesText )

	local lifeUpText    = widget.newButton ( buttonData.lifeUpText.options    )
		lifeUpText.anchorX, lifeUpText.anchorY = buttonData.lifeUpText.aX, buttonData.lifeUpText.aY
		buttonGroup:insert( lifeUpText )

	local specialUpText = widget.newButton ( buttonData.specialUpText.options )
		specialUpText.anchorX, specialUpText.anchorY = buttonData.specialUpText.aX, buttonData.specialUpText.aY
		--buttonGroup:insert( specialUpText )

	local buttons = {
		jump = jumpScreen,
		dleft = dpadLeft,
		dright = dpadRight,
		action = actionBtn,
		pause = pauseBtn,
		resume = resumeBtn,
		---------------------
		score = scoreText,
		scoreUp = scoreUpText,
		lives = livesText,
		lifeUp = lifeUpText,
		specialUp = specialUpText
	}

	buttonGroup:toFront()
	return buttons, buttonGroup
end

-- This function is called by the controller.
-- (Important: THIS causes the UI to appear on the screen!)
-- The only exception is the jumpScreen, which has to be manually istantiated on the map.
function ui.loadUI()
	-- Buttons refers to the WHOLE UI (including jumpScreen), use it for drastical changes
	-- ButtonGroup refers to every button that goes BEFORE the map.
	ui.buttons, ui.buttonGroup = createButtons()
end

-- Shortcut which allows to toggle enablement to the whole UI
function ui:setEnabled( boolean )
	for i in pairs (ui.buttons) do
		ui.buttons[i]:setEnabled( boolean )
		-- ui.buttons[i].isEnabled = boolean
	end
end

-- Animates one of the three <x>UpTexts
function ui.textFade( textWidget, duration )	
	transition.to( textWidget, { 
		alpha = 0,
		time = duration,
		effect = "crossfade", 
		onComplete = function() 
			textWidget.isVisible = false
			textWidget.alpha = 1
		end
	})
end

-- Called when a powerup is picked: this modifies the appearence of the action button 
-- to indicate a different action depending on the powerup.
function ui.updateActionButton(imageName)
	ui.buttons.action:removeSelf()

	local actionBtn = widget.newButton{
		id = buttonData.actionBtn.options.id,
		defaultFile = visual["actionBtn_"..tostring(imageName)],
		overFile = visual["actionBtn_"..tostring(imageName).."_over"],
		width = buttonData.actionBtn.options.width,
		height = buttonData.actionBtn.options.height,
		x = buttonData.actionBtn.options.x,
		y = buttonData.actionBtn.options.y,
	}
	actionBtn.anchorX, actionBtn.anchorY = buttonData.actionBtn.aX, buttonData.actionBtn.aY

	ui.buttonGroup:insert( actionBtn )
	ui.buttons.action = actionBtn
end

-- Restores the action button to the default attack
function ui.restoreActionButton()
	ui.buttons.action:removeSelf()
	local actionBtn = widget.newButton(buttonData.actionBtn.options)
	actionBtn.anchorX, actionBtn.anchorY = buttonData.actionBtn.aX, buttonData.actionBtn.aY
	ui.buttonGroup:insert( actionBtn )
	ui.buttons.action = actionBtn
end

return ui