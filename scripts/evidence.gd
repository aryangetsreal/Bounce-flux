extends Area2D

signal evidence_collected(id: String)

@export var evidence_id: String = "evidence_1"
@export var texture: Texture2D

var collected: bool = false
var pulse_time: float = 0.0

func _ready() -> void:
	add_to_group("rewindable")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not RewindManager.is_rewinding:
		pulse_time += delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if collected or RewindManager.is_rewinding:
		return
	if body.is_in_group("player") or body.name == "Player":
		collected = true
		monitoring = false
		evidence_collected.emit(evidence_id)
		# Audio feedback hook (null-safe) if sound exists

func capture_rewind_state() -> Dictionary:
	return {
		"collected": collected,
		"monitoring": monitoring,
		"pulse_time": pulse_time
	}

func restore_rewind_state(state: Dictionary) -> void:
	collected = state.collected
	monitoring = state.monitoring
	pulse_time = state.pulse_time
	queue_redraw()

func _draw() -> void:
	if collected:
		return
	var scale_pulse: float = 1.0 + sin(pulse_time * 4.0) * 0.12
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(scale_pulse, scale_pulse))
	if texture:
		draw_texture_rect(texture, Rect2(-16, -16, 32, 32), false)
	else:
		# Neo-noir glowing pale gold folder/record placeholder
		draw_rect(Rect2(-14, -18, 28, 36), Color("e8d07a"))
		draw_rect(Rect2(-11, -15, 22, 10), Color("fff8c4"))
		draw_line(Vector2(-10, 2), Vector2(10, 2), Color("7a6729"), 2.0)
		draw_line(Vector2(-10, 8), Vector2(10, 8), Color("7a6729"), 2.0)
	draw_set_transform(Vector2.ZERO)
