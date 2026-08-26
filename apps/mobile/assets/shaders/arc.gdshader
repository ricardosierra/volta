shader_type canvas_item;

uniform vec4 arc_color : source_color;
uniform float overload_ratio : hint_range(0.0, 1.0) = 0.0;
uniform float time;

void fragment() {
	// Basic line shader that flashes when overload is high
	vec4 base = arc_color;
	
	if (overload_ratio > 0.8) {
		float flash = (sin(time * 20.0) * 0.5) + 0.5;
		base.rgb = mix(base.rgb, vec3(1.0, 0.5, 0.0), flash); // Amber warning
	}
	
	COLOR = base;
}
