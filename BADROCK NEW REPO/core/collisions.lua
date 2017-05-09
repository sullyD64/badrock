-----------------------------------------------------------------------------------------
--
-- collisions.lua
--
-- This class handles all the #COLLISION# events between physical objects in the current 
-- map, whether they are Tiles or Entities. For this, it needs to store the current game 
-- in order to make it visible to the local collision handlers.
-- Also, game controls the activation (Runtime:addEventListener/removeEventListener).
-- These methods can access and modify the Game's current state, aswell as the Player's
-- current state, position on the map, sprite sequence and other properties.
-----------------------------------------------------------------------------------------
local items   = require ( "core.items" )

local collisions = {
	-- Used by npcDetectByCollision
	contactEnabled = true,
	releaseEnabled = false,
}

local game = {}
local steve = {}
local gState = {}		-- Game state is only modified in collision with end_level
local sState = {}		-- Steve state is modified in dangerCollision

-- This function is accessed from -game.loadGame-.
function collisions.setGame( currentGame, gameStateList, playerStateList )
	game = currentGame
	if (game) then 
		steve = currentGame.steve 
	end
	gState = gameStateList
	sState = playerStateList
end


-- Collision between the player and safe environment Tiles
local function environmentCollision( event )
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

-- Collision between the player and an Enemy (or dangerous environment Tiles)
local function dangerCollision( event )
	local other = event.object2
	if(event.object2.eName == "steve") then
		other = event.object1
	end

	-- For reasons, steve may collide with an enemy when attacking if he comes too close:
	-- this control allows to temporairly make Steve 'invincible' against certain entities 
	-- when attacking (with his default attack). This will NOT work if the entity 
	-- represents certain danger (void, spikes, invincible enemies and such).
	if ( (steve.state ~= sState.ATTACKING and (other.isEnemy or other.isDanger) ) or 
		(steve.state == sState.ATTACKING and other.isDanger) ) then 

		-- The whole death phase is handled in the controller
		-- the declaration below triggers a call in the game loop
		-- (see game and controller)
		steve.state = sState.DEAD
	end
end

-- Collision between the player's Attack and an Enemy
local function attackCollision( event )
	local other = event.object1
	if (other.sensorName == "A") then
		other = event.object2
	end

	-- Target is an enemy, targettable AND not invincible
	if( other.eName == "enemy" and other.isTargettable == true ) then 
		-- Locally stores some of the enemies attributes
		-- This is needed because they may become lost when the enemy is removed.
		local enemyHit = {}
		enemyHit.drop = other.drop
		enemyHit.name = other.name 
		enemyHit.x = other.x
		enemyHit.y = other.y

		other.lives = other.lives - 1
		if ( other.lives == 0 ) then  -- Enemy has no lives left: he is dead	
			other.isSensor = true
			other.isEnemy = false
			timer.performWithDelay(1000, other:applyLinearImpulse( 0.05, -0.30, other.x, other.y ))
			other.yScale = -1

			-- Forces the enemy to drop his item
			if (game.hasAttribute(enemyHit,"drop")) then 
				game.dropItemFrom(enemyHit) 
			end 
				
			timer.performWithDelay(5000, function() display.remove(other) end)
			---------------------------------------------------------------
			game.addScore(200) -- [We will modify this (but when???)]
			---------------------------------------------------------------
		else 	-- Enemy is still alive
			-- Makes the enemy temporairly untargettable and reverts it short after
			other.alpha = 0.5 
			other.isTargettable = false
			timer.performWithDelay(500, 
				function()
					other.alpha = 1
					other.isTargettable = true
				end
			)

			-- Knocks back the enemy from steve
			if (other.x > game.steve.x) then other:applyLinearImpulse(1,1,other.x,other.y) 
			elseif (other.x < game.steve.x) then other:applyLinearImpulse(-1,1,other.x,other.y)
			end
		end

	-- Target is a destroyable item (ie crates, rocks,)
	elseif( other.isBreakable ) then
		display.remove(other)
	-- elseif(other.isEnemy==false) then print("noEn")
	-- elseif(other.isEnemy==true) then print("èEn")
	-- elseif(other.isEnemy==true) then print("ètar")	
	-- elseif(other.isTargettable==false) then print ("notar")
	end	
end

-- Steve and every npc have an invisible "sensor" physical object surrounding
-- and following them at runtime. This function handles the collision between
-- the two (in future three) sensors, and acts differently depending if the
-- collision is a "contact" or a "release" between the two circles.
local function npcDetectByCollision( event )
	local sensorN, other = event.object1, event.object2
	local collName, flag

	if (other.sensorName == "N") then
		sensorN = event.object2
		other = event.object1
	end

	if (collisions.contactEnabled) then 
		collName = "contact"
		flag = "show"
	elseif (collisions.releaseEnabled) then
		collName = "release"
		flag = "hide"
	end

	-- Switches between the two if blocks (next collision will enter the other 'if')
	if (collName == "contact") then
		collisions.contactEnabled = false
		collisions.releaseEnabled = true
	elseif (collName == "release") then
		collisions.releaseEnabled = false
		collisions.contactEnabled = true
	end

	for i=1, #game.npcs, 1 do
		-- Selects the npc associated to the sensorN and calls the toggle function
		if (game.npcs[i].sensorN == sensorN) then
			--toggleNpcBalloon(game.npcs[i], flag)
			game.npcs[i].balloon:toggle(flag)
		end
	end
end


-- PLAYER-SPECIFIC COLLISIONS ------------------------------------------------------
	-- Allows the player to pass through a platform when jumping from below its base
	function collisions.playerPreCollision( self, event )
		if ( event.other.myName == "platform" ) then

			-- Compare Y position of character "base" to platform top
			-- A slight increase (0.2) is added to account for collision location inconsistency
			-- If collision position is greater than platform top, void/disable the specific collision
			if ( self.y+(self.height*0.5) > event.other.y-(event.other.height*0.5)+0.2 ) then
				if event.contact then
					event.contact.isEnabled = false
					-- The jump policy is briefly disabled
					self.canJump = false
				end
			end
		end
		return true
	end
------------------------------------------------------------------------------------

-- ENEMY-SPECIFIC COLLISIONS -------------------------------------------------------
	function collisions.enemyPreCollision( self, event )
		if ( event.other.myName == "platform" ) then
			if ( self.y+(self.height*0.5) > event.other.y-(event.other.height*0.5)+0.2 ) then
				if event.contact then
					event.contact.isEnabled = false
				end
			end
		return true
		end
	end

	-- Per risolvere il problema della formazione a torre indesiderata dei nemici, 
	-- in altre situazioni potremmo volerla come fight mode invece, per ora no
	local tower = false
	function collisions.enemyFormazioneATorre( self, event )
		if ( event.other.eName == "enemy" and tower==false and self.x==event.other.x ) then
			print("collisioneTOrre")
			if ( self.y+(self.height*0.5) > event.other.y-(event.other.height*0.5)+0.2 ) then
				if event.contact then
					event.other.x=event.other.x-100		--sposto il nemico
				end
			end
		return true
		else print ("noCollisioneTorre")
		return false
		end
	end
------------------------------------------------------------------------------------

-- Main collision handler index
function collisions.onCollision( event )
	local o1, o2 = event.object1, event.object2

	-- Index for collisions involving the player
	if ( (o1.eName == "steve") or (o2.eName == "steve") ) then
		local steve, other = o1, o2
		if(other.eName =="steve") then steve, other = o2, o1 end

		if(other.myName == "env" or other.myName == "platform") then
			environmentCollision(event)
		elseif (other.myName == "item") then
			items.itemCollision(game, event, other)
		elseif (other.isEnemy or other.isDanger) then
			dangerCollision(event)

		-- Special case for the level's ending block. Triggers -endGameScreen-
		elseif(other.myName == "end_level") then
			-- The whole end phase is handled in the controller
			-- the declaration below triggers a call in the game loop
			-- (see game and controller)
			game.state = gState.COMPLETED
		else
			if     (o1.eName == "steve") then o1.firstJumpReady = true
			elseif (o2.eName == "steve") then o2.firstJumpReady = true end
		end
	
	-- Index for collisions involving at least one sensor
	elseif( (o1.eName == "sensor") or (o2.eName == "sensor") ) then
		if ((o1.sensorName == "N" and o2.sensorName == "D") or
			 (o2.sensorName == "N" and o1.sensorName == "D")) then
			npcDetectByCollision( event )
		elseif 
			((o1.sensorName == "A" and (o2.eName == "enemy" or o2.isBreakable)) or
			 (o2.sensorName == "A" and (o1.eName == "enemy" or o1.isBreakable))) then
			attackCollision( event )
		end
	end
end

return collisions