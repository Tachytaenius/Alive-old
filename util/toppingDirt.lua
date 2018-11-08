local core = require("const.core")
local materials = require("materials")
local assets = require("assets")
local grass = require("util.superToppingGrass")

local dirt = {}

function dirt:growGrass()
	self.superTopping = grass.new(self)
end

function dirt:updateDrawFields()
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
	
	--[[ if dirt was a tall boi
	-- supertoppings work on occluder info bearing in mind that toppings have set it beforehand; toppings update their draw fields first.
	local solidShape = self.owner.owner:get(components.solidShape)
	if self.noiseInfo[4] >= 0.95 then
		if not solidShape.occluderInfo then
			solidShape.occluderInfo = {r = 1, g = 1, b = 1}
		end
		local occluderInfo = solidShape.occluderInfo
		occluderInfo.r, occluderInfo.g, occluderInfo.b = occluderInfo.r - 1, occluderInfo.g - 1, occluderInfo.b - 1
	elseif solidShape.occluderInfo then
		solidShape.occluderInfo.r, solidShape.occluderInfo.g, solidShape.occluderInfo.b = 1, 1, 1
	end]]
	
	if self.superTopping then self.superTopping:updateDrawFields() end
end

function dirt.new(tile, rng)
	local new = {}
	new.owner = tile
	-- TODO: not so random
	local constituents = {}
	local volume = core.terrainScale ^ 2 * core.ditchDepth * (rng:random() * 0.1 + 0.8)
	local total = 0
	for _, material in ipairs(materials.categories.loam) do
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
	if total2 == 0 then print(total, total2, volume) end
	new.constituents = constituents
	new.total = total2
	new.noiseInfo = {}
	new.growGrass = dirt.growGrass
	new.updateDrawFields = dirt.updateDrawFields
	new.texture = assets.images.arrangements.base
	new:updateDrawFields()
	return new
end

return dirt
