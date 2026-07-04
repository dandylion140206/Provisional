class_name Hurtbox
extends Area2D

signal hit_received(speed: float)

var _health: Health


func setup(health: Health) -> void:
	assert(health != null, "health must not be null.")
	_health = health


func receive_damage(amount: float) -> void:
	assert(_health != null, "health must be setup before receive_damage().")

	if amount <= 0.0:
		return

	_health.damage(amount)


func notify_hit(speed: float) -> void:
	hit_received.emit(speed)


func set_enabled(enabled: bool) -> void:
	set_deferred("monitoring", enabled)
	set_deferred("monitorable", enabled)
