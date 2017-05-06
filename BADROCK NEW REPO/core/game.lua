-----------------------------------------------------------------------------------------
--
-- game.lua
--
-- Game is intended to be the "simulator" of the application logic tier.
-- Accessibility to child modules (like collisions) is granted depending on the 
-- simulation state.
-- At startup, this class istantiates all the domain objects by calling the initializator 
-- methods contained in the "core" modules.
-----------------------------------------------------------------------------------------

local composer   = require ( "composer"         )
local physics    = require ( "physics"          )
local math       = require ( "math"             )
local entity     = require ( "lib.entity"       )
local player     = require ( "core.player"      )
local enemies    = require ( "core.enemies"     )
local npcs       = require ( "core.npcs"        )
local items      = require ( "core.items"       )
local controller = require ( "core.controller"  )
local ui         = require ( "core.ui"          )
local collisions = require ( "core.collisions"  )
local sfx        = require ( "audio.sfx"        )
local pauseMenu  = require ( "menu.pauseMenu"   )
-- local widget  = require ( "widget"           )
-- local panel   = require ( "menu.utilityMenu" )
-- local utility = require ( "menu.utilityMenu" )

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
	game.DIRECTION_LEFT        = -1				-- servono??
	game.DIRECTION_RIGHT       =  1				-- servono??
	game.MAX_LIVES             =  3

	local gameStateList = {
		RUNNING = "Running",
		PAUSED  = "Paused",
		RESUMED = "Resumed",
		ENDED   = "Ended",
	}

	local playerStateList = {
		IDLE      = "Idle",
		WALKING   = "Walking",
		ATTACKING = "Attacking",
		DEAD      = "Dead",
	}


	game.letMeJump = false
	game.SSVEnabled = true
	game.controlsEnabled = true
	game.levelCompleted = false
	local SSVLaunched, SSVType

--===========================================-- 

-- RUNTIME FUNCTIONS ---------------------------------------------------------------
	-- The only purpose of this is for text debugging on the console, do not add anything else.
	local function debug(event)
		-- print("Game " .. game.state)
		-- print(game.steve.state)
		-- if (game.steve.canJump == true) then print ("Steve can jump")
		-- elseif (game.steve.canJump == false) then print ("Steve can't jump now") end
		-- print("")

		--print("Level ended: ")
		--print(game.levelCompleted)
		-- if (game.steve.jumpForce) then
		-- 	print("jumpForce: " ..game.steve.jumpForce)
		-- end
		--local xv, yv = game.steve:getLinearVelocity()
		--print(yv)
		--print("AirState "..game.steve.airState)
		--print("Sequence: "..game.steveSprite.sequence)
		--print( "STEVEisPlaying: ", game.steveSprite.isPlaying)
		--if (game.steveSprite.phase)then print("AnimState"..game.steveSprite.phase) end
		--print("SteveY: "..game.steve.y)
		--print("SpriteY: "..game.steveSprite.y)
	end

	-- The main game loop, every function is described as follows.
	local function onUpdate ()
		-- Keeps the player's image, sprite and sensor all joined.
		-- (remember that ONLY the image "steve" acts as the hitbox)
		if(game.steve.x and game.steve.y) then
			game.steveSprite.x = game.steve.x
			game.steveSprite.y = game.steve.y -10
			game.sensorD.x, game.sensorD.y = game.steve.x, game.steve.y
		 	-- game.steve.sensorE.x, game.steve.sensorE.y = game.steve.x, game.steve.y
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
				composer.removeScene( "menu.highscores" )
				composer.gotoScene( "menu.highscores", { time=1500, effect="crossFade" } )
			end
			timer.performWithDelay( 1500, endGame )

		game.state = game.GAME_ENDED
		return true
	end

	-- Restores Steve at the current spawn point in the current game (triggered if lives are > 0).
	function game.restoreSteve()
		transition.to(game.steve, { time=0, onComplete = function()
			game.steve.isBodyActive = false
			game.steve.x, game.steve.y = game.spawn.x, game.spawn.y
		end})

		game.map:fadeToPosition (game.spawn.x, game.spawn.y, 250)
		
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
				game.steve.state = game.STEVE_STATE_WALKING
				game.steve:setLinearVelocity(game.steve.actualSpeed, steveYV)
			elseif (SSVType == "jump" and game.steve.jumpForce < 0) then
				-- When jumping, ActualSpeed will be 'jumpForce'
				game.steve:setLinearVelocity(steveXV, game.steve.actualSpeed )
				game.steve:applyForce(0, game.steve.jumpForce, game.steve.x, game.steve.y)

				if (   game.steve.state == game.STEVE_STATE_JUMPING
					and game.steve.jumpForce > - 400 and j ~= 0) then
					j = j - 1
					i = i + 1

					local maths = - i
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
					sfx.playSound( sfx.jumpSound, { channel = 2 } )
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
					sfx.playSound( sfx.attackSound, { channel = 4 } )

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
				pauseMenu.psbutton = ui.getButtonByName("pauseBtn")
				pauseMenu.rsbutton = ui.getButtonByName("resumeBtn")
		        pauseMenu.panel:show({ y = display.screenOriginY+225,})
			elseif (target.myName == "resumeBtn") then
				game.state = game.GAME_RESUMED
				ui.pauseBtn.isVisible = true
				ui.resumeBtn.isVisible = false
				pauseMenu.panel:hide()
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

-- GAME INITIALIZATION -------------------------------------------------------------
	-- See player.lua
	function game:loadPlayer()
		self.steve, self.steveSprite, self.sensorD = player.loadPlayer( self )

		-------------------------------------
		self.steve.sprite = self.steveSprite  -- for controller
		self.steve.sensorD = self.sensorD
		-------------------------------------

		self.steveSprite:setSequence("idle")
		--self.steveSprite:setFrame(1)
		self.steveSprite:play()
		--self.steveSprite:pause()

		self.steve.state = self.steve_STATE_IDLE
		self.steve.direction = self.DIRECTION_RIGHT
		self.steve.canJump = false

		self.steve.preCollision = collisions.stevePreCollision
		self.steve:addEventListener( "preCollision", self.steve )

		self.map:setFocus( self.steve )
	end

	-- See npcs.lua
	function game:loadNPCS() 
		self.npcs = npcs.loadNPCs( self )

		------------------------------------------------------------------------
			-- wip for control handlers, will be removed soon
			for i, v in ipairs(self.npcs) do
				self.npcs[i].balloon.button:addEventListener( "touch", balloonTouch )
			end
		------------------------------------------------------------------------
	end

	-- An enemy is an animated Entity capable of moving on the map and performing other actions 
		-- which can kill Steve in several ways.
		-- Loads all the enemies and initializes their attributes.
		-- Visually istantiates the enemies in the current game's map.
	function game:loadEnemies()
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

	-- Loads the UI's images and handlers.
		-- Visually istantiates the UI in the current game's map.
	function game:loadUi()
		self.ui = ui.loadUi(self)

		self.map:getTileLayer("JUMPSCREEN"):addObject(ui.jumpScreen)
		ui.jumpScreen:addEventListener( "touch", jumpTouch )

		-- Adds the event handlers to the UI.
		--ui.getButtonByName("jumpScreen"):addEventListener("touch", jumpTouch)
			ui.dpadLeft:addEventListener("touch", dpadTouch)
			ui.dpadRight:addEventListener("touch", dpadTouch)
			ui.actionBtn:addEventListener("touch", actionTouch)
			ui.pauseBtn:addEventListener("touch", pauseResume)
			ui.resumeBtn:addEventListener("touch",pauseResume)

		-- After a brief delay at game start, the dpad becomes transparent.
		-- local function lowerDpadAlpha()
		-- 	transition.to( ui.dpadLeft, {time = 1000, alpha = 0.1}  ) 
		-- 	transition.to( ui.dpadRight, {time = 1000, alpha = 0.1} ) 
		-- end
		-- timer.performWithDelay( 2000, lowerDpadAlpha)
	end

	-- Removes every Entity on the map when -game.stop- is triggered
		-- [[ lavori in corso: introdurre lista di entità in game ]]
	function game:removeAllEntities()
		self.map:getTileLayer("playerObject"):destroy()
		self.map:getTileLayer("playerEffects"):destroy()
		self.map:getTileLayer("items"):destroy()
		self.map:getTileLayer("balloons"):destroy()
		self.map:getTileLayer("sensors"):destroy()
		self.map:getTileLayer("entities"):destroy()
	end

	-- Main entry point for initialization (must be called from the current level).
	-- Triggers all the -game.load- functions.
	function game.loadGame( map, spawn )
		-- Locally stores the current level map and spawn coordinates
		game.map = map
		game.spawn = spawn

		game.score = 0
		game.lives = game.MAX_LIVES
		game.levelCompleted = false

		-- game:loadEnemies()
		-- game:loadNPCS()
		game:loadPlayer()
	
		-- game:loadUi()

	
		-- Critical, do not modify.
		SSVLaunched = false

		collisions.setGame( game )
		controller.setGame( game, gameStateList, playerStateList  )
		controller.prepareUI()

		local count = display.currentStage.numChildren
		print( "Number of objects on the screen = " .. count )

		for i=1,display.currentStage.numChildren do
		    local child = display.currentStage[i]
		    local description = (child.isVisible and "visible") or "not visible"
		    print( "child["..i.."] is " .. description )
		end

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
		local angle= math.atan2(game.steve.x - object.y, game.steve.y - object.x) -- work out angle between target and missile
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

-- MAIN ENTRY POINT (must be called from the current level after -game.loadGame-).
function game.start()
	-- game.state = game.GAME_RUNNING
	-- game.steve.state = game.STEVE_STATE_IDLE
	-- game.steveSprite:play()

	controller:start()
	physics.start()

	Runtime:addEventListener("enterFrame", moveCamera)
	Runtime:addEventListener("collision", collisions.onCollision)
	Runtime:addEventListener("enterFrame", onUpdate)

	timer.performWithDelay(200, debug, 0)
end

function game.pause()
	game.steve.state = game.STEVE_STATE_IDLE
	game.steveSprite:pause()
	physics.pause()
end

function game.resume()
	game.state = game.GAME_RUNNING
	game.steveSprite:play()
	physics.start()
end

function game.stop()
	game:removeAllEntities()

	Runtime:removeEventListener("enterFrame", moveCamera)
	Runtime:removeEventListener("collision", collisions.onCollision)
	Runtime:removeEventListener( "enterFrame", onUpdate )

	package.loaded[physics] = nil
	package.loaded[ui] = nil
	package.loaded[entity] = nil
	package.loaded[enemies] = nil
	package.loaded[npcs] = nil
	package.loaded[collisions] = nil
end

return game


