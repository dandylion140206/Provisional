class_name FloatingEffectPanel
extends PanelContainer


@onready var drag_area: Control = $VBox/Header/DragArea
@onready var close_button: Button = $VBox/Header/CloseButton

var _dragging := false
var _drag_offset := Vector2.ZERO


func _ready() -> void:
	drag_area.gui_input.connect(_on_drag_area_gui_input)
	close_button.pressed.connect(hide)


func _input(event: InputEvent) -> void:
	if not _dragging:
		return

	if event is InputEventMouseMotion:
		_update_position()

	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if (
			mouse_event.button_index == MOUSE_BUTTON_LEFT
			and not mouse_event.pressed
		):
			_dragging = false
			get_viewport().set_input_as_handled()


func _on_drag_area_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton

	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return

	if mouse_event.pressed:
		_dragging = true
		_drag_offset = (
			get_viewport().get_mouse_position()
			- position
		)
	else:
		_dragging = false

	drag_area.accept_event()


func _update_position() -> void:
	var target_position := (
		get_viewport().get_mouse_position()
		- _drag_offset
	)

	var viewport_size := get_viewport_rect().size
	var maximum_position := viewport_size - size

	target_position.x = clampf(
		target_position.x,
		0.0,
		maxf(maximum_position.x, 0.0),
	)
	target_position.y = clampf(
		target_position.y,
		0.0,
		maxf(maximum_position.y, 0.0),
	)

	position = target_position
