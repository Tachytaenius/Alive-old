math = require("lib/mathsies")
local settings = require("settings")
local hc = require("lib/hc")

local font, shader, canvas
local gameX, gameY
local time, paused

function love.load(args)
	font = love.graphics.newImageFont("assets/images/misc/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.!?$,#@~:;-{}|&()<>'[]^£%/\\*0123456789")
	love.graphics.setFont(font)
	
	love.graphics.setDefaultFilter("nearest", "nearest", 0)
	love.graphics.setLineStyle("rough")
	
	settings.read()
end

function love.update(dt)
	if not paused then
		
	end
end
