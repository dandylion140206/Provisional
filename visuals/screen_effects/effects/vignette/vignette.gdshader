shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture
	: hint_screen_texture, source_color, repeat_disable, filter_nearest;

uniform float strength : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float size : hint_range(0.0, 1.0, 0.01) = 0.7;
uniform float aspect_ratio : hint_range(0.25, 4.0, 0.01) = 1.0;
uniform float edge_blur : hint_range(0.0, 1.0, 0.01) = 0.25;


float get_vignette_amount(vec2 uv) {
	vec2 centered_uv = uv - vec2(0.5);
	float ratio = max(aspect_ratio, 0.001);
	float distance_from_center = length(vec2(centered_uv.x * ratio, centered_uv.y));
	float corner_distance = length(vec2(0.5 * ratio, 0.5));
	float normalized_distance = distance_from_center / max(corner_distance, 0.001);

	float edge_start = max(size - edge_blur, 0.0);
	float edge_end = max(size, edge_start + 0.0001);
	float edge_amount = smoothstep(edge_start, edge_end, normalized_distance);

	return clamp(edge_amount * strength, 0.0, 1.0);
}


void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	float vignette_amount = get_vignette_amount(SCREEN_UV);
	COLOR = vec4(screen_color.rgb * (1.0 - vignette_amount), screen_color.a);
}
