#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform float time;
uniform sampler2D noise;

void main(void) {
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / max(resolution.x, resolution.y);
	vec3 color = texture2D(
			noise,
			xy - vec2(sin(time * 0.1), cos(time * 0.1))
		).rgb;
	float last = texture2D(backbuffer, uv).r;
	vec3 flow = texture2D(backbuffer, uv + 0.002 * vec2(sin(last * 3.131), cos(last * 3.141))).rgb;
	color = mix(color, flow, 0.9);
	gl_FragColor = vec4(color, 1.0);
}
