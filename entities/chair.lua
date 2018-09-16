local BaseEntity = classes.baseEntity

local Chair = class("Chair", BaseEntity)

function Chair:initialize(dimension, spatials, integrity, maxIntegrity)
	BaseEntity.initialize(self, nil, dimension, spatials, true)
	self.maxIntegrity = maxIntegrity
	self.integrity = math.min(integrity, maxIntegrity)
end

function Chair:satOnBy(entity) -- returns whether the entity was allowed to sit down
	if entity.solidRadius > self.solidRadius + 1 then return false end -- 1 is for leeway
	-- TODO: meaningful names, please
	local oof = self.integrity - entity.immovability
	self.integrity = oof < 0 and oof or self.integrity
	self.occupier = entity
	return true
end

function Chair:checkDie()
	if self.integrity < 0 then
		self.isBroken = true
		if self.occupier then
			self.occupier:dismount()
		end
	end
end

local angles = constants.angles
function Chair:getQuad(angle)
	local size = self.spriteRadius * 2
	local whichX = self.isBroken and size or 0
	return quadreasonable.getQuad(whichX, angle, size, size, 2, 4, true)
end

return Chair
