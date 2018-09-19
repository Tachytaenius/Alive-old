const number colours = 16;

const number x = colours - 1;
vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec4 fragment_colour = Texel(texture, texture_coords);
	fragment_colour = floor(fragment_colour * x + 0.5) / x;
	return fragment_colour;
}
