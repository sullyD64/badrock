-----------------------------------------------------------------------------------------
--
-- util.lua
--
-----------------------------------------------------------------------------------------

local util = {}

--Setters for Entity speed and jump height (generic)
local function util.setEntitySpeed(entity, value)
	entity.speed = value
end

local function util.setEntityJumpHeight(entity, value)
	entity.jumpHeight = value
end

return util