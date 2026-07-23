shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, source_color, repeat_disable, filter_nearest;
uniform float glow_strength : hint_range(0.0, 2.0, 0.05) = 0.3;
uniform float glow_radius : hint_range(0.0, 8.0, 0.25) = 1.5;
uniform float glow_threshold : hint_range(0.0, 2.0, 0.05) = 0.65;
uniform float glow_softness : hint_range(0.01, 1.0, 0.05) = 0.2;

vec3 get_bright_color(vec2 uv) {
	vec3 color = texture(screen_texture, clamp(uv, vec2(0.0), vec2(1.0))).rgb;
	float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float amount = smoothstep(glow_threshold - glow_softness, glow_threshold + glow_softness, brightness);
	return color * amount;
}

void fragment() {
	vec2 offset = SCREEN_PIXEL_SIZE * glow_radius;
	vec3 source = texture(screen_texture, SCREEN_UV).rgb;
	vec3 glow = get_bright_color(SCREEN_UV) * 0.4;
	glow += get_bright_color(SCREEN_UV + vec2(offset.x, 0.0)) * 0.15;
	glow += get_bright_color(SCREEN_UV - vec2(offset.x, 0.0)) * 0.15;
	glow += get_bright_color(SCREEN_UV + vec2(0.0, offset.y)) * 0.15;
	glow += get_bright_color(SCREEN_UV - vec2(0.0, offset.y)) * 0.15;
	COLOR = vec4(source + glow * glow_strength, 1.0);
}
