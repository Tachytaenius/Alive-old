local path = (...):gsub("%.init$", "") .. "."

return {
	preact = require(path .. "preact"),
	realmTransfers = require(path .. "realmTransfers"),
	move = require(path .. "move"),
	updateViewSectors = require(path .. "updateViewSectors"),
	collide = require(path .. "collide"),
	see = require(path .. "see"),
	clean = require(path .. "clean"),
	tick = require(path .. "tick"),
	build = require(path .. "build")
}
