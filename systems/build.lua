local concord = require("lib.concord")
local components = require("components")
local behaviours = require("behaviours")
local core = require("const.core")
local updateReach = require("util.updateReach")
local build = concord.system({"builders", components.actor, components.reach, components.heldChunk, components.life})

function build:update()
	local instance = self:getInstance()
	local tiles = instance.tiles
	local buildRequests = {}
	local chiselRequests = {}
	for i = 1, self.builders.size do
		local e = self.builders:get(i)
		local actor = e:get(components.actor)
		local reach = e:get(components.reach)
		if not reach.updated then updateReach(e, reach) end
		local x, y = math.floor(reach.x / core.terrainScale), math.floor(reach.y / core.terrainScale)
		if actor.actions.build then
			if tiles[x] and tiles[x][y] then buildRequests[tiles[x][y]] = buildRequests[tiles[x][y]] and "conflict" or e end
		end
	end
	local tilesToUpdateDrawFields = {}
	for tile, requester in pairs(buildRequests) do
		if requester ~= "conflict" then
			
		end
	end
end

return build
