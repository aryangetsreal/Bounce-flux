extends "res://scripts/level_manager.gd"

# Stage 5: Drug Lord's Headquarters
# Climactic encounter: The Crime Boss patrols the inner sanctum.
# Above him is an overhead crush piston and release trigger.
# An electric barrier also guards the final safe containing the 5th piece of evidence.
# Player drops the trap to defeat the boss, grabs the final evidence, and escapes to close the case!

func build_level_geometry() -> void:
	# Sanctum ground floor
	add_floor(Vector2(640, 660), Vector2(1280, 80))

	# Left elevated vault entrance
	add_floor(Vector2(160, 500), Vector2(180, 24))
	# High catwalk with trap release trigger
	add_floor(Vector2(480, 360), Vector2(240, 24))
	# Final evidence vault pedestal
	add_floor(Vector2(950, 480), Vector2(180, 24))

	# Outer walls
	add_floor(Vector2(10, 360), Vector2(20, 720))
	add_floor(Vector2(1270, 360), Vector2(20, 720))

	# Catwalk trigger for overhead crate/crush trap over Boss
	var trigger_area := Area2D.new()
	trigger_area.position = Vector2(480, 320)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(80, 50)
	shape.shape = rect
	trigger_area.add_child(shape)
	trigger_area.body_entered.connect(_on_boss_trap_trigger)
	add_child(trigger_area)

func _on_boss_trap_trigger(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		var trap = get_node_or_null("BossCrateTrap")
		if trap and trap.has_method("trigger_trap"):
			trap.trigger_trap()
			if hud:
				hud.set_hint("CHANDELIER CRATE DROPPED ON THE CRIME BOSS!")
