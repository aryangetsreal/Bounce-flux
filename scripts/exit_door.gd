extends Area2D

signal exit_reached

@export var required_evidence_id: String = ""
var locked: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		exit_reached.emit()

func set_unlocked(val: bool) -> void:
	locked = not val
	queue_redraw()

func _draw() -> void:
	# Neo-noir doorway / crime scene exit
	var frame_color := Color("213047")
	var door_color := Color("101826")
	var sign_color := Color("4ee2a8") if not locked else Color("d64747")

	draw_rect(Rect2(-35, -70, 70, 70), frame_color)
	draw_rect(Rect2(-27, -65, 54, 65), door_color)
	# Glowing exit sign
	draw_rect(Rect2(-18, -82, 36, 12), sign_color)
	if not locked:
		# Ambient exit doorway light glow
		draw_rect(Rect2(-20, -55, 40, 55), Color(0.3, 0.9, 0.6, 0.25))
