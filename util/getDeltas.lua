-- Returns a table for which all keys in "a" whose value's truth differs to that of the value of the same key in "b" is a boolean representing the truth of the value that the key held in "b."
-- For example, if "a" is the table of inputs for one frame and "b" is a table of inputs for the next one, then every non-nil value in "getDeltas(a, b)" would be true if the input its key represented was newly pressed between the frames and false if it was released. That is the main purpose of this function.
return function(a, b)
	local c = {}
	for k in pairs(a) do
		if not a[k] and b[k] then
			c[k] = true
		elseif a[k] and not b[k] then
			c[k] = false
		end
	end
	for k in pairs(b) do
		if c[k] == nil then -- A did not have this key, but more relevantly: B does. This is part of the intersection and thus must be accounted for. Surrounding this in an IF statement was merely an optimisation, the return table would be the same either way.
			if not a[k] and b[k] then
				c[k] = true
			elseif a[k] and not b[k] then
				c[k] = false
			end
		end
	end
	return c
end
