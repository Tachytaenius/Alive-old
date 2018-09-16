vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec4 fragment_colour = Texel(texture, texture_coords);
	fragment_colour = floor(fragment_colour * 15 + 0.5) / 15;
	return fragment_colour;
}
