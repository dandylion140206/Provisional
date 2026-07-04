class_name ContactDamage
extends Node

@export_range(0.0, 10000.0, 1.0) var base_damage: float = 1.0
@export_range(0.0, 0.05, 0.0001) var multiplier: float = 0.0
@export_range(0.0, 10000.0, 1.0) var min_damage: float = 0.0
@export_range(0.0, 10000.0, 1.0) var max_damage: float = 100.0

var _get_speed: Callable


func setup(get_speed: Callable = Callable()) -> void:
	_get_speed = get_speed


func calculate_damage(speed: float) -> float:
	var damage_amount := base_damage + speed * multiplier
	return clampf(damage_amount, min_damage, max_damage)


func _on_hit_detected(hurtbox: Hurtbox) -> void:
	if hurtbox == null:
		return

	var speed := _get_speed_value()
	var damage_amount := calculate_damage(speed)

	hurtbox.receive_damage(damage_amount)


func _get_speed_value() -> float:
	assert(_get_speed.is_valid(), "get_speed must be setup.")
	return _get_speed.call()
