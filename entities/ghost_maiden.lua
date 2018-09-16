local Human = classes.human
local GhostMaiden = class("GhostMaiden", Human)

function GhostMaiden:initialize(player, dimension, spatials, name)
	local status = {gender = "female"}
	local stats = {}
	self.spritesheet = love.graphics.newImage("assets/images/entities/ghost_maiden.png")
	Human.initialize(self, player, dimension, spatials, status, stats) -- TODO: Stats and status.
end

return GhostMaiden
