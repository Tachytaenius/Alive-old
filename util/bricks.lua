local core = require("const.core")
local newArrangement = require("util.newArrangement")

return function(xcount, ycount, shift)
	return newArrangement(function(x, y, r, g, b, a)
		local xinterval = core.terrainScale / xcount
		local yinterval = core.terrainScale / ycount
		if shift == "x" then
			if math.floor(y / yinterval) % 2 == 1 then
				x = x + xinterval / 2
			end
		elseif shift == "y" then
			if math.floor(x / xinterval) % 2 == 1 then
				y = y + yinterval / 2
			end
		end
		local isBlack = math.isInteger(x / xinterval) or math.isInteger(y / yinterval)
		
		local i = isBlack and 0 or 1 -- intensity
		return i, i, i, 1
	end)
end
