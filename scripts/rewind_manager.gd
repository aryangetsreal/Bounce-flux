extends Node

const MAX_SNAPSHOTS: int = 180
var is_rewinding: bool = false
var history: Array[Array] = []

func _ready() -> void:
	# Restore before actors run; capture only after all actors finish their tick.
	process_physics_priority = -100

func _physics_process(_delta: float) -> void:
	is_rewinding = Input.is_action_pressed("rewind") and not history.is_empty()
	if Input.is_action_pressed("rewind"):
		# Keep simulation frozen even once the available history is exhausted.
		is_rewinding = true
		if not history.is_empty():
			var snapshot: Array = history.pop_back()
			for entry: Dictionary in snapshot:
				var actor = instance_from_id(entry["id"])
				if is_instance_valid(actor) and actor.is_inside_tree():
					actor.restore_rewind_state(entry["state"])
	else:
		capture_after_tick.call_deferred()

func capture_after_tick() -> void:
	if is_rewinding or get_tree().paused:
		return
	# Preserve the last living moments while the death prompt is displayed.
	for player in get_tree().get_nodes_in_group("player"):
		if player.dead:
			return
	var actors := get_tree().get_nodes_in_group("rewindable")
	actors.sort_custom(func(a: Node, b: Node) -> bool: return a.get_instance_id() < b.get_instance_id())
	var snapshot: Array = []
	for actor: Node in actors:
		snapshot.append({"id": actor.get_instance_id(), "state": actor.capture_rewind_state().duplicate(true)})
	if not snapshot.is_empty():
		history.append(snapshot)
		if history.size() > MAX_SNAPSHOTS:
			history.pop_front()

func clear_history() -> void:
	history.clear()
	is_rewinding = false

func available_seconds() -> float:
	return history.size() / 60.0
