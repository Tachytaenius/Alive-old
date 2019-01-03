local core = require("const.core")
local materials = require("materials")
local assets = require("assets")
local grass = require("util.superToppingGrass")

local ground = {}

function ground:growGrass()
	self.superTopping = grass.new(self)
end

function ground:updateDrawFields()
	local r, g, b, a, noisiness, contrast, brightness = 0, 0, 0, 0, 0, 0, 0
	local div = 0
	for material, quantity in pairs(self.constituents) do
		local x = material.impact * quantity
		if x > 0 then
			local weight = x / self.total
			r = r + weight * material.r
			g = g + weight * material.g
			b = b + weight * material.b
			a = a + weight * material.a
			noisiness = noisiness + weight * material.noisiness
			contrast = contrast + weight * material.contrast
			brightness = brightness + weight * material.brightness
			div = div + weight
		end
	end
	self.r = r / div
	self.g = g / div
	self.b = b / div
	self.a = a / div
	self.noiseInfo[1] = noisiness / div
	self.noiseInfo[2] = contrast / div
	self.noiseInfo[3] = brightness / div
	self.noiseInfo[4] = 1
	
	if self.superTopping then self.superTopping:updateDrawFields() end
end

function ground.new(tile, category, rng)
	local new = {}
	new.owner = tile
	-- TODO: not so random
	local constituents = {}
	local volume = core.terrainScale ^ 2 * core.ditchDepth * (rng:random() * 0.1 + 0.8)
	local total = 0
	for _, material in ipairs(category) do
		local quantity = rng:random() * material.abundance
		total = total + quantity
		constituents[material] = quantity
	end
	if total == 0 then
		constituents[materials.byName.clay] = 1
		total = 1
	end
	local total2 = 0
	for material, quantity in pairs(constituents) do
		quantity = math.floor(quantity / total * volume)
		total2 = total2 + quantity
		constituents[material] = quantity
	end
	new.constituents = constituents
	new.total = total2
	new.noiseInfo = {}
	new.growGrass = ground.growGrass
	new.updateDrawFields = ground.updateDrawFields
	new.texture = assets.images.arrangements.base
	new:updateDrawFields()
	return new
end

return ground
