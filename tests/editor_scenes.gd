extends SceneTree

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if ok:
		print("PASS: ", message)
	else:
		failures += 1
		push_error(message)

func check_mouse(node: Node) -> bool:
	if node is Control and node.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not check_mouse(child):
			return false
	return true

func run() -> void:
	var gm = root.get_node("GameManager")
	var expected_platforms := [6, 7, 8, 6, 6]
	for stage in range(1, 6):
		# Inspect the saved scene before _ready can add anything.
		var packed := load(gm.LEVEL_SCENES[stage - 1]) as PackedScene
		var editable := packed.instantiate()
		var world := editable.get_node("World")
		var static_count := 0
		for child in world.get_children():
			if child is StaticBody2D and not child is AnimatableBody2D:
				static_count += 1
		check(static_count == expected_platforms[stage - 1], "Stage %d: complete static geometry exists before entering tree" % stage)
		check(editable.has_node("Background"), "Stage %d: independent background is serialized" % stage)
		if stage == 4:
			var first: RectangleShape2D = world.get_node("Crane1/Collider").shape
			var second: RectangleShape2D = world.get_node("Crane2/Collider").shape
			check(first != second, "Rooftop cranes have independent collision resources")
		# Prove an authored move and shape resize survive packing and saving.
		var floor_node := world.get_child(0) as StaticBody2D
		floor_node.position += Vector2(11, -7)
		var collider := floor_node.get_node("Collider") as CollisionShape2D
		var original_size: Vector2 = collider.shape.size
		collider.shape.size = original_size + Vector2(16, 0)
		var saved := PackedScene.new()
		check(saved.pack(editable) == OK, "Stage %d: edited scene packs successfully" % stage)
		var save_path := "/tmp/bounceflux-edited-stage-%d.tscn" % stage
		check(ResourceSaver.save(saved, save_path) == OK, "Stage %d: edited scene saves" % stage)
		var loaded := load(save_path) as PackedScene
		var restored := loaded.instantiate()
		var restored_floor := restored.get_node("World").get_child(0)
		check(restored_floor.position == floor_node.position and restored_floor.get_node("Collider").shape.size == original_size + Vector2(16, 0), "Stage %d: position and collision edits survive disk reload" % stage)
		restored.free()
		editable.free()
		# Load the original resource, without the test's in-memory mutations.
		ResourceLoader.load(gm.LEVEL_SCENES[stage - 1], "PackedScene", ResourceLoader.CACHE_MODE_REPLACE)
		gm.load_level(stage)
		await process_frame
		await process_frame
		check(check_mouse(current_scene.hud), "Stage %d: all HUD controls ignore mouse" % stage)
		for method in ["set_stage_name", "set_evidence", "set_rewind_fraction", "set_hint", "set_death_visible", "set_paused"]:
			check(current_scene.hud.has_method(method), "HUD contract: " + method)
	# Match F6: scene loading bypasses the progression manager.
	gm.current_level = 1
	change_scene_to_file("res://scenes/levels/power_station.tscn")
	await process_frame
	await process_frame
	check(gm.current_level == 3, "Direct scene play synchronizes progression to the authored stage")
	print("EDITOR SCENES failures=", failures)
	quit(failures)
