return function(constituents)
	local total = 0
	for material, quantity in pairs(constituents) do
		total = total + quantity * material.mass
	end
	return total
end
