-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local composer = require ( "composer" )
local physics  = require ( "physics" )
local math     = require ( "math" )
local widget   = require ( "widget" )
local ui  	   = require ( "ui" )
local enemies  = require ( "enemies" )

local game = {}

physics.start()
physics.setGravity( 0, 35 )

--===========================================-- 

	local GAME_RUNNING    = "Running"
	local GAME_PAUSED     = "Paused"
	local GAME_RESUMED	  = "Resumed"
	local GAME_ENDED	  = "Ended"
	local STATE_IDLE 	  = "Idle"
	local STATE_WALKING   = "Walking"
	local STATE_JUMPING   = "Jumping"
	local STATE_ATTACKING = "Attacking"
	local STATE_DIED	  = "Died"
	local DIRECTION_LEFT  = -1
	local DIRECTION_RIGHT =  1
	local MAX_LIVES 	  =  3

	local buttonPressed
	local levelCompleted
	local posX, posY
	local spawnX, spawnY
	local controlsEnabled, SSVEnabled, SSVLaunched, letMeJump

--===========================================-- 



-- RUNTIME FUNCTIONS ---------------------------------------------------------------

	local function debug(event)
		--print("Steve Coordinates (x=" .. posX .. " , y=" .. posY .. ")")
		--print(game.steve.canJump)
		--print(game.steve.canJump)
		--print("Game " .. game.state)
		--print("Level ended: ")
		--print(levelCompleted)
		--print(spawnX .. "   " .. spawnY)

		--print(game.steve.canJump)
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

	local function onUpdate ()
		posX = game.steve.x
		posY = game.steve.y

		--	game.steveSprite.x , game.steveSprite.y = posX , posY
		if((game.steve.x) and (game.steve.y)) then
			game.steveSprite.x = game.steve.x 
			game.steveSprite.y = game.steve.y -10
		 	--(offset della sprite rispetto a game.steve)
			game.steveSprite.xScale = game.steve.direction
		end

		-- Deny jump if steve is falling
		if (SSVEnabled) then
			--print("controllo salto")
			local xv, yv = game.steve:getLinearVelocity()
			if (yv > 0 and letMeJump == false) then 
				game.steve.canJump = false
			elseif (yv == 0 and letMeJump == true) then
				game.steve.canJump = true
			end
			--print(game.steve.canJump)

				if(yv > 0) then
				game.steve.airState= "Falling"
			elseif(yv < 0) then
				game.steve.airState= "Jumping"

			elseif(yv == 0) then
				game.steve.airState= "Idle"
			end

		end

		-- Setting the AirState, needed for the Animation controls
		
			-- flag = game.steveSprite.sequence
			-- --Animation settings based on the steve states
			-- if((game.steve.state == STATE_WALKING) and game.steve.airState == "Idle") then

			-- 	game.steveSprite:setSequence("walking")
			-- 	game.testSprite:setSequence("walking")
			-- 	--game.testSprite:play()
			-- 	print("TEST Play()") 
				
			-- 	if(flag ~= "walking") then 
			-- 		print("Flag PRIMA: "..flag)
			-- 		for i=0, 10 do
			-- 		game.testSprite:play() 
			-- 		print("Play")
			-- 		 end
			-- 		game.steveSprite:play()
			-- 		--print("---------------Ho fatto play allo sprite")
			-- 		flag = game.steveSprite.sequence
			-- 		--print("Flag DOPO "..flag)
			-- 	end
			-- 	--	print("Ho fatto play allo sprite") end

			-- elseif((game.steve.state == STATE_IDLE) and game.steve.airState == "Idle") then
			-- 	game.steveSprite:setSequence("idle")
			-- 	--game.testSprite:setSequence
				
			-- 	if(flag ~= "idle") then 
			-- 		--game.testSprite:play() 
			-- 		--game.steveSprite:play()
			-- 		flag = game.steveSprite.sequence
			-- 	end
				

			-- elseif(game.steve.airState == "Falling") then
			-- 	game.steveSprite:setSequence("falling")
			-- 	if(flag ~= "falling") then 
			-- 		--game.testSprite:play() 
			-- 		--game.steveSprite:play()
			-- 		flag = game.steveSprite.sequence
			-- 	end
			-- 	--game.testSprite:setSequence("falling")
			-- 	--game.testSprite:play()

			-- elseif(game.steve.airState == "Jumping") then
			-- 	game.steveSprite:setSequence("jumping")
			-- 	if(flag ~= "jumping") then 
			-- 		--game.testSprite:play() 
			-- 		--game.steveSprite:play()
			-- 		flag = game.steveSprite.sequence
			-- 	end
			-- 	--game.steveSprite:play()
			-- 	-- game.testSprite:setSequence("walking")
			-- 	-- if(flag ~= "walking") then 
			-- 	-- 	game.testSprite:play()
			-- 	-- 	print("HO fatto Play") 
			-- 	-- 	flag = game.testSprite.sequence
			-- 	-- end
			-- end

			-- if(game.steve.state == STATE_ATTACKING) then
			-- 	game.steveSprite.alpha = 0
			-- else
			-- 	if(game.steveSprite.alpha == 0) then game.steveSprite.alpha = 1 end
			-- end

		local state = game.state
		if (state == GAME_RUNNING) then
		elseif (state == GAME_RESUMED) then
			game.resume()
		elseif (state == GAME_PAUSED) then
			game.pause()
		elseif (state == GAME_ENDED) then
			game.stop() 
		end
	end

	local function npcDetect( event )
		if (game.state == GAME_RUNNING) then
			playerPosX, playerPosY = game.steve.x, game.steve.y

			local rangeDetect = function(npc)
				local range = 50
				local isHere = false
				if (math.sqrt( (playerPosX-npc.x)^2 + (playerPosY-npc.y)^2 ) < range) then
					isHere = true
					npc.balloon:show()
					--npc.balloon.alpha = 1
				else
					isHere = false
					npc.balloon:hide()
					--npc.balloon.alpha = 0
					return false
				end

				if (isHere) then
					npc.balloon:show()
				else
					npc.balloon:hide()
				end
			end

			for i = 1, #game.npcs, 1  do
				if (game.npcs[i]) then
					rangeDetect(game.npcs[i])
				end
			end
		end
	end

	local function moveCamera( event ) 
		game.map:update(event)
	end
------------------------------------------------------------------------------------

-- PANEL WIDGET --------------------------------------------------------------------

	function widget.newPanel( options )
	    local customOptions = options or {}
	    local opt = {}
	 
	    opt.location = customOptions.location or "top"
	 
	    local default_width, default_height
	    if ( opt.location == "top" or opt.location == "bottom" ) then
	        default_width = display.contentWidth
	        default_height = display.contentHeight * 0.33
	    else
	        default_width = display.contentWidth * 0.33
	        default_height = display.contentHeight
	    end
	 
	    opt.width = customOptions.width or default_width
	    opt.height = customOptions.height or default_height
	 
	    opt.speed = customOptions.speed or 500
	    opt.inEasing = customOptions.inEasing or easing.linear
	    opt.outEasing = customOptions.outEasing or easing.linear
	 
	    if ( customOptions.onComplete and type(customOptions.onComplete) == "function" ) then
	        opt.listener = customOptions.onComplete
	    else 
	        opt.listener = nil
	    end
	 
	    local container = display.newContainer( opt.width, opt.height )
	 
	    if ( opt.location == "left" ) then
	        container.anchorX = 1.0
	        container.x = display.screenOriginX
	        container.anchorY = 0.5
	        container.y = display.contentCenterY
	    elseif ( opt.location == "right" ) then
	        container.anchorX = 0.0
	        container.x = display.actualContentWidth
	        container.anchorY = 0.5
	        container.y = display.contentCenterY
	    elseif ( opt.location == "top" ) then
	        container.anchorX = 0.5
	        container.x = display.contentCenterX
	        container.anchorY = 1.0
	        container.y = display.screenOriginY
	    elseif (opt.location == "npcPos") then
	    	container.x = npc.x
	    	container.y = npc.y-20
	    else
	        container.anchorX = 0.5
	        container.x = display.contentCenterX
	        container.anchorY = 0.0
	        container.y = display.actualContentHeight
	    end
	 
	    function container:show()
	        local options = {
	            time = opt.speed,
	            transition = opt.inEasing
	        }
	        if ( opt.listener ) then
	            options.onComplete = opt.listener
	            self.completeState = "shown"
	        end
	        if ( opt.location == "top" ) then
	            options.y = display.screenOriginY + opt.height
	        elseif ( opt.location == "bottom" ) then
	            options.y = display.actualContentHeight - opt.height
	        elseif ( opt.location == "left" ) then
	            options.x = display.screenOriginX + opt.width
	        else
	            options.x = display.actualContentWidth - opt.width
	        end 
	        transition.to( self, options )
	    end
	 
	    function container:hide()
	        local options = {
	            time = opt.speed,
	            transition = opt.outEasing
	        }
	        if ( opt.listener ) then
	            options.onComplete = opt.listener
	            self.completeState = "hidden"
	        end
	        if ( opt.location == "top" ) then
	            options.y = display.screenOriginY
	        elseif ( opt.location == "bottom" ) then
	            options.y = display.actualContentHeight
	        elseif ( opt.location == "left" ) then
	            options.x = display.screenOriginX
	        else
	            options.x = display.actualContentWidth
	        end 
	        transition.to( self, options )
	    end
	 
	    return container
	end


	local function panelTransDone( target )
	    --native.showAlert( "Panel", "Complete", { "Okay" } )
	    if ( target.completeState ) then
	        print( "PANEL STATE IS: "..target.completeState )
	    end
	end

	local panel = widget.newPanel{
		location = "top",
		onComplete = panelTransDone,
		width = display.actualContentWidth,
		height = display.actualContentHeight,
		speed = 250

	}
	panel.background = display.newImageRect( "sprites/balloons.png", 134, 107 )
	panel:insert( panel.background)

	panel.title = display.newText( "aiuto", display.contentCenterX, display.contentCenterY, native.systemFontBold, 18)
	panel.title:setFillColor( 1,1,1 )
	panel:insert(panel.title)


	local function handleButtonEvent(event)
		if("ended"==event.phase) then
			print("bottone premuto")
			panel:hide()
		end
	end


	--local button = widget.newButton( ){

		--balloon.button = display.newImageRect( "sprites/bottonefanculo.png", 58, 40 )
		--balloon.button.x = background.x
		--balloon.button.y = background.y -50

		--balloon:insert(balloon.button)
	--}
------------------------------------------------------------------------------------

-- MISCELLANEOUS FUNCTIONS ---------------------------------------------------------

	local function addScore(points)
		local pointsText = ui.getButtonByName("pointsText")
		local scoreText = ui.getButtonByName("scoreText")
		
		game.score = game.score + points
		scoreText.text = "Score: " .. game.score
		local pointsTimer = 250

		if (pointsText.isVisible == false) then
			pointsText.text = ("+" .. points)
			pointsText.isVisible = true 
			pointsTimer = 250
		end

		local pointsFade = function () 
			transition.to( pointsText, { alpha = 0, time = 250, effect = "crossfade", 
				onComplete = function() 
					pointsText.isVisible = false
					pointsText.alpha = 1
				end
				} ) 
		end
		timer.performWithDelay(pointsTimer, pointsFade)
	end

	--Update Life Icons: Works if we Lose or if we Get Lives
	local function updateLifeIcons()
		for i=1, #game.lifeIcons do
			if( i <= game.lives) then
				game.lifeIcons[i].isVisible = true
			else
				game.lifeIcons[i].isVisible = false
			end
		end
	end

	-- Endgame handler
	local function endGameScreen()
		SSVEnabled = false 		-- Prevents setSteveVelocity from accessing the physical Steve object
		game.map:setFocus( nil )
		display.remove(game.steve)
		display.remove(game.steveSprite)


		-- Display the exitText
			local exitText = display.newText( ui.uiGroup, "" , 250, 150, native.systemFontBold, 34 )
			if (levelCompleted == true) then
				exitText.text = "Level Complete"
				exitText:setFillColor( 0.75, 0.78, 1 )
			else
				exitText.text = "Game Over"
				exitText:setFillColor( 1, 0, 0 )
			end
			transition.to( exitText, { alpha=0, time=2000, onComplete = function() display.remove( exitText ) end } )
	    
		local endGame = function()
			game.ui:removeSelf( )

			-- Remove the event listener if endGame was triggered while pressing Dpad
			if (SSVLaunched) then
				Runtime:removeEventListener( "enterFrame", setSteveVelocity )
			end
		    composer.setVariable( "finalScore", game.score )
		    composer.removeScene( "highscores" )
		    composer.gotoScene( "highscores", { time=1500, effect="crossFade" } )
		end
		timer.performWithDelay( 1500, endGame )

		game.state = GAME_ENDED
		return true
	end

	-- Restores Steve at the current spawn point
	local function restoreSteve()
		transition.to(game.steve, { time=0, onComplete = function()
			game.steve.isBodyActive = false
			game.steve.x, game.steve.y = spawnX, spawnY
		end})

		game.map:fadeToPosition (spawnX, spawnY, 250)
		
		game.steve:setLinearVelocity( 0, 0 )
	    game.steve.state = STATE_IDLE

	    -- Fade in Steve's sprite
	    transition.to( game.steveSprite, { alpha = 1, time = 1000,
	        onComplete = function()
	            game.steve.isBodyActive = true
	            game.steve.state = STATE_IDLE
	            controlsEnabled = true
	            game.steveSprite:play()
	        end
	    } )  
	end
------------------------------------------------------------------------------------

-- COLLISION HANDLERS --------------------------------------------------------------

	-- Collision with Environments (Generic)
	local function environmentCollision( event )
		local env = event.object1
		local other = event.object2

		if(event.object2.isGround) then 
			env = event.object2
			other = event.object1
		end

		if (event.phase == "began" and env.isGround) then
			other.canJump = true
			game.steve.isTouchingGround = true -- non usata
		end
		--[[
		elseif(event.phase == "cancelled" or event.phase == "ended" ) then
			timer.performWithDelay( 250, function() other.canJump = false end )
			print("collision ended")
		end
		]]

	end

	-- Collision with Coins (Only for Steve)
	local function coinCollision( event )
		local steveObj = event.object1
		local coin = event.object2

		if(event.object2.myName =="steve") then 
			steveObj = event.object2
			coin = event.object1
		end

		if ( event.phase == "began" ) then
			audio.play( coinSound )
			coin.BodyType = "dynamic"
			display.remove( coin )
			addScore(100)

		elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		end
	end

	-- Collision with enemies and dangerous things (Only for Steve)
	local function dangerCollision( event )
		local other = event.object2
		if(event.object2.myName == "steve") then
			other = event.object1
		end

		-- Avoid Steve to take damage from enemy while attacking 
		-- (but only if the enemy isn't invincible)
		if ( (game.steve.state ~= STATE_ATTACKING and (other.isEnemy or other.isDanger) ) or
			 (game.steve.state == STATE_ATTACKING and other.isDanger) ) then 

			if (game.steve.state ~= STATE_DIED) then 
				game.steve.state = STATE_DIED

				audio.play( dangerSound )

				-- \\ CRITICAL CODE // --
				controlsEnabled = false
				SSVEnabled = false
				-- NON SPOSTARE CANI MALEDETTI --

				game.lives = game.lives - 1
				--ui.getButtonByName("livesText").text = "Lives: " .. game.lives
				updateLifeIcons()	--Refresh the Life Icons
				
				if ( game.lives == 0 ) then
					endGameScreen()
				else
					transition.to(game.steveSprite, { alpha=0, time=0, onComplete = function() 
						game.steve.isBodyActive = false
						game.steveSprite:setSequence("idle")
						game.steveSprite:pause()
						restoreSteve()
					end
					} )
				end
			end
		end
	end

	-- Collision with the Steve Attack
	local function steveAttackCollision( event )
		local attack = event.object1
		local other = event.object2

		if(other.myName == "steveAttack") then
			attack = event.object2
			other = event.object1
		end

		-- Other is an enemy, targettable AND not invincible
		if( other.isEnemy and other.isTargettable == true ) then 
			other.lives = other.lives - 1

			other.alpha = 0.5 -- Make the enemy temporairly untargettable 
			other.isTargettable = false

			if ( other.lives == 0 ) then -- Enemy has no lives left
				other.isSensor = true
				other.isEnemy = false
				timer.performWithDelay(1000, other:applyLinearImpulse( 0.05, -0.30, other.x, other.y ))
				other.yScale = -1
				timer.performWithDelay(5000, function() other:removeSelf() end)
				addScore(200) -- We will modify this
			
			else -- Enemy is still alive
				
				local removeMobImmunity = function() 
					other.alpha=1 
					other.isTargettable = true
				end
				timer.performWithDelay(500, removeMobImmunity)

				-- Knocks back the enemy
				if (other.x > game.steve.x) then other:applyLinearImpulse(1,1,other.x,other.y) 
				elseif (other.x < game.steve.x) then other:applyLinearImpulse(-1,1,other.x,other.y)
				end
			end

		-- If the object is a item that can be destroyed from steve attacks
		elseif( other.canBeBroken ) then
			display.remove(other)
		end
	end

	-- Generic Collision Handler
	function onCollision( event )
		if ( (event.object1.myName == "steve") or 
			 (event.object2.myName == "steve") ) then
			
			local steveObj = event.object1
			local other = event.object2

			if(other.myName =="steve") then 
				steveObj = event.object2
				other = event.object1
			end

			-- Collision Type
			if(other.myName == "env") then
				environmentCollision(event)
			elseif (other.myName == "coin") then
				coinCollision(event)
			elseif (other.isEnemy or other.isDanger) then
				dangerCollision(event)
			elseif(other.myName == "end_level") then
				levelCompleted = true
				controlsEnabled = false
				SSVEnabled = false
				endGameScreen()
			else
				letMeJump = true -- force enable the jump
			end

		-- SteveAttack collisions are handled by the attackedBySteve method
		elseif( (event.object1.myName == "steveAttack") or 
			    (event.object2.myName == "steveAttack") ) then
			steveAttackCollision( event )
		end
	end
------------------------------------------------------------------------------------


-- CONTROLS HANDLERS ---------------------------------------------------------------
	
	local function setSteveVelocity()
		if (SSVEnabled) then
			SSVLaunched = true
			local steveXV, steveYV = game.steve:getLinearVelocity()
			game.steve:setLinearVelocity(game.steve.actualSpeed, steveYV)
		end
	end

	local function dpadTouch(event)
		local target = event.target
		local lbutton = ui.getButtonByName("dpadLeft")
		local rbutton = ui.getButtonByName("dpadRight")

		if (game.state == GAME_RUNNING) then
			if (event.phase == "began") then
				display.currentStage:setFocus( target )

				if (target.myName == "dpadLeft") then
					game.steve.direction = DIRECTION_LEFT
					lbutton.alpha = 0.8
				elseif (target.myName == "dpadRight") then
					game.steve.direction = DIRECTION_RIGHT
					rbutton.alpha = 0.8
				end

				if (controlsEnabled) then
					SSVEnabled = true
					game.steve.state = STATE_WALKING

					--avoid walking animation in mid air
					if(game.steve.airState == "Idle" or game.steve.airState == nil) then
						game.steveSprite:setSequence("walking")
						game.steveSprite:play()
					end

					Runtime:addEventListener("enterFrame", setSteveVelocity)
					game.steve.actualSpeed = game.steve.direction * game.steve.speed
					game.steve.xScale = game.steve.direction
				end

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				game.steve.state = STATE_IDLE

				game.steveSprite:setSequence("idle")
			
				Runtime:removeEventListener("enterFrame", setSteveVelocity)	

				lbutton.alpha, rbutton.alpha = 0.1, 0.1
				display.currentStage:setFocus( nil )
			end
		end

		return true --Prevents touch propagation to underlying objects
	end

	local function jumpTouch(event)
		if (game.state == GAME_RUNNING) then
			if (event.phase == "began") then
				display.currentStage:setFocus( event.target )
				if (controlsEnabled and game.steve.canJump == true) then
					audio.play( jumpSound )
					game.steve.state = STATE_JUMPING

					game.steve:applyLinearImpulse(0,game.steve.jumpHeight, game.steve.x, game.steve.y)
					game.steve.canJump = false
					letMeJump = false
				end

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				display.currentStage:setFocus( nil )
			end
		end
		
		return true --Prevents touch propagation to underlying objects
	end

	local function actionTouch( event )
		local attackDuration = 500
		local actionBtn = event.target

		if (game.state == GAME_RUNNING) then
			if (event.phase=="began" and actionBtn.active == true) then
				display.currentStage:setFocus( actionBtn )

				if (controlsEnabled) then
					audio.play( attackSound )

					actionBtn.active = false
					actionBtn.alpha = 0.5
					game.steve.state = STATE_ATTACKING
					steveAttack = display.newCircle( game.steve.x, game.steve.y, 40)
					physics.addBody(steveAttack, {isSensor = true})
					steveAttack.myName = "steveAttack"
					steveAttack:setFillColor(0,0,255)
					steveAttack.alpha=0.6
				  	game.map:getTileLayer("playerEffects"):addObject( steveAttack )
				  	game.steveSprite.alpha=0

				  	-- Make steve dash forward
				  	game.steve:applyLinearImpulse( game.steve.direction * 8, 0, game.steve.x, game.steve.y )

					-- Link the SteveAttack to Steve
					local steveAttackFollowingSteve = function ()
						steveAttack.x, steveAttack.y = game.steve.x, game.steve.y
					end

					-- Handle the end of the SteveAttack phase
					local steveAttackStop = function ()
						display.remove(steveAttack)
						game.steve.state = STATE_IDLE
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

	local function pauseResume(event)
		local target = event.target
		local psbutton = ui.getButtonByName("pauseBtn")
		local rsbutton = ui.getButtonByName("resumeBtn")

		if (event.phase == "began") then
			display.currentStage:setFocus( target )

		elseif (event.phase == "ended" or "cancelled" == event.phase) then
			if (target.myName == "pauseBtn") then
				game.state = GAME_PAUSED
		        psbutton.isVisible = false
		        rsbutton.isVisible = true
		    elseif (target.myName == "resumeBtn") then
		    	game.state = GAME_RESUMED
		    	psbutton.isVisible = true
		        rsbutton.isVisible = false
		    end
		    display.currentStage:setFocus( nil )
		end

		return true --Prevents touch propagation to underlying objects
	end

	--// DA COMPLETARE //
	local function balloonTouch(event)
		if (game.state == GAME_RUNNING) then
			if (event.phase == "began") then
				display.currentStage:setFocus( event.target )

			elseif (event.phase == "ended" or "cancelled" == event.phase) then
				display.currentStage:setFocus( nil )
			end
		end

		return true --Prevents touch propagation to underlying objects
	end
------------------------------------------------------------------------------------


-- GAME INITIALIZATION -------------------------------------------------------------
	
 	function game.loadPlayer()
	
 		local sheetData ={
 			height = 50,
 			width = 30,
 			numFrames = 4,
 			sheetContentWidth = 120,--120,
        	sheetContentHeight = 50--40
 	 	}

 	 	local walkingSheet = graphics.newImageSheet("sprites/steveAnim.png", sheetData)

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

	
		game.steve = display.newImageRect( "sprites/rock_original.png", 30, 30 )
		game.steve.alpha = 0 
		game.steve.myName = "steve"
		game.steve.rotation = 0
		game.steve.speed = 180
		game.steve.jumpHeight = -18
		physics.addBody( game.steve, { density=1.0, friction=0.7, bounce=0.01} )
		game.steve.isFixedRotation = true
		game.steve.state = STATE_IDLE
		game.steve.direction = DIRECTION_RIGHT
		game.steve.canJump = false

		game.steve.x, game.steve.y = spawnX, spawnY
	end

	function game.loadEnemies()
		--Crea visivamente e con i relativi attributi tutti i nemici sulla mappa (Richiede che sulla mappa ci siano degli OGGETTI con il tipo = tipoNemico)

		--Riazzeriamo la lista dei nemici di un livello appena il gioco si carica
		game.enemyLevelList = {}
		local enemy = nil
		local enemyList = game.map:getObjectLayer("enemySpawn").objects

		for k, v in pairs(enemyList) do
			enemy = enemyList[k]
			--print ("primax= "..enemy.x.." primay= "..enemy.y)
			local en = enemies.createEnemy(enemy, enemy.type)
			--assegno qui la posizione perchè nella funzione precedente magicamente si perdono i valori della posizione
				en.x = enemy.x
				en.y = enemy.y
			game.map:getTileLayer("entities"):addObject( en )
			table.insert (game.enemyLevelList , en)
		end
	end

	function game.loadNPCS() 
		local layer = game.map:getObjectLayer("npcSpawn")
		game.npcs = layer:getObjects("npc")

		local loadNPC = function(npc)
			npc.image = display.newImageRect( "sprites/pinkie.png", 70, 70 )
			npc.image.x, npc.image.y = npc.x, npc.y 
			--physics.addBody( npc.image, {friction = 1.0})
			game.map:getTileLayer("entities"):addObject(npc.image)

		
			--npc.balloon = ui.createBalloon()

			npc.balloon = panel

			game.map:getTileLayer("entities"):addObject(npc.balloon)
			--npc.balloon.x, npc.balloon.y = npc.x, npc.y -20
			--npc.balloon.alpha = 1
			npc.balloon:show()

			--npc.balloon.button:addEventListener( "touch", balloonTouch )
		end

		for i = 1, #game.npcs, 1 do
			loadNPC(game.npcs[i])
		end
	end

	function game.loadUi()
		game.ui = ui.loadUi()

		-- Add the UI event listeners
		ui.getButtonByName("jumpScreen"):addEventListener("touch", jumpTouch)
		ui.getButtonByName("dpadLeft"):addEventListener("touch", dpadTouch)
		ui.getButtonByName("dpadRight"):addEventListener("touch", dpadTouch)
		ui.getButtonByName("actionBtn"):addEventListener("touch", actionTouch)
		ui.getButtonByName("pauseBtn"):addEventListener("touch", pauseResume)
		ui.getButtonByName("resumeBtn"):addEventListener("touch",pauseResume)
		
		-- Display the number of starting lives (specified by MAX_LIVES)
		--ui.getButtonByName("livesText").text = "Lives: ".. game.lives
		-- Display the life icon structure
		game.lifeIcons = ui.createLifeIcons(game.lives)

		local dpadLeft = ui.getButtonByName("dpadLeft")
		local dpadRight = ui.getButtonByName("dpadRight")
		local function grayOut()
			transition.to( dpadLeft, {time = 1000, alpha = 0.1}  ) 
			transition.to( dpadRight, {time = 1000, alpha = 0.1} ) 
		end
		timer.performWithDelay( 2000, grayOut)
	end

	function game.loadSounds()
		--backgroundMusic = audio.loadStream("audio/overside8bit.wav")
		backgroundMusic = audio.loadStream( nil )
		jumpSound = audio.loadSound("audio/jump.wav")
		coinSound = audio.loadSound("audio/coin.wav")
		attackSound = audio.loadSound( "audio/attack.wav")
		dangerSound = audio.loadSound( "audio/danger3.wav")
	end

	function game.disposeSounds()
		audio.dispose( backgroundMusic )
		audio.dispose( jumpSound )
		audio.dispose( coinSound )
		audio.dispose( attackSound )
		audio.dispose( dangerSound )
	end

	--[[  -- NOT USED -- 
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



	function game.loadGame( map, spawn )
		-- Locally stores the current level map and spawn coordinates
		game.map = map
		spawnX, spawnY = spawn.x, spawn.y

		game.score = 0
		game.lives = MAX_LIVES
		levelCompleted = false

		game.loadPlayer()
		game.loadEnemies()
		game.loadNPCS()
		game.loadUi()
		game.loadSounds()

		SSVEnabled = true
		controlsEnabled = true
		SSVLaunched = false

		physics.start()
		physics.pause()
	end
------------------------------------------------------------------------------------



function game.start()
	game.state = GAME_RUNNING
	game.steveSprite:play()
	physics.start()
	Runtime:addEventListener("enterFrame", moveCamera)
	Runtime:addEventListener("enterFrame", npcDetect)
	Runtime:addEventListener("collision", onCollision)
	Runtime:addEventListener("enterFrame", onUpdate)
	timer.performWithDelay(200, debug, 0)
	audio.play(backgroundMusic, {channel = 1 , loops=-1})
end

function game.pause()
	game.steve.state = STATE_IDLE
	game.steveSprite:pause()	
	physics.pause()
	audio.pause(1)
end

function game.resume()
	game.state = GAME_RUNNING
	game.steveSprite:play()
	physics.start()
	audio.resume(1)
end

function game.stop()
	game.disposeSounds()
	package.loaded[physics] = nil
	Runtime:removeEventListener("enterFrame", moveCamera)
	Runtime:removeEventListener("enterFrame", npcDetect)
	Runtime:removeEventListener("collision", onCollision)
	Runtime:removeEventListener( "enterFrame", onUpdate )

	--audio.stop(1)
end



return game



