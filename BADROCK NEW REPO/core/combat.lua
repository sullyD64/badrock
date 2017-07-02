-----------------------------------------------------------------------------------------
--
-- combat.lua
--
-- This class handles all the logic regarding the behavior of the Action Button, as this
-- varies when certain items are picked. In particular, when a "powerUp" is picked, it
-- will modify the player's "attack" attribute: a powerup may be a weapon or a generic 
-- item that can be CONSUMED to produce an action (differently from "bonuses", whose 
-- effects are immediate and don't modify the action button's behavior).
--
-- Some powerUps may be used more than once before they are "destroyed": this means they
-- have ammo, and those ammos are part of the player "attacks" attribute, which is another
-- table different from the player's "attack".
-- By default, the Action Button causes the player to perform a melee attack.
-----------------------------------------------------------------------------------------
local entity     = require ( "lib.entity"      )
local collisions = require ( "core.collisions" )
local controller = require ( "core.controller" )

local combat = {
	map = {},
	player = {},
	animationIsPlaying,
	endPhase,
	ammo,
}

local settings = {
	melee = {
		sensorOpts = {
			radius = 40,
			alpha = 0, --0.6
			color = {0, 0, 255},
		},
		sheetData = {
			height = 80,
			width = 80,
			numFrames = 13,
			sheetContentWidth = 240,
			sheetContentHeight = 400 
		},
		sequenceData = {
			{name = "beginning", start=1, count=7, time=300, loopCount=1},
			{name = "spinning",  start=8, count=3, time=300, loopCount=0},
			{name = "ending",    frames = {11, 12, 13, 1}, time=300, loopCount=1}
		},
	},

	gun = {
		ammo = 5,
		staticOptions = { 			-- provvisorie
			width = 20,
			height = 20,
			filePath = visual.steveGun,
			notPhysical = true,
			eName = "stevePowerUp",
		},
		sheetData = {
			-- FABIOOOO
		},
		sequenceData = {
			-- FABIOOOO
		}
	},

	bullet = {
		staticOptions = { 			-- provvisorie
			width = 20,
			height = 20,
			filePath = visual.bullet,
			notPhysical = true,
			eName = "steveAttack",
		},
		sensorOpts = {
			radius = 10,
			alpha = 0, -- 0.6
			color = {255, 0, 255},
		},
		sheetData = {
			-- FABIOOOO
		},
		sequenceData = {
			-- FABIOOOO
		}
	}

}

-- Memorizing the map is necessary for adding Entities produced by the attacks.
function combat.setMap( currentMap )
	map = currentMap
end

-- Memorizing the player is necessary for modifying its combat variables.
function combat.setPlayer( currentPlayer )
	player = currentPlayer
end

-- Handles the end of the attack phase
local function handleAttackEnd()
	-- The default attack and otherd are destroyed at the end of the attack phase, 
	-- as they don't depend on ammo but on time.
	if (player.attack.type == "default") then 
		player.attack.isVisible = false
		player.attack.isBodyActive = false
		player.attack.sprite:pause()
		player.attack.sprite.isVisible = false
		display.remove(player.attack)
		player.attack = nil
		combat.defaultLoaded = false
	end

	-- If powerUp has run out of ammo, it is destroyed and default attack is
	-- loaded again.
	if (player.hasPowerUp and combat.ammo == 0) then
		player:losePowerUp()
		controller.updateAmmo("destroy")
		player.attack = combat.loadDefaultAttack()
		combat.defaultLoaded = true
	end

	if (player.state ~= "Dead") then
		player.state = "Moving"
		-- Brings the player's sprite up again (if attack was melee)
		if (player.sprite.alpha == 0) then
			player.sprite.alpha = 1
		end
	end
end

-- Prematurely cancels the attack phase and invokes handleAttackEnd.
-- This happens when the player dies while in the attack phase.
function combat.cancel()
	combat.animationIsPlaying = false
	timer.cancel(combat.endPhase)
	player.attack.sprite:removeEventListener( "sprite", spinningPhase )
	handleAttackEnd()
end

-- DEFAULT ATTACK ------------------------------------------------------------------
	-- Loads the player's default attack (melee)
	function combat.loadDefaultAttack()
		-- Loads the Main sensor Entity ("hitbox")
			local atk = entity.newEntity{
				graphicType = "sensor",
				parentX = player.x,
				parentY = player.y,
				radius = settings.melee.sensorOpts.radius,
				color = settings.melee.sensorOpts.color,
				alpha = settings.melee.sensorOpts.alpha,
				physicsParams = { filter = filters.sensorAFilter },
				sensorName = "A"
			}
		-- Loads the sprite and animation sequences
			local sprite = entity.newEntity{
				graphicType = "animated",
				filePath = visual.steveAttack,
				spriteOptions = settings.melee.sheetData,
				spriteSequence = settings.melee.sequenceData,
				notPhysical = true,
				eName = "steveAttack"
			}

		atk.type = "default"
		atk.sprite = sprite

		-- The attack is initially inactive
		atk.isVisible = false
		atk.isBodyActive = false
		atk.sprite.isVisible = false

		-- Inserts the attack hitbox and sprite on the game's current map
		atk:addOnMap( map )
		atk.sprite:addOnMap( map )

		return atk
	end

	-- Performs a default, melee attack. The player rolls and dashes forward while dealing
	-- damage to everything he comes in touch with.
	function combat.performMelee()
		-- The melee sprite substitutes the player's sprite.
		player.sprite.alpha = 0

		if (not combat.defaultLoaded) then
			player.attack = combat.loadDefaultAttack()
		end
		player.attack.collision = collisions.attackCollision
		player.attack.duration = 1000

		-- Collision Handler Activation -------------------------
		player.attack:addEventListener("collision", player.attack)
		---------------------------------------------------------

		-- Position linking is handled in game -> onUpdate
		player.attack.isVisible = true
		player.attack.isBodyActive = true
		player.attack.sprite.isVisible = true

		-- The player dashes forward
		player:applyLinearImpulse( player.direction * 8, -5, player.x, player.y )
		
		-- Attack Sprite sequence ---------------------------------------------------
			combat.animationIsPlaying = true
			player.attack.sprite:setSequence("beginning")
			player.attack.sprite:play()

			spinningPhase = function(event)
				local sprite = event.target
				if(event.phase == "ended") then
					sprite:setSequence("spinning")
					sprite:play()
				end
			end
			player.attack.sprite:addEventListener("sprite", spinningPhase)

			combat.endPhase = timer.performWithDelay(player.attack.duration - 300, 
				function()
					player.attack.sprite:removeEventListener( "sprite", spinningPhase )
					player.attack.sprite:setSequence("ending")
					player.attack.sprite:play()
				end
			)
		-----------------------------------------------------------------------------

		if (combat.animationIsPlaying) then
			timer.performWithDelay(player.attack.duration, handleAttackEnd)
		end
	end
------------------------------------------------------------------------------------

-- POWERUPS ------------------------------------------------------------------------
	
	-- GUN --------------------------------------------------------------------------
		-- The gun is a simple semi-automatic gun which can shoot a short number
		-- of bullets. Each bullet travels horizontally and can collide with enemies
		-- as well as the enviroment.

		-- Loads the bullets. They are stored in player.attacks.
		-- The bullets are all created at the same time the gun is picked, but they
		-- become visible only when they are shot.
		local function loadBullets()
			local bullets = {}
			local progId = 0

			-- Loads one bullet.
			-- The bullet is composed of two entities: the hitbox and the sprite.
			local loadBullet = function()
				-- Loads the bullet sensor Entity ("hitbox") 
					local bullet = entity.newEntity {
						graphicType = "sensor",
						parentX = player.x,
						parentY = player.y,
						radius = settings.bullet.sensorOpts.radius,
						color = settings.bullet.sensorOpts.color,
						alpha = settings.bullet.sensorOpts.alpha,
						physicsParams = { filter = filters.sensorAFilter },
						sensorName = "A"
					}

				-- Loads the sprite and animation sequences
					local sprite = entity.newEntity(settings.bullet.staticOptions)

				-- Makes the bullet unaffected by gravity
				transition.to(bullet, {time = 0, 
					onComplete = function()
						bullet.gravityScale = 0
					end
				})

				bullet.sprite = sprite
				bullet.type = "bullet"
				bullet.hasBeenShot = false

				-- The bullet is initially inactive and invisible
				bullet.isVisible = false
				bullet.isBodyActive = false
				bullet.sprite.isVisible = false

				-- Inserts the bullet's hitbox and sprite on the game's current map
				bullet:addOnMap( map )
				bullet.sprite:addOnMap( map )

				-- Fires the bullet (which is now on unlinked from the player's position)
				function bullet:shoot()
					-- The bullet becomes active and visible
					self.isVisible = true
					self.isBodyActive = true
					self.sprite.isVisible = true

					-- Shoots the bullet horizontally
						self.hasBeenShot = true
						self:applyLinearImpulse( player.direction * 0.05, 0, 
							self.x, self.y )

					-- The bullet will collide with environment and enemies.
					self.collision = collisions.attackCollision

					-- Collision Handler Activation ------------
					self:addEventListener("collision", self)
					--------------------------------------------
				end

				-- The bullet is destroyed when it collides with enemies or the environment.
				function bullet:destroy()
					display.remove(bullet.sprite)
					display.remove(bullet)
					-- The relative entry in the bullet table is freed
					bullets[bullet.id] = nil
				end

				bullet.id = progId
				return bullet
			end

			for i=1, combat.ammo do
				progId = progId + 1
				bullets[i] = loadBullet()
			end

			return bullets
		end

		-- Loads the gun Entity, which is nothing but an animated sprite
		-- near the player which visually represents the equipped powerup.
		local function loadGun()
			-- Loads the gun sprite and animation sequences
			local gun = entity.newEntity(settings.gun.staticOptions)
			gun:addOnMap( map )

			-- Ammo and Bullets------------
			combat.ammo = settings.gun.ammo
			gun.attacks = loadBullets(gun)
			-------------------------------
			return gun
		end

		-- Shoots one bullet.
		function combat.useGun()
			player.powerUp.attacks[combat.ammo]:shoot()

			-- Attack duration is needed here for re-enabling the action button,
			-- managing the gun animation and triggering handleAttackEnd.
			player.attack = {}
			player.attack.type = "bullet"
			player.attack.duration = 100

			timer.performWithDelay(player.attack.duration, handleAttackEnd)
		end
	---------------------------------------------------------------------------------

	-- Loads a powerup which will appear as equipped near the player
	-- and will modify the ui's action button.
	function combat.loadPowerUp( name )
		local powerUp = {}

		-- Updates the UI to visually represent the new action
		controller.updateActionButton( name )

		-- Case switch depending on the item's name
		if ( name == "gun" ) then
			powerUp = loadGun()
			controller.updateAmmo("initialize", combat.ammo)
		else
			error("Invalid powerup name")
		end

		return powerUp
	end

	-- Uses the powerup.
	-- If the powerup uses ammo, decrements the ammo by 1 unit and
	-- updates the UI.
	function combat.usePowerUp( name )
		-- Case switch depending on the item's name
		if (name == "gun") then
			combat.useGun()
			combat.ammo = combat.ammo - 1
			controller.updateAmmo("update", combat.ammo)
		end
	end

	-- Unbinds the powerup from the player.
	function combat.losePowerUp()
		local powerUp = player.powerUp
		player.hasPowerUp = false

		-- Animation: the powerup is knocked away from the player and off the map.
			physics.addBody( powerUp, {isSensor = true, density = 2.0})
			powerUp.eName = "lostPowerUp"

			-- if (powerUp.sequence) then powerUp:pause() end
			powerUp:applyLinearImpulse( player.direction * 0.5, -10, powerUp.x, powerUp.y )
			powerUp:applyTorque( -player.direction * 50 )
			transition.to(powerUp, {time = 2000,  -- removes it when he's off the map 
				onComplete = function()
					display.remove(powerUp)
				end
			})
		----------------------------------------------------------------------------

		-- Destroys all the remaining bullets which haven't been shot.
		for k, bullet in pairs(player.attacks) do
			if (bullet.hasBeenShot == false) then
				bullet:destroy()
			end
		end
	end
------------------------------------------------------------------------------------

return combat