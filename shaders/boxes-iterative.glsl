#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D noise;
uniform float time;
uniform sampler2D backbuffer;
uniform int pointerCount;
uniform vec3 pointers[10];

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void) {
	float mx = max(resolution.x, resolution.y);
	vec2 xy = gl_FragCoord.xy / resolution.xy;
	vec2 uv = gl_FragCoord.xy / mx;
	const int ch = 9;
	const int cv = 16;
	int r = int(xy.x * float(ch));
	int c = int(xy.y * float(cv));
	int levels = 4;
	float rand = 0.0;
	for (int l = 0; l < levels; l++) {
		int scale = int(pow(3.0, float(l)) + 0.5);
		int chl = ch * scale;
		int cvl = cv * scale;
		float rl = float(int(xy.x * float(chl))) / float(chl) * float(scale);
		float cl = float(int(xy.y * float(cvl))) / float(chl) * float(scale);
		rand += texture2D(noise, vec2(
			0.25 + 0.5 * rl + 0.1 * sin(0.01 * time),
			0.25 + 0.5 * cl + 0.1 * cos(0.01 * time)
		)).r / float(l + 1);
	}
	vec3 color = hsv2rgb(vec3(0.5 + 0.08 * rand, 0.9, 0.4));
	for (int n = 0; n < pointerCount; ++n) {
		vec2 p = pointers[n].xy / resolution.xy;
		int pr = int(p.x * float(ch));
		int pc = int(p.y * float(cv));
		if (pr == r && pc == c) {
			color += vec3(1.0) * 0.1;
		}
	}
	gl_FragColor = vec4(color, 1.0);
}
