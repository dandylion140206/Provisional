class_name EffectPanel
extends VBoxContainer

@export var effect_path: NodePath

var _model: EffectModel
var _parameter_editors: Dictionary = {}


func _ready() -> void:
	var effect := get_node(effect_path)
	var model: EffectModel = effect.get_effect_model()
	setup(model)


func setup(model: EffectModel) -> void:
	_clear()
	_model = model
	_parameter_editors.clear()

	var enabled_checkbox := CheckBox.new()
	enabled_checkbox.text = model.display_name
	enabled_checkbox.button_pressed = model.enabled
	enabled_checkbox.toggled.connect(
		func(enabled: bool) -> void:
			model.enabled = enabled
	)
	add_child(enabled_checkbox)

	for parameter in model.parameters:
		_create_parameter_editor(model, parameter)

	if not model.parameter_changed.is_connected(_on_model_parameter_changed):
		model.parameter_changed.connect(_on_model_parameter_changed)

	_update_parameter_visibility()


func _create_parameter_editor(
	model: EffectModel,
	parameter: EffectParameter,
) -> void:
	var editor: Control = null

	match parameter.kind:
		EffectParameter.Kind.INTEGER:
			editor = _create_number_editor(model, parameter, true)
		EffectParameter.Kind.FLOAT:
			editor = _create_number_editor(model, parameter, false)
		EffectParameter.Kind.BOOLEAN:
			editor = _create_boolean_editor(model, parameter)
		EffectParameter.Kind.ENUM:
			editor = _create_enum_editor(model, parameter)

	if editor == null:
		push_warning(
			"Unsupported effect parameter kind: %s" % parameter.kind
		)
		return

	_parameter_editors[parameter.id] = editor


func _create_number_editor(
	model: EffectModel,
	parameter: EffectParameter,
	use_integer: bool,
) -> Control:
	var parameter_container := VBoxContainer.new()
	var header_row := HBoxContainer.new()
	var label := Label.new()
	var spin_box := SpinBox.new()
	var slider := HSlider.new()
	var line_edit := spin_box.get_line_edit()

	parameter_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	label.text = parameter.display_name
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	spin_box.custom_minimum_size.x = 96.0
	spin_box.min_value = parameter.min_value
	spin_box.max_value = parameter.max_value
	spin_box.step = parameter.step
	spin_box.value = float(model.get_value(parameter.id))

	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_edit.text_submitted.connect(
		func(_text: String) -> void:
			line_edit.release_focus()
	)

	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = parameter.min_value
	slider.max_value = parameter.max_value
	slider.step = parameter.step
	slider.value = spin_box.value

	spin_box.value_changed.connect(
		func(value: float) -> void:
			slider.set_value_no_signal(value)
			_set_number_value(
				model,
				parameter.id,
				value,
				use_integer,
			)
	)

	slider.value_changed.connect(
		func(value: float) -> void:
			spin_box.set_value_no_signal(value)
			_set_number_value(
				model,
				parameter.id,
				value,
				use_integer,
			)
	)

	header_row.add_child(label)
	header_row.add_child(spin_box)

	parameter_container.add_child(header_row)
	parameter_container.add_child(slider)

	add_child(parameter_container)
	return parameter_container


func _set_number_value(
	model: EffectModel,
	id: StringName,
	value: float,
	use_integer: bool,
) -> void:
	var result: Variant = int(value) if use_integer else value
	model.set_value(id, result)


func _create_boolean_editor(
	model: EffectModel,
	parameter: EffectParameter,
) -> Control:
	var checkbox := CheckBox.new()
	checkbox.text = parameter.display_name
	checkbox.button_pressed = bool(model.get_value(parameter.id))
	checkbox.toggled.connect(
		func(value: bool) -> void:
			model.set_value(parameter.id, value)
	)

	add_child(checkbox)
	return checkbox


func _create_enum_editor(
	model: EffectModel,
	parameter: EffectParameter,
) -> Control:
	var row := HBoxContainer.new()
	var label := Label.new()
	var option_button := OptionButton.new()

	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	label.text = parameter.display_name
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	option_button.custom_minimum_size.x = 160.0

	for option in parameter.options:
		option_button.add_item(str(option))

	option_button.select(int(model.get_value(parameter.id)))
	option_button.item_selected.connect(
		func(index: int) -> void:
			model.set_value(parameter.id, index)
	)

	row.add_child(label)
	row.add_child(option_button)

	add_child(row)
	return row


func _on_model_parameter_changed(
	_id: StringName,
	_value: Variant,
) -> void:
	_update_parameter_visibility()


func _update_parameter_visibility() -> void:
	if _model == null:
		return

	for parameter in _model.parameters:
		var editor := _parameter_editors.get(parameter.id) as Control
		if editor == null:
			continue

		if parameter.visibility_parameter == &"":
			editor.show()
			continue

		var condition_value: Variant = _model.get_value(
			parameter.visibility_parameter
		)
		editor.visible = parameter.visibility_values.has(
			condition_value
		)


func _clear() -> void:
	for child in get_children():
		child.queue_free()
