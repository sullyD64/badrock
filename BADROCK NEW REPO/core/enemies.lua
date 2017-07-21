-----------------------------------------------------------------------------------------
--
-- enemies.lua
--
-- An enemy is an hostile Entity capable of moving on the map and performing other actions 
-- which can kill Steve in several ways. 
-- There are several "species" of enemy, which differ in aspect, size and other aspects.
-- Enemies will also behave differently depending on other parameters. For now, there are 
-- two types of behavior [in the short future will become three]:
-- 1) If no additional property is specified, an Enemy will stay still and will only 
-- 	hurt the Player passively if this collides with him;
-- 2) If the property isChaser is true, the Enemy will be a Chaser.
-- 	A Chaser will stay still and have an "aggro" zone surrounding him; if the Player
--    gets inside this aggro zone, the Chaser will start "chasing" the Player; if the Player
-- 	dies (by any cause), the Chaser will return to the center of his aggro zone and wait 
-- 	for the Player to come closer again;
-- 	There is also a "safe zone" located around the Player's spawn point, which will make
-- 	the Chaser stop chasing the Player.
-- 3) If the property isWalker is true, the Enemy will be a Walker.
-- 	A Walker moves on the map following a pre-established route.
-- 
-- Every Enemy species and type is guessed from the properties of the objects declared in
-- the game's current map, all of which indicate the spawn point for that selected Enemy.
----------------------------------------------------------------------------------------
local entity     = require ( "lib.entity"      )
local collisions = require ( "core.collisions" )

local enemies = {
	descriptions = {
		-- 1 Paper
		{	
			species = "paper",
			lives = 1,
			isChaser = true,
			score = 250,
			options = {
				graphicType = "animated",
				filePath = visual.enemyPaper,
				spriteOptions = {
					width = 80,
					height = 90,
					numFrames = 9,
					sheetContentWidth = 240,
					sheetContentHeight = 270 
				},
				spriteSequence = {
					{name = "idle",    frames={1,2},         time=650, loopCount=0},
					{name = "walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
					{name = "running", start =4, count=5,    time=600, loopCount=0},
					{name = "dead",    frames={9},           time=500, loopCount=1}
				},
				physicsParams = { bounce = 0, friction = 1.0, density = 2 },
				eName = "enemy"
			}
		},
		-- 2 Robot
		{	
			species = "robot",
			lives = 1,
			isWalker = true,
			score = 150,
			options = {
				graphicType = "animated",
				filePath = visual.enemyRobot,
				spriteOptions = {
					width = 164,
					height = 153,
					numFrames = 3,
					sheetContentWidth = 493,
					sheetContentHeight = 153,
				},
				spriteSequence = {
					{name = "walking", frames={1,2}, time=400, loopCount=0},
					{name = "dead",    frames={3},   time=300, loopCount=1},
				},
				physicsParams = { bounce = 0, friction = 1.0, density = 0.5, },
				eName = "enemy",
			},
		},
		-- 3 Chair
		{
			species = "chair",
			lives = 2,
			score = 150,
			options = {
				filePath = visual.enemyChair,
				width = 140,
				height = 226,
				physicsParams = { bounce = 0, friction = 1.0, density = 0.5, },
				eName = "enemy",
			},
		},
		-- 4 Phoenix
		{	
			species = "phoenix",
			lives = 1,
			score = 200,
			options = {
				graphicType = "animated",
				filePath = visual.enemyPhoenix,
				spriteOptions = {
					width = 300,
					height = 160,
					numFrames = 5,
					sheetContentWidth = 300,
					sheetContentHeight = 800,
				},
				spriteSequence = {
					{name = "idle", start=1 ,count=4, time=500, loopCount=0},
					{name = "dead",    frames={5},   time=300, loopCount=1},
				},
				physicsParams = { bounce = 0, friction = 1.0, density = 0.5, gravityScale = 0 },
				eName = "enemy",
			},
		},
	}
}

-- CHASER-SPECIFIC FUNCTIONS -------------------------------------------------------
	-- Context: if the chaser's target is in his aggro zone, the chaser moves to reach
	-- the target.
	local function chaseTarget(currentGame, chaser, target)
		local tileWidth = currentGame.map:getProperty("tilewidth"):getValue()

		if (target.eName) then chaser.targetName = target.eName 
		elseif (target == chaser.home) then chaser.targetName = "spawn" 
		end

		if ( (chaser.x and chaser.y) and (target.x and target.y ) and chaser.lives ~= 0) then
			-- Normal chasing is disabled when jumping a void platform or jumping to reach higher ground.
			-- [note: this is done to overcome a double setting of the position which, if combined with 
			-- the impulse applied by this methode, will lead to unexpected and repentine behaviors]
			if (not chaser.isJumpingVoid and not chaser.isJumpingTo) then
				if( math.abs(chaser.x-target.x) <= tileWidth*9 or target.enemySprite ) then
					chaser.speed = 1.5 
					-- (moves faster when returning to spawn)
					if (target.enemySprite) then chaser.speed = 2 end 

					-- Works out angle between target and chaser
					local angle = math.atan2 (target.y - chaser.y, target.x - chaser.x) 
					-- Updates x pos in relation to angle
					chaser.x = chaser.x + ( math.cos(angle) * chaser.speed ) 
					
					if(target.x > chaser.x)
					then chaser.xScale = -1
					else chaser.xScale =  1
					end

					-- Every two seconds, the chaser checks if the target is in a higher position
					-- compared to him. If he is close enough, he attempts to reach that height.
					if not (chaser.isJumpingTo) 
						and not (chaser.isCheckingVerticalProximity and not chaser.isJumpingVoid) then
						chaser.isCheckingVerticalProximity = true
						chaser:checkVerticalProximity(target)
						timer.performWithDelay(2000, 
							function()
								chaser.isCheckingVerticalProximity = false
							end
						)
					end

					-- Every frame, the chaser checks if there is a void nearby (a ledge).
					-- If he is close enough, he attempts to reach over that void.
					for k, void in pairs(chaser.voidList) do
						chaser:checkVoidProximity(void)
					end

					-- The chaser must wait one second to jump past a void again, the count starts
					-- from when he jumps the first time.
					if not (chaser.isCheckingIfJumpedVoid) and (chaser.isJumpingVoid) then
						chaser.isCheckingIfJumpedVoid = true
						timer.performWithDelay(1000,
							function()
								chaser.canJumpVoid = true
							end
						)
						chaser.isCheckingIfJumpedVoid = false
					end


					if (chaser.hasReturnedHome == false) then
						-- The chaser "has returned home" (literally) only when he returns
						-- to the exact position where he spawned.
						if (math.abs(chaser.x - target.x) <= 20) then
							-- The chaser awaits little before returning to wait for the player
							timer.performWithDelay(500, 
								function()
									if (chaser.isIdleAwayFromHome ~= false) then
										chaser.isIdleAwayFromHome = false
									end
									if (chaser.hasReturnedHome ~= true) then
										chaser.hasReturnedHome = true
									end
								end
							)
						end
						-- If it's taking too long to return to the spawn point, 
						-- the chaser will teleport there immediately.
						if not (chaser.isCheckingIfTooLate) then
							chaser.isCheckingIfTooLate = true
							chaser:checkIfTooLate(target)
						end
					end
				end
			end
		end
	end

	-- Context: if the target is on a platform higher than the chaser, and the chaser is
	-- close enough to the target, the chaser can jump through the platform.
	local function checkVerticalProximity(currentGame, chaser, target)
		local tileWidth = currentGame.map:getProperty("tilewidth"):getValue()
		local xDist = math.abs(chaser.x - target.x)
		local yDist = math.abs(chaser.y - target.y)

		-- Chasers can reach a platforms which are 4 tiles higher than them
		local jumpTo = function(chaser) 
			if (yDist <= tileWidth*3) then
				chaser:applyLinearImpulse( 0, -450, chaser.x, chaser.y )
			elseif (yDist <= tileWidth*5 and yDist >= tileWidth*3) then
				chaser:applyLinearImpulse( 0, -620, chaser.x, chaser.y )
			end
		end

		if (chaser.y > target.y and xDist <= tileWidth*5 and yDist <= tileWidth*5) then
			if (chaser.canJumpVoid) then
				jumpTo(chaser)
				chaser.isJumpingTo = true
			end
		end
	end

	-- Context: if the chaser encounters a void between him and his target, he temporairly
	-- stops chasing the target and attempts to jump over the void.
	local function checkVoidProximity(currentGame, chaser, void )
		local tileWidth = currentGame.map:getProperty("tilewidth"):getValue()
		local lBorder, rBorder = void.x, void.x + void.shape[5]
		local lDist, rDist = math.abs(lBorder-chaser.x), math.abs(rBorder-chaser.x)
		
		local yDist = math.abs(chaser.y - void.y)
		local xDist
		if (lDist > rDist) 
		then xDist = rDist
		else xDist = lDist
		end

		local jumpPastVoid = function(chaser)
			chaser:applyLinearImpulse( 180 * -chaser.xScale, -250, chaser.x, chaser.y )
		end

		if ( xDist <= tileWidth*0.3 and yDist <= tileWidth*2.8) then
			if not (chaser.isJumpingVoid) and (chaser.canJumpVoid) then
				jumpPastVoid(chaser)
				chaser.isJumpingVoid = true
				chaser.canJumpVoid = false
			end
		end
	end

	-- Context: if the chaser has left its 'home' and has disaggroed, and has been in this
	-- state for more than a certain amount of time, the chaser begins returning home.
	local function checkIfIdleTimeExceeded(chaser)
		timer.performWithDelay( 2000, 
			function()
				if (chaser.isChasingPlayer == false) then
					chaser.hasReturnedHome = false
				end
				if (chaser.isCheckingIdleTime ~= false) then
					chaser.isCheckingIdleTime = false
				end
			end
		)
	end

	-- Context: the chaser is returning to its spawn point but it is stuck somewhere or
	-- the operation is taking too much time: in this case, the chaser is teleported
	-- home. During this transition, its body is unactive.
	local function checkIfTooLate(chaser, target)
		timer.performWithDelay( 1500, 
			function()
				if (chaser.hasReturnedHome == false) then
					local teleportHome = function()
						chaser.isBodyActive = false
						transition.to(chaser, {time = 1000, alpha = 0, 
							x = target.x, y = target.y, 
							transition = easing.outExpo,
							onComplete = function()
								chaser.alpha = 1
								chaser.isBodyActive = true
								chaser.hasReturnedHome = true
							end
						})
					end
					teleportHome()
				end
				chaser.isCheckingIfTooLate = false
			end
		)
	end

	-- MAIN -------------------------------------------------------------------------
	local function loadChaser( chaser, currentGame )
		chaser.voidList = currentGame.map:getObjectLayer("cadutaVuoto").objects
		chaser.isIdleAwayFromHome = false
		chaser.isChasingPlayer = false
		chaser.canJumpVoid = true

		-- Only chasers need (and therefore will have) preCollision handling.
		chaser.preCollision = collisions.enemyPreCollision
		chaser:addEventListener( "preCollision", chaser)

		-- Used when the chaser jumps, to re-enable normal chasing.
		-- Used also to detect collision with dangerous environment and trigger death.
		chaser.collision = function(self, event)
			if (event.other.tName ~= "danger") then
				if (event.other.isGround) then
					chaser.isJumpingTo = false
					chaser.isJumpingVoid = false
				end
			else
				if (chaser.lives ~= 0) then
					chaser.lives = 0
					currentGame.addScore(chaser.score)
					chaser:onDeathAnimation()
					chaser:destroy()
				end
			end
		end

		chaser:addEventListener("collision", chaser)

		-- Main function: target can be the player or the chaser's spawn point.
		function chaser:chase( target )
			chaseTarget(currentGame, self, target)
		end

		-- Invoked fr`om chase(target) periodically
		function chaser:checkVerticalProximity( target )
			checkVerticalProximity(currentGame, self, target)
		end

		-- Invoked from chase(target) at each frame
		function chaser:checkVoidProximity( void )
			checkVoidProximity(currentGame, self, void)
		end

		-- Invoked from chase(target) ONCE and only when isIdleAwayFromHome
		function chaser:checkIfIdleTimeExceeded()
			checkIfIdleTimeExceeded(self)
		end

		-- Invoked from chase(target) only if target is the chaser's spawn.
		function chaser:checkIfTooLate( target )
			checkIfTooLate(self, target)
		end
	end
	---------------------------------------------------------------------------------
------------------------------------------------------------------------------------

-- WALKER-SPECIFIC FUNCTIONS -------------------------------------------------------
	-- MAIN -------------------------------------------------------------------------
	local function loadWalker( walker, currentGame, enemy )
		walker.id = enemy.id
		walker.speed = enemy.speed
		walker.travelDistance = enemy.travelDistance
		walker.sensors = util.createObjectSensors(currentGame.map, walker)

		-- Handles the collision when a walker collides with one of its sensors.
		-- When that happens, bounces the walker in the opposite direction.
		-- Used also when the walker collides with the player
		walker.collision = function( self, event )
			if ( event.phase == "began") then
				if ( self.id == event.other.id) then
					local vx,vy = self:getLinearVelocity()
					self:setLinearVelocity( -vx, -vy )
					self.xScale = - self.xScale
				end
			end
		end
		walker:addEventListener( "collision", walker )

		transition.to(walker, {time = 500,
			onComplete = function()
				walker.bodyType = "kinematic"
				walker:setLinearVelocity( -walker.speed, 0 )
				walker:setSequence("walking")
				walker:play()
			end
		})
	end
	---------------------------------------------------------------------------------
------------------------------------------------------------------------------------

function enemies.assignChaserHomes( enemies, chasers )
	for i, chaser in pairs(chasers) do
		-- Each entry in enemies contains the original spawn coordinates of a chaser,
		-- while each enemySprite contains the current coordinates (and equals to the chaser).
		for k, enemy in pairs(enemies) do
			if (chaser == enemy.enemySprite) then
				-- Grants visibility to each chaser of its spawn coordinates.
				chaser.home = enemy
			end
		end
	end
end



	
-- Loads the enemies's images (and sprites) and initializes their attributes.
-- Visually instantiates the enemies in the current game's map.
-- @return enemyList, walkerList, chaserList
function enemies.loadEnemies( currentGame,lista) 
	local currentMap = currentGame.map
	--local enemyList = currentMap:getObjectLayer("enemySpawn").objects
	
	

	if not (lista) then return end

	local chaserList = {}
	local walkerList = {}
	
	-- Loads the main Entity.
	local loadEnemyEntity = function( enemy )
		local desc
		for i, v in ipairs(enemies.descriptions) do
			if (v.species == enemy.type) then
				desc = v
				break
			end
		end

		if (desc == nil ) then
			error(enemy.type .. ": Enemy species not found in the EnemyDescriptions")
		end
		
		desc.options.physicsParams.filter = filters.enemyHitboxFilter
		desc.options.isFixedRotation = true
		local enemySprite = entity.newEntity(desc.options)

		enemySprite.species = desc.species
		enemySprite.lives = desc.lives or 1
		enemySprite.score = desc.score

		if( enemy.drop ) then
			enemySprite.drop = enemy.drop
		end

		enemySprite.isTargettable = true
		enemySprite.x, enemySprite.y = enemy.x, enemy.y

		enemySprite:addOnMap( currentMap )
		if(desc.options.graphicType == "animated") then
			enemySprite:setSequence("idle")
			enemySprite:play()
		end
		---------------------------------------------------------------
		-- Temporary: assuming the species DOES determine the behavior,
		-- this is specified in the description list.
		if (desc.isChaser) then
			loadChaser(enemySprite, currentGame)
			table.insert(chaserList, enemySprite)
		elseif (desc.isWalker) then
			loadWalker(enemySprite, currentGame, enemy)
			table.insert(walkerList, enemySprite)
		end
		---------------------------------------------------------------

		-- Animation: Knocks the enemy AWAY given a x position
		function enemySprite:onHitAnimation(x)
			if (self.x > x) then self:applyLinearImpulse(40,-200,self.x,self.y)
			elseif (self.x < x) then self:applyLinearImpulse(-40,-200,self.x,self.y)
			end
		end

		-- Animation: knocks the enemy AWAY and off the map
		function enemySprite:onDeathAnimation()
			if (self.bodyType ~= "dynamic") then 
				transition.to (self, {time = 0, 
					onComplete = function()
						self.bodyType = "dynamic" 
						self:removeEventListener( "collision", self )
					end
				})
			end
			self.isSensor = true
			self.eName = "deadEnemy"
			self.yScale = -1
			-- If the enemy is an animated entity, sets its sequence to dead (parametrized)
			if (self.sequence) then
				self:setSequence("dead")
				self:play()
			end
			timer.performWithDelay(1000, self:applyLinearImpulse( 0.05, -200, self.x, self.y ))
			transition.to(self, {time = 5000,  -- removes it when he's off the map 
				onComplete = function()
					display.remove(self)
				end
			})
		end

		-- Called after onDeathAnimation
		function enemySprite:destroy()
			-- if Enemy is a Chaser, remove it from the list ----
				for k, chaser in pairs(currentGame.chaserList) do
					if (self == chaser) then
						chaser = nil
					end
				end
			-- if Enemy is a Walker, remove it from the list ----
				for k, chaser in pairs(currentGame.walkerList) do
					if (self == walker) then
						walker = nil
					end
				end
			self = nil
		end

		return enemySprite
	end

	for k, enemy in ipairs(lista) do
		enemy.enemySprite = loadEnemyEntity(enemy)
		print("loop "..k)
		---------------------------------------------------------------
		-- Temporary: assuming the species DOES NOT determine the 
		--	behavior, this is specified in the enemy object in the map,
		-- so appears in enemyList as an attribute.
		-- if (enemy.isChaser) then
		-- 	loadChaser(enemy.enemySprite, currentGame)	
		-- 	table.insert(chaserList, enemy.enemySprite)
		-- elseif (enemy.isWalker) then
		-- 	loadWalker(enemy.enemySprite, currentGame)	
		-- 	table.insert(walkerList, enemy.enemySprite)
		-- end
		---------------------------------------------------------------	
	end

	return lista, chaserList, walkerList
end

return enemies
