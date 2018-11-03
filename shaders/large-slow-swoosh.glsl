#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

// input
uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform int pointerCount;
uniform vec3 pointers[10];
uniform float time;

// constants
const float pi = 3.1415;
const float pi2 = 2.0 * pi;

// functions
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float angle(vec2 a, vec2 b) {
	vec2 d = a - b;
	return atan(d.x, d.y);
}
float lim(float mn, float mx, float v) {
	return max(mn, min(mx, v));
}
float sin01(float v) {
	return 0.5 + 0.5 * sin(v);
}

void main(void) {
	// misc
	vec2 axy = gl_FragCoord.xy;
	vec2 rxy = resolution.xy;
	float mxy = max(rxy.x, rxy.y);
	vec2 uv = axy / rxy.xy;
	vec2 xy = axy / mxy;
	
	// touch
	vec3 color = vec3(0.0);
	for (int n = 0; n < pointerCount; ++n) {
		vec2 pxy = pointers[n].xy / mxy;
		const float s = 2.0;
		const float e = 6.0;
		float d = 1.5 * distance(xy, pxy);
		float a = angle(xy, pxy) + 1.7 * float(n);
		float a1 = a - 0.5 * time;
		float a2 = a + s * time;
		color += hsv2rgb(vec3(
			a1 / pi2, 1.0,
			min(1.0, 20.0 * pow(sin01(e * (a2 - 0.04 / d * sin(30.0 * d))), 50.0 * d) *
			pow(sin01(-0.5 * pi + lim(0.0, pi2, 20.0 * d)), 10.0))
		));
	}
	
	// misc
	gl_FragColor = vec4(color, 1.0);
}
