#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform sampler2D noise;
uniform int pointerCount;
uniform vec3 pointers[10];
uniform float time;
uniform float startRandom;

// comstants
const float pi = 3.1415926536;
const float pi2 = 2.0 * pi;

// helpers
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec2 angleToVec(float rad) {
	return vec2(sin(rad), cos(rad));
}
float noise2(vec2 p) {
	p += startRandom;
	const int STEPS = 2;
	float n = 0.0;
	float fTotal = 0.0;
	for (int i = 0; i < STEPS; ++i) {
		float f = pow(0.5, float(i));
		n += (2.0 * texture2D(noise,
			pow(0.33, float(i)) * 5.0 * p + 50.0 * time
			+ angleToVec(pi2 * float(i + 1) * 50.0 * time)
		).r - 1.0) * f;
		fTotal += f;
	}
	return clamp(1.0 * n / fTotal, -1.0, 1.0);
}

void main(void) {
	// misc
	vec2 axy = gl_FragCoord.xy;
	vec2 rxy = resolution.xy;
	float mxy = max(rxy.x, rxy.y);
	vec2 uv = axy / rxy.xy;
	vec2 xy = axy / mxy;
	
	// flow pattern
	const float rows = 7.0;
	const float cols = 7.0;
	const float df = 0.005;
	float col = floor(uv.x * cols + 0.5);
	float row = floor(uv.y * rows + 0.5 + 0.5 * mod(col + 1.0, 2.0));
	float px = cols * uv.x;
	float py = rows * uv.y;
	float pxp = px * 2.0 * pi + pi;
	float pyp = py * 2.0 * pi + pi * float(col);
	float sctpx = sin(pxp);
	float srtpy = sin(pyp);
	float cc = min(abs(sin(0.5 * pxp)), abs(sin(0.5 * pyp)));
	float ccf = clamp(0.97 + 0.1 * pow(1.0 - cc, 10.0), 0.0, 1.0);
	
	// smoothing kernel
	const int ksize = 3;
	const int c = ksize / 2;
	float kernel1d[ksize];
	kernel1d[0] = 0.25;
	kernel1d[1] = 0.5;
	kernel1d[2] = 0.25;
	float kernel2d[ksize * ksize];
	for (int i = 0; i < ksize; i++) {
		for (int j = 0; j < ksize; j++) {
			kernel2d[i * ksize + j] = kernel1d[i] * kernel1d[j];
		}
	}
	
	// color
	float alpha = 0.0;
	for (int i = 0; i < ksize; i++) {
		for (int j = 0; j < ksize; j++) {
			alpha += kernel2d[i * ksize + j] * (1.0 - texture2D(backbuffer,
				uv + df * vec2(sctpx, srtpy) + vec2(i - c, j - c) / rxy.xy
			).a);
		}
	}
	
	// fade to black
	alpha -= 0.002;
	
	// touch
	for (int n = 0; n < pointerCount; ++n) {
		alpha += pow(1.0 - clamp(abs(10.0 * distance(xy, pointers[n].xy / mxy) - 0.5), 0.0, 1.0), 25.0);
	}
	
	// misc
	alpha *= ccf;
	float aa = alpha + 0.1 * noise2(xy) * pow(alpha, 0.5);
	vec3 color = hsv2rgb(vec3(
		0.6 - 0.1 * aa + 0.065 * (col + row * cols) + 0.01 * time,
		1.0 - pow(aa, 3.0),
		pow(aa, 0.3)
	));
	gl_FragColor = vec4(color, 1.0 - alpha);
}
