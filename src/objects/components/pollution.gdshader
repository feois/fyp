shader_type spatial;
render_mode unshaded; // remove this line if you want the disc to receive lighting

uniform float radius = 1.0;
uniform vec4 color : source_color;
uniform float thickness : hint_range(0.0, 1.0);
uniform vec4 fill : source_color;
uniform sampler2D noise;
uniform float noise_scale = 1.0;

varying vec2 xz;
varying vec2 p;

void vertex() {
	xz = VERTEX.xz;
	p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz / (radius * 2.0) * noise_scale;
}

void fragment() {
	float d = length(xz);
	
	if (d > radius) discard;
	
	float aa = max(fwidth(d), 0.0005); // anti-aliasing width for smoothstep edges
	
	// Base fill + outer edge ring
	float r = max(radius - thickness, 0.0);
	float mask = smoothstep(r - aa, r + aa, d);
	vec4 t = texture(noise, p) * fill;
	vec2 v = xz / radius;
	float a = sqrt(v.x * v.x + v.y * v.y);
	t.a *= 1.0 - a;
	vec4 c = mix(t, color, mask);
	
	ALBEDO = c.rgb;
	ALPHA = c.a;
}
