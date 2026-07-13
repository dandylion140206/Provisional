extends Node2D

@onready var ball: Ball = $Ball
@onready var input_controller: InputController = $InputController
@onready var boost_trail: BoostTrail = %BoostTrail


func _ready() -> void:
	boost_trail.setup(ball)

	input_controller.boost_requested.connect(ball.request_boost)
	ball.boost_used.connect(boost_trail.play_boost_trail)

	ball.set_target_position(get_global_mouse_position())


func _physics_process(_delta: float) -> void:
	ball.set_target_position(get_global_mouse_position())
