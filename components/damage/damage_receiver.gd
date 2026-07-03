class_name DamageReceiver
extends Node

signal damage_received(amount: float)

var _health: Health


func setup(health: Health) -> void:
	assert(health != null, "health must not be null.")
	_health = health


func receive_damage(amount: float) -> void:
	assert(_health != null, "health must be setup before receive_damage().")

	if amount <= 0.0:
		return

	_health.damage(amount)
	damage_received.emit(amount)
