extends Node2D

@onready var input_controller: InputController = $InputController
@onready var ball: Ball = $Ball
@onready var camera: Camera2D = $Camera2D
@onready var camera_shake: CameraShake = %CameraShake
@onready var impact_camera_shake: ImpactCameraShake = %ImpactCameraShake

func _ready() -> void:
	camera_shake.setup(camera)
	impact_camera_shake.setup(camera_shake)

	ball.hit_landed.connect(impact_camera_shake.apply_hit)
	input_controller.active_ability_requested.connect(
		ball.request_active_ability
	)

	ball.set_target_position(get_global_mouse_position())


func _physics_process(_delta: float) -> void:
	ball.set_target_position(get_global_mouse_position())
