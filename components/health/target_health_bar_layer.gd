class_name TargetHealthBarLayer
extends Node2D

@export var health_bar_offset := Vector2(0.0, -55.0)

var _health_bars: Dictionary = {}


func add_target(target: Target) -> void:
	assert(target != null, "Target must not be null")

	if _health_bars.has(target):
		return

	var health_bar := HealthBar.new()
	add_child(health_bar)

	_health_bars[target] = health_bar
	target.health_changed.connect(_on_target_health_changed.bind(target))
	target.died.connect(_on_target_died.bind(target))
	target.tree_exiting.connect(_on_target_tree_exiting.bind(target))

	health_bar.update_health(
		target.get_current_health(),
		target.get_max_health(),
	)
	_update_health_bar_position(target, health_bar)


func _process(_delta: float) -> void:
	for target_value: Variant in _health_bars.keys():
		var target := target_value as Target
		var health_bar := _health_bars[target] as HealthBar

		if not is_instance_valid(target) or not is_instance_valid(health_bar):
			remove_target(target)
			continue

		_update_health_bar_position(target, health_bar)


func remove_target(target: Target) -> void:
	if not _health_bars.has(target):
		return

	var health_bar := _health_bars[target] as HealthBar
	_health_bars.erase(target)

	if is_instance_valid(health_bar):
		health_bar.queue_free()


func _on_target_health_changed(
	current_health: float,
	max_health: float,
	target: Target,
) -> void:
	if not _health_bars.has(target):
		return

	var health_bar := _health_bars[target] as HealthBar
	health_bar.update_health(current_health, max_health)


func _on_target_died(target: Target) -> void:
	remove_target(target)


func _on_target_tree_exiting(target: Target) -> void:
	remove_target(target)


func _update_health_bar_position(
	target: Target,
	health_bar: HealthBar,
) -> void:
	health_bar.global_position = target.global_position + health_bar_offset
