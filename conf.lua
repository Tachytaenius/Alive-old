local core = require("const/core")

function love.conf(t)
	t.identity = core.identity
	t.version = "11.1"
	t.accelorometerjoystick = false
	t.appendidentity = true
	
	t.window.title = core.title
	t.window.icon = "icon.png"
	t.window.width = core.width
	t.window.height = core.height
end
