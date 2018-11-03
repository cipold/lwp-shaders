#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform int pointerCount;
uniform vec3 pointers[10];
uniform float time;
const float pi = 3.1415;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float angle(vec2 a, vec2 b) {
	vec2 d = a - b;
	return atan(d.x, d.y);
}

void main(void) {
	// misc
	vec2 axy = gl_FragCoord.xy;
	vec2 rxy = resolution.xy;
	float mxy = max(rxy.x, rxy.y);
	vec2 uv = axy / rxy.xy;
	vec2 xy = axy / mxy;
	
	// kernel
	const int ksize = 5;
	const int c = ksize / 2;
	float kernel1d[ksize];
	kernel1d[0] = 0.5;
	kernel1d[1] = 0.0;
	kernel1d[2] = 0.0;
	kernel1d[3] = 0.0;
	kernel1d[4] = 0.5;
	float kernel2d[ksize * ksize];
	for (int i = 0; i < ksize; i++) {
		for (int j = 0; j < ksize; j++) {
			kernel2d[i * ksize + j] = kernel1d[i]  * kernel1d[j];
		}
	}
	
	// color
	vec3 color = vec3(0.0);
	
	// touch
	for (int n = 0; n < pointerCount; ++n) {
		float dist = distance(xy, pointers[n].xy / mxy);
		float i = pow(1.0 - min(1.0, max(0.0, abs(30.0 * dist - 2.0))), 3.0);
		float a = angle(xy, pointers[n].xy / mxy);
		color += hsv2rgb(vec3(a / (2.0 * pi), 1.0, pow(0.5 + 0.5 * sin(6.0 * (a + pi / 12.0 + time - sin(dist))), 20.0)));
	}
	
	// misc
	gl_FragColor = vec4(color, 1.0);
}
