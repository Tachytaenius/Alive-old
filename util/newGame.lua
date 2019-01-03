local play = require("play")
local newRealm = require("util.newRealm")

return function(seed, host, canvas)
	seed = 1
	local new = play()
	new.seed = seed
	new.rng = love.math.newRandomGenerator(seed)
	new.realms = {newRealm("maacian overworld", 256, 256, new.rng)}
	new.thisClient = "aliveplayer"
	new.commands, new.lastCommands = {[new.thisClient] = {}}, {[new.thisClient] = {}}
	new.clients = {}
	new.canvas = canvas
	for _, v in pairs(new.clients) do
		new.commands[v] = {}
		new.lastCommands[v] = {}
	end
	return new
end
