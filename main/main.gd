extends Node

@onready var ball: Ball = $Ball
@onready var boost_trail: BoostTrail = %BoostTrail


func _ready() -> void:
	boost_trail.setup(
		ball,
		ball.interpolated_position_tracker
	)

	ball.boosted.connect(boost_trail.play_boost_trail)
