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

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local backgroundMusic

local map, visual, physical
local steve

local lives = 3
local score = 0
local died = false
local scoreText

--



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
  
    -- Fade in the steve
    transition.to( steve, { alpha=1, time=4000,
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


-- -----------------------------------------------------------------------------------
-- SCENE-ACCESSIBLE CODE
-- -----------------------------------------------------------------------------------


-- CAMERA IMPLEMENTATION ----------------- 
local perspective=require("perspective")
local camera = perspective.createView()

local function moveCamera()
	-- body
	if(steve)then


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

end
------------------------------------------


local function setEntitySpeed(entity, value)
	entity.speed = value
end

local function setEntityJumpHeight(entity, value)
	entity.jumpHeight = value
end

--[[local function morte ( event )

    if ( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2
    
        if ( ( obj1.myName == "steve" and obj2.myName == "nemico" ) or
                 ( obj1.myName == "nemico" and obj2.myName == "steve" ) )
        then
            if ( died == false ) then
                died = true

                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives

                if ( lives == 0 ) then
                    display.remove( steve )
                    timer.performWithDelay( 2000, endGame )
                else
                    steve.alpha = 0
                    timer.performWithDelay( 1000, restoreSteve )
                end
            end
        end

	end
 
end

local function eliminasteve()
	if (steve.isDead== true)
		then display.remove( steve ) 
		steve.isDead= false

	end
end
]]


local function onCollision ( event )


        local obj1 = event.object1
        local obj2 = event.object2

    if ( event.phase == "began" ) then

    
    -- "env" attribute of the environment
        if ( (obj1.myName == "steve" and obj2.myName == "env" ) or
             (obj1.myName == "env" and obj2.myName == "steve" ) )
        then
       	steve.isGrounded = true
        end

        else if (  obj1.myName == "steve" and obj2.myName == "coin" )
        	then
        	display.remove( event.object2 )
        	steve.isGrounded = true
        	            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score
        --end

        else if ( obj1.myName == "coin" and obj2.myName == "steve" ) 
             then
             display.remove( event.object1 ) 
             steve.isGrounded = true
                         -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score
       --end

       elseif ( ( obj1.myName == "steve" and obj2.myName == "nemico" ) or
                 ( obj1.myName == "nemico" and obj2.myName == "steve" ) )
        then
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
				steve.xScale=1 --flip the image to the right
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


	-- CHARACTER OPTIONS ----------------------------
	-- Load Steve, the player avatarS
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



	steve = display.newImageRect( mainGroup, "rock.png", 32, 32 )
	steve.x, steve.y = spawn.x, spawn.y
	steve.rotation = 15
	steve.myName = "steve"
	setEntitySpeed (steve, 150)
	setEntityJumpHeight (steve, -18)
	physics.addBody( steve, { density=1.0, friction=0.7, bounce=0 } )


	livesText = display.newText( uiGroup, "Lives: " .. lives, 100, 20, native.systemFont, 24 )
    scoreText = display.newText( uiGroup, "Score: " .. score, 400, 20, native.systemFont, 24 )
	-------------------------------------------------


	
	--[[ create left wall for avoiding falling down (for testing)
	local lwall = display.newImageRect( mainGroup, "platformdown.png", 50, screenH )
	lwall.anchorX = 0
	lwall.anchorY = 1
	lwall.x = 0
	lwall.y = display.actualContentHeight + display.screenOriginY -50 
	physics.addBody( lwall, "static", { friction = 0 } )
	
	platform.myName = "env"
	sqr.myName = "env"
	lwall.myName = "env"
	-------------------------------------------------
	]]--

	-- UI OPTIONS -----------------------------------
	-- Load the controls UI

	--Trasparent Giant Button on the screen with the screen size that allow us to jump
	jScreen = display.newImageRect(uiGroup,"emptyScreen.png", display.contentWidth, display.contentHeight)
	jScreen.x, jScreen.y = display.contentCenterX , display.contentCenterY
	jScreen.myName = "jumpScreen"
	jScreen:toBack()
	jScreen:addEventListener("touch", controlsTouch)

	dpad = display.newImageRect( uiGroup, "dpad.png", 100,51 )
	dpad.anchorX = 0
	dpad.x = 10
	dpad.y = display.contentHeight -60
	dpad.myName = "dpad"
	dpad:addEventListener("touch", controlsTouch)

	actionBtn = display.newImageRect( uiGroup, "actionbtn.png",51,51 )
	actionBtn.x = display.contentWidth -10
	actionBtn.y = display.contentHeight -60
	actionBtn.anchorX = 1
	actionBtn.myName = "actionBtn"
	actionBtn:addEventListener("touch", actionTouch)
-- DA IMPLEMENTARE FUNZIONALITA DI actionTouch
	
	-------------------------------------------------


	--
	-- CAMERA OPTIONS -------------------------------
  	-- second parameter is the Layer number
  	-- third parameter is the focus on that object
 
  	camera:add(visual,2,false)
  	camera:add(coin,1, false)
  	camera:add(steve, 1 , true)
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
	--	Runtime:addEventListener( "morte", eliminasteve)

		 camera:track() -- start the camera tracking
		physics.start()
		--Runtime:addEventListener( "pre", prendi )
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
	--	Runtime:addEventListener( "morte", eliminasteve)
       
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