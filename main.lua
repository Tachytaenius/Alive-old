love.graphics.setDefaultFilter("nearest", "nearest", 0)
love.graphics.setLineStyle("rough")

math = require("lib.mathsies")
local concord = require("lib.concord").init()
local knowledged = require("lib.knowledged")
local loadAssets = require("util.loadAssets")
local assets = require("assets")
local core = require("const.core")
local new = require("util.newGame")
-- local load = require("util.loadGame")
-- local join = require("util.joinGame")
local settings = require("settings")
local takeScreenshot = require("util.takeScreenshot")

local state, canvas

function love.load(args)
	settings.read()
	canvas = love.graphics.newCanvas(core.width, core.height)
	loadAssets()
	if args[1] == "new" or not args[1] then
		local seed = args[2] or love.math.random(2 ^ 53) - 1
		local host = args[3] or false
		state = new(seed, host, canvas)
	elseif args[1] == "load" then
		local path = args[2]
		local host = args[3] or false
		state = load(path, host, canvas)
	elseif args[1] == "join" then
		-- TODO
		local address = args[2]
		state = join(address, canvas)
	else
		knowledged.error("Invalid first argument: " .. args[1])
	end
end

function love.update(dt)
	if state and not state.paused then state:update() end
end

function love.draw()
	love.graphics.setFont(assets.images.misc.font.value)
	if state and not state.paused then
		love.graphics.setCanvas(canvas)
		state:draw()
		love.graphics.setCanvas()
	end
	
	love.graphics.setShader(assets.shaders.depth.value)
	love.graphics.draw(canvas, gameX, gameY, 0, settings.graphics.scale)
	love.graphics.setShader()
	
	if state and state.paused then
		love.graphics.print("PAUSED", 0, 0, 0, settings.graphics.scale)
	end
end

function love.run()
	love.load(love.arg.parseGameArguments(arg))
	love.timer.step()
	
	return function()
		love.event.pump()
		for name, a, b, c, d, e, f in love.event.poll() do
			if name == "quit" then
				if not love.quit() then
					return a or 0
				end
			end
			love.handlers[name](a, b, c, d, e, f)
		end
		
		love.update()
		if love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.draw()
		end
		if state and state.slowness then
			local wait = state.slowness - love.timer.step()
			love.timer.sleep(math.max(wait, 0))
			if love.graphics.isActive() then
				if settings.graphics.showPerformance then
					local performance = wait / state.slowness
					love.graphics.setColor(1 - performance, performance, 0, 1)
					love.graphics.print(math.round(performance * 100) .. "%", 0, 0, 0, settings.graphics.scale)
					love.graphics.setColor(1, 1, 1, 1)
				end
			end
		end
		if love.graphics.isActive() then
			love.graphics.present()
		end
		love.timer.step()
		
		love.timer.sleep(0.001)
	end
end

function love.quit()
	if state and state.quit then
		return state:quit()
	end
end

function love.keypressed(_, key)
	if state and state.thisClient then
		local command = settings.controls[key]
		if command then
			state.commands[state.thisClient][command] = true
		end
	end
end

function love.keyreleased(_, key)
	if state and state.thisClient then
		local command = settings.controls[key]
		if command == "pause" then
			state.paused = not state.paused
		elseif command == "takeScreenshot" then
			takeScreenshot(canvas)
		elseif command == "scaleDown" then
			if settings.graphics.scale > 1 then
				settings.graphics.scale = settings.graphics.scale - 1
				gameX, gameY = settings.updateWindow()
				settings.write()
			end
		elseif command == "scaleUp" then
			settings.graphics.scale = settings.graphics.scale + 1
			gameX, gameY = settings.updateWindow()
			settings.write()
		elseif command == "toggleFullscreen" then
			settings.graphics.fullscreen = not settings.graphics.fullscreen
			gameX, gameY = settings.updateWindow()
			settings.write()
		elseif command == "toggleInfo" then
			settings.graphics.showPerformance = not settings.graphics.showPerformance
			settings.write()
		elseif command then
			state.commands[state.thisClient][command] = nil
		end
	end
end
