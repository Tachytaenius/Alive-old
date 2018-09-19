number brightness(vec4 colour) {
	return (colour.r + colour.g + colour.b) / 3;
}

extern vec4 info; // draw x, draw y, fov, angle
extern Image occluders;
extern bool use_falloff;
const number penetration_threshold = 12;
const number tau = 6.28318530717958647692;
const vec2 size = vec2(1024, 1024);
vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 window_coords) {
	vec2 path = window_coords - info.xy;
	number len = length(path);
	vec2 direction = normalize(path);
	number angle = atan(direction.x, direction.y) + info[3];
	angle = mod(angle, tau) - tau / 2;
	vec4 destination = Texel(texture, window_coords / size);
	if (abs(angle) < info[2] / 2) {
		number alpha = 0;
		number last = 1;
		number downwards = 0;
		number penetration = 0;
		vec4 colour2 = vec4(1, 1, 1, 1);
		for (int i = 0; i < len; ++i) {
			vec2 location = info.xy + direction * i;
			vec4 through = Texel(occluders, location / size);
			number current = brightness(through);
			alpha += max(current - last, 0);
			downwards += max(last - current, 0);
			last = current;
			colour2 *= through;
			penetration += downwards;
		}
		if (penetration > penetration_threshold) {
			alpha = 1;
		}
		colour = colour * (1 - alpha) + colour2 * alpha;
	} else {
		return vec4(0, 0, 0, 0);
	}
	
	number intensity = 1;
	texture_coords = texture_coords * 2 - 1;
	intensity -= length(texture_coords);
	if (!use_falloff) {
		intensity = ceil(intensity);
	}
	
	return colour * intensity;
}
