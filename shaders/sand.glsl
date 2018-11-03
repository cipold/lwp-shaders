#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

// input
uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform float time;
uniform sampler2D noise;
uniform int pointerCount;
uniform vec3 pointers[10];

void main(void) {
	// misc
	float mx = max(resolution.x, resolution.y);
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 xy = gl_FragCoord.xy / mx;
	float hStep = 1.0 / float(resolution.x);
	float vStep = 1.0 / float(resolution.y);
	
	// surrounding
	vec3 last = texture2D(backbuffer, uv).rgb;
	vec3 above = texture2D(backbuffer, uv + vec2(0.0, vStep)).rgb;
	vec3 left = texture2D(backbuffer, uv + vec2(-hStep, 0)).rgb;
	vec3 right = texture2D(backbuffer, uv + vec2(hStep, 0)).rgb;
	vec3 tworight = texture2D(backbuffer, uv + vec2(2.0 * hStep, 0)).rgb;
	vec3 twoleft = texture2D(backbuffer, uv + vec2(2.0 * -hStep, 0)).rgb;
	vec3 abovel = texture2D(backbuffer, uv + vec2(-hStep, vStep)).rgb;
	vec3 abover = texture2D(backbuffer, uv + vec2(hStep, vStep)).rgb;
	vec3 below = texture2D(backbuffer, uv + vec2(0.0, -vStep)).rgb;
	vec3 belowl = texture2D(backbuffer, uv + vec2(-hStep, -vStep)).rgb;
	vec3 belowr = texture2D(backbuffer, uv + vec2(hStep, -vStep)).rgb;
	vec3 below2l = texture2D(backbuffer, uv + vec2(2.0 * -hStep, -vStep)).rgb;
	
	// logic
	vec3 color;
	if (gl_FragCoord.y <= 0.5) {
		color = vec3(1.0);
	} else {
		color = last;
		if (last.r >= 0.5) {
			if (below.r <= 0.5 ||
				belowl.r <= 0.5 && left.r <= 0.5 && (below2l.r <= 0.5 || twoleft.r <= 0.5) ||
				belowr.r <= 0.5 && right.r <= 0.5
				) color = vec3(0.0);
		} else {
			if (above.r >= 0.5) color = above;
			else if (abovel.r >= 0.5 && left.r >= 0.5) color = abovel;
			else if (abover.r >= 0.5 && right.r >= 0.5 && tworight.r >= 0.5) color = abover;
		}
	}
	
	// touch
	for (int n = 0; n < pointerCount; ++n) {
		if (distance(gl_FragCoord.xy, pointers[n].xy) < 10.0) {
			color += vec3(1.0);
		}
	}
	
	// misc
	gl_FragColor = vec4(color, 1.0);
}
