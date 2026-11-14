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
	var rewind = root.get_node("RewindManager")
	var gm = root.get_node("GameManager")
	
	# Test Evidence
	var ev_scene = load("res://scenes/evidence.tscn")
	var evidence = ev_scene.instantiate()
	root.add_child(evidence)
	check(evidence.is_in_group("rewindable"), "Evidence must be rewindable")
	check(not evidence.collected, "Evidence initially uncollected")
	
	# Test Guard
	var guard_scene = load("res://scenes/guard.tscn")
	var guard = guard_scene.instantiate()
	root.add_child(guard)
	check(guard.is_in_group("rewindable"), "Guard must be rewindable")
	check(not guard.disabled, "Guard initially active")
	
	# Test Trap
	var trap_scene = load("res://scenes/trap.tscn")
	var trap = trap_scene.instantiate()
	root.add_child(trap)
	check(trap.is_in_group("rewindable"), "Trap must be rewindable")
	
	await physics_frame
	await physics_frame
	
	# Knock out guard
	guard.knock_out()
	check(guard.disabled, "Guard disabled after knock_out")
	
	# State capture & restore
	var state = guard.capture_rewind_state()
	guard.disabled = false
	guard.restore_rewind_state(state)
	check(guard.disabled, "Guard state restored to disabled")
	
	print("GAMEPLAY COMPONENT TEST FAILURES=", failures)
	quit(failures)
