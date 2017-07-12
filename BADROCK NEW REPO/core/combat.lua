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
local myData = require ("myData")

local combat = {
	map = {},
	player = {},
	ammo,
	timers = {}, -- stores all the timers for allowing game to control them
	stopAnimation = false,
	performingAttack = false,
}

local settings = {
	melee = {
		sensor1Opts = {  -- Outer sensor
			radius = 80,
			alpha = 0, --0.6
			color = {0, 0, 255},
		},
		sensor2Opts = {  -- Inner sensor
			radius = 40,
			alpha = 0, --0.8
			color = {255, 0, 0},
		},
		options = {
			spriteOptions = {
				height = 160,
				width = 160,
				numFrames = 13,
				sheetContentWidth = 480,
				sheetContentHeight = 800 
			},
			spriteSequence = {
				{name = "beginning", start=1, count=7, time=300, loopCount=1},
				{name = "spinning",  start=8, count=3, time=300, loopCount=0},
				{name = "ending",    frames = {11, 12, 13, 1}, time=300, loopCount=1}
			},
		}
	},

	gun = {
		ammo = 5,
		options = {
			graphicType = "animated",
			filePath = visual.equipped_gun,
			notPhysical = true,
			eName = "stevePowerUp",
			spriteOptions = {
				height = 40,
				width = 60,
				numFrames = 4,
				sheetContentWidth = 240,
				sheetContentHeight = 40,
			},
			spriteSequence = {
				{name = "shooting", frames = {1,2,3,4,1}, time=300, loopCount=1},
			},
		},

		
	},

	bullet = {
		staticOptions = { 			-- provvisorie
			width = 40,
			height = 40,
			filePath = visual.bullet,
			notPhysical = true,
			eName = "steveAttack",
		},
		sensorOpts = {
			radius = 20,
			alpha = 0, -- 0.6
			color = {255, 0, 255},
		},
		spriteOptions = {
			-- FABIOOOO
		},
		spriteSequence = {
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
	-- The default attack and others are destroyed at the end of the attack phase, 
	-- as they don't depend on ammo but on time.
	if (player.attack and player.attack.type == "default") then 
		player.attack.isVisible = false
		player.attack.isBodyActive = false
		player.attack.inner.isVisible = false
		player.attack.inner.isBodyActive = false
		player.attack.sprite:pause()
		player.attack.sprite.isVisible = false
		display.remove(player.attack.sprite)
		display.remove(player.attack)
		player.attack = nil
		combat.defaultLoaded = false
	end

	-- If powerUp has run out of ammo, it is destroyed and default attack is
	-- loaded again.
	if (player.hasPowerUp and combat.ammo == 0) then
		-- audio ----------------------------------------
		audio.stop(7)
		sfx.playSound( sfx.noAmmoSound, { channel = 7 } )
		-------------------------------------------------
		player:losePowerUp()
		controller.updateAmmo("destroy")
		player.attack = combat.loadDefaultAttack()
		combat.defaultLoaded = true
	end

	if (player.state ~= "Dead") then
		player.state = "Moving"
		-- Brings the player's sprite up again (if attack was melee)
		if (player.sprite.alpha == 0 and not combat.stopAnimation) then
			player.sprite.alpha = 1
		end
	end
	combat.performingAttack = false
end

-- Prematurely cancels the attack phase.
-- This happens when the player dies while in the attack phase.
function combat.cancel()
	combat.stopAnimation = true
	combat.performingAttack = false

	player.attack.isVisible = false
	player.attack.isBodyActive = false
	if (player.attack.inner) then
		player.attack.inner.isVisible = false
		player.attack.inner.isBodyActive = false
	end
	if (player.attack.sprite.sequence) then
		player.attack.sprite:pause()
	end
	player.attack.sprite.isVisible = false

	if (player.isImmune) then
		timer.cancel(combat.timers.immunityTimer)
		-- audio ----------------------------------------
		sfx.toggleAlternativeBgm("off")
		-------------------------------------------------
		player.isImmune = false
		player.immunityDuration = nil
	end

	display.remove(player.attack)
end

-- BONUSES  ------------------------------------------------------------------------
	
	-- IMMUNITY ---------------------------------------------------------------------
		-- Immunity causes the player to immediately drop whatever powerup he is using
		-- and perform a melee attack which is much longer than usual.
		-- Enemies hit while in this state will be instantly killed regarding how many 
		-- lives they have.
		local function useImmunity()
			player.isImmune = true
			player.immunityDuration = 7000
			-- audio ----------------------------------------
			sfx.toggleAlternativeBgm("on")
			-------------------------------------------------
			transition.to(player, {time = 0, 
					onComplete = function()
						if (player.hasPowerUp) then
							player:losePowerUp()
							controller.updateAmmo("destroy")
						end
						-- Simulates the press of the action button to begin the rampage.
						controller.pressActionButton()
					end
				})

			combat.timers.immunityTimer = timer.performWithDelay(player.immunityDuration,
				function()
					-- audio ----------------------------------------
					sfx.toggleAlternativeBgm("off")
					-------------------------------------------------
				 	player.isImmune = false
				 	player.immunityDuration = nil
				end
			)
		end

		-- Applies a "godly" effect to the player's attack sprite.
		local function applyImmunityEffect()
			player.attack.sprite.fill.effect = "filter.invert"
			-- player.attack.sprite.fill.effect = "filter.sobel"
			-- player.attack.sprite.fill.effect.intensity = 0.6
		end
	---------------------------------------------------------------------------------

	-- Uses (consumes) the bonus
	function combat.useBonus( name )
		-- Case switch depending on the item's name
		if (name == "immunity") then
			useImmunity()
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
						self:applyLinearImpulse( player.direction * 0.3, 0, 
							self.x, self.y )

					-- The bullet will collide with environment and enemies.
					self.collision = collisions.attackCollision

					-- Collision Handler Activation ------------
					self:addEventListener("collision", self)
					--------------------------------------------
				end

				-- The bullet is destroyed when it collides with enemies or the environment.
				function bullet:destroy()
					-- audio ----------------------------------------
					audio.stop(6)
					sfx.playSound( sfx.boom1Sound, { channel = 6 } )
					-------------------------------------------------
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
			-- audio ----------------------------------------
			audio.stop(4)
			sfx.playSound( sfx.coinSound, { channel = 4 } )
			-------------------------------------------------

			-- Loads the gun sprite and animation sequences
			local gun = entity.newEntity(settings.gun.options)
			gun:addOnMap( map )

			-- Ammo and Bullets------------
			combat.ammo = settings.gun.ammo
			gun.attacks = loadBullets(gun)
			-------------------------------
			return gun
		end

		-- Shoots one bullet.
		local function useGun()
			combat.performingAttack = true
			-- audio ----------------------------------------
			audio.stop(4)
			sfx.playSound( sfx.gunSound, { channel = 4 } )
			-------------------------------------------------
			player.powerUp.attacks[combat.ammo]:shoot()

			player.powerUp:setSequence("shooting")
			player.powerUp:play()
			transition.to(player.powerUp, {time = 100, rotation = - player.direction * 30,
				transition = easing.continuousLoop})

			-- Attack duration is needed here for re-enabling the action button,
			-- managing the gun animation and triggering handleAttackEnd.
		
			player.attack=player.powerUp.attacks[combat.ammo]
			player.attack.type = "bullet"
			player.attackDuration = 100

			combat.timers.endTimer = timer.performWithDelay(player.attackDuration, handleAttackEnd)
		end
	---------------------------------------------------------------------------------

	-- Loads a powerup which will appear as equipped near the player
	-- and will modify the ui's action button.
	function combat.loadPowerUp( name )
		combat.defaultLoaded = false
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
			useGun()
			combat.ammo = combat.ammo - 1
			controller.updateAmmo("update", combat.ammo)
		end
	end

	-- Unbinds the powerup from the player.
	function combat.losePowerUp()
		local powerUp = player.powerUp
		player.hasPowerUp = false

		-- Animation: the powerup is knocked away from the player and off the map.
			physics.addBody( powerUp, {isSensor = true, density = 0.4})
			powerUp.eName = "lostPowerUp"

			-- if (powerUp.sequence) then powerUp:pause() end
			powerUp:applyLinearImpulse( player.direction * 3, -25, powerUp.x, powerUp.y )
			powerUp:applyTorque( -player.direction * 250 )
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

-- DEFAULT ATTACK ------------------------------------------------------------------
	-- Loads the player's default attack (melee)
	function combat.loadDefaultAttack()
		-- Loads the Main sensor Entity ("hitbox")
			local atk = entity.newEntity{
				graphicType = "sensor",
				parentX = player.x,
				parentY = player.y,
				radius = settings.melee.sensor1Opts.radius,
				color = settings.melee.sensor1Opts.color,
				alpha = settings.melee.sensor1Opts.alpha,
				physicsParams = { filter = filters.sensorAFilter },
				sensorName = "A"
			}
		-- Loads an auxiliary sensor Entity useful when the attack is performed at close range.
			local innerCircle = entity.newEntity{
				graphicType = "sensor",
				parentX = player.x,
				parentY = player.y,
				radius = settings.melee.sensor2Opts.radius,
				color = settings.melee.sensor2Opts.color,
				alpha = settings.melee.sensor2Opts.alpha,
				physicsParams = { filter = filters.sensorAFilter },
				sensorName = "A"
			}
		-- Loads the sprite and animation sequences
			local sprite = entity.newEntity{
				graphicType = "animated",
				-- Richiama myData che ha in memoria le sprite giuste per ogni skin e il numero della skin selezionata
				filePath = myData.settings.skins[myData.settings.selectedSkin].attackSheet,--visual.steveDarkAttack, --visual.steveDefaultAttack / visual.steveDarkAttack
				spriteOptions = settings.melee.options.spriteOptions,
				spriteSequence = settings.melee.options.spriteSequence,
				notPhysical = true,
				eName = "steveAttack"
			}

		atk.type = "default"
		atk.sprite = sprite

		atk.inner = innerCircle
		atk.inner.type = "default"

		-- The attack is initially inactive
		atk.isVisible = false
		atk.isBodyActive = false
		atk.sprite.isVisible = false
		atk.inner.isVisible = false
		atk.inner.isBodyActive = false

		-- Inserts the attack hitbox and sprite on the game's current map
		atk:addOnMap( map )
		atk.sprite:addOnMap( map )
		atk.inner:addOnMap( map )

		return atk
	end

	-- Performs a default, melee attack. The player rolls and dashes forward while dealing
	-- damage to everything he comes in touch with.
	function combat.performMelee()
		combat.performingAttack = true
		-- audio ----------------------------------------
		audio.stop(4)
		sfx.playSound( sfx.attackSound, { channel = 4 } )
		-------------------------------------------------

		-- The melee sprite substitutes the player's sprite.
		player.sprite.alpha = 0

		if (not combat.defaultLoaded) then
			player.attack = combat.loadDefaultAttack()
		end
		player.attack.collision = collisions.attackCollision
		player.attack.inner.collision = collisions.attackCollision

		-- Collision Handler Activation -------------------------
		player.attack:addEventListener("collision", player.attack)
		player.attack.inner:addEventListener( "collision", player.attack.inner )
		---------------------------------------------------------

		-- Position linking is handled in game -> onUpdate
		player.attack.isVisible = true
		player.attack.isBodyActive = true
		player.attack.sprite.isVisible = true
		player.attack.inner.isVisible = true
		player.attack.inner.isBodyActive = true

		if (player.isImmune) then
			applyImmunityEffect()
			player.attackDuration = player.immunityDuration
		else
			player.attackDuration = 1000
		end

		-- The player dashes forward
		player:applyLinearImpulse( player.direction * 35, -20, player.x, player.y )
		
		-- Attack Sprite sequence ---------------------------------------------------
			combat.stopAnimation = false
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

			combat.timers.endPhaseTimer = timer.performWithDelay(player.attackDuration - 300, 
				function()
					player.attack.sprite:removeEventListener( "sprite", spinningPhase )
					player.attack.sprite:setSequence("ending")
					player.attack.sprite:play()
				end
			)
		-----------------------------------------------------------------------------

		if (combat.stopAnimation) then
			player.attack.sprite:removeEventListener( "sprite", spinningPhase )
			timer.cancel(combat.timers.endPhaseTimer)
		else
			combat.timers.endTimer = timer.performWithDelay(player.attackDuration, handleAttackEnd)
		end
	end
------------------------------------------------------------------------------------

return combat