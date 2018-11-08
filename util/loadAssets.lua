local assets = require("assets")

local function loadAssets(start)
	start = start or assets
	for _, v in pairs(start) do
		if v.load then
			v:load()
		else
			loadAssets(v)
		end
	end
end

return loadAssets
