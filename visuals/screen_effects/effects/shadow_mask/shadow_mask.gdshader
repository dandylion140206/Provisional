shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture
	: hint_screen_texture, source_color, repeat_disable, filter_nearest;

uniform int mask_type
	: hint_enum("Dot Aligned", "Dot Staggered", "Slot Aligned", "Slot Staggered (Columns)", "Slot Aligned (Rows)") = 1;
uniform float mask_scale : hint_range(1.0, 32.0, 0.25) = 2.0;
uniform float mask_strength : hint_range(0.0, 1.0, 0.05) = 0.5;
uniform float mask_brightness : hint_range(0.0, 3.0, 0.05) = 1.0;

uniform float dot_size : hint_range(0.1, 1.0, 0.05) = 0.75;
uniform float slot_unit_gap_x : hint_range(0.0, 64.0, 0.25) = 0.0;
uniform float slot_unit_gap_y : hint_range(0.0, 64.0, 0.25) = 0.0;

const float SLOT_WIDTH = 0.75;
const float SLOT_HEIGHT = 2.4;
const float SLOT_GAP_X = 0.25;
const float SLOT_GAP_Y = 0.3;
const float SLOT_CORNER_RADIUS = 0.25;
const float SLOT_EDGE_SOFTNESS = 1.0;


vec3 get_phosphor_color(float index) {
	if (index < 0.5) {
		return vec3(1.0, 0.0, 0.0);
	}

	if (index < 1.5) {
		return vec3(0.0, 1.0, 0.0);
	}

	return vec3(0.0, 0.0, 1.0);
}


float get_rgb_index(float column) {
	return mod(mod(column, 3.0) + 3.0, 3.0);
}


vec3 get_dot_mask(vec2 position, float scale) {
	float row = floor(position.y / scale);
	float is_staggered_row = mask_type == 1 && mod(row, 2.0) > 0.5 ? 1.0 : 0.0;
	float row_offset = is_staggered_row * scale * 0.5;
	float column = floor((position.x - row_offset) / scale);
	float color_column = column - is_staggered_row;
	vec2 local_position = vec2(
		mod(position.x - row_offset, scale),
		mod(position.y, scale)
	);
	vec2 centered_position = local_position / scale - vec2(0.5);
	float radius = dot_size * 0.5;
	float is_lit = step(length(centered_position), radius);

	return get_phosphor_color(get_rgb_index(color_column)) * is_lit;
}


float rounded_box_distance(vec2 position, vec2 half_size, float corner_radius) {
	vec2 distance_to_corner = abs(position) - half_size + corner_radius;

	return (
		length(max(distance_to_corner, vec2(0.0)))
		+ min(max(distance_to_corner.x, distance_to_corner.y), 0.0)
		- corner_radius
	);
}


vec3 get_slot_mask(vec2 position, float scale) {
	bool is_horizontal = mask_type == 4;
	float width = (is_horizontal ? SLOT_HEIGHT : SLOT_WIDTH) * scale;
	float height = (is_horizontal ? SLOT_WIDTH : SLOT_HEIGHT) * scale;
	float base_pitch_x = (width / scale + SLOT_GAP_X) * scale;
	float base_pitch_y = (height / scale + SLOT_GAP_Y) * scale;
	float pitch_x = base_pitch_x + (is_horizontal ? slot_unit_gap_x : 0.0);
	float pitch_y = base_pitch_y + (is_horizontal ? 0.0 : slot_unit_gap_y);
	float triad_slot_pitch = is_horizontal ? pitch_y : pitch_x;
	float triad_width = triad_slot_pitch * 3.0;
	float triad_gap = is_horizontal ? slot_unit_gap_y : slot_unit_gap_x;
	float triad_pitch = triad_width + triad_gap;
	float triad_position = is_horizontal ? position.y : position.x;
	float triad = floor(triad_position / triad_pitch);
	float local_triad_position = mod(triad_position, triad_pitch);
	float is_in_triad = 1.0 - step(triad_width, local_triad_position);
	float column = floor(local_triad_position / pitch_x);
	float row = floor(local_triad_position / pitch_y);
	float column_offset = (
		mask_type == 3 && mod(triad, 2.0) > 0.5
		? pitch_y * 0.5
		: 0.0
	);
	float slot_position_x = is_horizontal ? position.x : local_triad_position;
	float slot_position_y = is_horizontal
		? local_triad_position
		: position.y - column_offset;

	vec2 local_position = vec2(
		mod(slot_position_x, pitch_x) - width * 0.5,
		mod(slot_position_y, pitch_y) - height * 0.5
	);
	float corner_radius = min(width, height) * SLOT_CORNER_RADIUS;
	float distance = rounded_box_distance(
		local_position,
		vec2(width, height) * 0.5,
		corner_radius
	);
	float is_lit = (
		1.0 - smoothstep(0.0, SLOT_EDGE_SOFTNESS, distance)
	) * is_in_triad;

	float phosphor_index = is_horizontal ? row : column;

	return get_phosphor_color(get_rgb_index(phosphor_index)) * is_lit;
}


void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	float scale = max(mask_scale, 1.0);
	vec2 pixel_position = floor(FRAGCOORD.xy) + vec2(0.5);
	vec3 mask = mask_type <= 1
		? get_dot_mask(pixel_position, scale)
		: get_slot_mask(pixel_position, scale);
	vec3 masked_color = screen_color.rgb * mask * mask_brightness;

	COLOR = vec4(
		mix(screen_color.rgb, masked_color, mask_strength),
		screen_color.a
	);
}
