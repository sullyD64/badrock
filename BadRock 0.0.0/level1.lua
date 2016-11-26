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

local map, visual, physical
local steve

local lives = 3
local score = 0
local died = false
local scoreText

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

--[[
local function createcoin()

	local layer = map:getObjectLayer("obj")
	local spawn = layer:getObject("spawn")

	--local spawn = layer:getObject("spawn")
	local coinspawn= layer:getObject("coinspawn")

	coin = display.newImageRect ( mainGroup, "coin.png", 32,32)
	coin.x, coin.y = coinspawn.x,coinspawn.y
	coin.myName = "coin"
	physics.addBody( coin, {isSensor = true} )
	--coin.HasBody= true
	coin.bodyType= "static"
	
    local newcoin = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
    table.insert( coinsTable, newcoin )
    physics.addBody( newcoin, "dynamic", { radius=40, bounce=0.8 } )
    newcoin.myName = "coin"

    local whereFrom = math.random( 3 )

    if ( whereFrom == 1 ) then
        -- From the left
        newcoin.x = -60
        newcoin.y = math.random( 500 )
        newcoin:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then
        -- From the top
        newcoin.x = math.random( display.contentWidth )
        newcoin.y = -60
        newcoin:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newcoin.x = display.contentWidth + 60
        newcoin.y = math.random( 500 )
        newcoin:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end

    newcoin:applyTorque( math.random( -6,6 ) )
end

--steve è invisibile
]]

local function restoreSteve()
	--local steve
	local layer = map:getObjectLayer("obj")
	local spawn = layer:getObject("spawn")
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


-- CAMERA IMPLEMENTATION ----------------- 
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
------------------------------------------


local function setEntitySpeed(entity, value)
	entity.speed = value
end

local function setEntityJumpHeight(entity, value)
	entity.jumpHeight = value
end

local function onCollision ( event )

        local obj1 = event.object1
        local obj2 = event.object2

    if ( event.phase == "began" ) then

    	-- "env" attribute of the environment
        if ( (obj1.myName == "steve" and obj2.myName == "env" ) or
             (obj1.myName == "env" and obj2.myName == "steve" ) ) then
       		steve.isGrounded = true
        end

        else if (  obj1.myName == "steve" and obj2.myName == "coin" ) then
        	display.remove( event.object2 )
        	steve.isGrounded = true
            score = score + 100
            scoreText.text = "Score: " .. score

        else if ( obj1.myName == "coin" and obj2.myName == "steve" ) then
            display.remove( event.object1 ) 
            steve.isGrounded = true
            score = score + 100
            scoreText.text = "Score: " .. score

        elseif ( ( obj1.myName == "steve" and obj2.myName == "nemico" ) or
                 ( obj1.myName == "nemico" and obj2.myName == "steve" ) ) then

            if ( died == false ) then
                died = true

                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives

                if ( lives == 0 ) then
                	steve.alpha = 0
					camera:cancel()
                    timer.performWithDelay( 2000, endGame )
                else
                    steve.alpha = 0
                    timer.performWithDelay( 50, restoreSteve )
                end
            end
        end       
    end
end
end

--Allows Steve to move on the x-axis while mid-air
local function setSteveVelocity()
	local steveHorizontalVelocity, steveVerticalVelocity = steve:getLinearVelocity()
	steve:setLinearVelocity(steve.actualSpeed, steveVerticalVelocity) 
end

local function controlsTouch(event)
	local target = event.target

	if (event.phase=="began") then

		display.currentStage:setFocus( target )

		-- if we touch the d-pad
		if (target.myName == "dpad") then
			Runtime:addEventListener("enterFrame", setSteveVelocity)
			if (event.x < dpad.contentWidth/2 ) then
				steve.actualSpeed = -steve.speed -- move left

				steve.xScale= -1 --flip the image to the left
			else
				steve.actualSpeed =  steve.speed -- move right
				steve.xScale=  1 --flip the image to the right
			end

		-- if we touch the jump button
		elseif (target.myName=="jumpScreen") and (steve.isGrounded) then
			steve:applyLinearImpulse(0,steve.jumpHeight, steve.x, steve.y)
			steve.isGrounded = false
		end


	elseif (event.phase=="ended" or "cancelled" == event.phase) then

		if (target.myName == "dpad") then
			steve.velocity=0
			Runtime:removeEventListener("enterFrame", setSteveVelocity)
		end

		display.currentStage:setFocus( nil )
	end

	return true --Prevents touch propagation to underlying objects
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

-- -----------------------------------------------------------------------------------
-- SCENE EVENT FUNCTIONS
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	physics.pause()

	backgroundMusic = audio.loadStream(nil)

	-- SCENE GROUPS ---------------------------------
	map = lime.loadMap("mappa1.tmx")
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
	-- lives and score texts
	livesText = display.newText( uiGroup, "Lives: " .. lives, 0, 0, native.systemFont, 24 )
	livesText.anchorX, livesText. anchorY = 0, 0
	livesText.x, livesText.y = 10, 30
	livesText:setFillColor( 255,0,0 )
    scoreText = display.newText( uiGroup, "Score: " .. score, 0, 0, native.systemFont, 24 )
    scoreText.anchorX, scoreText. anchorY = 1, 0
    scoreText.x, scoreText.y = display.contentWidth -10, 30
    scoreText:setFillColor( 0,0,255 )

	--Trasparent Giant Button on the screen with the screen size that allow us to jump
	jScreen = display.newImageRect(uiGroup,"emptyScreen.png", display.contentWidth, display.contentHeight)
	jScreen.x, jScreen.y = display.contentCenterX , display.contentCenterY
	jScreen.myName = "jumpScreen"
	jScreen:toBack()
	jScreen:addEventListener("touch", controlsTouch)

	-- Load the controls UI
	dpad = display.newImageRect( uiGroup, "dpad.png", 100,51 )
	dpad.anchorX, dpad.anchorY = 0, 1
	dpad.x, dpad.y = 10, display.contentHeight -30
	dpad.myName = "dpad"
	dpad:addEventListener("touch", controlsTouch)

	-- DA IMPLEMENTARE FUNZIONALITA DI actionTouch
	actionBtn = display.newImageRect( uiGroup, "actionbtn.png",51,51 )
	actionBtn.anchorX, actionBtn.anchorY = 1, 1
	actionBtn.x, actionBtn.y = display.contentWidth -10, display.contentHeight -30
	actionBtn.myName = "actionBtn"
	actionBtn:addEventListener("touch", actionTouch)
	-------------------------------------------------

	-- CHARACTER OPTIONS ----------------------------
	-- Load Steve, the player avatarS
	local layer = map:getObjectLayer("obj")
	local spawn = layer:getObject("spawn")

	local coinspawn= layer:getObject("coinspawn")

	coin = display.newImageRect ( mainGroup, "coin.png", 32, 32 )
	coin.x, coin.y = coinspawn.x,coinspawn.y
	coin.myName = "coin"
	physics.addBody( coin, "static", {isSensor = true, radius=30} )

	steve = display.newImageRect( mainGroup, "rock.png", 32, 32 )
	steve.x, steve.y = spawn.x, spawn.y
	steve.rotation = 15
	steve.myName = "steve"
	setEntitySpeed (steve, 150)
	setEntityJumpHeight (steve, -18)
	physics.addBody( steve, { density=1.0, friction=0.7, bounce=0 } )
	-------------------------------------------------

	-- CAMERA OPTIONS -------------------------------
  	-- second parameter is the Layer number
  	-- third parameter is the focus on that object
  	camera:add( visual,	2,	false )
  	camera:add( coin, 	1, 	false )
  	camera:add( steve, 	1,	true  )

	-- slow the track of a specific layer (for backgrounds)
	-- 1 is equal to us, 0.5 is half track
	--camera:layer(3).parallaxRatio = 0.3

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