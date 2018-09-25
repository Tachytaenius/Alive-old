local BaseEntity = classes.baseEntity

local Lamp = class("Lamp", BaseEntity)

Lamp.spriteRadius = 5
Lamp.solidRadius = 3
Lamp.immovability = 25

function Lamp:initialize(dimension, spatials, integrity, maxIntegrity, energy, r, g, b)
	BaseEntity.initialize(self, nil, dimension, spatials, true)
	self.energy = energy or 32
	self.r = r or 1
	self.g = g or 1
	self.b = b or 1
	self.maxIntegrity = maxIntegrity
	self.integrity = math.min(integrity, maxIntegrity)
	self:createLight()
end

function Lamp:checkDie()
	if self.integrity < 0 then
		self.isBroken = true
		self:disableLight()
	end
end

function Lamp:disableLight()
	if self.lightOn then
		self.lightOn = false
		self.dimension.collider:remove(self.lightShape)
	end
end

function Lamp:enableLight()
	-- if self.lightOn == nil then self:createLight() end
	if not self.lightOn then
		self.lightOn = true
		self.dimension.collider:register(self.lightShape)
	end
end

function Lamp:setLightState(to)
	if to then self:enableLight()
	elseif to == false then self:disableLight()
	else error("To what?") end
end

function Lamp:createLight()
	local light = self.dimension.collider:circle(self.x, self.y, self.energy)
	light.light = true -- entity, light or tile?
	light.energy, light.r, light.g, light.b = self.energy, self.r, self.g, self.b
	self.lightShape = light
	self.lightOn = true
end

Lamp.containable = true
function Lamp:tick(random, index)
	local x, y, theta = self:getSpatials()
	if self.lightOn then self.lightShape:moveTo(x, y) end
	
	local container = self.containedBy
	local shine = true
	if container then
		local inventory = container.inventory
		for i = index + 1, #inventory do
			local item = inventory[index]
			if item and not item.shineThrough then -- shineThrough is only meant to be off for solid piles of dirt and the like. If a jug is on top of a lamp, the lamp can still shrine 	around it.
				shine = false
				break
			end
		end
	end
	
	self:setLightState(shine)
end

return Lamp
