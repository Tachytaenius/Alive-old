local core = require("const.core")
local components = require("components")
local materials = require("materials")
local assets = require("assets")

local block = {}

function block:updateDrawFields()
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
	
	local solidShape = self.owner.owner:get(components.solidShape)
	local transparency = 1 - a / div
	local r, g, b = r / div * transparency, g / div * transparency, b / div * transparency
	solidShape.occluderInfo = solidShape.occluderInfo or {}
	solidShape.occluderInfo.r, solidShape.occluderInfo.g, solidShape.occluderInfo.b = r, g, b
end

function block.new(topping, category, rng)
	local new = {}
	new.owner = topping
	-- TODO: not so random
	local constituents = {}
	local volume = core.terrainScale ^ 3 * (rng:random() * 0.1 + 0.8)
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
	if total2 == 0 then print(total, total2, volume) end
	new.constituents = constituents
	new.total = total2
	new.noiseInfo = {}
	new.updateDrawFields = block.updateDrawFields
	new.texture = assets.images.arrangements.base
	new:updateDrawFields()
	new.owner.owner:get(components.solidShape).clip = true
	return new
end

function block:destroy()
	self.owner.owner:get(components.solidShape).clip = false
end

return block
