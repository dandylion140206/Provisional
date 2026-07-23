shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, source_color, repeat_disable, filter_nearest;
uniform bool curvature_enabled = true;
uniform float curvature : hint_range(0.0, 0.5, 0.01) = 0.12;
uniform float curvature_x : hint_range(0.0, 0.5, 0.01) = 0.08;
uniform float curvature_y : hint_range(0.0, 0.5, 0.01) = 0.06;
uniform float overscan : hint_range(0.0, 0.3, 0.01) = 0.08;
uniform bool scanlines_enabled = true;
uniform int scanline_count : hint_range(120, 1080, 1) = 480;
uniform float scanline_strength : hint_range(0.0, 1.0, 0.05) = 0.45;
uniform float scanline_sharpness : hint_range(0.1, 8.0, 0.1) = 2.5;
uniform float scanline_offset : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform bool beam_enabled = true;
uniform float beam_min_width : hint_range(0.05, 0.5, 0.01) = 0.2;
uniform float beam_max_width : hint_range(0.05, 0.5, 0.01) = 0.42;
uniform float beam_response : hint_range(0.1, 4.0, 0.05) = 1.2;
uniform float beam_intensity : hint_range(0.0, 2.0, 0.05) = 1.05;
uniform bool mask_enabled = true;
uniform int mask_type : hint_enum("Aperture Grille", "Shadow Mask", "Slot Mask") = 0;
uniform float mask_strength : hint_range(0.0, 1.0, 0.05) = 0.5;
uniform float mask_scale : hint_range(1.0, 16.0, 0.25) = 2.0;
uniform float mask_brightness : hint_range(0.0, 3.0, 0.05) = 1.25;

vec2 get_crt_uv(vec2 uv) {
	if (!curvature_enabled) return uv;
	vec2 point = uv * 2.0 - 1.0;
	point.x *= 1.0 + curvature_x * point.y * point.y;
	point.y *= 1.0 + curvature_y * point.x * point.x;
	point *= 1.0 + curvature * dot(point, point);
	return point * (1.0 + overscan) * 0.5 + 0.5;
}

vec3 phosphor_color(float index) {
	float color_index = mod(index, 3.0);
	if (color_index < 0.5) return vec3(1.0, 0.0, 0.0);
	if (color_index < 1.5) return vec3(0.0, 1.0, 0.0);
	return vec3(0.0, 0.0, 1.0);
}

vec3 get_mask(vec2 position) {
	float column = floor(position.x / mask_scale);
	if (mask_type == 0) return phosphor_color(column);
	float row = floor(position.y / mask_scale);
	vec2 local_position = fract(position / mask_scale) - 0.5;
	if (mask_type == 1) {
		float stagger = mod(row, 2.0) * 0.5;
		column = floor(position.x / mask_scale - stagger);
		local_position.x = fract(position.x / mask_scale - stagger) - 0.5;
		return phosphor_color(column) * step(length(local_position), 0.38);
	}
	float slot = step(abs(local_position.x), 0.32) * step(abs(local_position.y), 0.46);
	return phosphor_color(column) * slot;
}

void fragment() {
	vec2 crt_uv = get_crt_uv(SCREEN_UV);
	bool is_outside_screen = (
		any(lessThan(crt_uv, vec2(0.0)))
		|| any(greaterThan(crt_uv, vec2(1.0)))
	);

	if (is_outside_screen) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		vec3 color = texture(screen_texture, crt_uv).rgb;
		float phase = fract(crt_uv.y * float(scanline_count) + scanline_offset);
		float distance_from_beam = abs(phase - 0.5);
	float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float beam_width = beam_enabled
		? mix(beam_min_width, beam_max_width, pow(luminance, beam_response))
		: 0.42;
		float beam_profile = 1.0 - smoothstep(beam_width, 0.5, distance_from_beam);

		if (scanlines_enabled) color *= mix(1.0, beam_profile, scanline_strength);
		if (beam_enabled) color *= mix(1.0, beam_profile * beam_intensity, 0.35);
		if (mask_enabled) {
			vec3 mask = get_mask(floor(crt_uv / SCREEN_PIXEL_SIZE));
			color *= mix(vec3(1.0), mask * mask_brightness, mask_strength);
		}

		COLOR = vec4(color, 1.0);
	}
}
