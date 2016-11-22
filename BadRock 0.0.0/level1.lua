-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local physics = require ("physics")
--local tiledMap = require ("brt1")

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local backgroundMusic
local steve={}
local controls={}

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

local function setSteveProperties()
	steve.speed = 200
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
		if (target.name == "dpad") then
			Runtime:addEventListener("enterFrame", setSteveVelocity)

			local middle = dpad.x
			if (event.x < middle ) then
				steve.velocity = -steve.speed -- move left 
			else
				steve.velocity = steve.speed -- move right
			end

		-- if we touch the jump button
		elseif (target.name=="jumpBtn") then
			steve:applyLinearImpulse(0,-150, steve.x, steve.y)
		end

		-- if we touch the fire button
		--elseif(target.name=="fireBtn") then
			--[[INSERIRE CODICE BOTTONE AZIONE]]--
		--end

	elseif (event.phase=="ended" or "cancelled" == event.phase) then

		if (target.name == "dpad") then
			steve.velocity=0
			Runtime:removeEventListener("enterFrame", setSteveVelocity)
		end

		display.currentStage:setFocus( nil )
	end
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.setGravity( 0, 30 )
	physics.pause()

	backgroundMusic = audio.loadStream(nil)

	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	--camera = display.newGroup()


	local background = display.newImageRect( "background.png", 1080, 640)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	--[[
	map = tiledMap:load("brt1.json")
	map:setReferencePoint(display.contentReferencePoint)
	map.x = display.contentCenterX
	map.y = display.contentCenterY
	]]--

	-- make steve (off-screen), position it, and rotate slightly DA MODIFICARE
	steve = display.newImageRect( "rock.png", 90, 90 )
	steve.x, steve.y = 160, -30
	steve.rotation = 15
	
	-- add physics to the steve
	physics.addBody( steve, { density=1.0, friction=0.7, bounce=0 } )
	setSteveProperties()
	
	-- make the dpad
	dpad = display.newRect(80,290, 100,50)
	dpad.name="dpad"
	dpad:addEventListener("touch", controlsTouch)

	-- make the jump button
	local jumpBtn = display.newCircle( 400,290,30)
	jumpBtn.name="jumpBtn"
	jumpBtn:addEventListener("touch", controlsTouch)

	-- create one platform (for testing)
  	local platform = display.newImageRect( "platformdown.png", screenW, 50 )
  	platform.anchorX = 0
  	platform.anchorY = 1
	platform.x = display.screenOriginX
	platform.y = display.actualContentHeight + display.screenOriginY
	physics.addBody( platform, "static", { friction = 1 } )
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	--local platformShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	-- physics.addBody( platform, "static", { friction=0.3, shape=platformShape } )

	-- create one square (for testing friction)
	local sqr = display.newImageRect( "platformdown.png", 50, 50 )
	sqr.anchorY = 1
	sqr.x = display.contentCenterX
	sqr.y = display.actualContentHeight + display.screenOriginY -50 
	physics.addBody( sqr, "static", { friction = 1 } )
	  
  	-- second parameter is the Layer number, the 3rd is the focus on that object
  	camera:add(background, 3 , false)
  	camera:add(platform, 2 , false)
  	camera:add(sqr, 2, false)
  	camera:add(steve, 1 , true)

	--slow the track of a specific layer (perfect for backgrounds) 1 is equal to us, 0.5 is half track
	camera:layer(3).parallaxRatio = 0.3

	--camera Limits
	camera:setBounds(0 , display.contentWidth, 0 , display.contentHeight)

	--camera follow speed
	camera.dumping = 10

	-- all display objects must be inserted into group
	sceneGroup:insert(camera)
	sceneGroup:insert(dpad)
	sceneGroup:insert(jumpBtn)
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		--Runtime:addEventListener("enterFrame", moveCamera)

		--Start the camera tracking
		camera:track()
		physics.start()
		audio.play(backgroundMusic, {channel = 1 , loops= -1})
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
		audio.stop(1)

	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view



	audio.dispose( backgroundMusic )
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene