#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform float time;
uniform int pointerCount;
uniform vec3 pointers[10];
uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform float startRandom;

void main(void) {
	const float pi = 3.1415926536;
	float mx = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / mx;
	vec2 xy = vec2(
		gl_FragCoord.x / resolution.x,
		gl_FragCoord.y / resolution.y
	);
	vec2 c = vec2(0.5, 0.5);
	float s = 0.99;
	vec3 lastBg = texture2D(
		backbuffer,
		(0.5 + 0.4 * vec2(sin(uv.x * 3.0 * pi), cos(uv.y * 3.0 * pi)) - c) * s + c
	).rgb;
	float t = (time + startRandom * 100.0) * 0.02;
	float tm = mod(t, 1.0);
	float p = 1.0 / 4.0;
	float up = mod(tm, p) / p;
	float down = 1.0 - up;
	int i = int(tm / p);
	vec3 bgColor = vec3(
		i == 0 ? up : (i == 1 ? 1.0 : (i == 2 ? down : 0.0)),
		i == 1 ? up : (i == 2 ? 1.0 : (i == 3 ? down : 0.0)),
		i == 2 ? up : (i == 3 ? 1.0 : (i == 0 ? down : 0.0))
	) * 0.4;
	vec3 color = mix(lastBg, bgColor, 0.4);
	color += 0.1 * pow(0.5 + 0.5 * sin(xy.x * 7.0 + time * 0.2 + xy.y * 8.0), 1000.0);
	for (int n = 0; n < pointerCount; ++n) {
		vec2 p = pointers[n].xy / mx;
		float dist = distance(uv, p);
		color += vec3(
			pow(1.0 - min(1.0, max(0.0,
					abs(10.0 * (dist + 0.01 * sin(atan((p - uv).x, (p - uv).y) * 3.0 + 2.0 * time + float(5 * n) )) - 0.7)
				)), 30.0)
			) * 0.1;
	}
	gl_FragColor = vec4(color, 1.0);
}
