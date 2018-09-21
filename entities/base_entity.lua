local BaseEntity = class("BaseEntity")

function BaseEntity:initialize(player, dimension, spatials, square)
	self.x, self.y, self.theta, self.relativeTo = spatials.x or spatials[1], spatials.y or spatials[2], spatials.z or spatials[3], spatials.theta or spatials[4], spatials.relativeTo or spatials[5]
	self.knockX, self.knockY = 0, 0
	self.square = square
	self.dimension = dimension
	self:reregisterSolidShape()
	self.player = player
	self.new = true
end

function BaseEntity:reregisterSolidShape()
	self.solidShape = self.square and self.dimension.collider:rectangle(self.x - self.solidRadius, self.y - self.solidRadius, self.solidRadius * 2, self.solidRadius * 2) or self.dimension.collider:circle(self.x, self.y, self.solidRadius)
	self.solidShape.entity = self -- Mutually linked
end

-- TODO: put versions of all the standard entity functions in here and stop checking to see if they are on instances of this class or its descendants

function BaseEntity:setRelativity(to)
	-- TODO: Stay in the same place in global coordinates but switch relative point
	local x1, y1, theta1 = self:getSpatials()
	local x2, y2, theta2 = self.relativeTo:getSpatials()
	local x3, y3, theta3 = to:getSpatials()
	self.relativeTo = to
end

function BaseEntity:setSpatials(x, y, theta)
	-- TODO: aaaaaaaaaaaaaaahhhhhhhhhhhhssssgushgiubslnbjfsnjhbuyg
	self.x, self.y, self.theta = x, y, theta
	self.solidShape:moveTo(x, y)
end

function BaseEntity:getSpatials()
	-- TODO: If relative to something then treat self's spatials as an offset.
	
	local entity
	if self.relativeTo then
		entity = self.relativeTo
	else
		entity = self
	end
	
	return entity.x, entity.y, entity.theta
end

return BaseEntity
