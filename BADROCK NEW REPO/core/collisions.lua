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
			local enemy = other
			-- Locally stores some of the enemies attributes
			-- This is needed because they may become lost when the enemy is removed.
			local enemyHit = {}
			enemyHit.drop = enemy.drop
			enemyHit.name = enemy.name 
			enemyHit.x = enemy.x
			enemyHit.y = enemy.y

			enemy.lives = enemy.lives - 1

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

		-- Target is a breakable item (i.e. crates, rocks..)
		elseif( other.isBreakable ) then
			display.remove(other)
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

	-- Collision between the player and safe environment Tiles
	local function environmentCollision( player, event )
		local environment = event.other

		if (event.phase == "began" and environment.isGround) then
			player.canJump = true
			player.isAirborne = false 
			player.hasTouchedGround = true
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
		elseif (o.eName == "enemy" or (o.tName =="danger")) then
			dangerCollision( self, event )
		-- Special case for the level's ending block. Triggers -endGameScreen-
		elseif(o.tName == "endLevel") then
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

			for i, v in ipairs(game.npcs) do
				-- Selects the npc associated to the sensorN and calls the toggle function
				if (v.sensorN == sensorN) then
					v.balloon:toggle(flag)
				end
			end
		end
	end
------------------------------------------------------------------------------------

-- ITEM-SPECIFIC COLLISIONS --------------------------------------------------------

	function collisions.itemPreCollision( self, event )
		if (event.other.eName == "steve") then
			if (self.itemName == "life" and game.lives == game.MAX_LIVES) or
				(self.type == "powerup" and steve.hasPowerup) then
				event.contact.isEnabled = false
			end
		end
		return true
	end

	local function lifeCollision( life, event )
		if (event.phase == "began") then
			if (game.lives ~= game.MAX_LIVES) then
				display.remove(life)
				game.addOneLife()
			end
		end
	end

	-- local function gunCollision( gun, event )
		-- 	if ( event.phase == "began" ) then
		-- 		display.remove(gun)
		-- 		print("hai preso la Gun -- azione ancora da implementare")
		-- 		--da Implementare
				
		-- 	elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		-- 	end
		-- end

	-- local function immunityCollision( immunityItem , event )
		-- 	if ( event.phase == "began" ) then
		-- 	--[[	display.remove(immunityItem)
		-- 		sfx.playSound( sfx.coinSound, { channel = 3 } )
				
		-- 		local duration = 3000
		-- 		--per far capire che l'effetto è attivo riduco momentaneamente l'alpha di steve
		-- 		steve.sprite.alpha = 0.5 
		-- 		steve.immunity = true
		-- 		transition.to(steve , { time = duration , onComplete = function()
		-- 			steve.immunity = nil	
		-- 			steve.sprite.alpha = 1
		-- 		end})			
		-- 	]]
		-- 	elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		-- 	end
		-- end

	-- local function metheorsRainCollision( metheorsItem, event )
		-- 	if ( event.phase == "began" ) then
		-- 		display.remove(metheorsItem)
		-- 		--da Implementare
		-- 		local numberMetheors = 6
		-- 		local metheors = {}

		-- 		local function createMetheor()
		-- 			local metheor = entity.newEntity{
		-- 			graphicType = "static",
		-- 				filePath = visual.itemMetheor,
		-- 				width = 40,
		-- 				height = 40,
		-- 				bodyType = "dynamic",
		-- 				physicsParams = { isSensor = true , friction = 10.0, density = 0.3, },
		-- 				eName = "item"
		-- 			}

		-- 			local directionX = math.random(-2, 2)
		-- 			local directionY = math.random(-1, 1)
		-- 			local c = display.contentCenterX
		-- 			local spawnX = math.random( c - display.contentWidth , c + display.contentWidth)
		-- 			metheor.x , metheor.y = spawnX, display.contentHeight
		-- 			metheor:addOnMap(game.map)

		-- 			transition.to(metheor,{time =0, onComplete= function()
		-- 				metheor:applyLinearImpulse(directionX, directionY, metheor.x -5 , metheor.y +7)
		-- 			end})

		-- 			local funct = function()
		-- 				display.remove(metheor)
		-- 			end
		-- 			timer.performWithDelay(6000, funct)

		-- 			return metheor
		-- 		end

		-- 		local function effect()
		-- 			local m = createMetheor()
		-- 			table.insert(metheors, m)
		-- 		end

		-- 		local function executeWithDelay()
		-- 			local difference = math.random(1000, 2000)
		-- 			timer.performWithDelay(difference, effect)
		-- 		end

		-- 		for i=0, numberMetheors do
		-- 			executeWithDelay()
		-- 		end

		-- 	elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		-- 	end
		-- end

	-- local function summonCollision( summonItem, event )
		-- 	if ( event.phase == "began" ) then
		-- 		display.remove(summonItem)
		-- 		--da Implementare
				
		-- 	elseif(event.phase == "cancelled" or event.phase == "ended" ) then
		-- 	end
		-- end

	function collisions.itemCollision( self, event )
		local o = event.other
		if ( o.eName == "steve")  then

			--List of all items with relative collision handler
			elseif (self.itemName == "life") then
				lifeCollision( self, event)
			-- elseif (self.itemName == "coin") then
			-- 	coinCollision( self, event)
			-- elseif (self.itemName == "gun") then
			-- 	gunCollision( self, event)
			-- elseif (self.itemName == "immunity") then
			-- 	immunityCollision( self, event)
			-- elseif (self.itemName == "metheors") then
			-- 	metheorsRainCollision( self, event)
			-- end
			item = nil -- Distruzione dell'item
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