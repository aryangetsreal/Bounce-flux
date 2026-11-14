extends AnimatableBody2D

@export var amplitude: Vector2 = Vector2(110, 0)
@export_range(0.0, 10.0, 0.05) var angular_speed: float = 1.5
var phase: float = 0.0
var base_position: Vector2

func _ready() -> void:
	add_to_group("rewindable")
	base_position = position
	position = base_position + Vector2(0, amplitude.y)

func _physics_process(delta: float) -> void:
	if RewindManager.is_rewinding:
		return
	phase += delta * angular_speed
	position = base_position + Vector2(sin(phase) * amplitude.x, cos(phase) * amplitude.y)

func capture_rewind_state() -> Dictionary:
	return {"position": position, "phase": phase}

func restore_rewind_state(state: Dictionary) -> void:
	position = state.position
	phase = state.phase
