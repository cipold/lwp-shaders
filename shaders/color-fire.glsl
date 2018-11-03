#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform float time;
uniform sampler2D noise;
uniform int pointerCount;
uniform vec3 pointers[10];

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void) {
	float mx = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mx;
	float last = texture2D(backbuffer, uv).r;
	float x = 10.0 * (last + 1.0 * (texture2D(noise, uv).r - 0.5)) * 3.1415926536;
	vec3 flow = texture2D(backbuffer, uv + 0.001 * vec2(sin(x), cos(x))).rgb;
	vec3 color = mix(vec3(0.0), flow, 0.98);
	for (int n = 0; n < pointerCount; ++n) {
		vec2 p = pointers[n].xy / mx;
		float dist = distance(xy, p);
		float i = pow(1.0 - min(1.0, max(0.0,
					abs(6.0 * dist - 0.5)
				)), 3.0);
		color += hsv2rgb(vec3(time, 1.0, i)) * 0.2;
	}
	gl_FragColor = vec4(color, 1.0);
}
