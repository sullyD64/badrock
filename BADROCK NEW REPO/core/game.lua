-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local composer   = require ( "composer"         )
local physics    = require ( "physics"          )
local math       = require ( "math"             )
local widget     = require ( "widget"           )
local utility    = require ( "menu.utilityMenu" )
local panel      = require ( "lib.panel"        )
local ui         = require ( "core.ui"          )
local collisions = require ( "core.collisions"  )
local enemies    = require ( "core.enemies"     )
local items      = require ( "core.items"       )
local position   = require ( "lib.position"     )

local game = {}

physics.start()
physics.setGravity( 0, 50 )

--===========================================-- 

	game.GAME_RUNNING          = "Running"
	game.GAME_PAUSED           = "Paused"
	game.GAME_RESUMED          = "Resumed"
	game.GAME_ENDED            = "Ended"
	game.STEVE_STATE_IDLE      = "Idle"
	game.STEVE_STATE_WALKING   = "Walking"
	game.STEVE_STATE_JUMPING   = "Jumping"
	game.STEVE_STATE_ATTACKING = "Attacking"
	game.STEVE_STATE_DIED      = "Died"
	game.DIRECTION_LEFT        = -1
	game.DIRECTION_RIGHT       =  1
	game.MAX_LIVES             =  3

	game.letMeJump = false
	game.SSVEnabled = true
	game.controlsEnabled = true
	game.levelCompleted = false
	local spawnX, spawnY
	local SSVLaunched, SSVType

--===========================================-- 

-- RUNTIME FUNCTIONS ---------------------------------------------------------------
	-- The only purpose of this is for text debugging on the console, do not add anything else.
	local function debug(event)
		--print("Steve Coordinates (x=" .. posX .. " , y=" .. posY .. ")")
		--print(game.steve.canJump)
		--print("Game " .. game.state)
		--print("Level ended: ")
		--print(game.levelCompleted)
		--print(spawnX .. "   " .. spawnY)

		--print(game.steve.canJump)
		-- if (game.steve.jumpForce) then
		-- 	print("jumpForce: " ..game.steve.jumpForce)
		-- end
		--local xv, yv = game.steve:getLinearVelocity()
		--print(yv)
		--print("AirState "..game.steve.airState)
		--print("STATE "..game.steve.state)
		--print("Sequence: "..game.steveSprite.sequence)
		--print( "STEVEisPlaying: ", game.steveSprite.isPlaying)
		--if (game.steveSprite.phase)then print("AnimState"..game.steveSprite.phase) end
		--print("SteveY: "..game.steve.y)
		--print("SpriteY: "..game.steveSprite.y)
		--print( "TESTisPlaying: ", game.testSprite.isPlaying)
	end

	-- The main game loop, every function is described as follows.
	local function onUpdate ()
		--	game.steveSprite.x , game.steveSprite.y = posX , posY
		if((game.steve.x) and (game.steve.y)) then
			game.steveSprite.x = game.steve.x 
			game.steveSprite.y = game.steve.y -10
		 	--(offset della sprite rispetto a game.steve)
			game.steveSprite.xScale = game.steve.direction
		end

		-- Jumping is allowed only in two circumstances:
		-- 1) The player is touching the ground (see jumpTouch())
		-- 2) The player isn't falling (his vertical speed is greater than 0)
		-- This block checks the second condition.
		if (game.SSVEnabled) then
			local xv, yv = game.steve:getLinearVelocity()
			if (yv > 0 and game.letMeJump == false) then 
				game.steve.canJump = false
			elseif (yv == 0 and game.letMeJump == true) then
				game.steve.canJump = true
			end

			-- Setting the AirState, needed for the Animation controls.
			if(yv > 0) then
				game.steve.airState= "Falling"
			elseif(yv < 0) then
				game.steve.airState= "Jumping"
			elseif(yv == 0) then
				game.steve.airState= "Idle"
			end
		end

		-- If the game's state is changed by any event or trigger, 
		-- this invokes the corresponding method (for unification purposes).
		local state = game.state
		if (state == game.GAME_RUNNING) then
		elseif (state == game.GAME_RESUMED) then
			game.resume()
		elseif (state == game.GAME_PAUSED) then
			game.pause()
		elseif (state == game.GAME_ENDED) then
			game.stop() 
		end
	end

	-- Refresh the map around the focused object (which by default is Steve).
	local function moveCamera( event ) 
		game.map:update(event)
	end
------------------------------------------------------------------------------------

-- PAUSE MENU ----------------------------------------------------------------------
	local pausePanel, bgVolume, bgMuteBtn, fxVolume, fxMuteBtn

	local function onMenuBtnRelease()  
		pausePanel:hide({
			speed = 250,
			transition = easing.outElastic
		})
		game.state = game.GAME_ENDED

		--ui.pauseButton.isVisible = true
		--ui.resumeButton.isVisible = false
		composer.gotoScene( "menu.mainMenu", { effect="fade", time=280 } )
		return true
	end

	-- Background Volume slider listener
	local function bgVolumeListener( event )
		print( "Slider at " .. event.value .. "%" )
		audio.setVolume( event.value/100, { channel=1 } )
	end

	-- Effects Volume slider listener (canale fx?)
	local function fxVolumeListener( event )
		print( "Slider at " .. event.value .. "%" )
		audio.setVolume( event.value/100, { channel=2 } )
	end

	-- Handle press events for the mute background music checkbox [[funziona con pause-resume]]
	local function onBgMuteSwitchPress( event )
		local switch = event.target
		print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
		if (switch.isOn) then 
			audio.pause({channel =1})
			else audio.resume({channel =1})
		end
	end

	-- Handle press events for the mute effects checkbox [[canale fx?]]
	local function onFxMuteSwitchPress( event )
		local switch = event.target
		print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
		if (switch.isOn) then 
				audio.pause({channel =2})
				else audio.resume({channel =2})
		end
	end

	-- Create the options panel (shown when the clockwork is pressed/released)
	pausePanel = utility.newPanel{
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
		pausePanel.background = display.newImageRect(visual.panel, pausePanel.width, pausePanel.height-20)
		pausePanel:insert( pausePanel.background )
		   
		pausePanel.title = display.newText( "Pause", 0, -70, "Micolas.ttf", 15 )
		pausePanel.title:setFillColor( 1, 1, 1 )
		pausePanel:insert( pausePanel.title )

	-- Create the background music volume slider
	pausePanel.bgVolume = widget.newSlider {
		sheet = utility.sliderSheet,
		leftFrame = 1,
		middleFrame = 2,
		rightFrame = 3,
		fillFrame = 4,
		frameWidth = 18,
		frameHeight = 16,
		handleFrame = 5,
		handleWidth = 18,
		handleHeight = 18,
		top = 100,
		left= 50,
		orientation = "horizontal",
		width = 140,
		value = 40,  -- Start slider at 40%
		listener = bgVolumeListener
		}

		pausePanel.bgVolume.x= -10
		pausePanel.bgVolume.y = -30
		pausePanel:insert(pausePanel.bgVolume)

	-- Create the effects volume slider
	pausePanel.fxVolume = widget.newSlider {
		sheet = utility.sliderSheet,
		leftFrame = 1,
		middleFrame = 2,
		rightFrame = 3,
		fillFrame = 4,
		frameWidth = 18,
		frameHeight = 16,
		handleFrame = 5,
		handleWidth = 18,
		handleHeight = 18,
		top = 100,
		left= 50,
		orientation = "horizontal",
		width = 140,
		value = 40,  -- Start slider at 40%
		listener = fxVolumeListener
		}

		pausePanel.fxVolume.x= -10
		pausePanel.fxVolume.y = 5
		pausePanel:insert(pausePanel.fxVolume)

		pausePanel.bgVolumeText = display.newText( "Music", -20, -48,  "Micolas.ttf", 15 )
		pausePanel.bgVolumeText:setFillColor( 0, 0, 0 )
		pausePanel:insert(pausePanel.bgVolumeText)

		pausePanel.fxVolumeText = display.newText( "Sound Effects", -20, -12, "Micolas.ttf", 15 )
		pausePanel.fxVolumeText:setFillColor( 0, 0, 0 )
		pausePanel:insert(pausePanel.fxVolumeText)

	-- Create the background mute checkbox
	pausePanel.bgMuteBtn = widget.newSwitch {
		sheet = utility.checkboxSheet,
		frameOff = 1,
		frameOn = 2,
		left = 0,
		top = 100,
		style = "checkbox",
		id = "Checkbox",
		onPress = onBgMuteSwitchPress,
		height = 15,
		width = 15
		}
		pausePanel.bgMuteBtn.x= 64
		pausePanel.bgMuteBtn.y = -30
		pausePanel:insert(pausePanel.bgMuteBtn)

	-- Create the effects mute checkbox
	pausePanel.fxMuteBtn = widget.newSwitch {
		sheet = utility.checkboxSheet,
		frameOff = 1,
		frameOn = 2,
		left = 0,
		top = 100,
		style = "checkbox",
		id = "Checkbox",
		onPress = onFxMuteSwitchPress,
		height = 15,
		width = 15
		}
		pausePanel.fxMuteBtn.x= 64
		pausePanel.fxMuteBtn.y = 5
		pausePanel:insert(pausePanel.fxMuteBtn)

	-- Create the about button
	pausePanel.menuBtn = widget.newButton {
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
		pausePanel.menuBtn.x= -60
		pausePanel.menuBtn.y = 39
		pausePanel:insert(pausePanel.menuBtn)
------------------------------------------------------------------------------------

-- MISCELLANEOUS FUNCTIONS ---------------------------------------------------------
	-- Adds points to the current game's score (points are fixed for now).
	function game.addScore(points)
		
		game.score = game.score + points
		ui.scoreText.text = "Score: " .. game.score
		local pointsTimer = 250

		if (ui.pointsText.isVisible == false) then
			ui.pointsText.text = ("+" .. points)
			ui.pointsText.isVisible = true 
			pointsTimer = 250
		end

		-- Fancy animation
		local pointsFade = function () 
			transition.to( ui.pointsText, { alpha = 0, time = 250, effect = "crossfade", 
				onComplete = function() 
					ui.pointsText.isVisible = false
					ui.pointsText.alpha = 1
				end
				} )
			end
		timer.performWithDelay(pointsTimer, pointsFade)
		end

	--Adds -one- life to the current game's lives.
	function game.addLife()
		if(game.lives < game.MAX_LIVES ) then
			game.lives = game.lives + 1
			ui.updateLifeIcons(game.lives)
		end
	end

	-- Endgame handler (triggered if lives are 0 or by reaching the end of the level).
	function game.endGameScreen()
		game.SSVEnabled = false 	-- prevents setSteveVelocity from calling getLinearVelocity().
		game.controlsEnabled = false
		game.map:setFocus( nil )
		display.remove(game.steve)
		display.remove(game.steveSprite)

		-- Displays the outcome of the game.
			local exitText = display.newText( ui.uiGroup, "" , 250, 150, native.systemFontBold, 34 )
			if (game.levelCompleted == true) then
				exitText.text = "Level Complete"
				exitText:setFillColor( 0.75, 0.78, 1 )
			else
				exitText.text = "Game Over"
				exitText:setFillColor( 1, 0, 0 )
			end
			transition.to( exitText, {
				alpha=0,
				time=2000,
				onComplete = function() display.remove( exitText ) end
				} )

		-- What follows is executed with a brief delay.
		local endGame = function()
			game.ui:removeSelf( )

			-- Removes the event listener if endGame was triggered while still inputing a movement.
			if (SSVLaunched) then
				Runtime:removeEventListener( "enterFrame", setSteveVelocity )
			end

			-- Switches scene (from "levelX" to "highscores").
			composer.setVariable( "finalScore", game.score )
			composer.removeScene( "highscores" )
			composer.gotoScene( "highscores", { time=1500, effect="crossFade" } )
		end
		timer.performWithDelay( 1500, endGame )

		game.state = game.GAME_ENDED
		return true
	end

	-- Restores Steve at the current spawn point in the current game (triggered if lives are > 0).
	function game.restoreSteve()
		transition.to(game.steve, { time=0, onComplete = function()
			game.steve.isBodyActive = false
			game.steve.x, game.steve.y = spawnX, spawnY
		end})

		game.map:fadeToPosition (spawnX, spawnY, 250)
		
		-- Steve can't move or jump during the animation
		game.steve.state = game.STEVE_STATE_IDLE
		game.steve:setLinearVelocity( 0, 0 )
		game.steve.canJump = false

		-- Fades in Steve's sprite
		transition.to( game.steveSprite, { alpha = 1, time = 1000,
			onComplete = function()
				game.steve.state = game.STEVE_STATE_IDLE
				game.steve.isBodyActive = true
				game.controlsEnabled = true
				game.steveSprite:play()
			end
		} )
	end

	-- Animation on Steve's death: he explodes in small rock particles.
	function game.steveDeathAnimation(sx, sy)
		-- body
		local frammenti = {}
		local numRocce = 10
		
		for i = 1, numRocce, 1 do
			local dim = math.random (2, 10)
			local dx = math.random(-1, 1)
			local dy = math.random(-1, 1)
			local frammento = display.newImageRect( visual.lifeIcon, dim, dim)
			frammento.x , frammento.y = sx, sy
			game.map:getTileLayer("playerEffects"):addObject(frammento)
			
			transition.to(frammento, {time =0, onComplete= function()
				physics.addBody(frammento, {density = 1, friction = 1, bounce = 0.5})
				frammento:applyLinearImpulse(dx, dy, frammento.x , frammento.y)
			end})
			
			table.insert(frammenti , frammento)
		end

		-- Removes physics to the rock fragments after a brief delay.
		transition.to(frammenti, {time = 4000, onComplete = function()
			for i=1, #frammenti, 1 do
				frammenti[i].isBodyActive = false
			end
		end})
	end

	-- Returns True if an object has an attribute specified by its name 
	-- (attributeName must be a string).
	function game.hasAttribute( obj , attributeName )
		local ris = false
		for k, v in pairs(obj) do
			if k == attributeName then
				ris =true
				break
			end
		end
		return ris
	end

	-- Displays the item contained in the attribute -drop- of an enemy.
	function game.dropItemFrom( enemy )
		local item = items.createItem(enemy.drop)
		game.map:getTileLayer("items"):addObject(item)
		item.x = enemy.x
		item.y = enemy.y
	end
------------------------------------------------------------------------------------

-- COLLISION HANDLERS --------------------------------------------------------------
	-- See collisions.lua
	local function onCollision( event )
		collisions.onCollision( event , game )
	end
------------------------------------------------------------------------------------

-- CONTROLS HANDLERS ---------------------------------------------------------------
	-- Main movement handler: it physically translates Steve in the map by applying physical forces.
	local function setSteveVelocity()
		if (game.SSVEnabled) then
			SSVLaunched = true

			-- ActualSpeed is needed for allowing combinations of two-dimensional movements.
			-- In both cases (x-movement or y-movement), we set the character's linear velocity at each
			-- frame, overriding one of the two linear velocities when a movement is input.
			local steveXV, steveYV = game.steve:getLinearVelocity()
			if (SSVType == "walk") then
				-- When walking, ActualSpeed will be 'direction * walkForce'
				game.steve:setLinearVelocity(game.steve.actualSpeed, steveYV)
			elseif (SSVType == "jump" and game.steve.jumpForce < 0) then
				-- When jumping, ActualSpeed will be 'jumpForce'
				game.steve:setLinearVelocity(steveXV, game.steve.actualSpeed )
				game.steve:applyForce(0, game.steve.jumpForce, game.steve.x, game.steve.y)

				if (   game.steve.state == game.STEVE_STATE_JUMPING
					and game.steve.jumpForce > - 400 and j ~= 0) then
					j = j - 1
					i = i + 1

					maths = - i
					-- maths = - math.exp( i/2 ) + 1
					-- maths - game.steve.jumpForce*math.exp(-i/100000000)
					game.steve.jumpForce = game.steve.jumpForce + maths
				else
					game.steve.jumpForce = 0
				end

				--print("i:" ..i.. "| j:" ..j.. "	| jumpForce:" .. 
				--game.steve.jumpForce .. " | maths: " .. maths)
			end
		end
	end

	-- Inputs movement on the x-axis.
	local function dpadTouch(event)
		local target = event.target
		
		if (game.state == game.GAME_RUNNING) then
			if (event.phase == "began") then
				display.currentStage:setFocus( target, event.id )

				-- Visually simulate the button press (depending on which is pressed).
				if (target.myName == "dpadLeft") then
					game.steve.direction = game.DIRECTION_LEFT
					ui.dpadLeft.alpha = 0.8
				elseif (target.myName == "dpadRight") then
					game.steve.direction = game.DIRECTION_RIGHT
					ui.dpadRight.alpha = 0.8
				end

				if (game.controlsEnabled) then
					game.SSVEnabled = true
					game.steve.state = game.STEVE_STATE_WALKING

					--avoid walking animation in mid air
					if(game.steve.airState == "Idle" or game.steve.airState == nil) then
						game.steveSprite:setSequence("walking")
						game.steveSprite:play()
					end

					SSVType = "walk"
					Runtime:addEventListener("enterFrame", setSteveVelocity)
					game.steve.actualSpeed = game.steve.direction * game.steve.walkForce
					game.steve.xScale = game.steve.direction
				end

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				game.steve.state = game.STEVE_STATE_IDLE
				game.steveSprite:setSequence("idle")

				Runtime:removeEventListener("enterFrame", setSteveVelocity)	

				ui.dpadLeft.alpha, ui.dpadRight.alpha = 0.1, 0.1
				display.currentStage:setFocus( target, nil )
			end
		end

		return true --Prevents touch propagation to underlying objects
	end

	-- Inputs movement on the y-axis.
	local function jumpTouch(event)
		if (game.state == game.GAME_RUNNING) then
			if (event.phase == "began") then
				display.currentStage:setFocus( event.target, event.id )
				if (game.controlsEnabled and game.steve.canJump == true) then
					audio.play( jumpSound )
					game.steve.state = game.STEVE_STATE_JUMPING

					SSVType = "jump"
					Runtime:addEventListener("enterFrame", setSteveVelocity)
					game.steve.jumpForce = -200
					game.steve.actualSpeed = game.steve.jumpForce

					i = 0
					j = 18

					game.steve.canJump = false
					game.letMeJump = false
				end

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				display.currentStage:setFocus( event.target, nil )
				game.steve.state = game.STEVE_STATE_IDLE
				game.steve.jumpForce = 0
				game.steveSprite:setSequence("idle")
				Runtime:removeEventListener("enterFrame", setSteveVelocity)	
			end
		end

		return true --Prevents touch propagation to underlying objects
	end

	-- Inputs action, depending on the current weapon equipped or other circumstances.
	local function actionTouch( event )
		local attackDuration = 500
		local actionBtn = event.target

		if (game.state == game.GAME_RUNNING) then
			if (event.phase=="began" and actionBtn.active == true) then
				display.currentStage:setFocus( actionBtn )

				if (game.controlsEnabled) then
					audio.play( attackSound )

					-- Visually simulate the button press
					actionBtn.active = false
					actionBtn.alpha = 0.5

					game.steve.state = game.STEVE_STATE_ATTACKING
					steveAttack = display.newCircle( game.steve.x, game.steve.y, 40)
					physics.addBody(steveAttack, {isSensor = true})
					steveAttack.myName = "steveAttack"
					steveAttack:setFillColor(0,0,255)
					steveAttack.alpha=0.6
					game.map:getTileLayer("playerEffects"):addObject( steveAttack )
					game.steveSprite.alpha=0

					-- Steve dashes forward
					game.steve:applyLinearImpulse( game.steve.direction * 8, 0, game.steve.x, game.steve.y )

					-- Visually links the SteveAttack to Steve
					local steveAttackFollowingSteve = function ()
						steveAttack.x, steveAttack.y = game.steve.x, game.steve.y
					end

					-- Handles the end of the attack phase
					local steveAttackStop = function ()
						display.remove(steveAttack)
						game.steve.state = game.STEVE_STATE_IDLE
						Runtime:removeEventListener("enterFrame" , steveAttackFollowingSteve)
						actionBtn.active = true
						actionBtn.alpha = 1
						game.steveSprite.alpha = 1
					end

					Runtime:addEventListener("enterFrame", steveAttackFollowingSteve)
					timer.performWithDelay(attackDuration, steveAttackStop)
				end
			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				display.currentStage:setFocus( nil )
			end
		end

		return true --Prevents touch propagation to underlying objects
	end

	-- Inputs game pause (and opens the pause panel) if game is running and resume if paused.
	local function pauseResume(event)
		local target = event.target

		if (event.phase == "began") then
			display.currentStage:setFocus( target )

		elseif (event.phase == "ended" or "cancelled" == event.phase) then
			if (target.myName == "pauseBtn") then
				game.state = game.GAME_PAUSED
				ui.pauseBtn.isVisible = false
				ui.resumeBtn.isVisible = true
				pausePanel:show({ y = display.screenOriginY+225,})
			elseif (target.myName == "resumeBtn") then
				game.state = game.GAME_RESUMED
				ui.pauseBtn.isVisible = true
				ui.resumeBtn.isVisible = false
				pausePanel:hide()
			end
			display.currentStage:setFocus( nil )
		end

		return true --Prevents touch propagation to underlying objects
	end

	-- Inputs interaction with an npc's ballon.
	local function balloonTouch(event) 
		local target = event.target
		if (game.state == game.GAME_RUNNING) then
			if (event.phase == "began") then
				display.currentStage:setFocus( event.target )

				-- [[Work in progress]]
				print("BOOP")

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				display.currentStage:setFocus( nil )
			end
		end

		return true --Prevents touch propagation to underlying objects
	end
------------------------------------------------------------------------------------

-- NPCDETECT 3.0--------------------------------------------------------------------
	local contactEnabled = true
	local releaseEnabled = false

		-- Params: one npc from the npcs list and one flag string.
		-- The flag is calculated by the type of collision detected.
		local function toggleNpcBalloon ( npc, flag )
			if (flag == "show") then
				-- npc.balloon.alpha = 1
				npc.balloon:show()
			elseif (flag == "hide") then
				-- npc.balloon.alpha = 0
				npc.balloon:hide()
			end
		end

		-- Handles the triggering of the event of showing/hiding one npc's balloon.
		-- Steve and every npc have an invisible "sensor" physical object surrounding
		-- and following them at runtime. This function handles the collision between
		-- the two (in future three) sensors, and acts differently depending if the
		-- collision is a "contact" or a "release" between the two circles.
		local function npcDetectByCollision ( event )
			local sensorN, collName, flag 
			if ( (event.object1.sensorName == "N")   or 
				 (event.object2.sensorName == "N") ) and 
				( (event.object2.sensorName == "D")   or 
				  (event.object2.sensorName == "E") ) then
				sensorN = event.object1

				--[[
					-- if (event.object2.sensorName == "D") then
					-- 	sensorD = event.object2
					-- elseif (event.object2.sensorName == "E") then
					-- 	sensorE = event.object2
					-- end
					-- if (sensorN.sensorName ~= "N") then
					-- 	sensorN = event.object2
					-- end
				]]--

				if (contactEnabled) then 
					collName = "contact"
					flag = "show"
				elseif (releaseEnabled) then
					collName = "release"
					flag = "hide"
				end

				-- Switches between the two if blocks (next collision will enter the other if)
				if (collName == "contact") then
					contactEnabled = false
					releaseEnabled = true
				elseif (collName == "release") then
					releaseEnabled = false
					contactEnabled = true
				end

				for i = 1, #game.npcs, 1 do
					-- Selects the npc associated to the sensorN and calls the toggle function
					if (game.npcs[i].sensorN == sensorN) then
						toggleNpcBalloon(game.npcs[i], flag)
					end
				end
			end
		end

		-- [[Non so ancora se mi servirà a qualcosa]]
		local function sensorPreCollision ( self, event )
			if ( "sensor" ~= event.other.collType ) then
				if event.contact then
					event.contact.isEnabled = false
				end
			end
			return true
		end
------------------------------------------------------------------------------------

-- GAME INITIALIZATION -------------------------------------------------------------
	-- Loads the player's image, animations and initializes its attributes.
	-- Visually istantiates the player in the current game's map.
	function game.loadPlayer()

		-- Sprite and animation sequences
			local sheetData ={
				height = 50,
				width = 30,
				numFrames = 4,
				sheetContentWidth = 120,--120,
				sheetContentHeight = 50--40
			}

			local walkingSheet = graphics.newImageSheet(visual.steveSheetWalking, sheetData)

			local sequenceData = {
				{name = "walking", start= 1, count =4, time = 300, loopCount=0},
				{name = "idle", start= 1, count =1, time = 300, loopCount=0},
				{name = "falling", start= 1, count =1, time = 300, loopCount=0},
				{name = "jumping", start= 1, count =1, time = 300, loopCount=0 }
			}

			game.steveSprite = display.newSprite( walkingSheet , sequenceData)
			game.map:getTileLayer("playerEffects"):addObject( game.steveSprite )

			game.steveSprite:setSequence("idle")
			--game.steveSprite:setFrame(1)
			game.steveSprite:play()
			--game.steveSprite:pause()

		-- Image and physical object
			game.steve = display.newImageRect( visual.steveImage, 30, 30 )
			game.steve.alpha = 0 
			game.steve.myName = "steve"
			game.steve.rotation = 0
			game.steve.walkForce = 150
			game.steve.maxJumpForce = -20
			physics.addBody( game.steve, { density=1.0, friction=0.7, bounce=0.01} )
			game.steve.isFixedRotation = true
			game.steve.state = game.STEVE_STATE_IDLE
			game.steve.direction = game.DIRECTION_RIGHT
			game.steve.canJump = false

		-- Binds Steve to the initial spawn point in the current game.
		game.steve.x, game.steve.y = spawnX, spawnY

		game.steve.preCollision = collisions.stevePreCollision
		game.steve:addEventListener( "preCollision", game.steve )
	end

	-- Loads invisible "sensor" circles surrounding the player.
	-- Visually istantiates the sensors in the current game's map.
	function game.loadPlayerSensors()
		local sensorD
		-- local sensorE
		local followSteve = function (event)
			sensorD.x = game.steve.x
			sensorD.y = game.steve.y
			-- sensorE.x = game.steve.x
			-- sensorE.y = game.steve.y
		end

		sensorD = display.newCircle( game.steve.x, game.steve.y, 50 )
		physics.addBody( sensorD, {isSensor = true, radius = 50} )
		sensorD.sensorName = "D"
		sensorD:setFillColor( 100, 50, 0 )
		sensorD.alpha = 0
		--sensorD.collType = "sensor"
		--sensorD.preCollision = sensorPreCollision
		--sensorD:addEventListener( "preCollision", sensorD )

		-- sensorE = display.newCircle( game.steve.x, game.steve.y, 40)
		-- physics.addBody(sensorE, {isSensor = true, radius = 40})
		-- sensorE.sensorName = "E"
		-- sensorE:setFillColor(0,200,255)
		-- sensorE.alpha=0.4

		Runtime:addEventListener( "enterFrame", followSteve )
		game.map:getTileLayer( "playerEffects"):addObject( sensorD )
		-- game.map:getTileLayer("playerEffects"):addObject( sensorE )
	end

	-- An enemy is an animated entity capable of moving on the map and performing other actions 
	-- which can kill Steve in several ways.
	-- Loads all the enemies and initializes their attributes.
	-- Visually istantiates the enemies in the current game's map.
	function game.loadEnemies()
		--[[Richiede che sulla mappa ci siano degli OGGETTI con il tipo = tipoNemico]]

		-- The enemy list is empty at the start of each game.
		game.enemyLevelList = {}
		local enemy = nil
		local enemyList = game.map:getObjectLayer("enemySpawn").objects

		for k, v in pairs(enemyList) do
			enemy = enemyList[k]
			--print ("primax= "..enemy.x.." primay= "..enemy.y)
			local en = enemies.createEnemy(enemy, enemy.type)
				--[[assegno qui la posizione perchè nella funzione precedente
					magicamente si perdono i valori della posizione]]
				en.x = enemy.x
				en.y = enemy.y
				en.name = enemy.name
				--muovi4(en)

			-- If the enemy holds something, assign 
			if(enemy.drop ~=nil) then
				en.drop = enemy.drop 
			end

			game.map:getTileLayer("entities"):addObject( en )
			table.insert (game.enemyLevelList , en)

			--muovi(en)
		end

		--[[
			2 sedia, 3 paper sopra, 1 paper sotto
			for i=1,2 do
				local obj= game.enemyLevelList[i]
				transition.to( obj, { time=1500, onComplete=muovi(obj)} )
				print(obj)
				--table.remove (enemyList[0])
			end
			transition.to( game.enemyLevelList[2], { time=1500, x=(game.enemyLevelList[2].x - 120), onComplete=muovi(game.enemyLevelList[1]) } )
			transition.to( game.enemyLevelList[2], { time=1500, x=(game.enemyLevelList[1].x - 120), onComplete=muovi(game.enemyLevelList[3]) } )
				for i=2,3 do
				local obj= game.enemyLevelList[i]
				muovi(obj)
				print(obj)
				--table.remove (enemyList[0])
			end
			if(math.random(3)==1) then muovi(game.enemyLevelList[1])
			elseif(math.random(3)==2) then muovi(game.enemyLevelList[2])
			elseif(math.random(3)==3) then muovi(game.enemyLevelList[3])
			end
			esaurimento di memoria
			muovi(game.enemyLevelList[3],game.enemyLevelList[2],game.enemyLevelList[1])	--si muove comunque l'ultimo e solo lui
			muovi2(game.enemyLevelList[1])
			muovi(game.enemyLevelList[3])
			local i=0
			for i=0,1 do
				for k, v in pairs(game.enemyLevelList) do
					muovi(game.enemyLevelList[k])
					i=i+1
				end
			end
			local txt = display.newText( "Hello", 0, 0 )
				local g1 = display.newGroup()
				local g2 = display.newGroup()
		               
			for k, v in pairs(game.enemyLevelList) do
				g1:insert(game.enemyLevelList[k])  
			end
			--g1:toBack()
			--muovi(g1)
			prova()
			muovi(game.enemyLevelList[1])
			muovi(game.enemyLevelList[3])
			muovi(game.enemyLevelList[2])
			
			muovi3(game.enemyLevelList)
			for i=1,3 do
					timer.performWithDelay(1000,muovi(game.enemyLevelList[1]))
					timer.performWithDelay(2000,muovi(game.enemyLevelList[2]))
					timer.performWithDelay(1000,muovi(game.enemyLevelList[3]))
			end

			for k, v in pairs(game.enemyLevelList) do
				game.enemyLevelList[k].speed=5	
			end
		]]

		for k, v in pairs(game.enemyLevelList) do
			muovi(game.enemyLevelList[k])
		end
	end

	-- An NPC (non-playable character) is an animated entity with whom Steve can interact.
	-- Loads the npcs's images, speech balloons and initializes their attributes.
	-- Visually instantiates the npcs in the current game's map.
	function game.loadNPCS() 
		local layer = game.map:getObjectLayer("npcSpawn")
		game.npcs = layer:getObjects("npc")

		-- Loads the image and the sprites.
		local loadNPCimage = function(npc)
			npc.staticImage = display.newImageRect( visual.npcImage, 51, 128 )
			npc.staticImage.x, npc.staticImage.y = npc.x, npc.y
			game.map:getTileLayer("entities"):addObject(npc.staticImage)
		end

		-- Loads the speech balloon, the text and the buttons.
		local loadBalloon = function(npc)
			local panelTransDone = function( target )
				if ( target.completeState ) then
					--print( "PANEL STATE IS: "..target.completeState )
				end
			end
			
			npc.balloon = panel.newPanel{
				location = "static",
				onComplete = panelTransDone,
				speed = 200,
				x, y = npc.x, npc.y,
				anchorX, anchorY = 0.5, 0.5
			}

			local background = display.newImageRect( visual.npcBalloonBackground, 134, 107 )
			background.anchorY = 1
			npc.balloon:insert(background)

			local button = display.newImageRect( visual.npcBalloonButton1, 58, 40 )
			button.x, button.y = background.x, background.y -50
			npc.balloon:insert(button)
			npc.balloon.x, npc.balloon.y = npc.x, npc.y -20
			npc.balloon.alpha = 0
			npc.balloon:hide()

			game.map:getTileLayer("balloons"):addObject(npc.balloon)
			button:addEventListener( "touch", balloonTouch )
		end

		-- Loads the sensor for -npcDetect-.
		local loadSensor = function(npc)
			local followNpc = function ()
				npc.sensorN.x = npc.x
				npc.sensorN.y = npc.y
			end

			npc.sensorN = display.newCircle( npc.x, npc.y, 60)
			physics.addBody(npc.sensorN, {isSensor = true, radius = 60})
			npc.sensorN.sensorName = "N"
			npc.sensorN:setFillColor(0,100,0)
			npc.sensorN.alpha=0 --MODIFICTO DA FABIO
			
			-- npc.sensorN.collType = "sensor"
			-- npc.sensorN.preCollision = sensorPreCollision
			-- npc.sensorN:addEventListener( "preCollision", npc.sensorN )

			Runtime:addEventListener( "enterFrame", followNpc )
			game.map:getTileLayer("entities"):addObject(npc.sensorN)
		end

		for i = 1, #game.npcs, 1 do
			loadNPCimage(game.npcs[i])
			loadBalloon(game.npcs[i])
			loadSensor(game.npcs[i])
		end
	end

	-- Loads the UI's images and handlers.
	-- Visually istantiates the UI in the current game's map.
	function game.loadUi()
		game.ui = ui.loadUi(game)

		game.map:getTileLayer("JUMPSCREEN"):addObject(ui.jumpScreen)
		ui.jumpScreen:addEventListener( "touch", jumpTouch )

		-- Adds the event handlers to the UI.
		--ui.getButtonByName("jumpScreen"):addEventListener("touch", jumpTouch)
		ui.dpadLeft:addEventListener("touch", dpadTouch)
		ui.dpadRight:addEventListener("touch", dpadTouch)
		ui.actionBtn:addEventListener("touch", actionTouch)
		ui.pauseBtn:addEventListener("touch", pauseResume)
		ui.resumeBtn:addEventListener("touch",pauseResume)

		-- After a brief delay at game start, the dpad becomes transparent.
		local function lowerDpadAlpha()
			transition.to( ui.dpadLeft, {time = 1000, alpha = 0.1}  ) 
			transition.to( ui.dpadRight, {time = 1000, alpha = 0.1} ) 
		end
		timer.performWithDelay( 2000, lowerDpadAlpha)
	end

	-- Loads all the sounds and BGM.
	function game.loadSounds()
		backgroundMusic = audio.loadStream("audio/overside8bit.wav")
		--backgroundMusic = audio.loadStream( nil )
		jumpSound = audio.loadSound("audio/jump.wav")
		coinSound = audio.loadSound("audio/coin.wav")
		attackSound = audio.loadSound( "audio/attack.wav")
		dangerSound = audio.loadSound( "audio/danger3.wav")
	end

	-- Disposes the sounds when -endGame- is triggered.
	function game.disposeSounds()
		audio.dispose( backgroundMusic )
		audio.dispose( jumpSound )
		audio.dispose( coinSound )
		audio.dispose( attackSound )
		audio.dispose( dangerSound )
	end

	-- Disables the ui when -endGame- is triggered [NOT USED]
	--[[
		function game.disableUi()
			-- Removes any residual event listener from the UI
			ui.getButtonByName("jumpScreen"):removeEventListener("touch", jumpTouch)
			ui.getButtonByName("dpadLeft"):removeEventListener("touch", dpadTouch)
			ui.getButtonByName("dpadRight"):removeEventListener("touch", dpadTouch)
			ui.getButtonByName("actionBtn"):removeEventListener("touch", actionTouch)
			ui.getButtonByName("pauseBtn"):removeEventListener("touch", pauseResume)
			ui.getButtonByName("resumeBtn"):removeEventListener("touch",pauseResume)
		end
	  ]]

	-- Main entry point (must be called from the current level).
	-- Triggers all the -game.load- functions.
	function game.loadGame( map, spawn )
		-- Locally stores the current level map and spawn coordinates
		game.map = map
		spawnX, spawnY = spawn.x, spawn.y

		game.score = 0
		game.lives = game.MAX_LIVES
		game.levelCompleted = false

		game.loadUi()
		game.loadPlayer()
		game.loadEnemies()
		game.loadNPCS()
		game.loadSounds()

		game.loadPlayerSensors()

		-- Critical, do not modify.
		game.SSVEnabled = true
		game.controlsEnabled = true
		SSVLaunched = false

		physics.start()
		physics.pause()
	end
------------------------------------------------------------------------------------

-- GIGI WIP-------------------------------------------------------------------------
	--[[
	function prova()
	for k,v in ipairs(game.enemyLevelList) do
	transition.to(game.enemyLevelList[k], {
			time=1500,
			x=(game.enemyLevelList[k].x - 120),
			onComplete=prova()
		})
	end
	]]

	function f(object)
		local angle= math.atan2(game.steve.y - object.y, game.steve.x - object.x) -- work out angle between target and missile
		object.x = object.x + (math.cos(angle) * object.speed) -- update x pos in relation to angle
		object.y = object.y + (math.sin(angle) * object.speed) -- update y pos in relation to angle
	end

	function muovi2(object,a,b)
		function goLeft ()
			transition.to( object, { time=1500, x=(object.x - 120), onComplete=goRight } )
			transition.to( a, { time=1500, x=(a.x - 120), onComplete=goRight } )
			transition.to( b, { time=1500, x=(b.x - 120), onComplete=goRight } )
		end

		function goRight ()
			transition.to( object, { time=1500, x=(object.x - 120), onComplete=goLeft } )
			transition.to( a, { time=1500, x=(a.x - 120), onComplete=goLeft } )
			transition.to( b, { time=1500, x=(b.x - 120), onComplete=goLeft } )
		end

		goLeft()
	end

	-- i nemici si muovono a destra e sinistra, lista
	function muovi(object)
		object.isFixedRotation=true
		function goLeft ()
		transition.to( object, { time=1500, x=(object.x - 120), onComplete=goRight } )
		object.xScale=1
		end

		function goRight ()
		transition.to( object, { time=1500, x=(object.x + 120), onComplete=goLeft } )
		object.xScale=-1
		end

		goLeft()
	end

	function muovi4(table)
		function goLeft ()
			-- mi scandiscono tutta la table, ma crash
			print(table)
			transition.to( table, { time=2500, x=(table.x - 120), onComplete=function()
				timer.performWithDelay(1000,goRight)
				end } )
		end

		function goRight ()
			-- mi scandiscono tutta la table, ma crash
			print(table)
			transition.to( table, { time=2500, x=(table.x + 120), onComplete=function()
				timer.performWithDelay(1000,goLeft)
				end } )
		end
		goLeft()
	end

	-- questa muove tutti ma dopo un po' crasha, troppi controlli
	function muovi3(table)
		function goLeft ()
			-- mi scandiscono tutta la table, ma crash
			for k,v in ipairs(table) do
			print(table[k])
			transition.to( table[k], { time=2500, x=(table[k].x - 120), onComplete=goRight } )
			end
		end

		function goRight ()
			-- mi scandiscono tutta la table, ma crash
			for k,v in ipairs(table) do
			print(table[k])
			transition.to( table[k], { time=2500, x=(table[k].x + 120), onComplete=goLeft } )
			end
		end
		goLeft()
	end

	-- i nemici dovrebbero seguire steve, per alcuni, liste
	function segui(steve)
		for i = 1, #enemiesList do
			local distanceX = steve.x - enemiesList[i].x
			local distanceY = steve.y - enemiesList[i].y

			local angleRadians = math.atan2(distanceY, distanceX)
			local angleDegrees = math.deg(angleRadians)

			local enemySpeed = 5

			local enemyMoveDistanceX = enemySpeed*math.cos(angleDegrees)
			local enemyMoveDistanceY = enemySpeed*math.sin(angleDegrees)

			enemy.x = enemy.x + enemyMoveDistanceX
			enemy.y = enemy.y + enemyMoveDistanceY
		end
	end
------------------------------------------------------------------------------------


function game.start()
	game.state = game.GAME_RUNNING
	game.steveSprite:play()
	physics.start()
	Runtime:addEventListener("enterFrame", moveCamera)
	Runtime:addEventListener("collision", onCollision)
	Runtime:addEventListener("collision", npcDetectByCollision)
	Runtime:addEventListener("enterFrame", onUpdate)
	timer.performWithDelay(200, debug, 0)
	audio.play(backgroundMusic, {channel = 1 , loops=-1})
end

function game.pause()
	game.steve.state = game.STEVE_STATE_IDLE
	game.steveSprite:pause()
	physics.pause()
	audio.pause(1)
end

function game.resume()
	game.state = game.GAME_RUNNING
	game.steveSprite:play()
	physics.start()
	audio.resume(1)
end

function game.stop()
	game.disposeSounds()
	package.loaded[physics] = nil
	Runtime:removeEventListener("enterFrame", moveCamera)
	Runtime:removeEventListener("collision", npcDetectByCollision)
	Runtime:removeEventListener("collision", onCollision)
	Runtime:removeEventListener( "enterFrame", onUpdate )

	--audio.stop(1)
end

return game


