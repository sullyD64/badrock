-----------------------------------------------------------------------------------------
--
-- combat.lua
--
-----------------------------------------------------------------------------------------
local entity     = require ( "lib.entity"      )
local collisions = require ( "core.collisions" )

local combat = {
	map = {},
	player = {},
	animationIsPlaying,
	endPhase,
}

local settings = {
	meleeSensorOpts = {
		radius = 40,
		alpha = 0, --0.6
		color = {0, 0, 255},
	},

	meleeSheetData = {
		height = 80,
		width = 80,
		numFrames = 13,
		sheetContentWidth = 240,
		sheetContentHeight = 400 
	},
	
	meleeSequenceData = {
		{name = "beginning", start=1, count=7, time=300, loopCount=1},
		{name = "spinning",  start=8, count=3, time=300, loopCount=0},
		{name = "ending",    frames = {11, 12, 13, 1}, time=300, loopCount=1}
	},
}

function combat.setMap( currentMap )
	map = currentMap
end

function combat.setPlayer( currentPlayer )
	player = currentPlayer
end

-- Loads the player's default attack (melee)
local function loadDefaultAttack()
	-- Loads the Main sensor Entity ("hitbox")
		local atk = entity.newEntity{
			graphicType = "sensor",
			parentX = player.x,
			parentY = player.y,
			radius = settings.meleeSensorOpts.radius,
			color = settings.meleeSensorOpts.color,
			alpha = settings.meleeSensorOpts.alpha,
			sensorName = "A"
		}
	-- Loads the sprite and animation sequences
		local sprite = entity.newEntity{
			graphicType = "animated",
			parentX = player.x,
			parentY = player.y,
			filePath = visual.steveAttack,
			spriteOptions = settings.meleeSheetData,
			spriteSequence = settings.meleeSequenceData,
			notPhysical = true,
			eName = "steveAttack"
		}

	atk.gravityScale = 0

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


-- Handles the end of the attack phase
local function handleAttackEnd()
	-- Collision Handler Activation ---------------------------
	-- player.attack:removeEventListener("collision", player.attack)
	-----------------------------------------------------------
	player.attack.isVisible = false
	player.attack.isBodyActive = false
	player.attack.sprite:pause()
	player.attack.sprite.isVisible = false
	display.remove(player.attack)

	if (player.state ~= "Dead") then
		player.state = "Moving"
		-- Brings the player's sprite up again (if attack was melee)
		if (player.sprite.alpha == 0) then
			player.sprite.alpha = 1
		end	
	end
end

-- Performs a default, melee attack. Steve rolls and dashes forward while dealing
-- damage to everything he comes in touch with.
function combat.performMelee()
	-- The melee sprite substitutes the player's sprite.
	player.sprite.alpha = 0

	player.attack = loadDefaultAttack()
	player.attack.collision = collisions.attackCollision
	player.attack.duration = 1000

	-- Position linking is handled in game -> onUpdate
	player.attack.isVisible = true
	player.attack.isBodyActive = true
	player.attack.sprite.isVisible = true

	-- Collision Handler Activation -------------------------
	player.attack:addEventListener("collision", player.attack)
	---------------------------------------------------------

	-- Steve dashes forward
	player:applyLinearImpulse( player.direction * 8, 0, player.x, player.y )
	
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

function combat.cancel()
	combat.animationIsPlaying = false
	timer.cancel(combat.endPhase)
	player.attack.sprite:removeEventListener( "sprite", spinningPhase )
	handleAttackEnd()
end


return combat