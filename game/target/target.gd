class_name Target
extends Node2D

signal health_changed(current_health: float, max_health: float)
signal died
signal exited

var _is_dying: bool = false

@onready var _visual: TargetVisual = %Visual
@onready var _hit_flash: HitFlash = %HitFlash
@onready var _hurtbox: Hurtbox = %Hurtbox
@onready var _hit_stop: HitStop = %HitStop
@onready var _health: Health = %Health
@onready var _movement: Movement = %Movement
@onready var _target_movement: TargetMovement = %TargetMovement
@onready var _hit_sound: AudioStreamPlayer2D = %HitSound
@onready var _death_sound: AudioStreamPlayer2D = %DeathSound


func _ready() -> void:
	_hit_flash.setup(_visual)
	_movement.setup(self)
	_target_movement.setup(self, _movement)

	_hurtbox.hit_received.connect(_on_hit_received)

	_health.damaged.connect(_on_damaged)
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)
	_target_movement.exited.connect(_on_exited)

	_on_health_changed(
		_health.get_current_health(),
		_health.max_health
	)


func initialize_movement(
	spawn_position: Vector2,
	goal_position: Vector2,
	viewport_size: Vector2,
	spawn_margin: float
) -> void:
	_target_movement.initialize(
		spawn_position,
		goal_position,
		viewport_size,
		spawn_margin,
		_visual.radius
	)


func get_current_health() -> float:
	return _health.get_current_health()


func get_max_health() -> float:
	return _health.max_health


func _on_hit_received(hit_data: HitData) -> void:
	_health.damage(hit_data.damage)
	_hit_stop.start(hit_data.target_hit_stop_duration)


func _on_damaged(
	_amount: float,
	_current_health: float,
	_max_health: float
) -> void:
	if _is_dying:
		return

	_hit_flash.flash()
	_play_sound_from_start(_hit_sound)


func _on_health_changed(current_health: float, max_health: float) -> void:
	_visual.update_health(current_health, max_health)
	health_changed.emit(current_health, max_health)


func _on_died() -> void:
	if _is_dying:
		return

	_is_dying = true
	_target_movement.stop()

	_hurtbox.set_enabled(false)
	_visual.visible = false
	died.emit()

	_play_sound_from_start(_death_sound)

	await _death_sound.finished

	queue_free()


func _on_exited() -> void:
	if _is_dying:
		return

	_is_dying = true
	exited.emit()
	queue_free()


func _play_sound_from_start(sound: AudioStreamPlayer2D) -> void:
	sound.stop()
	sound.play()
