class_name Ball
extends Node2D

signal hit_landed(hit_data: HitData)
signal active_ability_activated

var _target_position: Vector2 = Vector2.ZERO

@onready var _hitbox: Hitbox = %Hitbox
@onready var _movement: Movement = %Movement
@onready var _impact_attack: ImpactAttack = %ImpactAttack
@onready var _hit_stop: HitStop = %HitStop
@onready var _ability_controller: AbilityController = %AbilityController
@onready var _physics_position_interpolator: PhysicsPositionInterpolator = (
	%PhysicsPositionInterpolator
)


func _ready() -> void:
	_movement.setup(self)
	_impact_attack.setup(_movement.get_speed)
	_physics_position_interpolator.setup(self)

	var ability_context := AbilityContext.new(
		self,
		_movement,
		_hit_stop.cancel_deferred,
		get_interpolated_global_position
	)

	_ability_controller.setup(ability_context)

	_hitbox.hit_detected.connect(_impact_attack.apply_hit)
	_impact_attack.hit_landed.connect(_on_hit_landed)
	_ability_controller.active_ability_activated.connect(active_ability_activated.emit)

	_target_position = global_position


func _physics_process(delta: float) -> void:
	if _hit_stop.is_active():
		_physics_position_interpolator.record_position()
		return

	_movement.update_velocity(
		global_position,
		_target_position,
		delta
	)
	_movement.move(delta)
	_physics_position_interpolator.record_position()


func set_target_position(target_position: Vector2) -> void:
	_target_position = target_position


func request_active_ability() -> bool:
	return _ability_controller.try_activate()


func get_interpolated_global_position() -> Vector2:
	return _physics_position_interpolator.get_interpolated_global_position()


func _on_hit_landed(hit_data: HitData) -> void:
	_hit_stop.start(hit_data.attacker_hit_stop_duration)
	hit_landed.emit(hit_data)
