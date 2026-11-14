extends "res://scripts/level_manager.gd"

# Stage 1: Detective's Apartment
# Teaches: Rolling, jumping across gap, using moving platform, rewinding if missed, grabbing evidence.

var platform: MovingPlatform

class MovingPlatform extends AnimatableBody2D:
	var phase: float = 0.0
	func _ready() -> void:
		add_to_group("rewindable")
		sync_to_physics = false
		collision_layer = 1
		var collider := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(140, 24)
		collider.shape = shape
		add_child(collider)
	func _physics_process(delta: float) -> void:
		if not RewindManager.is_rewinding:
			phase += delta * 1.5
			position = Vector2(620 + sin(phase) * 110, 480)
		queue_redraw()
	func capture_rewind_state() -> Dictionary:
		return {"position": position, "phase": phase}
	func restore_rewind_state(state: Dictionary) -> void:
		position = state.position
		phase = state.phase
	func _draw() -> void:
		# Pixelated amber moving platform
		draw_rect(Rect2(-70, -12, 140, 24), Color("b87723"))
		draw_rect(Rect2(-68, -10, 136, 20), Color("e9ae55"))
		draw_rect(Rect2(-70, -12, 140, 4), Color("f5d76e")) # top rim highlight
		# Pixel chevrons
		for x in range(-50, 60, 24):
			draw_rect(Rect2(x, -4, 8, 8), Color("8f5611"))

func build_level_geometry() -> void:
	# Starting floor
	add_floor(Vector2(200, 620), Vector2(400, 80))
	# Mid platform
	add_floor(Vector2(350, 500), Vector2(160, 24))
	# Right floor with exit & evidence
	add_floor(Vector2(1040, 620), Vector2(480, 80))
	add_floor(Vector2(950, 480), Vector2(220, 24))
	# Boundaries
	add_floor(Vector2(0, 360), Vector2(30, 720))
	add_floor(Vector2(1280, 360), Vector2(30, 720))

	# Moving rewindable platform
	platform = MovingPlatform.new()
	platform.position = Vector2(620, 480)
	platform.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(platform)
