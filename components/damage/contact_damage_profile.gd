class_name ContactDamageProfile
extends Resource

@export_range(0.0, 100.0, 1.0) var base_damage: float = 1.0
@export_range(0.0, 10.0, 0.1) var damage_add_per_100_speed: float = 1.2
@export_range(0.0, 1000.0, 1.0) var min_damage: float = 0.0
@export_range(0.0, 1000.0, 1.0) var max_damage: float = 100.0


func calculate_damage(speed: float) -> float:
	var damage_add_per_speed := damage_add_per_100_speed / 100.0
	var damage_amount := base_damage + speed * damage_add_per_speed

	return clampf(damage_amount, min_damage, max_damage)
