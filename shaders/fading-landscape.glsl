#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform float time;
uniform sampler2D noise;
uniform int pointerCount;
uniform vec3 pointers[10];
uniform float startRandom;

const float pi = 3.14159265359;
const int steps = 4;
const float div = 1.0 / float(steps + 1);

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec2 fromAngle(float rad) {
	return vec2(sin(rad), cos(rad));
}
float toAngle(vec2 v) {
	return atan(v.x, v.y);
}
float toAngle(vec2 a, vec2 b) {
	return toAngle(a - b);
}
float cos01(float v) {
	return 0.5 + 0.5 * cos(v);
}
float noise2(vec2 p) {
	float n = texture2D(noise, p).r * div;
	for (int i = 0; i < steps; ++i) {
		n += texture2D(noise, p + 0.0001 * fromAngle(2.0 * pi * float(i) * div)).r * div;
	}
	return n;
}
vec2 grad(vec2 p, float dx, float dy) {
	return vec2(
		noise2(p + vec2(dx, 0)) - noise2(p - vec2(dx, 0)),
		noise2(p + vec2(0, dy)) - noise2(p - vec2(0, dy))
	);
}

void main(void) {
	float mxy = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mxy;
	const float scale = 0.05;
	const float hSteps = 5.0;
	const float hStep = 1.0 / hSteps;
	vec2 off = scale * xy + startRandom;
	float alpha = texture2D(backbuffer, uv).a;
	if (alpha >= 1.0) alpha = noise2(off);
	float h = alpha;
	h = float(int(h * hSteps + 0.5)) / hSteps;
	h += hStep * pow(mod(h, hStep) / hStep, 100.0);
	vec3 color = vec3(0.1);
	color += 0.05 * (texture2D(noise, 10.0 * uv).rgb - 0.5);
	color += hsv2rgb(vec3(0.45 + 0.1 * h, 0.8 + 0.2 * cos01(10.0 * h * pi), h));
	alpha = mix(alpha, 0.0, 0.05 * pow(texture2D(noise, 100.0 * xy + vec2(sin(100.0 * time), cos(111.0 * time))).r, 5.0));
	for (int n = 0; n < pointerCount; ++n) {
		float dist = distance(xy, pointers[n].xy / mxy);
		alpha += 0.3 * pow(1.0 - min(1.0, max(0.0, 2.0 * dist)), 30.0);
	}
	alpha = min(alpha, 0.99);
	gl_FragColor = vec4(color, alpha);
}
