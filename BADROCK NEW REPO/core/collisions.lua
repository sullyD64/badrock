-----------------------------------------------------------------------------------------
--
-- collisions.lua
--
-----------------------------------------------------------------------------------------
local physics = require ( "physics" )
local ui = require      ( "core.ui" )
local items = require   ( "core.items" )

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
	if ( (game.steve.state ~= game.STATE_ATTACKING and (other.isEnemy or other.isDanger) ) or
		 (game.steve.state == game.STATE_ATTACKING and other.isDanger) ) then 

		if (game.steve.state ~= game.STATE_DIED) then 
			game.steve.state = game.STATE_DIED

			--audio.play( dangerSound ) DA SISTEMARE AUDIO
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

-- Collision between an Enemy and the player's Attack
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

-- Main collision handler index
function collisions.onCollision( event )
	-- Index for collisions involving the player
		if ( (event.object1.eName == "steve") or 
			 (event.object2.eName == "steve") ) then
			
			local steve = event.object1
			local other = event.object2

			if(other.eName =="steve") then 
				steve = event.object2
				other = event.object1
			end

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
		elseif( (event.object1.myName == "steveAttack") or 
			    (event.object2.myName == "steveAttack") ) then
			steveAttackCollision( event )
		end
end

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

return collisions