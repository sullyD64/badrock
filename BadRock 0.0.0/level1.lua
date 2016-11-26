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


-- CAMERA IMPLEMENTATION ----------------- 
local perspective=require("perspective")
local camera = perspective.createView()

local function moveCamera()
	-- body
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

    if ( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2

        local obj1X, obj1Y = obj1:localToContent(0,0)
        local obj2X, obj2Y = obj2:localToContent(0,0)
    
        if (obj1.myName == "steve" and obj2.myName == "env" ) then
        	if (obj1Y > obj2Y) then
        		steve.isGrounded = true
        	end
        elseif (obj1.myName == "env" and obj2.myName == "steve" ) then
        	if (obj2Y > obj1Y) then
        		steve.isGrounded = true
        	end
        end
    end
end

-- Allows Steve to move on the x-axis while mid-air
local function setSteveVelocity()
	local steveHorizontalVelocity, steveVerticalVelocity = steve:getLinearVelocity()
	steve:setLinearVelocity(steve.actualSpeed, steveVerticalVelocity) 
end

-- Event handler for the player inputs
local function controlsTouch(event)
	local target = event.target

	if (event.phase=="began") then
		display.currentStage:setFocus( target )

		-- if we touch the d-pad
		if (target.myName == "dpad") then
			Runtime:addEventListener("enterFrame", setSteveVelocity)
			if (event.x < dpad.contentWidth/2 ) then
				steve.actualSpeed = -steve.speed -- move left
				steve.xScale = -1 --flip the image to the left
			else
				steve.actualSpeed =  steve.speed -- move right
				steve.xScale =  1 --flip the image to the right
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
	local target = event.target

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
	steve = display.newImageRect( mainGroup, "rock.png", 30, 30 )
	steve.x, steve.y = spawn.x, spawn.y
	steve.rotation = 15
	steve.myName = "steve"
	setEntitySpeed (steve, 150)
	setEntityJumpHeight (steve, -18)
	physics.addBody( steve, { density=1.0, friction=0.7, bounce=0 } )
	-------------------------------------------------

	--[[
	-- TESTING ENVIRONMENT --------------------------
	-- create left wall for avoiding falling down (for testing)
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

	--Makes the whole screen tappable and triggers the jump function
	jScreen = display.newImageRect(uiGroup,"emptyScreen.png", display.contentWidth, display.contentHeight)
	jScreen.x, jScreen.y = display.contentCenterX , display.contentCenterY
	jScreen.myName = "jumpScreen"
	jScreen:toBack()
	jScreen:addEventListener("touch", controlsTouch)

	dpad = display.newImageRect( uiGroup, "dpad.png", 100,51 )
	dpad.anchorX = 0
	dpad.x, dpad.y = 10, display.contentHeight -60 
	dpad.myName = "dpad"
	dpad:addEventListener("touch", controlsTouch)

	actionBtn = display.newImageRect( uiGroup, "actionbtn.png", 51,51 )
	actionBtn.x, actionBtn.y = display.contentWidth -10, display.contentHeight -60
	actionBtn.anchorX = 1
	actionBtn.myName = "actionBtn"
	actionBtn:addEventListener("touch", actionTouch)
	-- DA IMPLEMENTARE FUNZIONALITA DI actionTouch
	
	-------------------------------------------------


	-- CAMERA OPTIONS -------------------------------
  	-- second parameter is the Layer number
  	-- third parameter is the focus on that object
  	camera:add(visual, 2, false)
  	camera:add(steve,  1, true)

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