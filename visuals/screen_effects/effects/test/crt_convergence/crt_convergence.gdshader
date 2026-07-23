shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, source_color, repeat_disable, filter_nearest;
uniform float convergence_strength : hint_range(0.0, 8.0, 0.25) = 0.75;
uniform float horizontal_error : hint_range(-1.0, 1.0, 0.05) = 1.0;
uniform float vertical_error : hint_range(-1.0, 1.0, 0.05) = 0.15;
uniform float edge_increase : hint_range(0.0, 4.0, 0.05) = 1.5;

void fragment() {
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	float edge_factor = pow(length(centered_uv) / 1.414214, edge_increase);
	vec2 offset = vec2(horizontal_error, vertical_error) * convergence_strength * edge_factor * SCREEN_PIXEL_SIZE;
	vec3 color = vec3(
		texture(screen_texture, clamp(SCREEN_UV + offset, vec2(0.0), vec2(1.0))).r,
		texture(screen_texture, SCREEN_UV).g,
		texture(screen_texture, clamp(SCREEN_UV - offset, vec2(0.0), vec2(1.0))).b
	);
	COLOR = vec4(color, 1.0);
}
