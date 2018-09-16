shader = love.graphics.newShader("quad.glsl")

local xywh = {0, 0, 0, 0}
local resolution = {0, 0}
function sendInfoToShader(x, y, w, h, w2, h2)
	xywh[1], xywh[2], xywh[3], xywh[4] = x, y, w, h
	shader:send("xywh", xywh)
	resolution[1], resolution[2] = w2, h2
	shader:send("texture_resolution", resolution)
end
