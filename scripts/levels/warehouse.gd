extends "res://scripts/level_manager.gd"

func _on_trap_released() -> void:
	if hud:
		hud.set_hint("CRATE RELEASED! Watch out below!")
