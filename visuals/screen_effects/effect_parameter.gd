class_name EffectParameter
extends RefCounted

enum Kind {
	INTEGER,
	FLOAT,
	BOOLEAN,
	ENUM,
}

var id: StringName
var display_name: String
var kind: Kind
var default_value: Variant
var min_value: float
var max_value: float
var step: float
var options: Array
var visibility_parameter: StringName
var visibility_values: Array


func _init(
	parameter_id: StringName = &"",
	parameter_display_name: String = "",
	parameter_kind: Kind = Kind.FLOAT,
	parameter_default_value: Variant = 0.0,
	parameter_min_value: float = 0.0,
	parameter_max_value: float = 1.0,
	parameter_step: float = 0.01,
	parameter_options: Array = [],
	parameter_visibility: StringName = &"",
	parameter_visibility_values: Array = [],
) -> void:
	id = parameter_id
	display_name = parameter_display_name
	kind = parameter_kind
	min_value = parameter_min_value
	max_value = parameter_max_value
	step = parameter_step
	options = parameter_options.duplicate()
	visibility_parameter = parameter_visibility
	visibility_values = parameter_visibility_values.duplicate()

	default_value = normalize_value(parameter_default_value)


func is_numeric() -> bool:
	return kind == Kind.INTEGER or kind == Kind.FLOAT


func is_visible_for(value: Variant) -> bool:
	if visibility_parameter == &"":
		return true

	return visibility_values.has(value)


func normalize_value(value: Variant) -> Variant:
	match kind:
		Kind.INTEGER:
			return clampi(
				roundi(float(value)),
				ceili(min_value),
				floori(max_value),
			)

		Kind.FLOAT:
			return clampf(float(value), min_value, max_value)

		Kind.BOOLEAN:
			return bool(value)

		Kind.ENUM:
			if options.is_empty():
				return -1

			return clampi(int(value), 0, options.size() - 1)

	return value
