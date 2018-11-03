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

void main(void) {
	float mx = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mx;
	vec3 color = vec3(0.3, 0.0, 0.0);
	float last = texture2D(backbuffer, uv).r;
	float x = 10.0 * (last + 1.0 * (texture2D(noise, uv).r - 0.5)) * 3.1415926536;
	vec3 flow = texture2D(backbuffer, uv + 0.001 * vec2(sin(x), cos(x))).rgb;
	color = mix(color, flow, 0.99);
	for (int n = 0; n < pointerCount; ++n) {
		vec2 p = pointers[n].xy / mx;
		float dist = distance(xy, p);
		float i = pow(1.0 - min(1.0, max(0.0,
					abs(5.0 * dist)
				)), 10.0);
		color += vec3(i, i, 0.0) * 0.5;
	}
	gl_FragColor = vec4(color, 1.0);
}
