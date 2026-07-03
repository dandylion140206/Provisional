class_name BallDamageDealer
extends Node

@export_range(0.0, 10000.0, 1.0) var base_damage: float = 10.0
@export_range(0.0, 100.0, 0.01) var multiplier: float = 0.0
@export_range(0.0, 10000.0, 1.0) var min_damage: float = 0.0
@export_range(0.0, 10000.0, 1.0) var max_damage: float = 100.0

var _get_input_value: Callable


func setup(get_input_value: Callable) -> void:
	_get_input_value = get_input_value


func calculate_damage() -> float:
	var input_value := 0.0

	if _get_input_value.is_valid():
		input_value = _get_input_value.call()

	var raw_damage := base_damage + input_value * multiplier
	return clampf(raw_damage, min_damage, max_damage)
