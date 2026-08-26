shader_type canvas_item;

uniform vec4 bg_color : source_color = vec4(0.04, 0.04, 0.05, 1.0);
uniform vec4 grid_color : source_color = vec4(0.1, 0.1, 0.12, 1.0);
uniform float time;

void fragment() {
	// Subtle grid
	vec2 grid_uv = fract(UV * 50.0);
	float grid_line = step(0.98, grid_uv.x) + step(0.98, grid_uv.y);
	grid_line = clamp(grid_line, 0.0, 1.0);
	
	// Vignette
	float dist = distance(UV, vec2(0.5));
	float vignette = smoothstep(0.8, 0.2, dist);
	
	vec4 final_color = mix(bg_color, grid_color, grid_line * 0.5);
	COLOR = final_color * vignette;
}
