class_name AbilityController
extends Node

signal active_ability_activated

@export var initial_active_ability_scene: PackedScene
@export var initial_passive_ability_scenes: Array[PackedScene] = []

var _context: AbilityContext
var _active_ability: ActiveAbility
var _passive_abilities: Array[PassiveAbility] = []


func setup(context: AbilityContext) -> void:
	assert(context != null, "context must not be null.")

	_context = context

	if initial_active_ability_scene != null:
		equip_active_ability(initial_active_ability_scene)

	for ability_scene in initial_passive_ability_scenes:
		add_passive_ability(ability_scene)


func equip_active_ability(ability_scene: PackedScene) -> bool:
	assert(_context != null, "AbilityController must be setup before equipping an ability.")

	if ability_scene == null:
		push_error("ability_scene must not be null.")
		return false

	var instance := ability_scene.instantiate()

	if not instance is ActiveAbility:
		push_error("The root node of ability_scene must inherit ActiveAbility.")
		instance.free()
		return false

	unequip_active_ability()

	_active_ability = instance as ActiveAbility
	add_child(_active_ability)
	_active_ability.setup(_context)
	_active_ability.activated.connect(_on_active_ability_activated)

	return true


func unequip_active_ability() -> void:
	if _active_ability == null:
		return

	if _active_ability.activated.is_connected(_on_active_ability_activated):
		_active_ability.activated.disconnect(_on_active_ability_activated)

	_active_ability.deactivate()
	_active_ability.queue_free()
	_active_ability = null


func has_active_ability() -> bool:
	return _active_ability != null


func try_activate() -> bool:
	assert(_context != null, "AbilityController must be setup before try_activate().")

	if _active_ability == null:
		return false

	return _active_ability.try_activate()


func add_passive_ability(ability_scene: PackedScene) -> PassiveAbility:
	assert(_context != null, "AbilityController must be setup before adding a passive ability.")

	if ability_scene == null:
		push_error("ability_scene must not be null.")
		return null

	var instance := ability_scene.instantiate()

	if not instance is PassiveAbility:
		push_error("The root node of ability_scene must inherit PassiveAbility.")
		instance.free()
		return null

	var passive_ability := instance as PassiveAbility

	add_child(passive_ability)
	passive_ability.setup(_context)
	passive_ability.activate()
	_passive_abilities.append(passive_ability)

	return passive_ability


func remove_passive_ability(passive_ability: PassiveAbility) -> bool:
	if passive_ability == null or not _passive_abilities.has(passive_ability):
		return false

	passive_ability.deactivate()
	_passive_abilities.erase(passive_ability)
	passive_ability.queue_free()

	return true


func remove_all_passive_abilities() -> void:
	while not _passive_abilities.is_empty():
		remove_passive_ability(_passive_abilities.back())


func _on_active_ability_activated() -> void:
	active_ability_activated.emit()
