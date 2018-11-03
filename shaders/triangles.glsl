#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D noise;
uniform float time;
uniform sampler2D backbuffer;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void) {
	vec2 xy = gl_FragCoord.xy / resolution.xy;
	vec2 uv = gl_FragCoord.xy / max(resolution.x, resolution.y);
	vec2 ab = xy;
	const int ch = 10;
	const int cv = 10;
	int r = int(ab.x * float(ch));
	int c = int(ab.y * float(cv));
	if (mod(ab.y * float(cv), 2.0) < 1.0) {
		if (mod(ab.x * float(ch), 2.0) < 1.0) {
			r += int(mod(ab.x * float(ch) + ab.y * float(cv), 2.0));
		} else {
			r += int(mod(ab.x * float(ch) - ab.y * float(cv), 2.0));
		}
	} else {
		if (mod(ab.x * float(ch), 2.0) < 1.0) {
			r += int(mod(ab.x * float(ch) - ab.y * float(cv), 2.0));
		} else {
			r += int(mod(ab.x * float(ch) + ab.y * float(cv), 2.0));
		}
	}
	float rand = texture2D(noise, vec2(
		0.25 + 0.5 * float(r) / float(ch) + 0.1 * sin(0.01 * time),
		0.25 + 0.5 * float(c) / float(cv) + 0.1 * cos(0.01 * time)
	)).r;
	vec3 color = hsv2rgb(vec3(mod(0.35 + rand, 1.0), 1.0, 0.5));
	color = mix(color, texture2D(backbuffer, mod(xy * 3.0, 1.0)).rgb, 0.6);
	gl_FragColor = vec4(color, 1.0);
}
