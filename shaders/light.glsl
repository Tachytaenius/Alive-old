extern vec2 drawpos;

extern Image occluders;
const vec2 size = vec2(1024, 1024);
vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 window_coords) {
	vec2 path = window_coords - drawpos;
	number len = length(path);
	vec2 direction = normalize(path);
	for (int i = 0; i < len; ++i) {
		vec2 location = drawpos + direction * i;
		colour *= Texel(occluders, location / size);
	}
	
	texture_coords = texture_coords * 2 - 1;
	number intensity = 1 - length(texture_coords);
	
	return colour * intensity;
}
