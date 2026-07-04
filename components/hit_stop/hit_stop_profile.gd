class_name HitStopProfile
extends Resource

const SPEED_UNIT := 1000.0

@export_range(0.0, 1.0, 0.001) var base_duration: float = 0.5
@export_range(0.0, 0.2, 0.001) var duration_per_1000_speed: float = 0.005
@export_range(0.0, 1.0, 0.001) var min_duration: float = 0.02
@export_range(0.0, 1.0, 0.001) var max_duration: float = 0.12


func calculate_duration(speed: float) -> float:
	var duration := base_duration + speed / SPEED_UNIT * duration_per_1000_speed
	return clampf(duration, min_duration, max_duration)
