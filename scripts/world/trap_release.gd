extends Area2D

signal activated

@export_node_path("CharacterBody2D") var trap_path: NodePath

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if RewindManager.is_rewinding or not body.is_in_group("player") or body.dead:
		return
	var trap := get_node_or_null(trap_path)
	if trap and trap.has_method("trigger_trap") and not trap.triggered:
		trap.trigger_trap()
		activated.emit()
