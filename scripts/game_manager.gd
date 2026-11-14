extends Node

signal evidence_updated(count: int, total: int)
signal level_changed(level_index: int)

var evidence_count: int = 0
var current_level: int = 1
var committed_evidence: Dictionary = {}

const LEVEL_SCENES: Array[String] = [
	"res://scenes/levels/apartment.tscn",
	"res://scenes/levels/warehouse.tscn",
	"res://scenes/levels/power_station.tscn",
	"res://scenes/levels/rooftops.tscn",
	"res://scenes/levels/headquarters.tscn"
]

func _ready() -> void:
	var bindings: Dictionary = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_UP, KEY_W],
		"rewind": [KEY_R],
		"pause": [KEY_ESCAPE]
	}
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
	get_tree().paused = false
	load_level(1)

func load_level(level_num: int) -> void:
	current_level = level_num
	RewindManager.clear_history()
	if level_num >= 1 and level_num <= LEVEL_SCENES.size():
		var path := LEVEL_SCENES[level_num - 1]
		get_tree().change_scene_to_file(path)
		level_changed.emit(current_level)
	else:
		# Victory / Case Closed
		get_tree().change_scene_to_file("res://scenes/ending.tscn")

func register_evidence(id: String) -> void:
	if not committed_evidence.has(id):
		committed_evidence[id] = true
		evidence_count = committed_evidence.size()
		evidence_updated.emit(evidence_count, 5)

func complete_level() -> void:
	current_level += 1
	RewindManager.clear_history()
	load_level(current_level)

func restart_current_level() -> void:
	RewindManager.clear_history()
	load_level(current_level)
