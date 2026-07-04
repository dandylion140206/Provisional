class_name Ball
extends Node2D

@export var seek_steering: SeekSteering

@onready var hitbox: Hitbox = %Hitbox
@onready var movement: Movement = %Movement
@onready var contact_damage: ContactDamage = %ContactDamage
@onready var boost: BallBoost = %BallBoost
@onready var boost_smoke: BoostSmoke = %Smoke
@onready var hit_stop: HitStop = %HitStop


func _ready() -> void:
	assert(seek_steering != null, "seek_steering must not be null.")

	movement.setup(self)
	contact_damage.setup(Callable(movement, "get_speed"))
	boost.setup(movement)
	boost_smoke.setup(movement)

	hitbox.hit_detected.connect(_on_hit_detected)
	boost.boost_used.connect(hit_stop.cancel_deferred)


func _process(delta: float) -> void:
	if hit_stop.is_active():
		_use_boost()
		return

	var target_position := get_global_mouse_position()

	_update_velocity(target_position, delta)
	_use_boost()
	movement.move(delta)


func _update_velocity(target_position: Vector2, delta: float) -> void:
	var new_velocity := seek_steering.calculate_velocity(
		movement.get_velocity(),
		global_position,
		target_position,
		delta
	)

	movement.set_velocity(new_velocity)


func _use_boost() -> void:
	if Input.is_action_just_pressed("primary_action"):
		boost.use()


func _on_hit_detected(hurtbox: Hurtbox) -> void:
	if hurtbox == null:
		return

	var speed := movement.get_speed()

	contact_damage.send_damage_to(hurtbox)
	hit_stop.start_by_speed(speed)
	hurtbox.notify_hit(speed)
