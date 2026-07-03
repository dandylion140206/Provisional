class_name DamageDealer
extends Node

@export_range(0.0, 10000.0, 1.0) var base_damage: float = 10.0
@export_range(0.0, 100.0, 0.01) var multiplier: float = 0.0
@export_range(0.0, 10000.0, 1.0) var min_damage: float = 0.0
@export_range(0.0, 10000.0, 1.0) var max_damage: float = 100.0


func calculate_damage(input_value: float = 0.0) -> float:
	var raw_damage := base_damage + input_value * multiplier
	return clampf(raw_damage, min_damage, max_damage)
