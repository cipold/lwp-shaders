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
	
	// kernel
	const int ksize = 3;
	const int c = ksize / 2;
	float kernel1d[ksize];
	kernel1d[0] = 0.25;
	kernel1d[1] = 0.5;
	kernel1d[2] = 0.25;
	float kernel2d[ksize * ksize];
	for (int i = 0; i < ksize; i++) {
		for (int j = 0; j < ksize; j++) {
			kernel2d[i * ksize + j] = kernel1d[i]  * kernel1d[j];
		}
	}
	
	// color * kernel
	vec3 color = vec3(0.0);
	for (int i = 0; i < ksize; i++) {
		for (int j = 0; j < ksize; j++) {
			color += kernel2d[i * ksize + j] *
				texture2D(backbuffer,
					uv + vec2(i - c, j - c) / rxy.xy
				).rgb;
		}
	}
	
	// fade
	color *= 0.8;
	color -= vec3(0.01);
	
	// touch
	for (int n = 0; n < pointerCount; ++n) {
		vec2 pxy = pointers[n].xy / mxy;
		float d = 1.5 * distance(xy, pxy);
		float a = angle(xy, pxy) + 4.0 * time + 1.7 * float(n);
		color += hsv2rgb(vec3(
			a / pi2, 1.0,
			pow(sin01(6.0 * (a - 0.04 / d * sin(30.0 * d))), 50.0 * d) *
			pow(sin01(-0.5 * pi + lim(0.0, pi2, 20.0 * d)), 10.0)
		));
	}
	
	// misc
	gl_FragColor = vec4(color, 1.0);
}
