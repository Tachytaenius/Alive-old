local Animal = classes.animal
local Biped = class("Biped", Animal)

Biped.POSE_VALUES = {stand = 0, walk1 = 1, walk2 = 2, walk3 = 3, lieBack = 4, lieFront = 5, sitCrossLegged = 6, sitChair = 7}
Biped.BATCH_SIZE = 8 -- The number of poses this entity has (a single batch is frames for all the poses for a certain appearance,) like walking on lying on the floor. See Biped:getFrame.
Biped.BLINK_SPEED = 150 -- Every 150 ticks the entity will blink.
Biped.BLINK_LENGTH = 4 -- A blink lasts 4 ticks (and carries into BLINK_SPEED)
Biped.WALK_FRAMES = 4

function Biped:initialize(player, dimension, spatials, stats, status, handedness)
	Animal.initialize(self, player, dimension, spatials, stats, status)
	
	self.handedness = handedness or "right"
	
	self.moved = false
	self.pose = "stand"
	
	self.gender = stats.gender
	if stats.gender == "male" then
		self.spritesX = 4
		self.spritesY = 20
	elseif stats.gender == "female" then
		self.spritesX = 2
		self.spritesY = 20
	else
		error("Invalid gender supplied to constructor.")
	end
	
	if self.toggleableOutfit then
		self.spritesX = self.spritesX * 2
	end
	
	self.blink = status.blink or 1
	self.walkTimer = 0
end

function Biped:grab(entity)
	local selfX, selfY, selfTheta = self:getSpatials()
	local grabeeX, grabeeY = entity:getSpatials()
	local r, theta = math.cartesianToPolar(grabeeX - selfX, grabeeY - selfY)
	-- is it in self.reach
	-- is it in self.fov
	-- ok, set it relative to you and kill its x y z and theta to 0
end

function Biped:control(key, inputs, deltaInputs)
	Animal.control(self, key, inputs, deltaInputs)
	if deltaInputs.act then self.actions.punch = true end
end

function Biped:grabAtCrosshairs()
	-- TODO
end

local wall = constants.wall
local sin, cos, abs, floor, polarToCartesian, sgn, min, max, sqrt = math.sin, math.cos, math.abs, math.floor, math.polarToCartesian, math.sgn, math.min, math.max, math.sqrt
local scale = constants.terrainScale
local toCheck = {}
function Biped:punch(hand, rng)
	-- if hand ~= "left" and hand ~= "right" then error("Hand isn't left or right...?!") end
	local reach = self.reach
	local selfX, selfY = self.x, self.y
	local selfTheta = self.theta + math.tau / 4
	
	-- punchable shapes are shapes that have a collisionType of wall or are entities without nonBlocking
	-- punched needs to be a set of the punchables for which no punchable is closer (ie "the" closest punchable and any punchables that tied with it)
	local x0, y0 = selfX, selfY
	local x1, y1 = selfX + reach * cos(selfTheta), selfY + reach * sin(selfTheta)
	local dx, dy = abs(x1 - x0), abs(y1 - y0)
	local magnitude = sqrt(dx ^ 2 + dy ^ 2)
	dx, dy = dx / magnitude, dy / magnitude
	local ix, iy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
	local e = 0
	local punched = {}
	local shapeCount = 0
	local currentDistance = reach
	hash = self.dimension.collider:hash()
	for i = 0, dx + dy - 1 do
		for shape in pairs(hash:cellAt(x0, y0)) do
			toCheck[shape] = true
		end
		local e1, e2 = e + dy, e - dx
		if abs(e1) < abs(e2) then
			x0 = x0 + ix
			e = e1
		else
			y0 = y0 + iy
			e = e2
		end
	end
	toCheck[self.solidShape] = nil
	local dx, dy = x1 - selfX, y1 - selfY
	for shape in pairs(toCheck) do
		toCheck[shape] = nil
		if shape.collisionType == wall or shape.entity and not shape.entity.nonBlocking then
			local rayParameters = shape:intersectionsWithRay(selfX, selfY, dx, dy)
			local distance
			for _, v in pairs(rayParameters) do
				v = v * reach
				if not distance or v < distance then distance = v end
			end
			if distance then
				if distance < currentDistance then
					currentDistance = distance
					punched = {[shape] = true}
					shapeCount = 1
				elseif distance == currentDistance then
					punched[shape] = true
					shapeCount = shapeCount + 1
				end
			end
		end
	end
	
	local damage = (rng:random(0.25) + 0.75) * self.strength / (self.handedness == hand and 1 or 1.5) * 1 - (currentDistance / reach)
	for punchable in pairs(punched) do
		if punchable.entity and not punchable.entity.new then
			if entity.damage then entity.damage = entity.damage + damage / shapeCount elseif entity.integrity then entity.integrity = entity.integrity - damage end
			local knockX, knockY = dx / reach * abs(reach - currentDistance), dy / reach * abs(reach - currentDistance)
			entity.knockX, entity.knockY = entity.knockX + knockX, entity.knockY + knockY
		elseif punchable.collisionType == wall then
			punchable:takeDamage(damage, dx / reach, dy / reach)
		end
	end
end

function Biped:tick(rng)
	self.blink = (self.blink + 1) % Biped.BLINK_SPEED
	
	if self.actions.x ~= 0 or self.actions.y ~= 0 then
		self.moved = true
		self.walkTimer = (self.walkTimer + self.actions.speedMultiplier / 2) % 16
		self.pose = "walk"
	elseif self.moved then
		self.moved = false
		self.walkTimer = 0
		self.pose = "stand"
	end
	
	if self.actions.punch then self:punch("right", rng) end
	
	return Animal.tick(self, random)
end

return Biped
