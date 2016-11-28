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
local backgroundMusic
local dpad, jumpScreen, actionBtn

local STATE_IDLE = "Idle"
local STATE_WALKING = "Walking"
local STATE_JUMPING = "Jumping"
local DIRECTION_LEFT = -1
local DIRECTION_RIGHT = 1

local map, visual, physical
local steve

local lives = 3
local score = 0
local died = false
local livesText, scoreText, pointsText
pointsText = "+100"

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
    pointsText.text = "+100"
end

local function restoreSteve()
	--local steve
	local layer = map:getObjectLayer("playerSpawn")
	local spawn = layer:getObject("playerSpawn")
	steve.x, steve.y = spawn.x , spawn.y

    steve.isBodyActive = false
    steve:setLinearVelocity( 0, 0 )
    steve.rotation=0
    steve.isGrounded= false
    -- Fade in the steve
    transition.to( steve, { alpha=1, time=2500,
        onComplete = function()

            steve.isBodyActive = true
            
            died = false
        end
    } )
end

local function endGame()
    composer.setVariable( "finalScore", score )
    composer.removeScene( "highscores" )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end


-- CAMERA IMPLEMENTATION -----------------------------------------------------------
local perspective=require("perspective")
local camera = perspective.createView()

local function moveCamera()
	local leftOffset= 60
	local screenLeft = -camera.x
	local safeMoveArea = 380
	if steve.x> leftOffset then
		if steve.x > screenLeft + safeMoveArea then
			camera.x = -steve.x + safeMoveArea
			elseif steve.x < screenLeft + leftOffset then
				camera.x = -steve.x + leftOffset
		end
	else
		camera.x=0
	end
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

	if (event.phase == "began") then
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
		display.remove( coin )
		score = score + 100
		scoreText.text = "Score: " .. score
		pointsText = display.newText( uiGroup, "+100", 
			display.contentWidth - 80, 60, native.systemFont, 14 )
		pointsText:setFillColor( 0,0,255 )
		transition.to( pointsText.text, { 
			alpha=1, 
			time=250, 
			effect="crossfade",
			onComplete = function() 
				display.remove(pointsText) 
			end
		} )
	elseif(event.phase == "cancelled" or event.phase == "ended" )then
		
		
	
	end
end

-- Collision with enemies and dangerous things (Only for Steve)
function dangerCollision( event )
	if ( died == false ) then
		died = true
		-- Update lives
		lives = lives - 1
		livesText.text = "Lives: " .. lives

		-- If we have no lives left
		if ( lives == 0 ) then
			steve.alpha = 0
			camera:cancel() --Stop camera Tracking
			timer.performWithDelay( 2000, endGame )
		else
			steve.alpha = 0
			timer.performWithDelay( 50, restoreSteve )
		end
	end
end

function onCollision( event )
	if ( (event.object1.myName == "steve") or 
		 (event.object2.myName == "steve") ) then
	steveCollisions( event )
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
	elseif (other.myName == "nemico")then
		dangerCollision(event)
	end
end
------------------------------------------------------------------------------------


local function setEntitySpeed(entity, value)
	entity.speed = value
end

local function setEntityJumpHeight(entity, value)
	entity.jumpHeight = value
end

--Allows Steve to move on the x-axis while mid-air
local function setSteveVelocity()
	local steveXV, steveYV = steve:getLinearVelocity()
	steve:setLinearVelocity(steve.actualSpeed, steveYV) 
end

-- CONTROLS HANDLERS ---------------------------------------------------------------

local function dpadTouch(event)
	local target = event.target

	if (event.phase=="began") then

		display.currentStage:setFocus( target )
		steve.state = STATE_WALKING
		Runtime:addEventListener("enterFrame", setSteveVelocity)
		if (target.myName == "dpadLeft") then
			steve.direction = DIRECTION_LEFT
		elseif (target.myName == "dpadRight") then
			steve.direction = DIRECTION_RIGHT
		end

		steve.actualSpeed = steve.direction * steve.speed
		steve.xScale = steve.direction

	elseif (event.phase =="ended" or "cancelled" == event.phase) then
		steve.actualSpeed=0
		Runtime:removeEventListener("enterFrame", setSteveVelocity)
		steve.state = STATE_IDLE
		display.currentStage:setFocus( nil )
	end

	return true --Prevents touch propagation to underlying objects
end

local function jumpTouch( event )
	if (event.phase=="began") then
		if (steve.canJump) then
			steve:applyLinearImpulse(0,steve.jumpHeight, steve.x, steve.y)
			steve.state = STATE_JUMPING
			steve.canJump = false
		end
	end
end

local function actionTouch( event )

	if (event.phase=="began") then
		display.currentStage:setFocus( event.target )

	-- CODE HERE

	elseif (event.phase=="ended" or "cancelled" == event.phase) then

	--CODE HERE

		display.currentStage:setFocus( nil )
	end
	return true --Prevents touch propagation to underlying objects
end

local function pauseGame(event)
    if(event.phase == "ended") then
        physics.pause()
        pauseBtn.isVisible = false
        resumeBtn.isVisible = true
        return true
    end
end
 
local function resumeGame(event)
    if(event.phase == "ended") then
        physics.start()
        pauseBtn.isVisible = true
        resumeBtn.isVisible = false
        return true
    end
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

	backgroundMusic = audio.loadStream(nil)

	-- SCENE GROUPS ---------------------------------
	map = lime.loadMap("testmap_new.tmx")
	visual = lime.createVisual(map)
	sceneGroup:insert( visual )

	mainGroup = display.newGroup()
	sceneGroup:insert( mainGroup )

	uiGroup = display.newGroup()
	sceneGroup:insert( uiGroup )
	-------------------------------------------------

	-- Apply physics to the map
	physical = lime.buildPhysical(map)	

	-- UI OPTIONS -----------------------------------
	-- The jump "button" is screen-wide
	jScreen = display.newImageRect(uiGroup,"emptyScreen.png", display.contentWidth, display.contentHeight)
	jScreen.x, jScreen.y = display.contentCenterX , display.contentCenterY
	jScreen.myName = "jumpScreen"
	jScreen:toBack()
	jScreen:addEventListener("touch", jumpTouch)

	-- Load the d-pad
	dpadLeft = display.newImageRect( uiGroup, "dpadLeft.png", 50, 52 )
	dpadLeft.anchorX, dpadLeft.anchorY = 0, 1
	dpadLeft.x, dpadLeft.y = dpadLeft.width / 2 + 10, display.contentHeight - dpadLeft.height / 2 - 10
	dpadLeft.myName = "dpadLeft"
	dpadLeft:addEventListener("touch", dpadTouch)

	dpadRight = display.newImageRect( uiGroup, "dpadRight.png", 50, 52 )
	dpadRight.anchorX, dpadRight.anchorY = 0, 1
	dpadRight.x, dpadRight.y = dpadLeft.x + dpadRight.width, dpadLeft.y
	dpadRight.myName = "dpadRight"
	dpadRight:addEventListener("touch", dpadTouch)

	-- Load the action button DA IMPLEMENTARE
	actionBtn = display.newImageRect( uiGroup, "actionbtn.png",51,51 )
	actionBtn.anchorX, actionBtn.anchorY = 1, 1
	actionBtn.x, actionBtn.y = display.contentWidth - actionBtn.width / 2, display.contentHeight -10 - actionBtn.height / 2
	actionBtn.myName = "actionBtn"
	actionBtn:addEventListener("touch", actionTouch) 
     
    -- Pause and resume buttons
    pauseBtn = display.newImageRect( uiGroup,"pause.png",35,35 )
    pauseBtn.anchorX, pauseBtn.anchorY = 1, 0
    pauseBtn.x, pauseBtn.y = display.contentWidth -10, 30
    pauseBtn.myName="pauseBtn"
    pauseBtn:addEventListener( "touch", pauseGame )
     
    --create resume button
    resumeBtn = display.newImageRect( uiGroup,"resume.png",35,35 )
    resumeBtn.anchorX, resumeBtn.anchorY = 1, 0
    resumeBtn.x, resumeBtn.y = pauseBtn.x, pauseBtn.y
    resumeBtn.myName="resumeBtn"
    resumeBtn.isVisible = false
    resumeBtn:addEventListener( "touch", resumeGame ) 


	-- lives and score texts
	livesText = display.newText( uiGroup, "Lives: " .. lives, 0, 0, native.systemFont, 24 )
	livesText.anchorX, livesText. anchorY = 0, 0
	livesText.x, livesText.y = 10, 30

	livesText:setFillColor( 255,0,0 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 0, 0, native.systemFont, 24 )
	scoreText.anchorX, scoreText. anchorY = 1, 0
	scoreText.x, scoreText.y = display.contentWidth -20 - pauseBtn.contentWidth, 30
	scoreText:setFillColor( 0,0,255 )
	-------------------------------------------------



	-- CHARACTER OPTIONS ----------------------------

	--[[local layer = map:getTileLayer("player")
	players = layer:getTIlesWithProperty("isPlayer")
	steve = players:get]]

	-- Load Steve, the player avatarS
	local layer = map:getObjectLayer("playerSpawn")
	local spawn = layer:getObject("playerSpawn")
	steve = display.newImageRect( mainGroup, "rock.png", 32, 32 )
	steve.x, steve.y = spawn.x, spawn.y
	steve.rotation = 0
	steve.myName = "steve"
	setEntitySpeed (steve, 150)
	setEntityJumpHeight (steve, -18)
	physics.addBody( steve, { density=1.0, friction=0.7, bounce=0 } )
	steve.isFixedRotation = true
	-------------------------------------------------



	-- CAMERA OPTIONS -------------------------------
  	-- second parameter is the Layer number
  	-- third parameter is the focus on that object
  	camera:add( visual,	2,	false )
  	camera:add( steve, 	1,	true  )

	-- slow the track of a specific layer (for backgrounds)
	-- 1 is equal to us, 0.5 is half track
	camera:layer(3).parallaxRatio = 0.3

	-- set the screen limits for the camera
	camera:setBounds(0, steve.x ,-100, steve.y)	-- TEST IN CORSO
	
	-- set the follow speed of the focused layer 
	camera.dumping = 50

	-- all display objects must be inserted into group
	sceneGroup:insert(camera)
	sceneGroup:insert(uiGroup)
	-------------------------------------------------
	
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		
	elseif phase == "did" then
		Runtime:addEventListener("enterFrame", moveCamera)
        Runtime:addEventListener( "collision", onCollision)

		camera:track() -- start the camera tracking
		physics.start()

		audio.play(backgroundMusic, {channel = 1 , loops=-1})
	end
end

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
	
	elseif phase == "did" then
		Runtime:removeEventListener( "collision", onCollision)
       
		physics.stop()
		audio.stop(1)
	end	
	
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	
	audio.dispose( backgroundMusic )
	package.loaded[physics] = nil
	physics = nil
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