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

--[[
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
]]

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
    
        if ( (obj1.myName == "steve" and obj2.myName == "env" ) or
             (obj1.myName == "env" and obj2.myName == "steve" ) )
        then
       	steve.isGrounded = true
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
			else
				steve.actualSpeed =  steve.speed -- move right
			end

		-- if we touch the jump button
		elseif (target.myName=="jumpBtn") and (steve.isGrounded) then
			steve:applyLinearImpulse(0,steve.jumpHeight, steve.x, steve.y)
			steve.isGrounded = false
		end

		-- if we touch the action button button
		--elseif(target.myName=="actionBtn") then
			--[[INSERIRE CODICE BOTTONE AZIONE]]--
		--end

	elseif (event.phase=="ended" or "cancelled" == event.phase) then

		if (target.myName == "dpad") then
			steve.velocity=0
			Runtime:removeEventListener("enterFrame", setSteveVelocity)
		end

		display.currentStage:setFocus( nil )
	end
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

	--[[
	backGroup = display.newGroup() 
	sceneGroup:insert( backGroup )
	]]

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
	steve = display.newImageRect( mainGroup, "rock.png", 32, 32 )
	steve.x, steve.y = spawn.x, spawn.y
	steve.rotation = 15
	steve.myName = "steve"
	setEntitySpeed (steve, 150)
	setEntityJumpHeight (steve, -18)
	physics.addBody( steve, { density=1.0, friction=0.7, bounce=0 } )
	-------------------------------------------------


	--[[
	-- TESTING ENVIRONMENT --------------------------
	-- Load the background
	local background = display.newImageRect( backGroup, "background.png", 480, 282)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-- create one platform (for testing)
  	local platform = display.newImageRect( mainGroup, "platformdown.png", screenW *3, 50 )
  	--platform.anchorX = 0
  	platform.anchorY = 1
	platform.x = display.screenOriginX
	platform.y =  display.actualContentHeight + display.screenOriginY
	physics.addBody( platform, "static", { friction = 1 } )
	
	-- create one square (for testing)
	local sqr = display.newImageRect( mainGroup, "platformdown.png", 50, 50 )
	sqr.anchorY = 1
	sqr.x = display.contentCenterX + 200
	sqr.y = display.actualContentHeight + display.screenOriginY -50 
	physics.addBody( sqr, "static", { friction = 1 } )
	
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
	dpad = display.newImageRect( uiGroup, "dpad.png", 100,51 )
	dpad.anchorX = 0
	dpad.x = 10
	dpad.y = display.contentHeight -60
	dpad.myName = "dpad"
	dpad:addEventListener("touch", controlsTouch)

	jumpBtn = display.newImageRect( uiGroup, "actionbtn.png",51,51 )
	jumpBtn.x = display.contentWidth -10
	jumpBtn.y = display.contentHeight -60
	jumpBtn.anchorX = 1
	jumpBtn.myName = "jumpBtn"
	jumpBtn:addEventListener("touch", controlsTouch)
	-------------------------------------------------


	--[[
	-- CAMERA OPTIONS -------------------------------
  	-- second parameter is the Layer number
  	-- third parameter is the focus on that object
  	camera:add(background, 3 , false)
  	camera:add(platform, 2 , false)
  	camera:add(sqr, 2, false)
  	camera:add(lwall, 2, false)
  	camera:add(steve, 1 , true)

	-- slow the track of a specific layer (for backgrounds)
	-- 1 is equal to us, 0.5 is half track
	camera:layer(3).parallaxRatio = 0.3

	-- set the screen limits for the camera
	camera:setBounds(0,0,0,0)	-- TEST IN CORSO

	-- set the follow speed of the focused layer 
	camera.dumping = 10

	-- all display objects must be inserted into group
	sceneGroup:insert(camera)
	sceneGroup:insert(dpad)
	sceneGroup:insert(jumpBtn)
	-------------------------------------------------
	]]
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		
	elseif phase == "did" then
		--Runtime:addEventListener("enterFrame", moveCamera)
		Runtime:addEventListener( "collision", onCollision)

		-- camera:track() -- start the camera tracking
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