extends "res://scripts/level_manager.gd"

# Stage 4: City Rooftops
# Precision bounce platforming above neon city skyline.
# Discontinuous floating rooftops, moving amber crane platforms, narrow landings.

var platform1: MovingPlatform
var platform2: MovingPlatform

class MovingPlatform extends AnimatableBody2D:
	var phase: float = 0.0
	var base_pos: Vector2
	var amplitude: Vector2
	var speed_mult: float

	func _init(base: Vector2, amp: Vector2, spd: float = 1.6) -> void:
		base_pos = base
		amplitude = amp
		speed_mult = spd

	func _ready() -> void:
		add_to_group("rewindable")
		sync_to_physics = false
		collision_layer = 1
		var collider := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(130, 22)
		collider.shape = shape
		add_child(collider)

	func _physics_process(delta: float) -> void:
		if not RewindManager.is_rewinding:
			phase += delta * speed_mult
			position = base_pos + Vector2(sin(phase) * amplitude.x, cos(phase) * amplitude.y)
		queue_redraw()

	func capture_rewind_state() -> Dictionary:
		return {"position": position, "phase": phase}

	func restore_rewind_state(state: Dictionary) -> void:
		position = state.position
		phase = state.phase

	func _draw() -> void:
		draw_rect(Rect2(-65, -11, 130, 22), Color("e9ae55"))

func build_level_geometry() -> void:
	# Rooftop 1 (start)
	add_floor(Vector2(120, 600), Vector2(240, 60))
	# Rooftop 2
	add_floor(Vector2(450, 520), Vector2(150, 30))
	# Rooftop 3 (pinnacle with evidence)
	add_floor(Vector2(850, 380), Vector2(160, 30))
	# Rooftop 4 (exit)
	add_floor(Vector2(1180, 560), Vector2(200, 60))

	# Moving Crane platforms
	platform1 = MovingPlatform.new(Vector2(290, 560), Vector2(60, 0), 1.8)
	platform1.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(platform1)

	platform2 = MovingPlatform.new(Vector2(650, 450), Vector2(70, 40), 1.5)
	platform2.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(platform2)

	# Left/right boundaries
	add_floor(Vector2(0, 360), Vector2(20, 720))
	add_floor(Vector2(1280, 360), Vector2(20, 720))
