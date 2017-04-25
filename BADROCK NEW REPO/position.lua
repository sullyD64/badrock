-----------------------------------------------------------------------------------------
--
-- position.lua
--
-----------------------------------------------------------------------------------------

position = {}
position.__index = position

function position.new(x, y)
	return setmetatable( {x = x or 0, y = y or 0}, position )
end

function position:unpack()
  return self.x, self.y
end

function position:clone()
  return position.new(self.x, self.y)
end

setmetatable(position, {
	__call = function(_, ...) 
		return position.new(...) 
	end })