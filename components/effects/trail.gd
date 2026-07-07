class_name Trail
extends Line2D

enum SourcePositionMode {
	SOURCE_POSITION,
	INTERPOLATED_POSITION,
}

@export var source: Node2D
@export var source_position_tracker: InterpolatedPositionTracker
@export var source_position_mode: SourcePositionMode = SourcePositionMode.SOURCE_POSITION

@export_range(1, 500, 1) var max_points: int = 200
@export_range(0.0, 32.0, 0.1) var min_distance: float = 4.0
@export_range(0.0, 1.0, 0.01) var point_lifetime: float = 0.5

var _point_ages: Array[float] = []

var _is_lifetime_transitioning := false
var _lifetime_transition_start := 0.0
var _lifetime_transition_target := 0.0
var _lifetime_transition_duration := 0.0
var _lifetime_transition_elapsed := 0.0


func _ready() -> void:
	clear_trail()


func _process(delta: float) -> void:
	_update_lifetime_transition(delta)
	_update_point_ages(delta)

	if point_lifetime <= 0.0:
		return

	if source == null:
		return

	var local_point_position := to_local(_get_source_global_position())
	var point_count := get_point_count()

	if point_count > 0:
		var last_point_position := get_point_position(point_count - 1)

		if local_point_position.distance_to(last_point_position) < min_distance:
			return

	add_point(local_point_position)
	_point_ages.append(0.0)

	while get_point_count() > max_points:
		_remove_oldest_point()


func clear_trail() -> void:
	clear_points()
	_point_ages.clear()


func change_lifetime(value: float, duration: float) -> void:
	if value < 0.0:
		push_warning("Trail lifetime was clamped to 0.0.")

	var target_lifetime := maxf(value, 0.0)

	if duration <= 0.0:
		point_lifetime = target_lifetime
		_is_lifetime_transitioning = false
		return

	_is_lifetime_transitioning = true
	_lifetime_transition_start = point_lifetime
	_lifetime_transition_target = target_lifetime
	_lifetime_transition_duration = duration
	_lifetime_transition_elapsed = 0.0


func _get_source_global_position() -> Vector2:
	match source_position_mode:
		SourcePositionMode.SOURCE_POSITION:
			return source.global_position

		SourcePositionMode.INTERPOLATED_POSITION:
			if source_position_tracker != null:
				return source_position_tracker.get_interpolated_global_position()

			push_warning("source_position_tracker is null. Falling back to source.global_position.")
			return source.global_position

		_:
			return source.global_position


func _update_lifetime_transition(delta: float) -> void:
	if not _is_lifetime_transitioning:
		return

	_lifetime_transition_elapsed += delta

	var progress := _lifetime_transition_elapsed / _lifetime_transition_duration
	progress = clampf(progress, 0.0, 1.0)

	point_lifetime = lerpf(
		_lifetime_transition_start,
		_lifetime_transition_target,
		progress
	)

	if progress >= 1.0:
		point_lifetime = _lifetime_transition_target
		_is_lifetime_transitioning = false


func _update_point_ages(delta: float) -> void:
	for i in range(_point_ages.size()):
		_point_ages[i] += delta

	while _point_ages.size() > 0 and _point_ages[0] >= point_lifetime:
		_remove_oldest_point()


func _remove_oldest_point() -> void:
	assert(get_point_count() > 0, "Cannot remove point because Trail has no points.")
	assert(_point_ages.size() > 0, "Cannot remove point age because Trail has no point ages.")

	remove_point(0)
	_point_ages.remove_at(0)
