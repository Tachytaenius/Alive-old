local Biped = classes.biped
local Human = class("Human", Biped)

Human.spriteRadius = 8
Human.solidRadius = 4
Human.senseRadius = 12
Human.BEARD_THRESHOLD = 60 * 60 * 2 * constants.speedOfPlay -- At what point does a male player become bearded?
Human.MAX_BEARD = Human.BEARD_THRESHOLD -- We don't really need to continue incrementing the beard counter if it will have no effect. 
Human.reach = constants.terrainScale

function Human:initialize(player, dimension, spatials, stats, status)
	Biped.initialize(self, player, dimension, spatials, stats, status)
	
	if self.gender == "male" then
		self.beard = status.beard or 1
		self.speed = 1.5
		self.immovability = 50
	elseif self.gender == "female" then
		self.speed = 1.45
		self.immovability = 40
	end
end

function Human:tick(random)
	if self.gender == "male" then
		self.beard = math.min(self.beard + 1, Human.MAX_BEARD)
	end
	return Biped.tick(self, random)
end

function Human:getQuad(angle)
	local whichX, whichY = 0, 0
	
	if self.blink < Human.BLINK_LENGTH then whichX = whichX + 1 end
	if self.gender == "male" and self.beard >= Human.BEARD_THRESHOLD then whichX = whichX + 2 end
	if self.toggledOutfit then
		if self.gender == "male" then
			whichX = whichX + 4 -- beard
		else
			whichX = whichX + 2
		end
	end
	
	if self.pose == "walk" then
		whichY = whichY + 1 + math.floor(self.walkTimer / Human.WALK_FRAMES)
	else
		whichY = whichY + Human.POSE_VALUES[self.pose]
	end
	
	local size = self.spriteRadius * 2
	
	return quadreasonable.getQuad(whichX, whichY * constants.angles + angle, size, size, self.spritesX, self.spritesY, 2)
end

return Human
