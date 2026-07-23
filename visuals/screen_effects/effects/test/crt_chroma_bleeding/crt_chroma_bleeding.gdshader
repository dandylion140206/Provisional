shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, source_color, repeat_disable, filter_nearest;
uniform float chroma_bleed : hint_range(0.0, 1.0, 0.05) = 0.35;
uniform float chroma_bandwidth : hint_range(0.0, 1.0, 0.05) = 0.6;
uniform float chroma_delay : hint_range(-8.0, 8.0, 0.25) = 0.5;
uniform float chroma_saturation : hint_range(0.0, 2.0, 0.05) = 1.0;

vec3 rgb_to_yiq(vec3 color) {
	return vec3(
		dot(color, vec3(0.299, 0.587, 0.114)),
		dot(color, vec3(0.596, -0.274, -0.322)),
		dot(color, vec3(0.211, -0.523, 0.312))
	);
}

vec3 yiq_to_rgb(vec3 color) {
	return vec3(
		color.x + 0.956 * color.y + 0.621 * color.z,
		color.x - 0.272 * color.y - 0.647 * color.z,
		color.x - 1.106 * color.y + 1.703 * color.z
	);
}

void fragment() {
	vec3 source = texture(screen_texture, SCREEN_UV).rgb;
	float radius = mix(4.0, 0.5, chroma_bandwidth);
	vec2 offset = vec2(radius, 0.0) * SCREEN_PIXEL_SIZE;
	vec3 chroma = (
		rgb_to_yiq(texture(screen_texture, clamp(SCREEN_UV - offset, vec2(0.0), vec2(1.0))).rgb)
		+ rgb_to_yiq(source) * 2.0
		+ rgb_to_yiq(texture(screen_texture, clamp(SCREEN_UV + offset, vec2(0.0), vec2(1.0))).rgb)
	) * 0.25;
	vec3 delayed = rgb_to_yiq(texture(
		screen_texture,
		clamp(SCREEN_UV + vec2(chroma_delay, 0.0) * SCREEN_PIXEL_SIZE, vec2(0.0), vec2(1.0))
	).rgb);
	chroma.yz = mix(delayed.yz, chroma.yz, chroma_bleed) * chroma_saturation;
	chroma.x = source.r * 0.299 + source.g * 0.587 + source.b * 0.114;
	COLOR = vec4(max(yiq_to_rgb(chroma), vec3(0.0)), 1.0);
}
