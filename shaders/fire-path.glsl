#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

// inputs
uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform float time;
uniform sampler2D noise;
uniform int pointerCount;
uniform vec3 pointers[10];
uniform float startRandom;
uniform vec3 gravity;
uniform vec3 linear;

// comstants
const float PI = 3.1415;
const float PI2 = 2.0 * PI;

// helper functions
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec2 angleToVec(float rad) {
	return vec2(sin(rad), cos(rad));
}
float vecToAngle(vec2 v) {
	return atan(v.x, v.y);
}
float noise2(vec2 p) {
	return 0.5 + 0.5 * sin(15.0 * p.x) + sin(10.0 * p.y);;
	const int STEPS = 3;
	const float DIV = 1.0 / float(STEPS + 1);
	float n = texture2D(noise, p).r * DIV;
	for (int i = 0; i < STEPS; ++i) {
		n += texture2D(noise, p + 0.0001 * angleToVec(PI2 * float(i) * DIV)).r * DIV;
	}
	return n;
}
float step(float v, float s) {
	return float(int(v / s)) * s;
}
float sin01(float v) {
	return 0.5 + 0.5 * sin(v);
}

void main(void) {
	// misc
	float mxy = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mxy;
	
	// magic
	vec2 p = xy + 0.05 * (vec2(
		noise2(xy + 0.5 * startRandom + 0.003 * time) + noise2(3.0 * xy + 0.005 * time),
		noise2(xy + startRandom + 0.003 * time) + noise2(3.0 * xy)
	) - 0.5);
	float a = PI * pow(
		sin01(8.0 * PI * p.x) +
		sin01(8.0 * PI * p.y),
	2.0);
	float flow = 1.0 - texture2D(backbuffer,
		uv + 0.003 * angleToVec(a)
	).a;
	
	// fade
	flow = mix(flow, 0.0, 0.00) - 0.003;
	flow = max(flow, 0.0);
	
	// touch
	for (int i = 0; i < pointerCount; ++i) {
		float dist = distance(xy, pointers[i].xy / mxy);
		flow += pow(1.0 - min(1.0, max(0.0, 2.0 * dist)), 30.0);
	}
	flow = min(flow, 1.0);
	
	// background
	vec3 color = vec3(0.15);
	
	// visualize flow
	color += hsv2rgb(vec3(0.15 * flow, 1.0, pow(flow, 0.35)));
	
	// height lines
	color += 0.1 * (a > 0.1 && a < 0.15 ? 1.0 : 0.0);
	color += 0.1 * (a > 8.9 && a < 9.2 ? 1.0 : 0.0);
	color += 0.1 * (a > 4.0 && a < 4.3 ? 1.0 : 0.0);
	
	// noise
	color += 0.1 * (texture2D(noise, 10.0 * uv).r - 0.5);
	
	// misc
	gl_FragColor = vec4(color, 1.0 - flow);
}
