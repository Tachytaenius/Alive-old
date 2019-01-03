local core = require("const.core")
local components = require("components")
local materials = require("materials")
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

function grass.new(owner)
	local new = {}
	new.owner = owner
	local water = owner.constituents[materials.byName.water] / (core.terrainScale ^ 2 * core.ditchDepth)
	new.health = math.min(water * 2, 1)
	new.noiseInfo = {}
	new.updateDrawFields = grass.updateDrawFields
	new.texture = assets.images.arrangements.base
	new:updateDrawFields()
	return new
end

return grass
