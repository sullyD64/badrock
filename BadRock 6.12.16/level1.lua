-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

lime = require("lime.lime")

local physics = require ("physics")
physics.start()
physics.setGravity( 0, 30 )

-- -----------------------------------------------------------------------------------
-- SCENE-ACCESSIBLE CODE
-- -----------------------------------------------------------------------------------

-- forward declarations and other locals
	local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
	local dpad, jumpScreen, actionBtn
	local steveAttack
	local backgroundMusic, jumpSound, coinSound, attackSound, dangerSound

	local STATE_IDLE 	  = "Idle"
	local STATE_WALKING   = "Walking"
	local STATE_JUMPING   = "Jumping"
	local STATE_ATTACKING = "Attacking"
	local DIRECTION_LEFT  = -1
	local DIRECTION_RIGHT =  1

	local map, visual, physical
	local mainGroup, uiGroup, pauseGroup
	local steve

	lifeIcons = {}
	local lives = 3
	local MAX_LIVES = 5
	local score = 0
	local died = false
	local levelCompleted = false
	local livesText, scoreText, pointsText, exitText
	pointsText = "+100"

	--[[
	local function updateText()
	    livesText.text = "Lives: " .. lives
	    scoreText.text = "Score: " .. score
	end
	]]


-- CAMERA FUNCTIONS ----------------------------------------------------------------
	--local perspective = require("perspective")
	--local camera = perspective.createView()

	--[[
	local function moveCamera()
		if ( camera ) then
			local leftOffset = 95
			local screenLeft = -camera.x
			local safeMoveArea = 290
			if steve.x > leftOffset then
				if steve.x > screenLeft + safeMoveArea then
					camera.x = -steve.x + safeMoveArea
					elseif steve.x < screenLeft + leftOffset then
						camera.x = -steve.x + leftOffset
				end
			else
				camera.x  = 0
			end
		end
	end
	]]

	local function moveCamera( event )
		map:update(event)
	end
------------------------------------------------------------------------------------


-- MISC FUNCTIONS ------------------------------------------------------------------

	-- Endgame handler
	local function endGame()
	    composer.setVariable( "finalScore", score )
	    composer.removeScene( "highscores" )
	    composer.gotoScene( "highscores", { time=1500, effect="crossFade" } )
	end

	-- Endgame screen handler
	local function endGameScreen()
		steve.alpha = 0
		camera:cancel() --Stop camera Tracking
		display.remove(mainGroup)
		display.remove(uiGroup)

		if (levelCompleted == true) then
			exitText = display.newText( pauseGroup, "Level Complete" , 250, 150, native.systemFontBold, 34 )
			exitText:setFillColor( 0.75, 0.78, 1 )
		else
			exitText = display.newText( pauseGroup, "Game Over" , 250, 150, native.systemFontBold, 34 )
			exitText:setFillColor( 1, 0, 0 )
		end

		transition.to( exitText, { alpha=0, time=2000,
	        onComplete = function()
	            display.remove( exitText )
	        end
	    } )
		timer.performWithDelay( 1500, endGame )

		return true
	end

	-- Replaces Steve on the spawn point
	local function restoreSteve()
		--local steve
		--local layer = map:getObjectLayer("playerSpawn")
		--local spawn = layer:getObject("playerSpawn")
		steve.x, steve.y = spawn.x , spawn.y

	    steve.isBodyActive = false
	    steve:setLinearVelocity( 0, 0 )
	    steve.rotation = 0
	    steve.isGrounded = false
	    -- Fade in Steve
	    transition.to( steve, { alpha = 1, time = 1000,
	        onComplete = function()
	            steve.isBodyActive = true
	            died = false
	        end
	    } )
	end

	-- Add points to the score
	local function addScore( points )
		score = score + points
		scoreText.text = "Score: " .. score
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

	-- Remove one life             -- WORK IN PROGRESS -- 
	function decrementLives()
		
		if (lives > 0) then
			lives = lives - 1
			livesText.text = "Lives: " .. lives
			
		end
		--lifeIcons[lives].isVisible = false
		--end
		--[[lives = lives + 1
		if lives &gt; MAX_LIVES then
		lives = MAX_LIVES
		end
		lifeIcons[lives].isVisible = true]]
		-- Steve has no lives left
	end

	--Getters and setters for Entity speed and jump height (generic)
		local function setEntitySpeed(entity, value)
			entity.speed = value
		end

		local function setEntityJumpHeight(entity, value)
			entity.jumpHeight = value
		end

	-- Allows Steve to move on the x-axis while mid-air
	local function setSteveVelocity()
		local steveXV, steveYV = steve:getLinearVelocity()
		steve:setLinearVelocity(steve.actualSpeed, steveYV) 
	end
------------------------------------------------------------------------------------


-- ATTACK FUNCTIONS ----------------------------------------------------------------

	-- Links the SteveAttack to Steve
	local function steveAttackFollowingSteve()
		steveAttack.x, steveAttack.y = steve.x, steve.y
	end

	-- Handles the end of the SteveAttack phase
	local function steveAttackStop()
		-- Quando finisce il tempo di attacco di Steve
		display.remove(steveAttack)
		steve.state = STATE_IDLE
		Runtime:removeEventListener("enterFrame" , steveAttackFollowingSteve)
		--Rende il tasto nuovamente premibile
		actionBtn.active = true
		actionBtn.alpha = 1
	end

	-- Action Button Method
	local function actionTouch( event )
		local attackDuration = 500

		if (event.phase=="began" and actionBtn.active == true) then
			display.currentStage:setFocus( event.target )
			audio.play( attackSound )

			--Evita che il button di azione sia permaspammato
			actionBtn.active=false
			actionBtn.alpha = 0.5

			steve.state = STATE_ATTACKING

			steveAttack = display.newCircle(mainGroup , steve.x, steve.y, 40)
			physics.addBody(steveAttack, {isSensor = true})
			steveAttack.myName = "steveAttack"


			--Statistiche momentanee per rendere visibile l'area d'attacco
			steveAttack:setFillColor(0,0,255)
			steveAttack.alpha=0.6
		  	--camera:add(steveAttack,1, false)
			map:getTileLayer("playerEffects"):addObject(steveAttack)

		  	-- Fa rotolare Steve nella direzione in cui sta guardando
		  	steve:applyLinearImpulse(steve.direction * 10, 0,steve.x,steve.y)

			Runtime:addEventListener("enterFrame", steveAttackFollowingSteve)
			timer.performWithDelay(attackDuration, steveAttackStop)
			display.currentStage:setFocus( nil )
		end

		return true --Prevents touch propagation to underlying objects
	end
------------------------------------------------------------------------------------


-- COLLISION HANDLERS --------------------------------------------------------------

	-- Collision with Environments (Generic)
	function environmentCollision( event )
		local env = event.object1
		local other = event.object2

		if(event.object2.isGround) then 
			env = event.object2
			other = event.object1
		end

		if (event.phase == "began" and env.isGround) then
			other.canJump = true
		end
	end

	-- Collision with Coins (Only for Steve)
	function coinCollision( event )
		local steveObj = event.object1
		local coin = event.object2

		if(event.object2.myName =="steve") then 
			steveObj = event.object2
			coin = event.object1
		end

		if ( event.phase == "began" ) then
			audio.play( coinSound )
			display.remove( coin )
			addScore(100)

		elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		end
	end

	-- Collision with enemies and dangerous things (Only for Steve)
	function dangerCollision( event )
		local other = event.object2
		if(event.object2.myName == "steve") then
			other = event.object1
		end

		--Avoids Steve to take damage from enemy while attacking (but only if the enemy isn't invincible)
		if ( (steve.state ~= STATE_ATTACKING and other.isEnemy) or
			 (steve.state == STATE_ATTACKING and other.isInvincible) ) then 

			if (died == false) then 
				died = true
				audio.play( dangerSound )
				decrementLives()
				if ( lives == 0 ) then
					endGameScreen()
				else
					steve.alpha = 0
					timer.performWithDelay( 50, restoreSteve )
				end
			end
		end
	end

	-- Special handler for the "End Level" block (Only for Steve)
	function endCollision( event )
		if ( event.phase == "began" ) then
			levelCompleted = true
			endGameScreen()
		end
	end

	-- Steve Collisions Handler
	function steveCollisions( event )
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
		elseif ((other.myName == "nemico") or (other.isEnemy)) then
			dangerCollision(event)
		elseif(other.myName == "end_level") then
			endCollision(event)
		end
	end

	-- Steve's "attack" Collisions Handler
	local function steveAttackCollision( event )
		local attack = event.object1
		local other = event.object2

		if(other.myName == "steveAttack") then
			attack = event.object2
			other = event.object1
		end

		-- Other is an enemy, targettable AND not "invincible"
		if( (other.isEnemy == true ) and (other.isInvincible == false) and (other.alpha == 1) ) then 
			other.lives = other.lives - 1

			-- Enemy has no lives left
			if ( other.lives == 0 ) then 
				display.remove(other)
				addScore(200) -- Successivamente al posto di 200, useremo other.score, perchè ogni nemico ha un suo valore
			
			-- Enemy is still alive
			else 
				other.alpha = 0.5 -- Make the enemy temporairly untargettable 
				local removeImmunity = function() 
					other.alpha=1 
				end
				timer.performWithDelay(500, removeImmunity)

				-- Little "knockBack" of the enemy when is hit from Steve (pushed Away from Steve) 
				if (other.x > steve.x) then other:applyLinearImpulse(1,1,other.x,other.y) --if the enemy is on the Steve's Right
				elseif (other.x < steve.x) then other:applyLinearImpulse(-1,1,other.x,other.y) --if the enemy is on the Steve's Left
				end
			end

		-- If the object is a item that can be destroyed from steve attacks
		elseif(other.canBeBroken) then
			display.remove(other)
		end
	end

	-- Generic Collision Handler
	function onCollision( event )
		if ( (event.object1.myName == "steve") or 
			 (event.object2.myName == "steve") ) then
			steveCollisions( event )

		-- SteveAttack collisions are handled by the attackedBySteve method
		elseif( (event.object1.myName == "steveAttack") or 
			    (event.object2.myName == "steveAttack") ) then
			steveAttackCollision( event )
		end
	end
------------------------------------------------------------------------------------


-- CONTROLS HANDLERS ---------------------------------------------------------------

	local function dpadTouch(event)
		local target = event.target

		if (event.phase=="began") then

			display.currentStage:setFocus( target )
			steve.state = STATE_WALKING
			Runtime:addEventListener("enterFrame", setSteveVelocity)
			if (target.myName == "dpadLeft") then
				steve.direction = DIRECTION_LEFT
				dpadLeft.alpha = 0.5
			elseif (target.myName == "dpadRight") then
				steve.direction = DIRECTION_RIGHT
				dpadRight.alpha = 0.5
			end

			steve.actualSpeed = steve.direction * steve.speed
			steve.xScale = steve.direction

		elseif (event.phase =="ended" or "cancelled" == event.phase) then
			Runtime:removeEventListener("enterFrame", setSteveVelocity)
			steve.state = STATE_IDLE
			dpadLeft.alpha, dpadRight.alpha = 1, 1
			display.currentStage:setFocus( nil )
		end

		return true --Prevents touch propagation to underlying objects
	end

	local function jumpTouch( event )
		if (event.phase=="began") then
			if (steve.canJump) then
				audio.play( jumpSound )
				steve:applyLinearImpulse(0,steve.jumpHeight, steve.x, steve.y)
				steve.state = STATE_JUMPING
				steve.canJump = false
			end
		end
	end

	local function pauseResume(event)
		local target = event.target

			if (event.phase=="began") then
				display.currentStage:setFocus( target )
				steve.state = STATE_IDLE

			elseif(event.phase == "ended" or "cancelled" == event.phase) then
				if (target.myName == "pauseBtn") then
					physics.pause()
					audio.pause(1)
			        pauseBtn.isVisible = false
			        resumeBtn.isVisible = true
			    elseif (target.myName == "resumeBtn") then
			    	physics.start()
			    	audio.resume(1)
			        pauseBtn.isVisible = true
			        resumeBtn.isVisible = false
			    end
				display.currentStage:setFocus( nil )
			end

		return true
	end
------------------------------------------------------------------------------------



-- TESTING ANIMATION
--[[local onPlayerProperty = function(property, type, object)
  steve = object.sprite

  steve.state = STATE_IDLE
  steve:setSequence("anim" .. steve.state)
  steve:play()
  --steve.collision = onCollision
  --steve:addEventListener( "collision", player )
end]]



-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	physics.pause()

	-- MUSIC AND SOUNDS -----------------------------
		backgroundMusic = audio.loadStream("audio/overside8bit.wav")
		--backgroundMusic = audio.loadStream( nil )
		jumpSound = audio.loadSound("audio/jump.wav")
		coinSound = audio.loadSound("audio/coin.wav")
		attackSound = audio.loadSound( "audio/attack.wav")
		dangerSound = audio.loadSound( "audio/danger3.wav")
	-------------------------------------------------

	-- SCENE GROUPS ---------------------------------
		map = lime.loadMap("testmap_new.tmx")
		visual = lime.createVisual(map)
		sceneGroup:insert( visual )

		mainGroup = display.newGroup()
		sceneGroup:insert( mainGroup )

		--sceneGroup:insert(camera)

		uiGroup = display.newGroup()
		sceneGroup:insert( uiGroup )

		pauseGroup = display.newGroup()
		sceneGroup:insert( pauseGroup )
	-------------------------------------------------

	-- Apply physics to the map
	physical = lime.buildPhysical(map)	

	-- UI OPTIONS -----------------------------------
		-- The jump "button" is screen-wide
		jScreen = display.newImageRect(uiGroup, "ui/emptyScreen.png", display.contentWidth, display.contentHeight )
		jScreen.x, jScreen.y = display.contentCenterX , display.contentCenterY
		jScreen.myName = "jumpScreen"
		jScreen:toBack()
		jScreen:addEventListener( "touch", jumpTouch )

		-- Load the d-pad
		dpadLeft = display.newImageRect( uiGroup, "ui/dpadLeft.png", 50, 52 )
		dpadLeft.anchorX, dpadLeft.anchorY = 0, 1
		dpadLeft.x, dpadLeft.y = dpadLeft.width / 2 + 10, display.contentHeight - dpadLeft.height / 2 - 10
		dpadLeft.myName = "dpadLeft"
		dpadLeft:addEventListener( "touch", dpadTouch )

		dpadRight = display.newImageRect( uiGroup, "ui/dpadRight.png", 50, 52 )
		dpadRight.anchorX, dpadRight.anchorY = 0, 1
		dpadRight.x, dpadRight.y = dpadLeft.x + dpadRight.width, dpadLeft.y
		dpadRight.myName = "dpadRight"
		dpadRight:addEventListener( "touch", dpadTouch )

		-- Load the action button DA IMPLEMENTARE
		actionBtn = display.newImageRect( uiGroup, "ui/actionbtn.png", 51, 51 )
		actionBtn.anchorX, actionBtn.anchorY = 1, 1
		actionBtn.x, actionBtn.y = display.contentWidth - actionBtn.width / 2, display.contentHeight -10 - actionBtn.height / 2
		actionBtn.myName = "actionBtn"
		actionBtn:addEventListener( "touch", actionTouch ) 
		actionBtn.active = true -- to avoid Action spam
	     
	    -- Pause and resume buttons
	    pauseBtn = display.newImageRect( uiGroup, "ui/pause.png", 35, 35 )
	    pauseBtn.anchorX, pauseBtn.anchorY = 1, 0
	    pauseBtn.x, pauseBtn.y = display.contentWidth -10, 30
	    pauseBtn.myName="pauseBtn"
	    pauseBtn:addEventListener( "touch", pauseResume )

	    resumeBtn = display.newImageRect( uiGroup, "ui/resume.png", 35, 35 )
	    resumeBtn.anchorX, resumeBtn.anchorY = 1, 0
	    resumeBtn.x, resumeBtn.y = pauseBtn.x, pauseBtn.y
	    resumeBtn.myName="resumeBtn"
	    resumeBtn.isVisible = false
	    resumeBtn:addEventListener( "touch", pauseResume ) 

		-- Lives and score texts
		local i, currIcon
		for i = 1, lives do
			currIcon = lifeIcons[i]
	    	currIcon = display.newImageRect( uiGroup, "ui/life.png", 30, 30 )
	    	currIcon.anchorX, currIcon.anchorY = 0, 0
	    	currIcon.x = 10 + currIcon.contentWidth / 2 + (currIcon.contentWidth * (i - 1))
	    	currIcon.y = 10 + currIcon.contentHeight / 2
	    	currIcon.isVisible = true
		end

		livesText = display.newText( uiGroup, "Lives: " .. lives, 0, 0, native.systemFont, 24 )
		livesText.anchorX, livesText. anchorY = 0, 0
		livesText.x, livesText.y = 10, 50
		livesText:setFillColor( 255,0,0 )

		scoreText = display.newText( uiGroup, "Score: " .. score, 0, 0, native.systemFont, 24 )
		scoreText.anchorX, scoreText. anchorY = 1, 0
		scoreText.x, scoreText.y = display.contentWidth -20 - pauseBtn.contentWidth, 30
		scoreText:setFillColor( 0,0,255 )

		pointsText = display.newText( uiGroup, "", display.contentWidth - 80, 60, native.systemFont, 14 )
		pointsText:setFillColor( 0,0,255 )
		pointsText.isVisible = false
	-------------------------------------------------

	-- CHARACTER OPTIONS ----------------------------

		--[[local layer = map:getTileLayer("player")
		players = layer:getTIlesWithProperty("isPlayer")
		steve = players:get]]

		-- Load Steve, the player avatarS
		local layer = map:getObjectLayer("playerSpawn")
		spawn = layer:getObject("playerSpawn")
		steve = display.newImageRect( mainGroup, "sprites/rock.png", 32, 32 )
		steve.x, steve.y = spawn.x, spawn.y
		steve.rotation = 0
		steve.myName = "steve"
		setEntitySpeed (steve, 150)
		setEntityJumpHeight (steve, -18)
		physics.addBody( steve, { density=1.0, friction=0.7, bounce=0.01 } )
		steve.isFixedRotation = true
		steve.direction = DIRECTION_RIGHT

		map:getTileLayer("playerObject"):addObject(steve)
	-------------------------------------------------

	-- CAMERA OPTIONS -------------------------------
	  	--[[
	  	-- second parameter is the Layer number
	  	-- third parameter is the focus on that object
	  	camera:add( visual,	2,	false )
	  	camera:add( steve, 	1,	true  )

		-- slow the track of a specific layer (for backgrounds)
		-- 1 is equal to us, 0.5 is half track
		camera:layer(1).parallaxRatio = 1
		camera:layer(2).parallaxRatio = 1



		-- set the screen limits for the camera
		--camera:setBounds(0, steve.x ,-100, steve.y)	-- TEST IN CORSO
		
		-- set the follow speed of the focused layer 
		camera.dumping = 10
		]]

		map:setFocus( steve )
	-------------------------------------------------
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if ( phase == "will" ) then
		
	elseif ( phase == "did" ) then
		Runtime:addEventListener("enterFrame", moveCamera)
        Runtime:addEventListener( "collision", onCollision)

		--camera:track() -- start the camera tracking
		physics.start()

		audio.play(backgroundMusic, {channel = 1 , loops=-1})
	end
end

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if ( phase == "will" ) then
	
	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "collision", onCollision)
       
		physics.stop()
		audio.stop(1)
	end		
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	
	audio.dispose( backgroundMusic )
	audio.dispose( jumpSound )
	audio.dispose( coinSound )
	audio.dispose( attackSound )
	audio.dispose( dangerSound )
	package.loaded[physics] = nil
	physics = nil
	camera = nil
end

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTION LISTENERS
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene