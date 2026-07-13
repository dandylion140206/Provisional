class_name AbilityContext
extends RefCounted

var body: Node2D
var movement: Movement
var cancel_hit_stop: Callable
var get_interpolated_position: Callable


func _init(
	body: Node2D,
	movement: Movement,
	cancel_hit_stop: Callable,
	get_interpolated_position: Callable
) -> void:
	assert(body != null, "body must not be null.")
	assert(movement != null, "movement must not be null.")
	assert(cancel_hit_stop.is_valid(), "cancel_hit_stop must be a valid Callable.")
	assert(get_interpolated_position.is_valid(), "get_interpolated_position must be a valid Callable.")

	self.body = body
	self.movement = movement
	self.cancel_hit_stop = cancel_hit_stop
	self.get_interpolated_position = get_interpolated_position
