extends "res://scripts/level_manager.gd"

# Stage 3: Power Station
# Hazards: Timed pulsing high-voltage arcs (TrapType.ELECTRICAL).
# Player must gauge the pulse cycle, jump across generator platforms, and rewind if zapped!

func build_level_geometry() -> void:
	# Discontinuous industrial floor with hazard gaps
	add_floor(Vector2(140, 640), Vector2(280, 80))
	add_floor(Vector2(440, 580), Vector2(160, 30))
	add_floor(Vector2(680, 520), Vector2(160, 30))
	add_floor(Vector2(920, 580), Vector2(160, 30))
	add_floor(Vector2(1160, 640), Vector2(240, 80))

	# Upper access gantry where evidence is tucked
	add_floor(Vector2(680, 360), Vector2(220, 24))

	# Outer barriers
	add_floor(Vector2(10, 360), Vector2(20, 720))
	add_floor(Vector2(1270, 360), Vector2(20, 720))
