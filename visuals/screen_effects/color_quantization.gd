class_name ColorQuantizationEffect
extends CanvasLayer

enum QuantizationMode {
	RGB_UNIFORM,
	RGB_PER_CHANNEL,
}

enum ColorSpace {
	SRGB,
	LINEAR,
}

enum DitherMode {
	BAYER_2X2,
	BAYER_4X4,
	BAYER_8X8,
	IGN,
}

@onready var effect_rect: ColorRect = $EffectRect

var model := EffectModel.new("色量子化")
var _material: ShaderMaterial


func _ready() -> void:
	_material = effect_rect.material as ShaderMaterial

	_add_quantization_parameters()
	_add_dither_parameters()

	model.parameter_changed.connect(_on_parameter_changed)
	model.enabled_changed.connect(_on_enabled_changed)
	_apply_initial_values()


func get_effect_model() -> EffectModel:
	return model


func _add_quantization_parameters() -> void:
	model.add_parameter(
		EffectParameter.new(
			&"quantization_mode",
			"量子化モード",
			EffectParameter.Kind.ENUM,
			QuantizationMode.RGB_UNIFORM,
			0.0,
			1.0,
			1.0,
			["RGB共通", "RGB個別"],
		)
	)

	model.add_parameter(
		EffectParameter.new(
			&"color_space",
			"色空間",
			EffectParameter.Kind.ENUM,
			ColorSpace.SRGB,
			0.0,
			1.0,
			1.0,
			["sRGB", "Linear"],
		)
	)

	model.add_parameter(
		EffectParameter.new(
			&"color_levels",
			"色段階",
			EffectParameter.Kind.INTEGER,
			8,
			2,
			32,
			1,
			[],
			&"quantization_mode",
			[QuantizationMode.RGB_UNIFORM],
		)
	)

	for data in [
		[&"red_levels", "R段階"],
		[&"green_levels", "G段階"],
		[&"blue_levels", "B段階"],
	]:
		model.add_parameter(
			EffectParameter.new(
				data[0],
				data[1],
				EffectParameter.Kind.INTEGER,
				8,
				2,
				32,
				1,
				[],
				&"quantization_mode",
				[QuantizationMode.RGB_PER_CHANNEL],
			)
		)


func _add_dither_parameters() -> void:
	model.add_parameter(
		EffectParameter.new(
			&"dither_enabled",
			"ディザリング",
			EffectParameter.Kind.BOOLEAN,
			true,
		)
	)

	model.add_parameter(
		EffectParameter.new(
			&"dither_mode",
			"方式",
			EffectParameter.Kind.ENUM,
			DitherMode.BAYER_4X4,
			0.0,
			3.0,
			1.0,
			["Bayer 2×2", "Bayer 4×4", "Bayer 8×8", "IGN"],
			&"dither_enabled",
			[true],
		)
	)

	model.add_parameter(
		EffectParameter.new(
			&"dither_strength",
			"ディザー強度",
			EffectParameter.Kind.FLOAT,
			1.0,
			0.0,
			1.0,
			0.05,
			[],
			&"dither_enabled",
			[true],
		)
	)

	model.add_parameter(
		EffectParameter.new(
			&"dither_scale",
			"パターンスケール",
			EffectParameter.Kind.INTEGER,
			1,
			1,
			8,
			1,
			[],
			&"dither_enabled",
			[true],
		)
	)


func _apply_initial_values() -> void:
	for parameter in model.parameters:
		_on_parameter_changed(parameter.id, model.get_value(parameter.id))


func _on_parameter_changed(id: StringName, value: Variant) -> void:
	_material.set_shader_parameter(id, value)


func _on_enabled_changed(enabled: bool) -> void:
	effect_rect.visible = enabled
