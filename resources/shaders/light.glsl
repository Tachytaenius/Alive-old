number brightness(vec4 colour) {
	return (colour.r + colour.g + colour.b) / 3;
}

extern vec4 info; // draw x, draw y, fov, angle
extern vec2 eyeLocation;
extern Image occluders;
extern bool lamp; // lamp or view?
const number basePenetrationThreshold = 8;
const number tau = 6.28318530717958647692;
const vec2 size = vec2(1024, 1024);
vec4 effect(vec4 colour, Image texture, vec2 textureCoords, vec2 windowCoords) {
	vec2 path = windowCoords - info.xy;
	vec2 direction = normalize(path);
	number angle = atan(direction.x, direction.y);
	number signedAngle = mod(angle + info[3], tau) - tau / 2;
	if (abs(signedAngle) <= info[2] / 2) {
		number len = length(path);
		number penetrationThreshold = basePenetrationThreshold;
		if (lamp) {
			vec2 eyeVector = windowCoords - eyeLocation;
			number eyeAngle = atan(eyeVector.x, eyeVector.y);
			number angleFarness = abs(mod(angle - eyeAngle + tau / 2, tau) - tau / 2) / (tau / 2);
			penetrationThreshold *= (1 - angleFarness);
		}
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
		if (penetration > penetrationThreshold) {
			alpha = 1;
		}
		colour = colour * (1 - alpha) + colour2 * alpha;
	} else {
		return vec4(0, 0, 0, 0);
	}
	
	number intensity = 1;
	textureCoords = textureCoords * 2 - 1;
	intensity -= length(textureCoords);
	if (!lamp) {
		intensity = ceil(intensity);
	}
	
	return colour * intensity;
}
