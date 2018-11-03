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
	vec3 color = vec3(0.5);
	float last = texture2D(backbuffer, uv + 0.01 * (texture2D(noise, uv).rg - 0.5)).r;
	float x = last * 2000.0 * 3.1415;
	vec3 flow = texture2D(backbuffer, uv + 0.002 * vec2(sin(x), cos(x))).rgb;
	color = mix(flow, texture2D(noise, uv).rgb, 0.01);
	for (int n = 0; n < pointerCount; ++n) {
		float dist = distance(xy, pointers[n].xy / mx);
		color += vec3(pow(1.0 - min(1.0, max(0.0, abs(10.0 * dist - 0.7))), 30.0)) * 1.0;
	}
	gl_FragColor = vec4(color, 1.0);
}
