extern vec4 info; // draw x, draw y, fov, angle
extern vec2 eyeLocation;
extern Image occluders;
extern bool lamp; // lamp or view?
const number basePenetrationThreshold = 12;
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
		number tolerance = 1;
		vec4 lastColour = Texel(occluders, info.xy / size);
		vec3 colour2 = vec3(1, 1, 1);
		for (int i = 1; i < len; ++i) {
			vec2 location = info.xy + direction * i;
			vec4 through = Texel(occluders, location / size);
			number current = 1 - through.a;
			alpha += max(current - last, 0);
			downwards += max(last - current, 0);
			last = current;
			colour2 = current * colour2.rgb + (1 - current) * min(colour2.rgb, through.rgb);
			penetration += downwards;
		}
		vec4 colour3 = vec4(colour2.r, colour2.g, colour2.b, 1);
		if (penetration > penetrationThreshold) {
			alpha = 1;
		}
		colour = colour * (1 - alpha) + colour3 * alpha;
	} else {
		return vec4(0, 0, 0, 0);
	}
	
	return colour * intensity;
}
