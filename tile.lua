changes = {} -- TODO: *locally* accessible from main.lua

local unitsPerTile, scale = constants.unitsPerTile, constants.terrainScale

local boost = 4 -- the greater this number the less of a constituent you need to give it a greater impact when drawing the tile

local function new(mapFunction)
	local tile = love.image.newImageData(scale, scale)
	tile:mapPixel(mapFunction)
	return love.graphics.newImage(tile)
end

local function bricks(xcount, ycount, shift)
	return new(function(x, y, r, g, b, a)
		local xinterval = scale / xcount
		local yinterval = scale / ycount
		if shift == "x" then
			if math.floor(y / yinterval) % 2 == 1 then
				x = x + xinterval / 2
			end
		elseif shift == "y" then
			if math.floor(x / xinterval) % 2 == 1 then
				y = y + yinterval / 2
			end
		end
		local isBlack = math.isInteger(x / xinterval) or math.isInteger(y / yinterval)
		
		local i = isBlack and 0 or 1 -- intensity
		return i, i, i, 1
	end)
end

local base = new(function(x, y, r, g, b, a)
	return 1, 1, 1, 1
end)
local flagstones = bricks(2, 2, "x")

local colour, rectangle, draw = love.graphics.setColor, love.graphics.rectangle, love.graphics.draw
local getQuad = quadreasonable.getQuad
local round = math.round
local sbm = love.graphics.setBlendMode
local tileLocation, noiseInfo = {}, {}
local constituentQuantityStages = constants.constituentQuantityStages
local wall = constants.wall
local function drawFunction(self, shader, entityX, entityY) -- draw co-ordinates
	local selfX, selfY = self.x, self.y
	local drawX, drawY = entityX - selfX * scale - scale, entityY - selfY * scale - scale
	tileLocation[1], tileLocation[2] = selfX, selfY
	shader:send("tile_location", tileLocation)
	local totalComponents, totalToppings = self.constituentTotal, self.overlayTotal
	-- TODO: organise
	if self.collisionType == wall then
		local components = self.wallComponents
		local style = self.wallStyle
		for constituent, quantity in pairs(components) do
			noiseInfo[1], noiseInfo[2], noiseInfo[3], noiseInfo[4] = constituent.noisiness, constituent.contrast, constituent.brightness, 1
			shader:send("noise_info", noiseInfo)
			colour(constituent.r, constituent.g, constituent.b, constituent.a * quantity / totalComponents * boost)
			draw(flagstones, drawX, drawY)
		end
	else
		local components = self.groundComponents
		for constituent, quantity in pairs(components) do
			noiseInfo[1], noiseInfo[2], noiseInfo[3], noiseInfo[4] = constituent.noisiness, constituent.contrast, constituent.brightness, 1
			shader:send("noise_info", noiseInfo)
			colour(constituent.r, constituent.g, constituent.b, constituent.a * quantity / totalComponents * boost)
			draw(base, drawX, drawY)
		end
		for overlay, quantity in pairs(self.toppings) do
			if quantity > 0 then
				colour(overlay.getColour(totalComponents, components))
				noiseInfo[1], noiseInfo[2], noiseInfo[3], noiseInfo[4] = overlay.noisiness, overlay.contrast, overlay.brightness, quantity
				shader:send("noise_info", noiseInfo)
				draw(base, drawX, drawY)
			end
		end
	end
end
local takenDamage = constants.takenDamage
local function takeDamageFunction(self, amount, dx, dy)
	local change = {nature = takenDamage, tile = self, amount = amount, dx = dx, dy = dy}
	changes[change] = true
end

local round = math.round
local scale, tbs = constants.terrainScale, constants.tileBorderSize
local water = constituents.water
function new(newTile, dimension, rng, x, y) -- tile co-ordinates
	newTile.tile = true
	newTile.x, newTile.y = x, y
	newTile.draw = drawFunction
	newTile.takeDamage = takeDamageFunction
	local fullness = rng:random() * 0.1 + 0.8
	local components = {}
	local total = 0
	for _, constituent in pairs(constituents) do
		local quantity = rng:random()
		total = total + quantity
		components[constituent] = quantity * constituent.rarity
	end
	if total == 0 then
		components.clay = 1
		total = 1
	end
	local actualTotal = 0
	for constituent, quantity in pairs(components) do
		local actualQuantity = round(fullness * unitsPerTile * quantity / total)
		actualTotal = actualTotal + actualQuantity
		components[constituent] = actualQuantity
	end
	newTile.constituentTotal = actualTotal
	newTile.groundComponents = components
	local toppings = {}
	local total = 0
	for overlayName, overlay in pairs(overlays) do
		local quantity
		if overlayName == "grass" then
			quantity = components[water] / actualTotal -- actualTotal isn't used for overlay generation so it's still the value of newTile.constituentTotal
		else
			quantity = rng:random()
		end
		total = total + quantity
		toppings[overlay] = quantity
	end
	newTile.overlayTotal = total
	newTile.toppings = toppings
	return newTile
end

return new
