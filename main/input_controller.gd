class_name InputController
extends Node

signal active_ability_requested


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("primary_action"):
		return

	active_ability_requested.emit()
	get_viewport().set_input_as_handled()
