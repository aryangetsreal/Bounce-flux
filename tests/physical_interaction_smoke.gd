extends SceneTree

var failures: int = 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("FAILURE: " + message)
	else:
		print("PASS: " + message)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	print("--- TEST PHYSICS OVERLAP FOR EVIDENCE & EXIT DOOR ---")
	
	# Load Apartment level
	var apt_scene = load("res://scenes/levels/apartment.tscn")
	var level = apt_scene.instantiate()
	root.add_child(level)
	current_scene = level
	
	await physics_frame
	await physics_frame
	
	var player = level.get_node("Player")
	var evidence = level.get_node("Evidence")
	var exit_door = level.get_node("ExitDoor")
	
	check(player.collision_layer == 2, "Player is on collision layer 2")
	check(evidence.collision_mask & 2 != 0, "Evidence mask includes player layer 2")
	check(exit_door.collision_mask & 2 != 0, "Exit door mask includes player layer 2")
	
	# Verify initial state
	check(not evidence.collected, "Evidence initially not collected")
	check(not level.level_evidence_collected, "Level evidence initially not collected")
	check(exit_door.locked, "Exit door initially locked")
	
	# Move player to evidence position
	player.global_position = evidence.global_position
	for i in range(10):
		await physics_frame
	
	check(evidence.collected, "Evidence collected on physical collision with Player")
	check(level.level_evidence_collected, "Level evidence marked collected")
	check(not exit_door.locked, "Exit door unlocked after physical evidence collection")
	
	# Move player to exit door position
	var level_completed := false
	var gm = root.get_node("GameManager")
	var start_level = gm.current_level
	
	player.global_position = exit_door.global_position
	for i in range(10):
		await physics_frame
	
	check(gm.current_level == start_level + 1, "Level progressed to next level (Stage 2)")
	
	print("\n--- PHYSICAL INTERACTION TEST FAILURES = %d ---" % failures)
	quit(failures)
