@abstract
class_name ActiveAbility
extends Node

signal activated


@abstract
func setup(context: AbilityContext) -> void


@abstract
func try_activate() -> bool


@abstract
func deactivate() -> void
