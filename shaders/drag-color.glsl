#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform sampler2D backbuffer;
uniform int pointerCount;
uniform vec3 pointers[10];
uniform vec2 resolution;

void main(void) {
	float mxy = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mxy;
	vec4 last = texture2D(backbuffer, uv);
	vec3 color = vec3(last.a, last.r, last.g);
	float alpha = last.b * 0.5;
	for (int n = 0; n < pointerCount; ++n) {
		float radius = 0.1;
		float dist = distance(xy, pointers[n].xy / mxy);
		float i = 1.0 - min(1.0, max(0.0, abs(dist / radius)));
		alpha += i * 1.0;
	}
	gl_FragColor = vec4(color, alpha);
}
