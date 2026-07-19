class_name EffectUI
extends CanvasLayer


@onready var floating_panel: Control = $FloatingPanel


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if (
		key_event.pressed
		and not key_event.echo
		and key_event.keycode == KEY_F1
	):
		floating_panel.visible = not floating_panel.visible
		get_viewport().set_input_as_handled()
