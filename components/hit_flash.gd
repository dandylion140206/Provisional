class_name HitFlash
extends Node

@export var flash_modulate: Color = Color(3.0, 3.0, 3.0, 1.0)
@export_range(0.01, 0.5, 0.01) var duration: float = 0.08

var _target: CanvasItem
var _base_self_modulate: Color = Color.WHITE
var _tween: Tween


func setup(target: CanvasItem) -> void:
	assert(target != null, "target must not be null.")

	_target = target
	_base_self_modulate = _target.self_modulate


func flash() -> void:
	assert(_target != null, "target must be setup before flash().")

	if _tween != null:
		_tween.kill()

	_target.self_modulate = flash_modulate

	_tween = create_tween()
	_tween.tween_property(
		_target,
		"self_modulate",
		_base_self_modulate,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
