local BaseEntity = classes.baseEntity
local Pickable = class("Pickable", BaseEntity)

Pickable.nonBlocking = true
Pickable.floor = true

function Pickable:initialize(dimension, spatials, growth)
	BaseEntity.initialize(self, nil, dimension, spatials, false, true)
	self.growth = math.min(growth, self.growTime)
end

function Pickable:generate(rng, dimension, x, y)
	return self(dimension, {x, y}, self.growTime * rng:random())
end

function Pickable:tick(random)
	self.growth = math.min(self.growth + 1, self.growTime)
end

local getQuad = quadreasonable.getQuad
function Pickable:getQuad(angle)
	local grown = self.growth >= self.growTime
	local whichX = 0
	if grown then
		whichX = 1
	end
	local size = self.spriteRadius * 2
	return getQuad(whichX, 0, size, size, 2, 1, 2)
end


return Pickable
