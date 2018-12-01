local path = (...):gsub("%.init$", "") .. "."

return {
	tile = require(path .. "tile"),
	maleHuman = require(path .. "maleHuman"),
	femaleHuman = require(path .. "femaleHuman"),
	door = require(path .. "door")
}
