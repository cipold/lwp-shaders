#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 resolution;
uniform sampler2D noise;
uniform float time;

void main(void) {
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	int cols = 4;
	int rows = 6;
	float s = 0.01;
	float ts = 0.0002;
	float n1 = texture2D(noise, s * uv + ts * time).x
		+ texture2D(noise, s * uv - ts * time).x;
	float n2 = 0.5 * texture2D(noise, s * uv + 0.5 + ts * time).x
		+ 0.5 * texture2D(noise, s * uv + 0.5 - ts * time).x;
	int col = int((uv.x + uv.y + 0.3 * n1) * float(cols));
	float rcol = float(col) / float(cols);
	int row = int((uv.y - uv.x + 0.3 * n2) * float(rows));
	float rrow = float(row) / float(rows);
	float cs = float(row + col) / float(rows + cols);
	vec3 c = vec3(0.2 * cs, 0.7 * cs + 0.2, 0.5 * cs + 0.4);
	c += 0.1 * vec3(texture2D(noise, 10.0 * uv));
	gl_FragColor = vec4(c, 1.0);
}
