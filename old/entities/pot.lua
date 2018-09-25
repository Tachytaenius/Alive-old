local BaseEntity = classes.baseEntity
local Pot = class("Pot", BaseEntity)

function Pot:initialize(dimension, spatials, integrity, maxIntegrity, radius, depth)
	BaseEntity.initialize(self, nil, dimension, spatials, true)
	self.maxIntegrity = maxIntegrity
	self.integrity = math.min(integrity, maxIntegrity)
	self.radius = radius
	self.depth = depth
	self.inventory = {}
end

function Pot:checkDie()
	if self.integrity < 0 then
		self.isBroken = true
	end
end

Pot.container = true
function Pot:takeEntity(entity)
	local inventory = self.inventory
	if #inventory < self.capacity then
		table.insert(inventory, entity)
		entity.containedBy, entity.relativeTo = self, self
	end
end

function Pot:getEntity()
	local inventory = self.inventory
	local length = #inventory
	if length > 0 then
		return inventory[length]
	end
end

function Pot:giveEntity()
	local inventory = self.inventory
	if #inventory > 0 then
		local entity = table.remove(inventory)
		entity.containedBy, entity.relativeTo = nil, nil
		return entity
	end
end

function Pot:tickContainedEntity(entity, rng)
	local inventory = self.inventory
	local index = getKey(entity)
	if index > 1 then
		entity:reactTo(inventory[index - 1], rng)
	end
	local dimensionChange, escaped = entity:tick(rng, index)
	if dimensionChange or escaped then
		table.remove(inventory, index)
		entity:setSpatials(self:getSpatials())
	end
	return dimensionChange
end

local round = math.round
function Pot:tick(rng)
	if self.isBroken then
		self.leakTimer = (self.leakTimer + 1) % self.maxLeak
		if self.leakTimer == 0 then
			local inventory = self.inventory
			local index = round(rng:random() * #inventory)
			local entity = table.remove(inventory, index)
			entity:setSpatials(self:getSpatials())
		end
	end
end

return Pot
