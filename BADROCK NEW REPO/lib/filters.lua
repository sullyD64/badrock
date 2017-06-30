-----------------------------------------------------------------------------------------
--
-- collisionFilters.lua
--
-----------------------------------------------------------------------------------------

local filters = {
	steveHitboxFilter = { categoryBits = 1,   maskBits = 184 },
	sensorDFilter     = { categoryBits = 2,   maskBits = 64  },
	sensorAFilter     = { categoryBits = 4,   maskBits = 56  },
	envFilter         = { categoryBits = 8,   maskBits = 437 },
	dynamicEnvFilter  = { categoryBits = 16,  maskBits = 285 },
	enemyHitboxFilter = { categoryBits = 32,  maskBits = 13  },
	sensorNFilter     = { categoryBits = 64,  maskBits = 2   },
	itemFilterOff     = { categoryBits = 128, maskBits = 8   },
	itemFilterOn      = { categoryBits = 128, maskBits = 9   },
	parcticleFilter   = { categoryBits = 256, maskBits = 280 },
}

return filters