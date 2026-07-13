class_name BallBoost
extends Node2D

@export_range(0.0, 5000.0, 10.0) var boost_speed: float = 1700.0
@export_range(0.0, 2.0, 0.01) var cooldown: float = 0.4

var _movement: Movement

@onready var _cooldown_timer: Timer = $CooldownTimer


func setup(movement: Movement) -> void:
	assert(movement != null, "movement must not be null.")

	_movement = movement

	_cooldown_timer.one_shot = true
	_cooldown_timer.wait_time = cooldown


func try_use() -> bool:
	assert(_movement != null, "movement must be setup before try_use().")

	if not _can_use():
		return false

	var velocity := _movement.get_velocity()

	if velocity.is_zero_approx():
		return false

	var boost_velocity := velocity.normalized() * boost_speed

	_movement.add_velocity(boost_velocity)
	_cooldown_timer.start()

	return true


func _can_use() -> bool:
	return _cooldown_timer.is_stopped()
