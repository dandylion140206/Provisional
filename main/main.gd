extends Node

@onready var ball: Ball = $Ball
@onready var effects_layer: EffectsLayer = $EffectsLayer


func _ready() -> void:
	effects_layer.setup(ball)

	ball.boosted.connect(effects_layer._on_boosted)
