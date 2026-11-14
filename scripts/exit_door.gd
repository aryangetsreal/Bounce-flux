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
	# 2D Pixelated minimalist doorway
	var frame_color := Color("182333")
	var door_color := Color("0b111c")
	var door_edge := Color("2c3b54")
	var sign_color := Color("4deeea") if not locked else Color("e04545")

	# Outer pixel doorframe
	draw_rect(Rect2(-36, -72, 72, 72), frame_color)
	# Recessed door panels
	draw_rect(Rect2(-30, -66, 60, 66), door_color)
	# Inner panel line
	draw_rect(Rect2(-24, -60, 48, 26), door_edge)
	draw_rect(Rect2(-22, -58, 44, 22), door_color)
	draw_rect(Rect2(-24, -30, 48, 26), door_edge)
	draw_rect(Rect2(-22, -28, 44, 22), door_color)

	# Pixel EXIT sign overhead
	draw_rect(Rect2(-20, -84, 40, 10), Color("0d141e"))
	draw_rect(Rect2(-18, -82, 36, 6), sign_color)

	if not locked:
		# Pixel glow beam
		draw_rect(Rect2(-20, -56, 40, 56), Color(0.3, 0.93, 0.91, 0.18))
		# Door handle (pixel gold)
		draw_rect(Rect2(14, -36, 4, 8), Color("f5d76e"))
	else:
		# Red lock bolt (pixel)
		draw_rect(Rect2(14, -36, 4, 8), Color("e04545"))
