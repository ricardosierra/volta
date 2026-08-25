shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	// Additive blending will drop the black in the godot material setting.
	// We just tint the white/gray parts of the raw JPG asset.
	
	float luma = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = tint_color * luma;
	COLOR.a = tex_color.a;
}
