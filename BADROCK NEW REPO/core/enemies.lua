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
-- 3) [If the property isWalker is true, the Enemy will be a Walker.
-- 	 A Walker moves on the map following a pre-established route].
-- 
-- Every Enemy species and type is guessed from the properties of the objects declared in
-- the game's current map, all of which indicate the spawn point for that selected Enemy.
----------------------------------------------------------------------------------------
local entity     = require ( "lib.entity"      )
local collisions = require ( "core.collisions" )

local enemies = {
	descriptions = {
		-- 1 Paper
			-- For now, ALL paper guys in the map (and only them) are Chasers, and therefore will 
			-- try to follow the Player if he gets too close to their "aggro" sensor.
			-- In a future implementation this property (as the isWalker property) will be 
			-- appliable to single, select Enemies directly from the map file. 
		{	
			species = "paper",
			lives = 1,
			isChaser = true,
			score=250,
			options = {
				graphicType = "animated",
				filePath = visual.enemyPaperAnim,
				spriteOptions = {
					height = 45,
					width = 40,
					numFrames = 9,
					sheetContentWidth = 120,
					sheetContentHeight = 135 
				},
				spriteSequence = {
					{name = "idle",    frames={1,2},         time=650, loopCount=0},
					{name = "walking", frames={1,2,3,3,2,1}, time=650, loopCount=0},
					{name = "running", start =4, count=5,    time=600, loopCount=0},
					{name = "dead",    frames={9},           time=500, loopCount=1}
				},
				physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
				eName = "enemy"
			}
		},

		-- 2 Chair
		{
			species = "chair",
			lives = 2,
			score=150,
			options = {
				filePath = visual.enemySedia,
				width = 70,
				height = 113,
				physicsParams = { bounce = 0, friction = 1.0, density = 1.0, },
				eName = "enemy",
			},
		},
	}
}

-- CHASER-SPECIFIC FUNCTIONS -------------------------------------------------------
	-- (must be self-contained and not call anything outside this module)

	-- Context: if the chaser's target is in his aggro zone, the chaser moves to reach
	-- the target.
	local function chaseTarget(currentGame, chaser, target)
		local tileWidth = currentGame.map:getProperty("tilewidth"):getValue()

		if ( (chaser.x and chaser.y) and (target.x and target.y ) and chaser.lives ~= 0) then
			-- Normal chasing is disabled when jumping a void platform or jumping to reach higher ground.
			-- [note: this is done to overcome a double setting of the position which, if combined with 
			-- the impulse applied by this methode, will lead to unexpected and repentine behaviors]
			if (not chaser.isJumpingVoid and not chaser.isJumpingTo) then

				chaser.speed = 1 
				-- (moves faster when returning to spawn)
				if (target.enemySprite) then chaser.speed = 2 end 

				if( math.abs(chaser.x-target.x) <= tileWidth*9 or target.enemySprite ) then --old value: 400
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
					if not (chaser.isJumpingTo) and not (chaser.isCheckingVerticalProximity and not chaser.isJumpingVoid) then
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

					if (chaser.hasReturnedHome == false) then
						-- The chaser "has returned home" (literally) only when he returns
						-- to the exact position where he spawned.
						if (math.abs(chaser.x - target.x) <= 20) then
							-- The chaser awaits little before returning to wait for the player
							timer.performWithDelay(1000, 
								function()
									chaser.hasReturnedHome = true
								end
							)
						end

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

		local jumpTo = function(chaser) 
			if (yDist <= tileWidth*3) then --old value: 150, 100
				chaser:applyLinearImpulse( 0, -30, chaser.x, chaser.y )
			elseif (yDist <= tileWidth*5 and yDist >= tileWidth*3) then
				chaser:applyLinearImpulse( 0, -48, chaser.x, chaser.y )
			end
			chaser:addEventListener("collision", chaser)
		end

		if (chaser.y > target.y and yDist <= tileWidth*4) then  --old value: 150
			jumpTo(chaser)
			chaser.isJumpingTo = true
		end
	end

	-- Context: if the chaser encounters a void between him and his target, he temporairly
	-- stops chasing the target and attempts to jump over the void.
	local function checkVoidProximity(currentGame, chaser, void )
		local tileWidth = currentGame.map:getProperty("tilewidth"):getValue()
		local lBorder, rBorder = void.x + void.shape[1], void.x + void.shape[3]
		local lDist, rDist = math.abs(lBorder-chaser.x), math.abs(rBorder-chaser.x)
		
		local yDist = math.abs(chaser.y - void.y)
		local xDist
		if (lDist > rDist) 
		then xDist = rDist
		else xDist = lDist
		end

		local jumpPastVoid = function(chaser)
			if( chaser.xScale == -1) then
				chaser:applyLinearImpulse( 10, -35, chaser.x, chaser.y )
			elseif( chaser.xScale == 1) then
				chaser:applyLinearImpulse( -10, -35, chaser.x, chaser.y )
			end
			chaser:addEventListener("collision", chaser)
		end

		if ( xDist <= tileWidth*2.5 and yDist <= tileWidth*2.5) then
			if not (chaser.isJumpingVoid) then
				jumpPastVoid(chaser)
				chaser.isJumpingVoid = true
			end
		end
	end

	-- Context: the chaser is returning to its spawn point but it is stuck somewhere or
	-- the operation is taking too much time: in this case, the chaser is teleported
	-- home. During this transition, its body is unactive.
	local function checkIfTooLate(chaser, target)
		timer.performWithDelay( 4000, 
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

	-- Adds special behavior to an enemy if he isChaser
	local function loadChaser( chaser, currentGame )
		-- Only chasers need (and therefore will have) preCollision handling.
		chaser.preCollision = collisions.enemyPreCollision
		chaser:addEventListener( "preCollision", chaser)

		chaser.voidList = currentGame.map:getObjectLayer("cadutaVuoto").objects

		-- Used when the chaser jumps, to re-enable normal chasing.
		chaser.collision = function(self, event)
			if (event.other.isGround or event.other.tName) then
				chaser.isJumpingTo = false
				chaser.isJumpingVoid = false
			end
		end

		-- Main function: target can be the player or the chaser's spawn point.
		function chaser:chase( target )
			chaseTarget(currentGame, self, target)
		end

		-- Invoked from chase(target) periodically
		function chaser:checkVerticalProximity( target )
			checkVerticalProximity(currentGame, self, target)
		end

		-- Invoked from chase(target) at each frame
		function chaser:checkVoidProximity( void )
			checkVoidProximity(currentGame, self, void)
		end

		-- Invoked from chase(target) only if target is the chaser's spawn.
		function chaser:checkIfTooLate( target )
			checkIfTooLate(self, target)
		end
	end
-----------------------------------------------------------------------------------


-- Loads the enemies's images (and sprites) and initializes their attributes.
-- Visually instantiates the enemies in the current game's map.
-- @return enemyList (a table of Enemies)
function enemies.loadEnemies( currentGame ) 
	local currentMap = currentGame.map
	local enemyList = currentMap:getObjectLayer("enemySpawn"):getObjects("enemy")

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
		enemySprite.score= desc.score

		if( enemy.drop ) then
			enemySprite.drop = enemy.drop
		end

		enemySprite.isTargettable = true
		enemySprite.x, enemySprite.y =  enemy.x, enemy.y

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
		end
		---------------------------------------------------------------

		return enemySprite
	end

	for i, v in ipairs(enemyList) do
		enemyList[i].enemySprite = loadEnemyEntity(enemyList[i])
		---------------------------------------------------------------
		-- Temporary: assuming the species DOES NOT determine the 
		--	behavior, this is specified in the enemy object in the map,
		-- so appears in enemyList as an attribute.
		-- if (enemyList[i].isChaser) then
		-- 	loadChaser(enemyList[i].enemySprite, currentGame)	
		-- 	table.insert(chaserList, enemySprite)
		-- end
		---------------------------------------------------------------	
	end

	return enemyList, chaserList, walkerList
end

return enemies
