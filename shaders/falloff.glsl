extern vec4 info; // translation x, translation y, falloff start, precalculated power.

const vec2 size = vec2(1024, 1024);
vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 window_coords) {
	texture_coords *= size;
	texture_coords -= info.xy;
	number r = length(texture_coords);
	r = max(info[2] * pow(r / info[2], 1 / info[3]), r);
	texture_coords = info.xy + r * normalize(texture_coords);
	return colour * Texel(texture, texture_coords / size);
}
