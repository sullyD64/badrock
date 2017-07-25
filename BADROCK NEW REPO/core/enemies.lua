-----------------------------------------------------------------------------------------
--
-- enemies.lua
--
-- An enemy is an hostile Entity capable of moving on the map and performing other actions 
-- which can kill Steve in several ways. 
-- There are several "species" of enemy, which differ in aspect, size and other aspects.
-- Enemies will also behave differently depending on other parameters.
-- 1) If no additional property is specified, an Enemy will stay still and will only 
-- 	hurt the Player passively if this collides with him;
-- The property "behavior" specifies additional behavior.
-- 2) If "behavior" is "chaser", the Enemy will be a Chaser.
-- 	A Chaser will stay still and have an "aggro" zone surrounding him; if the Player
--    gets inside this aggro zone, the Chaser will start "chasing" the Player; if the Player
-- 	dies (by any cause), the Chaser will return to the center of his aggro zone and wait 
-- 	for the Player to come closer again;
-- 	There is also a "safe zone" located around the Player's spawn point, which will make
-- 	the Chaser stop chasing the Player.
-- 3) If "behavior" is "walker", the Enemy will be a Walker.
-- 	A Walker moves on the map following a pre-established route.
-- 
-- Every Enemy species and type is guessed from the properties of the objects declared in
-- the game's current map, all of which indicate the spawn point for that selected Enemy.
----------------------------------------------------------------------------------------
local entity     = require ( "lib.entity"          )
local walkers    = require ( "core.enemies_walker" )
local chasers    = require ( "core.enemies_chaser" )

local enemies = {
	descriptions = {
		-- 1 Paper
		{	
			species = "paper",
			behavior = "chaser",
			lives = 1,
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
			behavior = "walker",
			lives = 1,
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
				bodyType = "static",
				physicsParams = { bounce = 0, friction = 1.0, density = 0.5, gravityScale = 0, shape ={-150,-80,  150,-80,  80,80, -80,80} },
				eName = "enemy",
			},
		},
	}
}

-- Invokes the methods above to give additional behavior to enemies.
local function loadBehavior( enemyObj, behavior, currentGame )
	if (behavior == "chaser") then
		chasers.loadChaserBehavior( enemyObj, currentGame )
	elseif (behavior == "walker") then
		walkers.loadWalkerBehavior( enemyObj, currentGame )
	end
end

local function activateBehavior( enemyObj )
	if (enemyObj.behavior == "chaser") then
		--
	elseif (enemyObj.behavior == "walker") then
		walkers.activateWalkerBehavior( enemyObj )
	end
end

-- Loads the enemies's images (and sprites) and initializes their attributes.
-- Visually instantiates the enemies in the current game's map.
-- @return enemyList, walkerList, chaserList
function enemies.loadEnemies( currentGame ) 
	local currentMap = currentGame.map
	local enemyList = currentGame.enemiesGen

	local chaserList = {}
	local walkerList = {}
	
	-- Loads the main Entity.
	local loadEntity = function( enemyObj )
		local desc, eSprite
		for k, v in pairs(enemies.descriptions) do
			if (v.species == enemyObj.type) then
				desc = v
				break
			end
		end

		if (desc == nil ) then
			error(enemyObj.type .. ": Enemy species not found in the EnemyDescriptions")
		end
		
		desc.options.physicsParams.filter = filters.enemyHitboxFilter
		desc.options.isFixedRotation = true

		eSprite = entity.newEntity(desc.options)
		eSprite.species = desc.species
		eSprite.lives = desc.lives or 1
		eSprite.score = desc.score
		if(enemyObj.drop) then eSprite.drop = enemyObj.drop	end
		eSprite.isTargettable = true
		eSprite.x, eSprite.y = enemyObj.x, enemyObj.y
		eSprite:addOnMap( currentMap )

		if (desc.behavior) then
			enemyObj.behavior = desc.behavior
		end

		function eSprite:activate()
			if (desc.options.graphicType == "animated") then
				eSprite:setSequence("idle")
				eSprite:play()

				if (desc.behavior) then
					activateBehavior(enemyObj)
				end
			end
		end

		-- Animation: Knocks the enemy AWAY given a x position
		function eSprite:onHitAnimation(x)
			if (self.x > x) then self:applyLinearImpulse(40, -200, self.x, self.y)
			elseif (self.x < x) then self:applyLinearImpulse(-40, -200, self.x, self.y)
			end
		end

		-- Animation: knocks the enemy AWAY and off the map
		function eSprite:onDeathAnimation()
			if (self.bodyType ~= "dynamic") then 
				transition.to (self, {time = 0, 
					onComplete = function()
						self.bodyType = "dynamic" 
						self.gravityScale = 1
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

		-- Called after onDeathAnimation, destroys the visual attributes of an enemy
		function eSprite:destroy()
			-- if Enemy is a Chaser, remove it from the list ----
				local csr = currentGame.loadedChasers[self.oName]
				if (csr) then
					csr = nil
				end
			-- if Enemy is a Walker, remove it from the list ----
				local wkr = currentGame.loadedWalkers[self.oName]
				if (wkr) then
					if (self.sensors) then
						self.sensors:destroy()
					end
					wkr = nil
				end
			currentGame.loadedEnemies[self.oName].entity = nil
			currentGame.loadedEnemies[self.oName].active = false	
		end

		return eSprite
	end

	-- Iterates the objects in enemyList and loads the visual attributes of all objects
	for k, obj in pairs(enemyList) do
		if (not obj.entity) then
			obj.entity = loadEntity(obj)
			obj.entity.oName = obj.name

			-- Loads the additional behavior for the enemies that have it specified.
			-- Additional attributes are added to the enemyObj.entity table.	
			if (obj.behavior) then
				loadBehavior(obj, obj.behavior, currentGame)
			end
		end
	end

	return enemyList, chaserList, walkerList
end

return enemies
