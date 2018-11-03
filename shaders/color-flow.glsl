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

const float pi = 3.1415;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec2 angle(float rad) {
	return vec2(sin(rad), cos(rad));
}

void main(void) {
	float mxy = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mxy;
	vec2 direction = angle(texture2D(noise, 0.07 * xy + 0.001 * time).r * 8.0 * pi);
	vec3 flow = texture2D(backbuffer, uv + 0.005 * direction).rgb;
	vec3 color = mix(flow, vec3(0.0), 0.01) - 0.01;
	for (int n = 0; n < pointerCount; ++n) {
		float dist = distance(xy, pointers[n].xy / mxy);
		float i = pow(1.0 - min(1.0, max(0.0, abs(30.0 * dist - 2.0))), 3.0);
		color += vec3(hsv2rgb(vec3(mod(0.2 * time + 0.3 * float(n), 1.0), 1.0, i))) * 1.0;
	}
	gl_FragColor = vec4(color, 1.0);
}
