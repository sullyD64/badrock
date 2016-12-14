-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------
--non so se è il caso di usare qui il composer, ma l'ho messo per far funzionare endGame()
local composer = require( "composer" )
local ui = 		require ( "ui" )
local physics = require ( "physics" )

local game = {}

physics.start()
physics.setGravity( 0, 30 )

--===========================================-- 

local GAME_RUNNING    = "Running"
local GAME_PAUSED     = "Paused"
local GAME_ENDEND	  = "Ended"
local STATE_IDLE 	  = "Idle"
local STATE_WALKING   = "Walking"
local STATE_JUMPING   = "Jumping"
local STATE_ATTACKING = "Attacking"
local DIRECTION_LEFT  = -1
local DIRECTION_RIGHT =  1
local MAX_LIVES 	  =  5

game.state = GAME_PAUSED
game.score = 0
game.level = nil
game.levelCompleted = false

--game.steve = player.loadPlayer()
--local steve = game.steve
 
game.steve = nil
game.ui = nil 

game.died = false
game.lives = MAX_LIVES
game.lifeIcons= {}

local function moveCamera( event ) 
	game.level:update(event)
end

function setSteveVelocity()
	local steveXV, steveYV = game.steve:getLinearVelocity()
	game.steve:setLinearVelocity(game.steve.actualSpeed, steveYV) 
end



-- SOME UTILITY FUNCTIONS THAT CANNOT BE MOVED TO OTHER FILES (FOR NOW)-----------

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

		--lives = lives + 1
		--if lives &gt; MAX_LIVES then
		--lives = MAX_LIVES
		--end
		--lifeIcons[lives].isVisible = true
		-- Steve has no lives left
	end


-- Endgame handler
	local function endGame()
	    composer.setVariable( "finalScore", game.score )
	    composer.removeScene( "highscores" )
	    composer.gotoScene( "highscores", { time=1500, effect="crossFade" } )
	end

	-- Endgame screen handler
	function game.endGameScreen()
		local exitText
		game.steve.alpha = 0

		--DA SISTEMARE
	--	display.remove(mainGroup)
	--	display.remove(uiGroup)

		if (game.levelCompleted == true) then
			exitText = display.newText( ui.uiGroup, "Level Complete" , 250, 150, native.systemFontBold, 34 )
			exitText:setFillColor( 0.75, 0.78, 1 )
		else
			exitText = display.newText( ui.uiGroup, "Game Over" , 250, 150, native.systemFontBold, 34 )
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
	function game.restoreSteve(steve)
		--local steve
		map = lime.loadMap("testmap_new.tmx") -- Momentaneamente qui, ma DEVE essere spostato successivamente in una giusta struttura dati

		local layer = map:getObjectLayer("playerSpawn")
		local spawn = layer:getObject("spawn0")

		--TRANSITION TO RISOLVE IL BUG CHE DAVA QUANDO CERCAVAMO DI SPOSTARE STEVE MENTRE ERA ANCORA IN COLLISIONE CON ALTRI OGGETTI
		transition.to(game.steve, { time=0, onComplete = function()
			game.steve.isBodyActive = false
			game.steve.x = spawn.x
			game.steve.y = spawn.y
		end})
		  
	    game.steve:setLinearVelocity( 0, 0 )
	    game.steve.rotation = 0
	    game.steve.isGrounded = false
	    -- Fade in Steve
	    transition.to( game.steve, { alpha = 1, time = 1000,
	        onComplete = function()
	            game.steve.isBodyActive = true
	            game.died = false
	        end
	    } )
	end


	
---------------------------------------------------------------------------------

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
	local	function coinCollision( event )
		local steveObj = event.object1
		local coin = event.object2

		if(event.object2.myName =="steve") then 
			steveObj = event.object2
			coin = event.object1
		end

		if ( event.phase == "began" ) then
			--audio.play( coinSound )
			display.remove( coin )
			addScore(100)

		elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		end
	end


	-- Collision with enemies and dangerous things (Only for Steve)
	local	function dangerCollision( event)
		local other = event.object2
		if(event.object2.myName == "steve") then
			other = event.object1
		end

		--Avoids Steve to take damage from enemy while attacking (but only if the enemy isn't invincible)
		if ( (game.steve.state ~= STATE_ATTACKING and other.isEnemy) or
			 (game.steve.state == STATE_ATTACKING and other.isInvincible) ) then 

			if (game.died == false) then 
				game.died = true
				--audio.play( dangerSound )
				
				game.lives = game.lives - 1
				ui.getButtonByName("livesText").text = "Lives: " .. game.lives
				updateLifeIcons()	--Refresh the Life Icons
				
				if ( game.lives == 0 ) then
					game.level:setFocus( nil ) --Stop camera Tracking
					--game.level:getTileLayer("playerObject"):destroy() --Completely removes all visual and physical objects associated with the TileLayer.
					display.remove(game.steve)
					game.endGameScreen()
				else

					game.steve.alpha = 0
					timer.performWithDelay( 50, game.restoreSteve(steve) )
				end
			end
		end
	end


	--Collisions with the Steve Attack
	local function steveAttackCollision( event )
		local attack = event.object1
		local other = event.object2

		if(other.myName == "steveAttack") then
			attack = event.object2
			other = event.object1
		end

		-- Other is an enemy, targettable AND not "invincible"
		if( (other.isEnemy == true ) and (other.isInvincible == false)  ) then 
			other.lives = other.lives - 1

			-- Enemy has no lives left
			if ( other.lives == 0 ) then 
				display.remove(other)
				addScore(200) -- Successivamente al posto di 200, useremo other.score, perchè ogni nemico ha un suo valore
			
			-- Enemy is still alive
			else 
				other.alpha = 0.5 -- Make the enemy temporairly untargettable 
				other.isInvincible = true
				local removeImmunity = function() 
					other.alpha=1 
					other.isInvincible = false
				end
				timer.performWithDelay(500, removeImmunity)

				-- Little "knockBack" of the enemy when is hit from Steve (pushed Away from Steve) 
				if (other.x > game.steve.x) then other:applyLinearImpulse(1,1,other.x,other.y) --if the enemy is on the Steve's Right
				elseif (other.x < game.steve.x) then other:applyLinearImpulse(-1,1,other.x,other.y) --if the enemy is on the Steve's Left
				end
			end

		-- If the object is a item that can be destroyed from steve attacks
		elseif(other.canBeBroken) then
			display.remove(other)
		end
	end




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
			elseif ((other.myName == "nemico") or (other.isEnemy == true)) then
				dangerCollision(event)
			elseif(other.myName == "end_level") then
				--endCollision(event)
			end

		-- SteveAttack collisions are handled by the attackedBySteve method
		elseif( (event.object1.myName == "steveAttack") or 
			    (event.object2.myName == "steveAttack") ) then
			steveAttackCollision( event )
		end
	end
-----------------------------------------------------------------------------------


-- CONTROLS HANDLERS ---------------------------------------------------------------
	
	function dpadTouch(event)
		local target = event.target
		local lbutton = ui.getButtonByName("dpadLeft")
		local rbutton = ui.getButtonByName("dpadRight")

		if (event.phase == "began") then
			display.currentStage:setFocus( target )
			game.steve.state = STATE_WALKING
			Runtime:addEventListener("enterFrame", setSteveVelocity)
			if (target.myName == "dpadLeft") then
				game.steve.direction = DIRECTION_LEFT
				lbutton.alpha = 0.5
			elseif (target.myName == "dpadRight") then
				game.steve.direction = DIRECTION_RIGHT
				rbutton.alpha = 0.5
			end

			game.steve.actualSpeed = game.steve.direction * game.steve.speed
			game.steve.xScale = game.steve.direction

		elseif (event.phase == "ended" or "cancelled" == event.phase) then
			Runtime:removeEventListener("enterFrame", setSteveVelocity)
			game.steve.state = STATE_IDLE
			
			lbutton.alpha, rbutton.alpha = 1, 1
			display.currentStage:setFocus( nil )
		end

		return true --Prevents touch propagation to underlying objects
	end

	function jumpTouch(event)
		
			display.currentStage:setFocus( event.target )
			if (game.steve.canJump == true) then
				--audio.play( jumpSound )
				game.steve:applyLinearImpulse(0,game.steve.jumpHeight, game.steve.x, game.steve.y)
				game.steve.state = STATE_JUMPING
				game.steve.canJump = false
			end
			display.currentStage:setFocus( nil )
		
		return true --Prevents touch propagation to underlying objects
	end



	-- Action Button Method
	local function actionTouch( event )
		local attackDuration = 500
		local actionBtn = event.target

		if (event.phase=="began" and actionBtn.active == true) then
			display.currentStage:setFocus( actionBtn )
			--audio.play( attackSound )

			--Evita che il button di azione sia permaspammato
			actionBtn.active=false
			actionBtn.alpha = 0.5

			game.steve.state = STATE_ATTACKING

			steveAttack = display.newCircle( game.steve.x, game.steve.y, 40)
			physics.addBody(steveAttack, {isSensor = true})
			steveAttack.myName = "steveAttack"

			--Statistiche momentanee per rendere visibile l'area d'attacco
			steveAttack:setFillColor(0,0,255)
			steveAttack.alpha=0.6
		  	game.level:getTileLayer("playerEffects"):addObject( steveAttack )

		  	-- Fa rotolare Steve nella direzione in cui sta guardando
		  	game.steve:applyLinearImpulse( game.steve.direction * 10, 0, game.steve.x, game.steve.y )

			-- Links the SteveAttack to Steve
			local steveAttackFollowingSteve = function ()
				steveAttack.x, steveAttack.y = game.steve.x, game.steve.y
			end

			-- Handles the end of the SteveAttack phase
			local steveAttackStop = function ()
				display.remove(steveAttack)
				game.steve.state = STATE_IDLE
				Runtime:removeEventListener("enterFrame" , steveAttackFollowingSteve)
				--Rende il tasto nuovamente premibile
				actionBtn.active = true
				actionBtn.alpha = 1
			end

			Runtime:addEventListener("enterFrame", steveAttackFollowingSteve)
			timer.performWithDelay(attackDuration, steveAttackStop)
			display.currentStage:setFocus( nil )
		end

		return true --Prevents touch propagation to underlying objects
	end



	function pauseResume(event)
		local target = event.target
		local psbutton = ui.getButtonByName("pauseBtn")
		local rsbutton = ui.getButtonByName("resumeBtn")

		if (event.phase == "began") then
			display.currentStage:setFocus( target )

		elseif (event.phase == "ended" or "cancelled" == event.phase) then
			if (target.myName == "pauseBtn") then
				game.pause()
		        psbutton.isVisible = false
		        rsbutton.isVisible = true
		    elseif (target.myName == "resumeBtn") then
		    	game.resume()
		    	psbutton.isVisible = true
		        rsbutton.isVisible = false
		    end
		    display.currentStage:setFocus( nil )
		end

		return true --Prevents touch propagation to underlying objects
	end

-- MOMENTANEAMENTE NON USATA PER MALFUNZIONAMENTI CON IL TOCCO SULL'ASSE Z
	function uiHandler ( event )
		local target = event.target
		if 	   ( (target.myName == "dpadLeft") or
				 (target.myName == "dpadRight") ) then
			dpadTouch(event)
		elseif ( target.myName == "jumpScreen" ) then
			jumpTouch(event)
		elseif ( (target.myName == "pauseBtn") or 
				 (target.myName == "resumeBtn") ) then
			pauseResume(event)
		end
	end
------------------------------------------------------------------------------------




function game.loadPlayer()
	game.steve = display.newImageRect( "sprites/rock.png", 32, 32 )
	game.steve.myName = "steve"
	game.steve.rotation = 0
	game.steve.speed = 150
	game.steve.jumpHeight = -18
	physics.addBody( game.steve, { density=1.0, friction=0.7, bounce=0.01} )
	game.steve.isFixedRotation = true
	game.steve.state = STATE_IDLE
	game.steve.direction = DIRECTION_RIGHT
	game.steve.canJump = true

	game.steve.lives = 3
	game.steve.died = false
end


function game.create( spawn, map )
	physics.start()

	game.score = 0
	game.lives = MAX_LIVES
	game.levelCompleted = false

	game.loadPlayer()

	game.steve.x, game.steve.y = spawn.x, spawn.y
	game.level = map

	game.ui = ui.loadUi()

	--Links an appropriate eventListener to every Button
	ui.getButtonByName("jumpScreen"):addEventListener("touch", jumpTouch)
	ui.getButtonByName("dpadLeft"):addEventListener("touch", dpadTouch)
	ui.getButtonByName("dpadRight"):addEventListener("touch", dpadTouch)
	ui.getButtonByName("actionBtn"):addEventListener("touch", actionTouch)
	ui.getButtonByName("pauseBtn"):addEventListener("touch", pauseResume)
	ui.getButtonByName("resumeBtn"):addEventListener("touch",pauseResume)
	
	--display the number of lives
	ui.getButtonByName("livesText").text = "Lives: ".. game.lives
	--display all the life Icons
	game.lifeIcons = ui.createLifeIcons(MAX_LIVES)

	--	for i = 1, game.ui.numChildren do
	--		game.ui[i]:addEventListener( "touch", uiHandler )
	--	end

	physics.pause()

end


function game.start()
	game.state = GAME_RUNNING
	physics.start()
	Runtime:addEventListener("enterFrame", moveCamera)
	Runtime:addEventListener( "collision", onCollision)
	audio.play(backgroundMusic, {channel = 1 , loops=-1})
end

function game.pause()
	game.state = GAME_PAUSED
	game.steve.state = STATE_IDLE	
	physics.pause()
	--audio.pause(1)
end

function game.resume()
	game.state = GAME_RUNNING
	physics.start()
	--audio.resume(1)
end

function game.stop()
	game.state = GAME_ENDEND
	physics.stop()
	Runtime:removeEventListener("collision", onCollision)

	--audio.stop(1)
end



return game



