extends Node2D

@onready var ball: Ball = $Ball
@onready var input_controller: InputController = $InputController


func _ready() -> void:
	input_controller.active_ability_requested.connect(
		ball.request_active_ability
	)

	ball.set_target_position(get_global_mouse_position())


func _physics_process(_delta: float) -> void:
	ball.set_target_position(get_global_mouse_position())
