class_name ScreenEffectPresetStore
extends RefCounted

const FILE_PATH := "user://screen_effect_presets.cfg"
const SETTINGS_SECTION := "settings"
const ACTIVE_PRESET_KEY := "active_preset"
const PRESET_SECTION_PREFIX := "preset/"

var _config: ConfigFile = ConfigFile.new()


func _init() -> void:
	var error := _config.load(FILE_PATH)

	if error != OK and error != ERR_FILE_NOT_FOUND:
		push_error("Failed to load screen effect presets: %s" % error)


func get_active_preset_name() -> String:
	return String(_config.get_value(SETTINGS_SECTION, ACTIVE_PRESET_KEY, "Default"))


func get_preset_names() -> Array[String]:
	var preset_names: Array[String] = []

	for section in _config.get_sections():
		if not section.begins_with(PRESET_SECTION_PREFIX):
			continue

		preset_names.append(section.trim_prefix(PRESET_SECTION_PREFIX))

	preset_names.sort()
	return preset_names


func has_preset(preset_name: String) -> bool:
	return _config.has_section(_get_preset_section(preset_name))


func load_preset(preset_name: String) -> Dictionary:
	var settings: Variant = _config.get_value(
		_get_preset_section(preset_name),
		"settings",
		{},
	)

	if settings is Dictionary:
		return settings

	push_warning("Invalid screen effect preset: %s" % preset_name)
	return {}


func save_preset(preset_name: String, settings: Dictionary) -> Error:
	if not is_valid_preset_name(preset_name):
		return ERR_INVALID_PARAMETER

	_config.set_value(_get_preset_section(preset_name), "settings", settings)
	_config.set_value(SETTINGS_SECTION, ACTIVE_PRESET_KEY, preset_name)

	return _config.save(FILE_PATH)


func set_active_preset_name(preset_name: String) -> Error:
	_config.set_value(SETTINGS_SECTION, ACTIVE_PRESET_KEY, preset_name)

	return _config.save(FILE_PATH)


func delete_preset(preset_name: String) -> Error:
	_config.erase_section(_get_preset_section(preset_name))

	if get_active_preset_name() == preset_name:
		_config.set_value(SETTINGS_SECTION, ACTIVE_PRESET_KEY, "Default")

	return _config.save(FILE_PATH)


static func is_valid_preset_name(preset_name: String) -> bool:
	return (
		not preset_name.strip_edges().is_empty()
		and not preset_name.contains("/")
		and not preset_name.contains("\n")
	)


func _get_preset_section(preset_name: String) -> String:
	return PRESET_SECTION_PREFIX + preset_name
