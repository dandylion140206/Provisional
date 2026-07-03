class_name Hitbox
extends Area2D

signal hit(hurtbox: Hurtbox)


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		hit.emit(area as Hurtbox)
