shader_type canvas_item;

uniform sampler2D palette;
uniform float time : hint_range(0.0, 1000.0);

void fragment() {
	float owner_val = texture(TEXTURE, UV).r;
	if (owner_val > 0.99) { // 254 or 255
		COLOR = vec4(0.0);
	} else {
		vec4 base_color = texture(palette, vec2(owner_val, 0.5));
		// Add subtle geometric pulse
		float pulse = (sin(time * 2.0 + UV.x * 20.0) * 0.1) + 0.9;
		COLOR = vec4(base_color.rgb * pulse, 0.5); // translucent interior
	}
}
