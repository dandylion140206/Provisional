class_name BoostTrail
extends Line2D

@export_range(0.01, 1.0, 0.01) var emit_duration: float = 0.22
@export_range(0.05, 2.0, 0.01) var trail_lifetime: float = 0.32
@export_range(1.0, 80.0, 1.0) var min_point_distance: float = 10.0
@export_range(0.0, 80.0, 1.0) var emit_offset: float = 22.0
@export_range(1.0, 80.0, 1.0) var trail_width: float = 18.0
@export var tail_color: Color = Color(0.2, 1.0, 0.45, 0.0)
@export var body_color: Color = Color(0.2, 1.0, 0.45, 0.65)
@export var head_color: Color = Color(0.8, 1.0, 0.9, 0.9)

var _source: Node2D
var _movement: Movement
var _remaining_emit_time: float = 0.0
var _global_points: Array[Vector2] = []
var _point_ages: Array[float] = []
var _has_last_point: bool = false
var _last_point: Vector2 = Vector2.ZERO


func _ready() -> void:
	global_position = Vector2.ZERO
	z_as_relative = false
	z_index = -1

	width = trail_width
	closed = false
	antialiased = true
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	joint_mode = Line2D.LINE_JOINT_ROUND
	gradient = _create_gradient()
	width_curve = _create_width_curve()

	clear_points()
	visible = false
	set_process(false)
	set_physics_process(false)


func _process(delta: float) -> void:
	_update_point_ages(delta)
	_update_line_points()
	_update_visibility()


func _physics_process(delta: float) -> void:
	if _remaining_emit_time <= 0.0:
		set_physics_process(false)
		return

	_remaining_emit_time -= delta
	_append_point(false)

	if _remaining_emit_time <= 0.0:
		_remaining_emit_time = 0.0
		set_physics_process(false)


func setup(source: Node2D, movement: Movement) -> void:
	assert(source != null, "source must not be null.")
	assert(movement != null, "movement must not be null.")

	_source = source
	_movement = movement


func start_trail() -> void:
	assert(_source != null, "source must be setup before start_trail().")
	assert(_movement != null, "movement must be setup before start_trail().")

	_clear_trail()

	_remaining_emit_time = emit_duration
	visible = true
	set_process(true)
	set_physics_process(true)

	_append_point(true)


func _update_point_ages(delta: float) -> void:
	for i in range(_point_ages.size() - 1, -1, -1):
		_point_ages[i] += delta

		if _point_ages[i] >= trail_lifetime:
			_point_ages.remove_at(i)
			_global_points.remove_at(i)


func _update_line_points() -> void:
	var local_points := PackedVector2Array()

	for global_point in _global_points:
		local_points.append(to_local(global_point))

	points = local_points


func _update_visibility() -> void:
	visible = _global_points.size() >= 2

	if _remaining_emit_time <= 0.0 and _global_points.is_empty():
		set_process(false)


func _append_point(force: bool) -> void:
	var point := _get_emit_position()

	if force or not _has_last_point:
		_add_point(point)
		return

	var distance := point.distance_to(_last_point)

	if distance < min_point_distance:
		return

	var step_count := ceili(distance / min_point_distance)

	for i in range(1, step_count + 1):
		var weight := float(i) / float(step_count)
		var interpolated_point := _last_point.lerp(point, weight)

		_add_point(interpolated_point)


func _add_point(point: Vector2) -> void:
	_global_points.append(point)
	_point_ages.append(0.0)

	_last_point = point
	_has_last_point = true


func _get_emit_position() -> Vector2:
	var velocity := _movement.get_velocity()

	if velocity.is_zero_approx():
		return _source.global_position

	return _source.global_position - velocity.normalized() * emit_offset


func _clear_trail() -> void:
	_global_points.clear()
	_point_ages.clear()
	_has_last_point = false
	_last_point = Vector2.ZERO
	clear_points()


func _create_gradient() -> Gradient:
	var new_gradient := Gradient.new()

	new_gradient.set_color(0, tail_color)
	new_gradient.set_color(1, head_color)
	new_gradient.add_point(0.65, body_color)

	return new_gradient


func _create_width_curve() -> Curve:
	var curve := Curve.new()

	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(0.25, 0.65))
	curve.add_point(Vector2(0.75, 1.0))
	curve.add_point(Vector2(1.0, 0.15))

	return curve
