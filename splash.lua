local Splash = class("Splash")

Splash.ukrizzus = image("misc/ukrizzus")

function Splash:initialize()
	self.slowness = 0.125
	self.phase = 0
	self.time = 16
	self.lastInputs = {{}}
end

function Splash:tick(...)
	self.slowness = 0.25
	local inputs = select(1, ...)
	local deltas = getDeltas(self.lastInputs, inputs)
	self.lastInputs[1] = copy(inputs)
	if inputs.run then self.slowness = 0.125 end
	if deltas.use then self.phase = self.phase + 1 self.time = 16 end
	self.time = self.time - 1
	if self.time == 0 then
		self.time = 16
		self.phase = self.phase + 1
	end
	if self.phase >= 3 or deltas.act
		or true -- TODO: remove
	then
		state = require("play")(0) -- replace state
	end
end

function Splash:draw()
	love.graphics.print(self.slowness .. "            " .. self.phase .. "               " .. self.time)
end

return Splash
