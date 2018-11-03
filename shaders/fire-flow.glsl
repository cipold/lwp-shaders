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
	const int STEPS = 3;
	const float DIV = 1.0 / float(STEPS + 1);
	float n = texture2D(noise, p).r * DIV;
	for (int i = 0; i < STEPS; ++i) {
		n += texture2D(noise, p + 0.0001 * angleToVec(PI2 * float(i) * DIV)).r * DIV;
	}
	return n;
}

void main(void) {
	// misc
	float mxy = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mxy;
	
	// landscape
	float n = noise2(0.05 * xy + 0.0001 * time + startRandom);
	
	// flow from last value along landscape
	float flow = 1.0 - texture2D(backbuffer,
		uv + 0.004 * angleToVec(n * 4.0 * PI2 + vecToAngle(gravity.xy))
	).a;
	
	// fade
	flow = mix(flow, 0.0, 0.02) - 0.002;
	flow = max(flow, 0.0);
	
	// touch
	for (int n = 0; n < pointerCount; ++n) {
		float dist = distance(xy, pointers[n].xy / mxy);
		flow += pow(1.0 - min(1.0, max(0.0, 2.0 * dist)), 30.0);
	}
	
	// glow
	flow = min(flow, 1.0);
	
	// background
	vec3 color = vec3(0.15);
	
	// visualize flow
	color += hsv2rgb(vec3(0.15 * flow, 1.0, pow(flow, 0.35)));
	
	// height lines
	color += n > 0.4 && n < 0.5 ? 0.05 : 0.0;
	color += n > 0.1 && n < 0.17 ? 0.05 : 0.0;
	
	// noise
	color += 0.1 * (texture2D(noise, 10.0 * uv).r - 0.5);
	
	// misc
	gl_FragColor = vec4(color, 1.0 - flow);
}
