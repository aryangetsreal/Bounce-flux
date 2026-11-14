extends Node

var evidence_count: int = 0
var current_level: int = 1
var committed_evidence: Dictionary = {}

func _ready() -> void:
	var bindings: Dictionary = {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "jump": [KEY_SPACE], "rewind": [KEY_R], "pause": [KEY_ESCAPE]}
	for action: String in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key: int in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

func new_game() -> void:
	evidence_count = 0
	current_level = 1
	committed_evidence.clear()
	RewindManager.clear_history()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func register_evidence(id: String) -> void:
	if not committed_evidence.has(id):
		committed_evidence[id] = true
		evidence_count = committed_evidence.size()

func complete_level() -> void:
	current_level += 1
	RewindManager.clear_history()
