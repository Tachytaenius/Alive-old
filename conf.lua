local CORE, TITULAR = require("const/core"), require("const/titular")

function love.conf(t)
	t.identity = "alive"
	t.version = "11.1"
	t.accelorometerjoystick = false
	t.appendidentity = true
	
	t.window.title = TITULAR.base
	t.window.icon = "icon.png"
	t.window.width = CORE.WIDTH
	t.window.height = CORE.HEIGHT
end
