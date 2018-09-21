-- These are not necessarily elements of the periodic table, just things that a tile can be made from.

local function newConstituent(name, mass, rarity, r, g, b, a, noisiness, brightness, contrast)
	local constituent = {r = r, g = g, b = b, a = a, noisiness = noisiness, brightness = brightness, contrast = contrast, name = name, mass = mass, rarity = rarity}
	return constituent
end
-- TODO: Rarity --> Commonness
local iron = newConstituent("iron", 50,	1,			0.75, 0.3, 0.25, 1,		1, 0, 0.25)
local water = newConstituent("water", 10, 5,		0.5, 0.5, 0.75, 0.125,	0.5, 0, 0.2)
local clay = newConstituent("clay", 11,	2,			0.75, 0.5, 0.5, 1, 		1.5, 0, 0.15)
local sand = newConstituent("sand", 9, 2,			0.8, 0.8, 0.3, 1,	 	7, 0, 0.15)
local silt = newConstituent("silt", 8, 2,			0.4, 0.35, 0.4, 1, 		3, 0, 0.375)
local granite = newConstituent("granite", 25, 2,	0.6, 0.5, 0.55, 1,		4, 0, 0.7)
local quartz = newConstituent("quartz", 25, 0,		0.5, 0.5, 0.5, 1,		1, 1, 0)

-- TODO: reactions

local function newOverlay(name, getColour, textureOrNoisiness, brightness, contrast)
	local overlay = {name = name, getColour = getColour}
	if type(textureOrNoisiness) == "number" then
		overlay.noisiness = textureOrNoisiness
		overlay.brightness = brightness
		overlay.contrast = contrast
	else -- image
		overlay.texture = textureOrNoisiness
	end
	return overlay
end

-- TODO: species
local grass = newOverlay("grass", function(total, components)
	-- colours for wet and dry
	local wetness = components[water] / total
	return 1 - wetness, 0.8, 0.3, 1
end, 6, 0.5, 0.2)
-- TODO: living together

constituents = {
	iron = iron,
	water = water,
	clay = clay,
	sand = sand,
	silt = silt,
	granite = granite,
	quartz = quartz
}

overlays = {
	grass = grass
}
