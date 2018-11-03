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

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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
			color += kernel2d[i * ksize + j] * texture2D(backbuffer, uv + vec2(i - c, j - c) / rxy.xy).rgb;
		}
	}
	
	// fade
	color *= 0.99;
	color -= vec3(0.001);
	
	// touch
	for (int n = 0; n < pointerCount; ++n) {
		float dist = distance(xy, pointers[n].xy / mxy);
		float i = pow(1.0 - min(1.0, max(0.0, abs(10.0 * dist - 0.7))), 30.0);
		color += vec3(hsv2rgb(vec3(mod(0.2 * time + 0.3 * float(n), 1.0), 1.0, i))) * 1.0;
	}
	
	// misc
	gl_FragColor = vec4(color, 1.0);
}
