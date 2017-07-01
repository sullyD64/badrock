-----------------------------------------------------------------------------------------
--
-- combat.lua
--
-----------------------------------------------------------------------------------------
local entity     = require ( "lib.entity"      )
local collisions = require ( "core.collisions" )
local controller = require ( "core.controller" )

local combat = {
	map = {},
	player = {},
	animationIsPlaying,
	endPhase,
}

local settings = {
	melee = {
		sensorOpts = {
			radius = 40,
			alpha = 0.6, --0.6
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
		-- provvisorie
		staticOptions = {
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
		-- provvisorie
		staticOptions = {
			width = 20,
			height = 20,
			filePath = visual.bullet,
			notPhysical = true,
			eName = "steveAttack",
		},
		sensorOpts = {
			radius = 10,
			alpha = 0.6,
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

function combat.setMap( currentMap )
	map = currentMap
end

function combat.setPlayer( currentPlayer )
	player = currentPlayer
end

-- Handles the end of the attack phase
local function handleAttackEnd()
	if (player.attack.type == "default") then 
		player.attack.isVisible = false
		player.attack.isBodyActive = false
		player.attack.sprite:pause()
		player.attack.sprite.isVisible = false
		display.remove(player.attack)
		player.attack = nil
	end

	if (player.state ~= "Dead") then
		player.state = "Moving"
		-- Brings the player's sprite up again (if attack was melee)
		if (player.sprite.alpha == 0) then
			player.sprite.alpha = 1
		end
	end
end

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

		-- The attack is initially inactive
		atk.isVisible = false
		atk.isBodyActive = false

		atk.sprite = sprite
		atk.sprite.isVisible = false
		atk.sprite.isBodyActive = false

		-- Inserts the attack hitbox and sprite on the game's current map
		atk:addOnMap( map )
		atk.sprite:addOnMap( map )

		return atk
	end

	-- Performs a default, melee attack. Steve rolls and dashes forward while dealing
	-- damage to everything he comes in touch with.
	function combat.performMelee()
		-- The melee sprite substitutes the player's sprite.
		player.sprite.alpha = 0

		if (not player.attack) then
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

		-- Steve dashes forward
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
	-- Loads a gun which can shoot bullets to damage enemies.
	-- The usage is limited by the ammo.
	local function loadGun()
		-- Loads the gun sprite and animation sequences
		local gun = entity.newEntity(settings.gun.staticOptions)

		-- Inserts the gun's sprite on the game's current map
		gun:addOnMap( map )

		player.attack = nil
		return gun
	end

	local function loadBullet()
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

		bullet.type = "bullet"
		-- Needed for making the bullet unaffected by gravity
		transition.to(bullet, {time = 0, 
			onComplete = function()
				bullet.gravityScale = 0
			end
		})
		bullet.sprite = sprite
		bullet.sprite.xScale = player.direction

		-- Inserts the attack hitbox and sprite on the game's current map
		bullet:addOnMap( map )
		bullet.sprite:addOnMap( map )

		-- The table attack is used to manage position linking of more entities.
		if (not player.attack) then player.attacks = {} end
		table.insert( player.attacks, bullet )

		function bullet:destroy()
			display.remove(bullet.sprite)
			display.remove(bullet)
			bullet = nil
		end

		return bullet
	end

	-- Loads a powerup which will appear as equipped near the player
	-- and will modify the ui's action button
	function combat.loadPowerUp( itemName )
		local powerUp = {}

		-- Updates the UI to visually represent the new action
		controller.updateActionButton( itemName )

		if ( itemName == "gun" ) then
			powerUp = loadGun()
		else
			error("Invalid powerup name")
		end

		return powerUp
	end

	-- Shoots one bullet. The bullet will travel horizontally and stop when
	-- it collides with an enemy or with the environment.
	function combat.useGun()
		player.attack = loadBullet()

		transition.to(player.attack, {time = 0, 
			onComplete = function()
				player.attack:applyLinearImpulse( player.direction * 0.05, 0, player.attack.x, player.attack.y )
			end
		})

		player.attack.collision = collisions.attackCollision
		player.attack.duration = 100

		-- Collision Handler Activation -------------------------
		player.attack:addEventListener("collision", player.attack)
		---------------------------------------------------------

		timer.performWithDelay(player.attack.duration, handleAttackEnd)
	end

	-- Uses the powerup. If the powerup has limited usages,
	-- handles the ammo decreasement [TO-DO]
	function combat.usePowerUp( itemName )
		if (itemName == "gun") then
			combat.useGun()
		end
	end
------------------------------------------------------------------------------------

return combat