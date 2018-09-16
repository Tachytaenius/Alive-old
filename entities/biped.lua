local Animal = classes.animal
local Biped = class("Biped", Animal)

Biped.POSE_VALUES = {stand = 0, walk1 = 1, walk2 = 2, walk3 = 3, lieBack = 4, lieFront = 5, sitCrossLegged = 6, sitChair = 7}
Biped.BATCH_SIZE = 8 -- The number of poses this entity has (a single batch is frames for all the poses for a certain appearance,) like walking on lying on the floor. See Biped:getFrame.
Biped.BLINK_SPEED = 150 -- Every 150 ticks the entity will blink.
Biped.BLINK_LENGTH = 4 -- A blink lasts 4 ticks (and carries into BLINK_SPEED)
Biped.WALK_FRAMES = 4

function Biped:initialize(player, dimension, spatials, stats, status)
	Animal.initialize(self, player, dimension, spatials, stats, status)
	
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

function Biped:grabAtCrosshairs()
	-- TODO
end

function Biped:tick(world, random)
	Animal.tick(self, world, random)
	
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
end

return Biped
