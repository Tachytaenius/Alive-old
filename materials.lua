local byIndex, byName, categories = {}, {}, {}

local function newMaterial(name, mass, abundance, impact, r, g, b, a, noisiness, brightness, contrast, ...)
	local material = {r = r, g = g, b = b, a = a, impact = impact, noisiness = noisiness, brightness = brightness, contrast = contrast, name = name, mass = mass, abundance = abundance}
	table.insert(byIndex, material)
	byName[name] = material
	for _, category in ipairs({...}) do if categories[category] then table.insert(categories[category], material) else categories[category] = {material} end end
	return material
end

newMaterial("iron", 50,	1,    1,       0.75, 0.3, 0.25, 1,     1, 0, 0.35)
newMaterial("water", 10, 5,   0.03125, 0.15, 0.15, 0.75, 0.25, 0.5, 0.1, 0.15, "loam")
newMaterial("clay", 11,	1,    1,       0.55, 0.3, 0.3, 1,      1.5, 0.05, 0.5, "loam")
newMaterial("sand", 9, 1,     0.25,    0.9, 0.7, 0.3, 1,       8, 0.1, 0.5,    "loam")
newMaterial("silt", 8, 1,     0.25,    0.4, 0.35, 0.4, 1,      3, 0, 0.475,    "loam")
newMaterial("granite", 25, 2, 1,       0.6, 0.5, 0.55, 1,      2, 0.9, 0.6)
newMaterial("quartz", 25, 0,  1,       0.5, 0.5, 0.5, 1,       1, 0.9, 0.1)
newMaterial("glass", 9, 0,    1.5,     1, 1, 1, 0.0625,        0.5, 0.35, 0.2)

-- TODO: reactions

return {byIndex = byIndex, byName = byName, categories = categories}
