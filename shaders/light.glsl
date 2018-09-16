extern vec4 info; // draw x, draw y, fov, angle
extern Image occluders;
const int start = 5;
const number tau = 6.28318530717958647692;
const vec2 size = vec2(1024, 1024);
vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 window_coords) {
	vec2 path = window_coords - info.xy;
	number len = length(path);
	vec2 direction = normalize(path);
	number angle = atan(direction.x, direction.y) + info[3];
	angle = mod(angle, tau) - tau / 2;
	if (abs(angle) < info[2] / 2) {
		for (int i = start; i < len; ++i) {
			vec2 location = info.xy + direction * i;
			colour *= Texel(occluders, location / size);
		}
	} else {
		return vec4(0, 0, 0, 0);
	}
	
	texture_coords = texture_coords * 2 - 1;
	number intensity = 1 - length(texture_coords);
	
	return colour * intensity;
}
