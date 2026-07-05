extends Node

@onready var ball: Ball = $Ball
@onready var effects_layer: EffectsLayer = $EffectsLayer


func _ready() -> void:
	ball.boosted.connect(_on_ball_boosted)


func _on_ball_boosted(source: Ball, movement: Movement) -> void:
	effects_layer.spawn_boost_trail(source, movement)
