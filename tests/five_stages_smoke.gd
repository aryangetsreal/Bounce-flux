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
	var gm = root.get_node("GameManager")
	var rewind = root.get_node("RewindManager")
	
	print("--- TESTING ALL 5 STAGES & PROGRESSION ---")
	
	# Start game
	gm.new_game()
	await process_frame
	await process_frame
	
	for stage_num in range(1, 6):
		print("Testing Stage %d..." % stage_num)
		check(gm.current_level == stage_num, "Current level is %d" % stage_num)
		check(current_scene != null, "Scene %d loaded" % stage_num)
		
		var player = current_scene.get_node_or_null("Player")
		check(player != null, "Player exists in Stage %d" % stage_num)
		
		var evidence = current_scene.get_node_or_null("Evidence")
		check(evidence != null, "Evidence exists in Stage %d" % stage_num)
		
		var exit_door = current_scene.get_node_or_null("ExitDoor")
		check(exit_door != null, "ExitDoor exists in Stage %d" % stage_num)
		check(exit_door.locked, "ExitDoor initially locked in Stage %d" % stage_num)
		
		# Collect evidence
		evidence.evidence_collected.emit(evidence.evidence_id)
		await process_frame
		check(not exit_door.locked, "ExitDoor unlocked after evidence collected in Stage %d" % stage_num)
		
		# Reach exit
		exit_door.exit_reached.emit()
		await process_frame
		await process_frame
		
		check(gm.evidence_count == stage_num, "Global evidence count committed to %d" % stage_num)

	# Verify Ending scene reached
	print("Testing Ending Scene...")
	check(current_scene.name == "Ending", "Ending scene loaded after 5 stages")
	check(gm.evidence_count == 5, "Total evidence count is 5")

	print("\n--- ALL 5 STAGES PROGRESSION SMOKE TEST FAILURES = %d ---" % failures)
	quit(failures)
