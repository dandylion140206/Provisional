class_name HitStopProfile
extends Resource

@export_range(0.0, 20000.0, 100.0) var min_speed: float = 1000.0
@export_range(0.0, 0.5, 0.001) var duration: float = 0.01


func get_duration(speed: float) -> float:
	if speed < min_speed:
		return 0.0

	return duration
