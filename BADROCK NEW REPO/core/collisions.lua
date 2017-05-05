-----------------------------------------------------------------------------------------
--
-- collisions.lua
--
-- This class handles all the #COLLISION# events between physical objects in the current 
-- map, whether they are Tiles or Entities. For this, it needs to store the current game 
-- in order to make it visible to the local collision handlers.
-----------------------------------------------------------------------------------------
local physics = require ( "physics"    )
local ui      = require ( "core.ui"    )
local npcs    = require ( "core.npcs"  )
local items   = require ( "core.items" )
local sfx     = require ( "audio.sfx"  )

local collisions = {}
local game

function collisions.setGame( currentGame )
	game = currentGame
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

	-- Avoid Steve to take damage from enemy while attacking 
	-- (but only if the enemy isn't invincible)
	if ( (game.steve.state ~= game.STEVE_STATE_ATTACKING and (other.isEnemy or other.isDanger) ) or
		 (game.steve.state == game.STEVE_STATE_ATTACKING and other.isDanger) ) then 

		if (game.steve.state ~= game.STATE_DIED) then 
			game.steve.state = game.STATE_DIED

			sfx.playSound( sfx.dangerSound, { channel = 5 } )
			game.steveDeathAnimation(game.steve.x , game.steve.y)

			game.controlsEnabled = false
			game.SSVEnabled = false

			game.lives = game.lives - 1
			ui.updateLifeIcons(game.lives)	-- Refresh the Life Icons
			
			if ( game.lives == 0 ) then
				game.endGameScreen()
			else
				transition.to(game.steveSprite, { alpha=0, time=0, onComplete = function() 
					game.steve.isBodyActive = false
					game.steveSprite:setSequence("idle")
					game.steveSprite:pause()
				end
				} )

				transition.to(game.steveSprite, { time=2000, onComplete = function() 
					game.restoreSteve()
				end
				} )
			end
		end
	end
end

-- Collision between the player's Attack and an Enemy
local function steveAttackCollision( event )
	local attack = event.object1
	local other = event.object2

	if(other.myName == "steveAttack") then
		attack = event.object2
		other = event.object1
	end

	-- salvo localmente alcuni attributi del nemico prima che, venendo colpito e ucciso, li perda
	local enemy = {}
	enemy.drop = other.drop
	enemy.name = other.name 
	enemy.x = other.x
	enemy.y = other.y

	-- Other is an enemy, targettable AND not invincible
	if( other.isEnemy and other.isTargettable == true ) then 
		other.lives = other.lives - 1

		other.alpha = 0.5 -- Make the enemy temporairly untargettable 
		other.isTargettable = false

		if ( other.lives == 0 ) then -- Enemy has no lives left
			other.isSensor = true
			other.isEnemy = false
			timer.performWithDelay(1000, other:applyLinearImpulse( 0.05, -0.30, other.x, other.y ))
			other.yScale = -1

			--Force the enemy to drop his item
			if ( game.hasAttribute(enemy,"drop") ) then game.dropItemFrom(enemy) end 
				
			timer.performWithDelay(5000, function() other:removeSelf() end)
			game.addScore(200) -- We will modify this
		
		else -- Enemy is still alive
			
			local removeMobImmunity = function() 
				other.alpha=1 
				other.isTargettable = true
			end
			timer.performWithDelay(500, removeMobImmunity)

			-- Knocks back the enemy
			if (other.x > game.steve.x) then other:applyLinearImpulse(1,1,other.x,other.y) 
			elseif (other.x < game.steve.x) then other:applyLinearImpulse(-1,1,other.x,other.y)
			end
		end

	-- If the object is a item that can be destroyed from steve attacks
	elseif( other.isBreakable ) then
		display.remove(other)
	end
end

-------------------------------------
	-- Used by npcDetectByCollision
	local contactEnabled = true
	local releaseEnabled = false
-------------------------------------

-- Steve and every npc have an invisible "sensor" physical object surrounding
-- and following them at runtime. This function handles the collision between
-- the two (in future three) sensors, and acts differently depending if the
-- collision is a "contact" or a "release" between the two circles.
local function npcDetectByCollision( event )
	local sensorN, collName, flag 
	if ( (event.object1.sensorName == "N") or (event.object2.sensorName == "N") ) and 
		( (event.object2.sensorName == "D") or (event.object2.sensorName == "E") ) then
		sensorN = event.object1

		--[[
			-- if (event.object2.sensorName == "D") then
			-- 	sensorD = event.object2
			-- elseif (event.object2.sensorName == "E") then
			-- 	sensorE = event.object2
			-- end
			-- if (sensorN.sensorName ~= "N") then
			-- 	sensorN = event.object2
			-- end
		]]--

		if (contactEnabled) then 
			collName = "contact"
			flag = "show"
		elseif (releaseEnabled) then
			collName = "release"
			flag = "hide"
		end

		-- Switches between the two if blocks (next collision will enter the other 'if')
		if (collName == "contact") then
			contactEnabled = false
			releaseEnabled = true
		elseif (collName == "release") then
			releaseEnabled = false
			contactEnabled = true
		end

		for i=1, #game.npcs, 1 do
			-- Selects the npc associated to the sensorN and calls the toggle function
			if (game.npcs[i].sensorN == sensorN) then
				--toggleNpcBalloon(game.npcs[i], flag)
				game.npcs[i].balloon:toggle(flag)
			end
		end
	end
end


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
			game.levelCompleted = true
			game.endGameScreen()
		else
			game.letMeJump = true -- force enable the jump
		end

	-- Index for collisions involving the player's Attack
	elseif( (o1.myName == "steveAttack") or (o2.myName == "steveAttack") ) then
		steveAttackCollision( event )
	
	-- Index for collisions involving sensors
	elseif( (o1.eName == "sensor") and (o2.eName == "sensor") ) then
		npcDetectByCollision( event )
	end
end

--------------------------------------------------------------------------------------------------
-- Allows the player to pass through certain platforms when jumping from below the platform's base
function collisions.stevePreCollision( self, event )
	if ( event.other.myName == "platform" ) then

		-- Compare Y position of character "base" to platform top
		-- A slight increase (0.2) is added to account for collision location inconsistency
		-- If collision position is greater than platform top, void/disable the specific collision
		if ( self.y+(self.height*0.5) > event.other.y-(event.other.height*0.5)+0.2 ) then
			if event.contact then
				event.contact.isEnabled = false
				-- The jump policy is disabled temporairly while the player is passing through
				self.canJump = false
			end
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------


return collisions