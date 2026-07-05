class_name BoostTrail
extends Line2D

enum SourcePositionMode {
	INTERPOLATED,
	PHYSICS
}

@export var source_position_mode: SourcePositionMode = SourcePositionMode.PHYSICS

@export_range(0.05, 2.0, 0.01) var duration: float = 0.34
@export_range(10.0, 600.0, 1.0) var max_trail_length: float = 400.0
@export_range(1.0, 80.0, 1.0) var min_point_distance: float = 4.0
@export_range(0.0, 80.0, 1.0) var emit_offset: float = 0.0
@export_range(1.0, 80.0, 1.0) var trail_width: float = 40.0
@export_range(4, 256, 1) var max_points: int = 80

@export var tail_color: Color = Color(0.35, 0.75, 1.0, 0.0)
@export var body_color: Color = Color(0.35, 0.9, 1.0, 0.65)
@export var head_color: Color = Color(1.0, 1.0, 1.0, 0.95)

var _source: Ball
var _movement: Movement
var _elapsed_time: float = 0.0
var _world_points: Array[Vector2] = []


func _ready() -> void:
	width = trail_width
	antialiased = true
	round_precision = 16
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND

	gradient = _create_gradient()
	width_curve = _create_width_curve()

	clear_points()
	set_process(false)


func setup(source: Ball, movement: Movement) -> void:
	assert(source != null, "source must not be null.")
	assert(movement != null, "movement must not be null.")

	_source = source
	_movement = movement


func start_trail() -> void:
	_elapsed_time = 0.0
	_world_points.clear()

	var start_point: Vector2 = _get_emit_world_position()
	_world_points.append(start_point)

	_apply_line_points()
	set_process(true)


func _process(delta: float) -> void:
	_elapsed_time += delta

	var head_position: Vector2 = _get_emit_world_position()

	_update_head_point(head_position)
	_trim_to_current_length()
	_apply_line_points()

	if _should_finish():
		queue_free()


func _update_head_point(head_position: Vector2) -> void:
	if _world_points.is_empty():
		_world_points.append(head_position)
		return

	var last_point: Vector2 = _world_points.back()
	var distance: float = last_point.distance_to(head_position)

	if distance >= min_point_distance:
		var step_count: int = ceili(distance / min_point_distance)

		for i in range(1, step_count + 1):
			var weight: float = float(i) / float(step_count)
			var interpolated_point: Vector2 = last_point.lerp(head_position, weight)
			_world_points.append(interpolated_point)
	else:
		_world_points[_world_points.size() - 1] = head_position

	while _world_points.size() > max_points:
		_world_points.pop_front()


func _trim_to_current_length() -> void:
	var allowed_length: float = _get_current_allowed_length()

	if allowed_length <= 0.0:
		_world_points.clear()
		return

	_trim_points_to_length(allowed_length)


func _trim_points_to_length(allowed_length: float) -> void:
	while _get_total_length() > allowed_length and _world_points.size() >= 2:
		var current_total_length: float = _get_total_length()
		var excess_length: float = current_total_length - allowed_length

		var first_point: Vector2 = _world_points[0]
		var second_point: Vector2 = _world_points[1]
		var segment_length: float = first_point.distance_to(second_point)

		if segment_length <= 0.001:
			_world_points.pop_front()
			continue

		if excess_length >= segment_length:
			_world_points.pop_front()
		else:
			var trim_ratio: float = excess_length / segment_length
			_world_points[0] = first_point.lerp(second_point, trim_ratio)
			break


func _get_total_length() -> float:
	var total_length: float = 0.0

	for i in range(1, _world_points.size()):
		var previous_point: Vector2 = _world_points[i - 1]
		var current_point: Vector2 = _world_points[i]
		total_length += previous_point.distance_to(current_point)

	return total_length


func _get_current_allowed_length() -> float:
	if duration <= 0.0:
		return 0.0

	var progress: float = clampf(_elapsed_time / duration, 0.0, 1.0)
	var shrink_ratio: float = 1.0 - progress

	return max_trail_length * shrink_ratio


func _apply_line_points() -> void:
	var local_points := PackedVector2Array()

	for world_point: Vector2 in _world_points:
		local_points.append(to_local(world_point))

	points = local_points


func _should_finish() -> bool:
	if _elapsed_time < duration:
		return false

	return _world_points.size() <= 1


func _get_emit_world_position() -> Vector2:
	if _source == null:
		return global_position

	var source_position: Vector2 = _get_source_position()

	if _movement == null:
		return source_position

	var velocity: Vector2 = _movement.get_velocity()

	if velocity.is_zero_approx():
		return source_position

	return source_position - velocity.normalized() * emit_offset


func _get_source_position() -> Vector2:
	match source_position_mode:
		SourcePositionMode.INTERPOLATED:
			return _source.get_interpolated_global_position()
		SourcePositionMode.PHYSICS:
			return _source.global_position
		_:
			return _source.global_position


func _create_gradient() -> Gradient:
	var new_gradient: Gradient = Gradient.new()

	new_gradient.set_color(0, tail_color)
	new_gradient.set_offset(0, 0.0)

	new_gradient.add_point(0.45, body_color)
	new_gradient.add_point(1.0, head_color)

	return new_gradient


func _create_width_curve() -> Curve:
	var curve: Curve = Curve.new()

	var sample_count: int = 24

	for i in range(sample_count + 1):
		var t: float = float(i) / float(sample_count)
		var width_factor: float = _smooth_width(t)
		curve.add_point(Vector2(t, width_factor))

	return curve


func _smooth_width(t: float) -> float:
	t = clampf(t, 0.0, 1.0)

	return t * t * (3.0 - 2.0 * t)
