shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, source_color, repeat_disable, filter_nearest;
uniform float crt_gamma : hint_range(1.0, 3.0, 0.05) = 1.15;
uniform float black_level : hint_range(0.0, 0.3, 0.01) = 0.0;
uniform float white_level : hint_range(0.1, 2.0, 0.05) = 1.0;
uniform float contrast : hint_range(0.0, 2.0, 0.05) = 1.0;

void fragment() {
	vec3 source = max(texture(screen_texture, SCREEN_UV).rgb, vec3(0.0));
	vec3 contrast_color = (source - vec3(0.5)) * contrast + vec3(0.5);
	vec3 color = pow(max(contrast_color, vec3(0.0)), vec3(crt_gamma));
	COLOR = vec4(color * white_level + vec3(black_level), 1.0);
}
