extends SceneTree
var failures: int = 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var gm = root.get_node("GameManager")
	var rewind = root.get_node("RewindManager")
	gm.new_game()
	await process_frame
	for i in range(210):
		await physics_frame
	var player = current_scene.get_node("Player")
	check(player.is_on_floor(), "Player must land on floor")
	check(rewind.history.size() == 180, "History must be capped at 180")
	var start_x: float = player.position.x
	Input.action_press("move_right")
	for i in range(24):
		await physics_frame
	Input.action_release("move_right")
	check(player.position.x > start_x + 30, "Horizontal movement failed")
	Input.action_press("jump")
	for i in range(4):
		await physics_frame
	Input.action_release("jump")
	check(player.velocity.y < 0, "Jump must rise")
	var moving = current_scene.platform
	var phase_before: float = moving.phase
	Input.action_press("rewind")
	for i in range(20):
		await physics_frame
	check(moving.phase < phase_before, "Platform must rewind")
	check(rewind.history.size() < 180, "Rewind must consume history")
	Input.action_release("rewind")
	for i in range(3):
		await physics_frame
	check(not rewind.is_rewinding, "Rewind release must resume")
	check(player.position.x < start_x + 110, "Player rewind must restore earlier movement")
	player.position.y = 900
	for i in range(3):
		await physics_frame
	check(player.dead, "Fall must mark player dead")
	Input.action_press("rewind")
	for i in range(10):
		await physics_frame
	check(not player.dead, "Rewind must recover death")
	Input.action_release("rewind")
	for i in range(3):
		await physics_frame
	Input.action_press("pause")
	await process_frame
	await process_frame
	Input.action_release("pause")
	check(paused, "Escape action must pause")
	Input.action_press("pause")
	await process_frame
	await process_frame
	Input.action_release("pause")
	check(not paused, "Escape action must unpause")
	print("BOUNCEFLUX SMOKE failures=", failures)
	quit(failures)
