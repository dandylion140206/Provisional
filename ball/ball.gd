class_name Ball
extends Node2D

signal boosted

@export var seek_steering: SeekSteering
@export var hit_stop_profile: HitStopProfile

var _target_position := Vector2.ZERO

@onready var hitbox: Hitbox = %Hitbox
@onready var movement: Movement = %Movement
@onready var hit_stop: HitStop = %HitStop
@onready var contact_damage: ContactDamage = %ContactDamage
@onready var boost: BallBoost = %BallBoost
@onready var interpolated_position_tracker: InterpolatedPositionTracker = %InterpolatedPositionTracker


func _ready() -> void:
	assert(seek_steering != null, "seek_steering must not be null.")
	assert(hit_stop_profile != null, "hit_stop_profile must not be null.")

	movement.setup(self)
	boost.setup(movement)
	interpolated_position_tracker.setup(self)

	hitbox.hit_detected.connect(_on_hit_detected)
	boost.boost_used.connect(_on_boost_used)
	boost.boost_used.connect(hit_stop.cancel_deferred)

	_target_position = global_position


func _physics_process(delta: float) -> void:
	if hit_stop.is_active():
		interpolated_position_tracker.update_tracking()
		return

	_update_velocity(_target_position, delta)
	movement.move(delta)

	interpolated_position_tracker.update_tracking()


func set_target_position(target_position: Vector2) -> void:
	_target_position = target_position


func request_boost() -> void:
	boost.use()


func get_interpolated_global_position() -> Vector2:
	return interpolated_position_tracker.get_interpolated_global_position()


func _update_velocity(target_position: Vector2, delta: float) -> void:
	var new_velocity := seek_steering.calculate_velocity(
		movement.get_velocity(),
		global_position,
		target_position,
		delta
	)

	movement.set_velocity(new_velocity)


func _on_boost_used() -> void:
	boosted.emit()


func _on_hit_detected(hurtbox: Hurtbox) -> void:
	if hurtbox == null:
		return

	var speed := movement.get_speed()
	var damage_amount := contact_damage.calculate_damage(speed)
	var hit_stop_duration := hit_stop_profile.get_duration(speed)

	hurtbox.receive_hit(damage_amount, speed)
	hit_stop.start(hit_stop_duration)
