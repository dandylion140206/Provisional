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
	default_value = parameter_default_value
	min_value = parameter_min_value
	max_value = parameter_max_value
	step = parameter_step
	options = parameter_options
	visibility_parameter = parameter_visibility
	visibility_values = parameter_visibility_values
