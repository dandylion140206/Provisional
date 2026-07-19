class_name EffectUI
extends CanvasLayer

@onready var floating_panel: Control = $FloatingPanel


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().gui_release_focus()

	elif event is InputEventKey:
		var key_event := event as InputEventKey

		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_F1:
			floating_panel.visible = not floating_panel.visible
			get_viewport().set_input_as_handled()
