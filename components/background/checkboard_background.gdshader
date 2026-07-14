shader_type canvas_item;

uniform vec4 dark_color : source_color = vec4(
	0.0314,
	0.0314,
	0.0314,
	1.0
);

uniform vec4 light_color : source_color = vec4(
	0.0627,
	0.0627,
	0.0627,
	1.0
);

uniform float cell_size : hint_range(1.0, 512.0, 1.0) = 64.0;

varying vec2 local_position;


void vertex() {
	local_position = VERTEX;
}


void fragment() {
	vec2 cell_position = floor(local_position / cell_size);
	float checker = mod(cell_position.x + cell_position.y, 2.0);

	COLOR = mix(dark_color, light_color, checker);
}
