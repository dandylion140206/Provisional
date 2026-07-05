class_name EffectsLayer
extends Node2D

@export var boost_trail_z_index: int = 5


func spawn_boost_trail(source: Ball, movement: Movement) -> void:
	if source == null:
		return

	if movement == null:
		return

	var trail := BoostTrail.new()

	add_child(trail)

	trail.z_as_relative = false
	trail.z_index = boost_trail_z_index
	trail.setup(source, movement)
	trail.start_trail()
