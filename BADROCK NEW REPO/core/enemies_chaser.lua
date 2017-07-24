local collisions = require ( "core.collisions" )

local behavior = {}

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
------------------------------------------------------------------------------------

-- MAIN -------------------------------------------------------------------------
	function behavior.loadChaserBehavior( enemyObj, currentGame )
		local chaser = enemyObj.entity
		chaser.voidList = currentGame.map:getObjectLayer("cadutaVuoto").objects
		chaser.home = {
			x = enemyObj.x,
			y = enemyObj.y
		}

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

		-- Invoked from chase(target) periodically
		function chaser:checkVerticalProximity( target )
			checkVerticalProximity(currentGame, self, target)
		end

		-- Invoked from chase(target) at each frame
		function chaser:checkVoidProximity( void )
			checkVoidProximity(currentGame, self, void)
		end

		-- Invoked from chase(target) ONCE when the chaser isIdleAwayFromHome
		function chaser:checkIfIdleTimeExceeded()
			checkIfIdleTimeExceeded(self)
		end

		-- Invoked from chase(target) only if target is the chaser's spawn.
		function chaser:checkIfTooLate( target )
			checkIfTooLate(self, target)
		end
	end
	---------------------------------------------------------------------------------

return behavior