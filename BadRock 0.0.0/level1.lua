-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local physics = require ("physics")
physics.start()
physics.setGravity( 0, 30 )

--local tiledMap = require ("brt1")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local backgroundMusic

local steve
local controls={}	-- MAI USATA

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

local function setEntitySpeed(entity, value)
	entity.speed = value
end

local function setEntityJumpHeight(entity, value)
	entity.jumpHeight = value
end

--Allows Steve to move on the x-axis while mid-air
local function setSteveVelocity()
	local steveHorizontalVelocity, steveVerticalVelocity = steve:getLinearVelocity()
	steve:setLinearVelocity(steve.velocity, steveVerticalVelocity) 
end

local function controlsTouch(event)
	local target = event.target

	if (event.phase=="began") then

		display.currentStage:setFocus( target )

		-- if we touch the d-pad
		if (target.myName == "dpad") then
			Runtime:addEventListener("enterFrame", setSteveVelocity)
			if (event.x < dpad.x ) then
				steve.velocity = -steve.speed -- move left 
			else
				steve.velocity = steve.speed -- move right
			end

		-- if we touch the jump button
		elseif (target.myName=="jumpBtn") then
			steve:applyLinearImpulse(0,steve.jumpHeight, steve.x, steve.y)
		end

		-- if we touch the fire button
		--elseif(target.myName=="fireBtn") then
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
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause() -- Temporarily pause the physics engine

	backgroundMusic = audio.loadStream(nil)

	-- camera = display.newGroup()
	backGroup = display.newGroup()
	sceneGroup:insert( backGroup )

	mainGroup = display.newGroup()
	sceneGroup:insert( mainGroup )

	uiGroup = display.newGroup()
	sceneGroup:insert( uiGroup )


	-- Load the background
	local background = display.newImageRect( backGroup, "background.png", 480, 282)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	--[[
	map = tiledMap:load("brt1.json")
	map:setReferencePoint(display.contentReferencePoint)
	map.x = display.contentCenterX
	map.y = display.contentCenterY
	]]--

	-- Load Steve, the player avatar
	steve = display.newImageRect( mainGroup, "rock.png", 50, 50 )
	steve.x, steve.y = 160, -30
	steve.rotation = 15
	steve.myName = "steve"
	setEntitySpeed (steve, 120)
	setEntityJumpHeight (steve, -45)
	physics.addBody( steve, { density=1.0, friction=0.7, bounce=0 } )

	-- create one platform (for testing)
  	local platform = display.newImageRect( mainGroup, "platformdown.png", screenW *3, 50 )
  	platform.anchorX = 0
  	platform.anchorY = 1
	platform.x = display.screenOriginX
	platform.y =  display.actualContentHeight + display.screenOriginY
	physics.addBody( platform, "static", { friction = 1 } )
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	-- local platformShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	-- physics.addBody( platform, "static", { friction=0.3, shape=platformShape } )

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

	-- UI OPTIONS -----------------------------------
	-- Load the controls UI
	dpad = display.newImageRect( uiGroup, "dpad.png", 100,51 )
	dpad.x = 60
	dpad.y = display.contentHeight-60
	dpad.myName = "dpad"
	dpad:addEventListener("touch", controlsTouch)

	jumpBtn = display.newCircle( uiGroup, 
		display.contentWidth-10, 
		display.contentHeight-60,20 )
	jumpBtn.anchorX = 1
	jumpBtn.myName = "jumpBtn"
	jumpBtn:addEventListener("touch", controlsTouch)
	-------------------------------------------------

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
	camera:setBounds(display.contentWidth, display.contentWidth,
	 display.contentHeight , display.contentHeight)

	-- set the follow speed of the focused layer 
	camera.dumping = 10

	-- all display objects must be inserted into group
	sceneGroup:insert(camera)
	sceneGroup:insert(dpad)
	sceneGroup:insert(jumpBtn)
	-------------------------------------------------
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Code here runs when the scene is entirely on screen
		Runtime:addEventListener("enterFrame", moveCamera)

		--Start the camera tracking
		camera:track()
		physics.start()
		audio.play(backgroundMusic, {channel = 1 , loops=-1})
	end
end

-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Code here runs when the scene is on screen (but is about to go off screen)
	elseif phase == "did" then
		-- Code here runs immediately after the scene goes entirely off screen
		physics.stop()
		audio.stop(1)
	end	
	
end

-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose( backgroundMusic )
	package.loaded[physics] = nil
	physics = nil
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene