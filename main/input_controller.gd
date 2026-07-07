class_name InputController
extends Node

signal boost_requested


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("primary_action"):
		boost_requested.emit()
