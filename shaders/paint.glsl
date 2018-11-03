#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform sampler2D backbuffer;
uniform int pointerCount;
uniform vec3 pointers[10];
uniform vec2 resolution;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// paint
void main(void) {
	float selTop = 0.15;
	float selBot = 0.1;
	float mxy = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mxy;
	vec3 color = texture2D(backbuffer, uv).rgb;
	if (uv.y < selTop) {
		// color selector
		if (uv.y > selBot) {
			color = hsv2rgb(vec3(uv.x, 1.0, 1.0));
		} else {
			for (int n = 0; n < pointerCount; ++n) {
				vec2 p = pointers[n].xy / resolution.xy;
				if (p.y < selTop && p.y > selBot) {
					color = hsv2rgb(vec3(p.x, 1.0, 1.0));
				}
			}
		}
	} else {
		// paint
		for (int n = 0; n < pointerCount; ++n) {
			vec2 p = pointers[n].xy / mxy;
			float radius = 0.03;
			float dist = distance(xy, p);
			float i = 1.0 - min(1.0, max(0.0, abs(dist / radius)));
			color += i * texture2D(backbuffer, vec2(0)).rgb;
		}
	}
	gl_FragColor = vec4(color, 1.0);
}
