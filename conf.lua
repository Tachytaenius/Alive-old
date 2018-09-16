constants = require("constants")

function love.conf(t)
	t.identity = "alive"
	t.version = "11.1"
	t.accelorometerjoystick = false
	t.appendidentity = true
	
	t.window.title = "Alive"
	t.window.icon = "icon.png"
	t.window.width = constants.screenWidth
	t.window.height = constants.screenHeight
end
