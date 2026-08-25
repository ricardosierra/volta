shader_type canvas_item;

uniform sampler2D palette;

void fragment() {
	float owner_val = texture(TEXTURE, UV).r;
	if (owner_val > 0.99) { // 254 or 255
		COLOR = vec4(0.0);
	} else {
		COLOR = texture(palette, vec2(owner_val, 0.5));
	}
}
