// Code needs to be vectorised.
// Doesn't change the positions of the vertices to the intended texture width and height, they stay at the corners of the original spritesheet

extern vec4 xywh;
extern vec2 texture_resolution;

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords) {
	number texture_width = texture_resolution.x;
	number texture_height = texture_resolution.y;
	number quad_x = xywh[0] / texture_width;
	number quad_y = xywh[1] / texture_height;
	number quad_width = xywh[2] / texture_width;
	number quad_height = xywh[3] / texture_height;
	if (texture_coords.x > quad_width || texture_coords.y > quad_height) {
		return vec4(0, 0, 0, 0);
	}
	return Texel(texture, vec2(texture_coords.x + quad_x, texture_coords.y + quad_y)) * colour;
}
