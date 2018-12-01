extern vec4 info; // translation x, translation y, falloff start, precalculated power.
extern bool blur;

const vec2 size = vec2(1024, 1024);
vec4 effect(vec4 colour, Image texture, vec2 textureCoords, vec2 windowCoords) {
	textureCoords *= size;
	textureCoords -= info.xy;
	number r = length(textureCoords);
	r = max(info[2] * pow(r / info[2], 1 / info[3]), r);
	textureCoords = info.xy + r * normalize(textureCoords);
	vec4 colour2 = Texel(texture, textureCoords / size);
	return colour * colour2;
}
