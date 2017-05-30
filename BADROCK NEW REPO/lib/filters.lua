-----------------------------------------------------------------------------------------
--
-- collisionFilters.lua
--
-----------------------------------------------------------------------------------------

local filters = {
	steveHitboxFilter = { categoryBits = 1,   maskBits = 184 },										
	sensorDFilter     = { categoryBits = 2,   maskBits = 64  },										
	sensorAFilter     = { categoryBits = 4,   maskBits = 56  },										
	envFilter         = { categoryBits = 8,   maskBits = 421 },							
	dynamicEnvFilter  = { categoryBits = 16,  maskBits = 293 },									
	enemyHitboxFilter = { categoryBits = 32,  maskBits = 61  },								
	sensorNFilter     = { categoryBits = 64,  maskBits = 2   },									
	itemFilter        = { categoryBits = 128, maskBits = 9   },								
	parcticleFilter   = { categoryBits = 256, maskBits = 280 },	
}

return filters