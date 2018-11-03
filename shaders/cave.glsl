#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform sampler2D noise;
uniform float time;
uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform int pointerCount;
uniform float startRandom;

bool ami(float x, float y) {
	vec2 xy = gl_FragCoord.xy;
	return xy.x >= x - 0.5 && xy.x <= x + 0.5 && xy.y >= y - 0.5 && xy.y <= y + 0.5;
}

vec3 cave(vec2 ab) {
	return vec3(0.2 * texture2D(noise, ab * 1.5 + vec2(0.2 * time, 0.0)).r);
}

vec3 wall(vec2 ab, float dist) {
	return vec3(0.004 / dist, dist, 0.4) * (0.7 + 0.3 * texture2D(noise, ab * 0.5 + vec2(0.14 * time, 0.0)).r);
}

vec3 player(vec2 ab) {
	return vec3(1.0, 1.0, 0.0);
}

vec2 level(float x) {
	float ls = 0.02 * (1.0 + 0.005 * time);
	float p = mod(x * 0.025 + time * ls, 3.1415);
	float lv = texture2D(noise, vec2(0.5) + 0.5 * vec2(sin(p), cos(p)) + vec2(startRandom)).r * 0.3;
	float d = 0.25 - 0.001 * time;
	return vec2(0.6 - d / 2. + lv, 0.6 + d / 2. + lv);
}

void main(void) {
	bool touched = pointerCount > 0;

	// pixel
	vec2 xy = gl_FragCoord.xy;
	vec2 dr = 1. / resolution.xy;
	float mxy = max(resolution.x, resolution.y);
	float ar = resolution.y / resolution.x;
	vec2 uv = xy * dr;
	vec2 ab = xy / mxy;

	// color
	vec3 color = texture2D(backbuffer, uv).rgb;
	float alpha = texture2D(backbuffer, uv).a;

	// player
	float hpos = 0.1;
	float vpos = texture2D(backbuffer, vec2(0., 0.) * dr).a;
	float psize = 0.01;

	// level
	vec2 lv = level(uv.x);
	vec2 pv = level(hpos * ar);

	if (vpos < pv.x || vpos > pv.y) {
		// game over
		if (texture2D(backbuffer, vec2(0., 0.) * dr).b > 0.03) {
			color = vec3(1., 0., 0.);
			alpha = 0.;
		} else {
			color -= 0.01;
		}

		if (color.r < 0.1 && touched) {
			// reset
			if (ami(0., 0.)) {
				alpha = 0.6 + (pv.x + pv.y) * dr.y * 0.5;
			}
		}
	} else {
		// draw player and level
		if (distance(ab, vec2(hpos, vpos)) < psize) {
			color = player(ab);
		} else {
			color = uv.y < lv.x || uv.y > lv.y ? wall(ab, min(abs(uv.y - lv.x), abs(uv.y - lv.y))) : cave(ab);
		}

		// control
		float speed = (touched ? 0.003 : - 0.003);
		if (ami(0., 0.)) {
			alpha += speed;
		}
	}

	gl_FragColor = vec4(color, alpha);
}
