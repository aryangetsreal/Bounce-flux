extends "res://scripts/level_manager.gd"

# Stage 2: Criminal Warehouse
# Puzzle: Patrolling guard blocks the ground passage to the evidence.
# Above him hangs a heavy cargo crate trap.
# Stepping on the high catwalk trigger or dropping the crate crushes the guard, clearing the way.
# If player mistimes or drops down too early, rewind lets player retry!

var guard: CharacterBody2D
var crate_trap: CharacterBody2D

func build_level_geometry() -> void:
	# Main lower floor
	add_floor(Vector2(640, 660), Vector2(1280, 80))
	# Walls
	add_floor(Vector2(10, 360), Vector2(20, 720))
	add_floor(Vector2(1270, 360), Vector2(20, 720))

	# Catwalks and upper shelves
	add_floor(Vector2(200, 520), Vector2(180, 24))
	add_floor(Vector2(450, 400), Vector2(220, 24))
	add_floor(Vector2(750, 320), Vector2(200, 24))
	add_floor(Vector2(1080, 460), Vector2(220, 24))

	# Trigger area for falling crate trap
	var trigger_area := Area2D.new()
	trigger_area.position = Vector2(750, 280)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(100, 60)
	shape.shape = rect
	trigger_area.add_child(shape)
	trigger_area.body_entered.connect(_on_catwalk_trigger_entered)
	add_child(trigger_area)

func _on_catwalk_trigger_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		var trap = get_node_or_null("CrateTrap")
		if trap and trap.has_method("trigger_trap"):
			trap.trigger_trap()
			if hud:
				hud.set_hint("CRATE RELEASED! Watch out below!")
