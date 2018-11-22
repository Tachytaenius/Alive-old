local core = require("const.core")
local getDeltas = require("util.getDeltas")
local settings = require("settings")
local socket = require("socket")
local play = {name = "play"}

play.speed = core.speed
play.slowness = core.slowness

function play:update()
	local realmChanges, involvedRealms = {}, {}
	
	local deltaCommands = {}
	for _, v in pairs(self.clients) do
		deltaCommands[v] = getDeltas(self.lastCommands[v], self.commands[v])
	end
	if self.thisClient then deltaCommands[self.thisClient] = getDeltas(self.lastCommands[self.thisClient], self.commands[self.thisClient]) end
	
	for _, realm in ipairs(self.realms) do
		realm:emit("update", self.commands, deltaCommands, realmChanges)
	end
	for realmChange in pairs(realmChanges) do
		realmChange.from:removeEntity(realmChange.entity)
		involvedRealms[from] = true
		realmChange.to:addEntity(realmChange.entity)
	end
	for realm in pairs(involvedRealms) do
		realm:flush()
	end
	
	for _, v in pairs(self.clients) do
		local last = {}
		for k, v in pairs(self.commands[v]) do
			last[k] = v
		end
		self.lastCommands[v] = last
	end
	if self.thisClient then
		local last = {}
		for k, v in pairs(self.commands[self.thisClient]) do
			last[k] = v
		end
		self.lastCommands[self.thisClient] = last
	end
end

function play:quit()
	for address, id in pairs(self.clients) do
		
	end
	
	if settings.autosave.quit then
		self:autosave()
	end
end

function play:draw()
	for _, realm in ipairs(self.realms) do
		realm:emit("draw", self.thisClient, self.canvas)
	end
end

function play:quit()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear(0, 0, 0, 1)
	love.graphics.setCanvas()
end

return function()
	local instance = {}
	for k, v in pairs(play) do
		instance[k] = v
	end
	return instance
end
