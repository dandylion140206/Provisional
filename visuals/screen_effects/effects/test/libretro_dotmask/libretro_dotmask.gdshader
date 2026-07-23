shader_type canvas_item;
render_mode unshaded;

// Port of Libretro's dotmask.glsl by cgwg and Timothy Lottes.
uniform sampler2D screen_texture
	: hint_screen_texture, repeat_disable, filter_nearest;

uniform int mask_style : hint_enum(
	"CGWG Dot Mask",
	"Compressed TV Shadow Mask",
	"Aperture Grille",
	"Stretched VGA Shadow Mask",
	"VGA Shadow Mask"
) = 3;
uniform bool bgr_subpixels = false;
uniform float dotmask_strength : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float mask_dark : hint_range(0.0, 2.0, 0.1) = 0.5;
uniform float mask_light : hint_range(0.0, 2.0, 0.1) = 1.5;
uniform float mask_intensity : hint_range(0.0, 2.0, 0.01) = 1.5;


vec3 get_shadow_mask(vec2 position) {
	vec3 mask = vec3(mask_dark);

	if (mask_style == 1) {
		float line = mask_light;
		float odd = fract(position.x / 6.0) < 0.5 ? 1.0 : 0.0;
		if (fract((position.y + odd) / 2.0) < 0.5) {
			line = mask_dark;
		}

		position.x = fract(position.x / 3.0);
		if (position.x < 0.3333) {
			mask = bgr_subpixels
				? vec3(mask.r, mask.g, mask_light)
				: vec3(mask_light, mask.g, mask.b);
		} else if (position.x < 0.6666) {
			mask.g = mask_light;
		} else {
			mask = bgr_subpixels
				? vec3(mask_light, mask.g, mask.b)
				: vec3(mask.r, mask.g, mask_light);
		}

		return mask * line;
	}

	if (mask_style == 2) {
		position.x = fract(position.x / 3.0);
		if (position.x < 0.3333) {
			return bgr_subpixels
				? vec3(mask.r, mask.g, mask_light)
				: vec3(mask_light, mask.g, mask.b);
		}
		if (position.x < 0.6666) {
			mask.g = mask_light;
			return mask;
		}
		return bgr_subpixels
			? vec3(mask_light, mask.g, mask.b)
			: vec3(mask.r, mask.g, mask_light);
	}

	if (mask_style == 3) {
		position.x = fract((position.x + position.y * 3.0) / 6.0);
	} else if (mask_style == 4) {
		position = floor(position * vec2(1.0, 0.5));
		position.x = fract((position.x + position.y * 3.0) / 6.0);
	} else {
		return mask;
	}

	if (position.x < 0.3333) {
		return bgr_subpixels
			? vec3(mask.r, mask.g, mask_light)
			: vec3(mask_light, mask.g, mask.b);
	}
	if (position.x < 0.6666) {
		mask.g = mask_light;
		return mask;
	}
	return bgr_subpixels
		? vec3(mask_light, mask.g, mask.b)
		: vec3(mask.r, mask.g, mask_light);
}


vec3 apply_mask_intensity(vec3 mask) {
	return max(
		vec3(0.0),
		vec3(1.0) + (mask - vec3(1.0)) * mask_intensity
	);
}


void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	vec3 mask;

	if (mask_style == 0) {
		float dark = 1.0 - dotmask_strength;
		vec3 even_weights = vec3(1.0, dark, 1.0);
		vec3 odd_weights = vec3(dark, 1.0, dark);
		float column = floor(mod(FRAGCOORD.x, 2.0));
		mask = mix(even_weights, odd_weights, column);
	} else {
		vec2 mask_position = floor(1.000001 * FRAGCOORD.xy + vec2(0.5));
		mask = get_shadow_mask(mask_position);
	}
	color *= apply_mask_intensity(mask);

	COLOR = vec4(max(color, vec3(0.0)), 1.0);
}
