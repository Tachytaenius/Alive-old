local Human = classes.human
local MalePlayer = class("MalePlayer", Human)

function MalePlayer:initialize(player, dimension, spatials, name)
	local status = {gender = "male"}
	local stats = {}
	self.spritesheet = love.graphics.newImage("assets/images/entities/male_player.png")
	Human.initialize(self, player, dimension, spatials, status, stats) -- TODO: Stats and status.
end

return MalePlayer
