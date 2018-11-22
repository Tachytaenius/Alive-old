local path = (...):gsub("%.init$", "") .. "."

local commands = require("const.commands")

return {
	position = require(path .. "position"),
	ai = require(path .. "ai"),
	actor = require(path .. "actor"),
	camera = require(path .. "camera"),
	seenShapes = require(path .. "seenShapes"),
	viewSector = require(path .. "viewSector"),
	mob = require(path .. "mob"),
	solidShape = require(path .. "solidShape"),
	senseCircle = require(path .. "senseCircle"),
	tile = require(path .. "tile"),
	sprite = require(path .. "sprite"),
	reach = require(path .. "reach"),
	gender = require(path .. "gender"),
	blink = require(path .. "blink"),
	toggleOutfit = require(path .. "toggleOutfit"),
	tiredness = require(path .. "tiredness"),
	pose = require(path .. "pose"),
	beard = require(path .. "beard"),
	puncher = require(path .. "puncher"),
	light = require(path .. "light"),
	integrity = require(path .. "integrity"),
	metabolism = require(path .. "metabolism"),
	rot = require(path .. "rot"),
	life = require(path .. "life"),
	HUD = require(path .. "HUD")
}
