class_name Hurtbox
extends Area2D

signal hurt(amount: float)


func receive_damage(amount: float) -> void:
	if amount <= 0.0:
		return

	hurt.emit(amount)


func set_enabled(enabled: bool) -> void:
	monitoring = enabled
	monitorable = enabled
