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

-- ATTACK-SPECIFIC COLLISIONS ------------------------------------------------------
	-- Collision between the player's Attack and an Enemy
	function collisions.attackCollision( self, event )
		local other = event.other

		-- Target is an enemy, targettable AND not invincible
		if( other.eName == "enemy" and other.isTargettable == true ) then 
			-- audio --------------------------------------------
			if (steve.isImmune) then
				audio.stop(3)
				sfx.playSound( sfx.boom2Sound, { channel = 3 } )
			else
				audio.stop(3)
				sfx.playSound( sfx.enemyDefSound, { channel = 3 } )
			end
			-----------------------------------------------------

			local enemy = other
			-- Locally stores some of the enemies attributes
			-- This is needed because they may become lost when the enemy is removed.
			local enemyHit = {}
			enemyHit.drop = enemy.drop
			enemyHit.name = enemy.name 
			enemyHit.x = enemy.x
			enemyHit.y = enemy.y

			-- Enemy is insta-killed if the player is using the bonus "immunity"
			if (steve.isImmune) then
				enemy.lives = 0
			else
				enemy.lives = enemy.lives - 1
			end

			-- Enemy has no lives left: handle death
			if ( enemy.lives == 0 ) then 
				game.addScore(enemy.score)

				-- Forces the enemy to drop his item
				if (enemyHit.drop) then	game.dropItemFrom(enemyHit) end
				
				enemy:onDeathAnimation()
				enemy:destroy()

			-- Enemy is still alive: handle hit
			else 									
				enemy:onHitAnimation(steve.x)

				-- Makes the enemy temporairly untargettable and reverts it short after
				enemy.alpha = 0.5 
				enemy.isTargettable = false
				timer.performWithDelay(500, 
					function()
						enemy.alpha = 1
						enemy.isTargettable = true
					end
				)
			end

			if (self.type == "bullet") then
				self:destroy()
			end

		-- Target is a boss part, targettable
		elseif( (other.eName == "boss") and other.isTargettable == true ) then
			local bossPart = other

			-- audio --------------------------------------------
			if (bossPart.isProjectile) then
				audio.stop(2)
				sfx.playSound( sfx.boom1Sound, { channel = 2 } )
			else
				audio.stop(3)
				sfx.playSound( sfx.enemyDefSound, { channel = 3 } )
			end
			-----------------------------------------------------

			bossPart.lives = bossPart.lives - 1

			-- Destructible projectiles which belong the boss don't count in 
			-- decrementing the boss' total life
			if (not bossPart.isProjectile) then	
				game.bossFight:decrementTotalLives()
			end

			-- bossPart has no lives left: handle death
			if (bossPart.lives == 0) then
				transition.cancel(bossPart)
				if (bossPart.isProjectile) then
					display.remove(bossPart)
				else
					bossPart:onDeathAnimation()
				end

			-- bossPart is still alive: handle hit
			else
				bossPart:onHitAnimation()

				-- Makes the bossPart temporairly untargettable and reverts it short after
				bossPart.alpha = 0.5 
				bossPart.isTargettable = false
				timer.performWithDelay(1000, 
					function()
						bossPart.alpha = 1
						bossPart.isTargettable = true
					end
				)
			end

			if (self.type == "bullet") then
				self:destroy()
			end

		-- Target is a breakable item (i.e. crates, rocks..)
		elseif( other.isBreakable ) then
			-- audio ----------------------------------------
			audio.stop(6)
			sfx.playSound( sfx.boom1Sound, { channel = 6 } )
			-------------------------------------------------
			util.generateParticles( game, other )

			if (self.type == "bullet") then
				self:destroy()
			end

		elseif((other.tName == "env") and (self.type == "bullet")) then
			self:destroy()
		end
	end	
------------------------------------------------------------------------------------

-- PLAYER-SPECIFIC COLLISIONS ------------------------------------------------------
	-- Allows the player to pass through a platform when jumping from below its base
	function collisions.playerPreCollision( self, event )
		if ( event.other.isPlatform ) then

			-- Compare Y position of character "base" to platform top
			-- A slight increase (0.2) is added to account for collision location inconsistency
			-- If collision position is greater than platform top, void/disable the specific collision
			if ( self.y+(self.height*0.5) > event.other.y-(event.other.height*0.5)+0.2 ) then
				if event.contact then
					event.contact.isEnabled = false
					-- The jump policy is briefly disabled
					self.canJump = false
					self.isAirborne = true
				end
			end
		end
		return true
	end

	-- l'idea di questa funzione era creare un effetto quando steve raggiungeva 
	-- un checkpoint: ho usato il metodo che genera i frammenti alla morte di steve,
	-- ma l'idea è creare delle stelle o dei fuochi d'artificio molto semplici, basta 
	-- cambiare il filePath e mettere un'immagine adatta
		-- local function generateStars(currentGame, pointX, pointY)
		-- 	local fragments = {}
		-- 	local fragmentGroup = display.newGroup()
		-- 	local numStars = 5
		-- 	local cp
		-- 	for i = 1, numStars, 1 do
		-- 		local dim = math.random (4, 20)
		-- 		local directionX = math.random(-5, 5)
		-- 		local directionY = math.random(-50, -30)
		-- 		local frag = entity.newEntity{
		-- 			filePath = visual.lifeIcon,
		-- 			width = dim,
		-- 			height = dim,
		-- 			physicsParams = {density = 1, friction = 1, bounce = 0.5, filter = filters.parcticleFilter},
		-- 			eName = "particle"
		-- 		}	
		-- 		frag.x , frag.y = pointX, pointY-30
		-- 		frag:addOnMap(currentGame.map)
		-- 		fragmentGroup:insert(frag)

		-- 		-- Transition here is needed because we need to wait newEntity to finish
		-- 		-- its transition to the entities' physical bodies.
		-- 		transition.to(frag, {time = 0,
		-- 			onComplete = function()
		-- 				frag:applyLinearImpulse(directionX, directionY, frag.x , frag.y)
		-- 				cp=display.newText("checkpoint",50,10)
						
		-- 				end
		-- 			})
		-- 		table.insert(fragments, frag)
		-- 	end

		-- 	currentGame.map:getTileLayer("entities"):addObject(fragmentGroup)

		-- 	-- Removes physics to the rock fragments after a brief delay.
		-- 	transition.to(fragmentGroup, {alpha = 0, time = 3000, transition = easing.inExpo, 
		-- 		onComplete = function()
		-- 			for i=1, #fragments, 1 do
		-- 				fragments[i].isBodyActive = false
		-- 				fragments[i].alpha = 0
		-- 				if(gameStateList ~= ENDED) then fragments[i]:removeSelf() display.remove(cp) cp.isVisible= false end
		-- 			end
		-- 			if (gameStateList ~= ENDED) then display.remove( fragmentGroup ) end
		-- 		end
		-- 	})
		-- end

	-- Collision between the player and safe environment Tiles
	local function environmentCollision( player, event )
		local environment = event.other
		if (event.phase == "began" and environment.isGround) then
			player.canJump = true
			player.isAirborne = false 
			player.hasTouchedGround = true

			if (environment.isMovingPlatform and event.contact.isEnabled) then
				player.isOnMovingPlatform = true
			else
				player.isOnMovingPlatform = false
			end
		end

		if(environment.type == "event") then
			environment.owner.listener(event)
		end
	end

	-- Collision between the player and an Enemy (or dangerous environment Tiles)
	local function dangerCollision( player, event )
		local danger = event.other
		-- For reasons, steve may collide with an enemy when attacking if he comes too close:
		-- this control allows to temporairly make Steve 'invincible' against certain entities 
		-- when attacking (with his default attack). This will NOT work if the entity 
		-- represents certain danger (void, spikes, invincible enemies and such).
		if ( (player.state ~= sState.ATTACKING) or 
			(player.state == sState.ATTACKING and danger.tName == "danger") ) then 

			-- The whole death phase is handled in the controller
			-- the declaration below triggers a call in the game loop
			-- (see game and controller)
			player.state = sState.DEAD
		end
	end

	function collisions.playerCollision( self, event )
		local o = event.other

		if (o.tName == "env") then
			environmentCollision( self, event )
		elseif ((o.eName == "enemy") or (o.eName == "boss") or (o.tName =="danger")) then
			dangerCollision( self, event )
		-- Special case for the level's ending block. Triggers -endGameScreen-
		elseif(o.tName == "endLevel") then
			-- audio ----------------------------------------
			sfx.playSound( sfx.levelEndSound, { channel = 7 } )
			-------------------------------------------------

			-- The whole end phase is handled in the controller
			-- the declaration below triggers a call in the game loop
			-- (see game and controller)
			game.state = gState.COMPLETED
		end
	end
------------------------------------------------------------------------------------

-- ENEMY-SPECIFIC COLLISIONS -------------------------------------------------------
	function collisions.enemyPreCollision( self, event )
		if ( event.other.isPlatform ) then
			if ( self.y+(self.height*0.5) > event.other.y-(event.other.height*0.5)+0.2 ) then
				if event.contact then
					event.contact.isEnabled = false
				end
			end
		return true
		end
	end
------------------------------------------------------------------------------------

-- NPC-SPECIFIC COLLISIONS ---------------------------------------------------------
	-- Steve and every npc have an invisible "sensor" physical object surrounding
	-- and following them at runtime. This function handles the collision between
	-- the two (in future three) sensors, and acts differently depending if the
	-- collision is a "contact" or a "release" between the two circles.
	function collisions.npcDetectByCollision( sensorN, event )
		if (event.other.eName == "sensor" and event.other.sensorName == "D") then
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

			-- Selects the npc associated to the sensorN and calls the toggle function
			game.loadedNPCs[sensorN.oName].balloon:toggle(flag)
		end
	end
------------------------------------------------------------------------------------

-- ITEM-SPECIFIC COLLISIONS --------------------------------------------------------

	local function lifeCollision( life, event )
		if (event.phase == "began") then
			if (game.lives ~= game.MAX_LIVES) then
				-- audio ----------------------------------------
				audio.stop(5)
				sfx.playSound( sfx.lifeupSound, { channel = 5 } )
				-------------------------------------------------
				display.remove(life)
				game.addOneLife()
			else
				print("max lives!")
				---------------------------------
				game.maxLivesReached(life) 
				---------------------------------
			end
		end
	end

	local function bonusCollision( bonus, event )
		-- The bonus can't be picked up if the player is attacking, as this action MAY
		-- modify the attack itself wich is a sequence of timed events.
		if (not steve:isPerformingAttack()) then
			-- print("Picked "..bonus.itemName)
			display.remove(bonus)
			steve:useBonus(bonus.itemName)
		end
	end

	local function powerupCollision( powerup, event )
		-- The powerUp can't be picked up if the player is attacking, as this action modifies
		-- the attack itself which is a sequence of timed events.
		if (steve.state ~= "Attacking" and (not steve.isImmune)) then
			-- print("Picked "..powerup.itemName)
			display.remove(powerup)
			if (not steve.hasPowerUp) then 
				steve:equipPowerUp(powerup.itemName)
			elseif (steve.hasPowerUp and steve.equipped == powerup.itemName) then
				steve:refreshPowerUp(powerup.itemName)
			end
		end
	end

	function collisions.itemCollision( self, event )
		local o = event.other
		if ( o.eName == "steve" and self.isPickable) then
			-- Conditional handling depending on item type
			if (self.type == "life" and self.itemName == "life") then
				lifeCollision(self, event)
			elseif (self.type == "bonus") then
				bonusCollision(self, event)
			elseif (self.type == "powerup") then
				powerupCollision(self, event)
			end
			self:destroy()
		end
	end
------------------------------------------------------------------------------------

-- local i = 0
-- Generic collision handler (now used for debugging collisions)
function collisions.onCollision( event )
	-- local o1, o2 = event.object1, event.object2

	-- if((o1.eName or o1.tName) and (o2.eName or o2.tName)) then
	-- 	i = i+1
	-- 	local n1 = o1.eName or o1.tName
	-- 	local n2 = o2.eName or o2.tName

	-- 	print("["..i.."] Collision between " .. n1 .. " and ".. n2 )
	-- 	if (o1.sensorName) then
	-- 		print ("    - (sensor1: "..o1.sensorName..")")
	-- 	end
	-- 	if (o2.sensorName) then
	-- 		print ("    - (sensor2: "..o2.sensorName..")")
	-- 	end
	-- end
end

return collisions