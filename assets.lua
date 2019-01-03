local newArrangement, bricks = require("util.newArrangement"), require("util.bricks")

local assets = {
	shaders = {
		depth = {load = function(self) self.value = love.graphics.newShader("resources/shaders/depth.glsl") end},
		light = {load = function(self) self.value = love.graphics.newShader("resources/shaders/light.glsl") end},
		texture = {load = function(self) self.value = love.graphics.newShader("resources/shaders/texture.glsl") end},
		falloff = {load = function(self) self.value = love.graphics.newShader("resources/shaders/falloff.glsl") end},
		erode = {load = function(self) self.value = love.graphics.newShader("resources/shaders/erode.glsl") end}
	},
	images = {
		HUD = {
			integrity = {load = function(self) self.value = love.graphics.newImage("resources/images/HUD/integrity.png") end}
		},
		misc = {
			font = {load = function(self) self.value = love.graphics.newImageFont("resources/images/misc/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.!?$,#@~:;-{}|&()<>'[]^£%/\\*0123456789") end},
			crosshairs = {load = function(self) self.value = love.graphics.newImage("resources/images/misc/crosshairs.png") end},
			title = {load = function(self) self.value = love.graphics.newImage("resources/images/misc/title.png") end},
			ukrizzus = {load = function(self) self.value = love.graphics.newImage("resources/images/misc/ukrizzus.png") end},
			null = {load = function(self) self.value = love.graphics.newImage(love.image.newImageData(1, 1)) end}
		},
		mobs = {
			malePlayer = {load = function(self) self.value = love.graphics.newImage("resources/images/mobs/malePlayer.png") end},
			femalePlayer = {load = function(self) self.value = love.graphics.newImage("resources/images/mobs/femalePlayer.png") end}
		},
		arrangements = {
			base = {load = function(self) self.value = newArrangement(function(r, g, b, x, y) return 1, 1, 1, 1 end) end},
			flagstones = {load = function(self) self.value = bricks(4, 4) end}
		}
	} 
}

return assets
