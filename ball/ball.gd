class_name Ball
extends Node2D

signal active_ability_activated

@export var hit_stop_profile: HitStopProfile

var _target_position := Vector2.ZERO

@onready var hitbox: Hitbox = %Hitbox
@onready var movement: Movement = %Movement
@onready var contact_damage: ContactDamage = %ContactDamage
@onready var hit_stop: HitStop = %HitStop
@onready var ability_controller: AbilityController = %AbilityController
@onready var physics_position_interpolator: PhysicsPositionInterpolator = %PhysicsPositionInterpolator


func _ready() -> void:
	assert(hit_stop_profile != null, "hit_stop_profile must not be null.")

	movement.setup(self)
	contact_damage.setup(movement.get_speed)
	physics_position_interpolator.setup(self)

	var ability_context := AbilityContext.new(
		self,
		movement,
		hit_stop.cancel_deferred,
		get_interpolated_global_position
	)
	ability_controller.setup(ability_context)

	hitbox.hit_detected.connect(contact_damage.apply_hit)
	contact_damage.hit_applied.connect(_on_contact_damage_hit_applied)
	ability_controller.active_ability_activated.connect(active_ability_activated.emit)

	_target_position = global_position


func _physics_process(delta: float) -> void:
	if hit_stop.is_active():
		physics_position_interpolator.record_position()
		return

	movement.update_velocity(
		global_position,
		_target_position,
		delta
	)
	movement.move(delta)

	physics_position_interpolator.record_position()


func set_target_position(target_position: Vector2) -> void:
	_target_position = target_position


func request_active_ability() -> bool:
	return ability_controller.try_activate()


func get_interpolated_global_position() -> Vector2:
	return physics_position_interpolator.get_interpolated_global_position()


func _on_contact_damage_hit_applied(speed: float) -> void:
	var hit_stop_duration := hit_stop_profile.get_duration(speed)
	hit_stop.start(hit_stop_duration)
