extern vec4 info; // draw x, draw y, fov, angle
extern vec2 eyeLocation;
extern Image occluders;
extern bool lamp; // lamp or view?
const number basePenetrationThreshold = 10;
const number tau = 6.28318530717958647692;
const vec2 size = vec2(1024, 1024);
vec4 effect(vec4 colour, Image texture, vec2 textureCoords, vec2 windowCoords) {
	textureCoords = textureCoords * 2 - 1;
	number intensity = 1 - length(textureCoords);
	if (intensity <= 0) {
		return vec4(0, 0, 0, 1);
	}
	if (!lamp) {
		intensity = ceil(intensity);
	}
	
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
		vec3 colour2 = vec3(1);
		for (int i = 0; i < len; ++i) {
			vec2 location = info.xy + direction * i;
			vec4 through = Texel(occluders, location / size);
			number current = 1 - through.a;
			colour2 = min(colour2, through.rgb);
			alpha += max(current - last, 0);
			downwards += max(last - current, 0);
			last = current;
			penetration += downwards;
		}
		if (penetration > penetrationThreshold) {
			alpha = 1;
		}
		colour = colour * (1 - alpha) + vec4(colour2, 1) * alpha;
	} else {
		return vec4(0);
	}
	
	return colour * intensity;
}
