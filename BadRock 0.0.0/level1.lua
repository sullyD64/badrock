-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require ("physics")

local tiledMap = require ("brt1")

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local backgroundMusic
local rock={}
local controls={}

local perspective=require("perspective")
local camera = perspective.createView()

local function moveCamera()
	-- body
	local leftOffset= 60
	local screenLeft = -camera.x
	local safeMoveArea = 380
	if rock.x> leftOffset then
		if rock.x > screenLeft + safeMoveArea then
			camera.x = -rock.x + safeMoveArea
			elseif rock.x < screenLeft + leftOffset then
				camera.x = -rock.x + leftOffset

		end
	else
		camera.x=0
	end
end


local function setRockProperties()
	rock.speed = 80
end

local function setRockVelocity()
	local rockHorizontalVelocity, rockVerticalVelocity = rock:getLinearVelocity()
	rock:setLinearVelocity(rock.velocity, rockVerticalVelocity)

end
local function controlsTouch(event)
	local target = event.target

	if event.phase=="began" then

		display.currentStage:setFocus( target )

		--IF WE TOUCH MOVEMENT CONTROLS
		if(target.name == "controls") then


			Runtime:addEventListener("enterFrame", setRockVelocity)

			local middleOfControlPad= controls.x

			if (event.x < middleOfControlPad )then
			--move left

				rock.velocity = -rock.speed
			else
				--move right
				rock.velocity = rock.speed
			end
		--IF WE TOUCH ACTION BUTTON
		elseif(target.name=="actionBtn") then

			rock:applyLinearImpulse(0,-50, rock.x, rock.y)
		end

	elseif (event.phase=="ended"or "cancelled" == event.phase) then

		if(target.name == "controls") then
			rock.velocity=0
			Runtime:removeEventListener("enterFrame", setRockVelocity)
		end

		display.currentStage:setFocus( nil )
	end
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scen
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()

	backgroundMusic= audio.loadStream("Cthulhu Rising.wav")
	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	--camera = display.newGroup()


	local background = display.newImageRect( "cthulhu_by_disse86-d9tq84i.jpg", 800, 500)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	--[[
	map = tiledMap:load("brt1.json")
	map:setReferencePoint(display.contentReferencePoint)
	map.x = display.contentCenterX
	map.y = display.contentCenterY
	]]--

	-- make a rock (off-screen), position it, and rotate slightly
	rock = display.newImageRect( "rock.png", 90, 90 )
	rock.x, rock.y = 160, -100
	rock.rotation = 15
	
	-- add physics to the rock
	physics.addBody( rock, { density=1.0, friction=0.3, bounce=0 } )
	setRockProperties()
	

	-- Movement Pad
	controls = display.newRect(80,290, 100,50)
	controls.name="controls"
	controls:addEventListener("touch", controlsTouch)





	local actionBtn = display.newCircle( 400,290,30)
	actionBtn.name="actionBtn"
	actionBtn:addEventListener("touch", controlsTouch)

	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	--  draw the grass at the very bottom of the screen
	grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	

	
-- second parameter is the Layer number, the 3rd is the focus on that object
	camera:add(background, 3 , false)
	camera:add(grass, 2 , false)
	camera:add(rock, 1 , true)

	--slow the track of a specific layer (perfect for backgrounds) 1 is equal to us, 0.5 is half track
	camera:layer(3).parallaxRatio = 0.3


	--camera Limits
	camera:setBounds(0 , display.contentWidth, 0 , display.contentHeight)

	--camera follow speed
	camera.dumping = 10

	-- all display objects must be inserted into group
	sceneGroup:insert( camera )
	sceneGroup:insert(controls)
	sceneGroup:insert(actionBtn)

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