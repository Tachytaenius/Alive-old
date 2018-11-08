local core = require("const.core")
local assets = require("assets")

local grass = {}

function grass:updateDrawFields()
	self.r = (1 - self.health) * 0.5 + 0.2
	self.g = 0.6
	self.b = 0.2
	self.a = 1
	self.noiseInfo[1] = 5
	self.noiseInfo[2] = 0.5
	self.noiseInfo[3] = 0.1
	self.noiseInfo[4] = self.health * 0.5 + 0.6
end

function grass.new(water)
	local new = {}
	new.health = water
	new.noiseInfo = {}
	new.updateDrawFields = grass.updateDrawFields
	new.texture = assets.images.arrangements.base
	new:updateDrawFields()
	return new
end

return grass
