extends Node2D

@export var level_index: int = 1
@export var stage_title: String = "STAGE 1: DETECTIVE'S APARTMENT"
@export var level_hint: String = "A/D to move • Space to jump • Hold R to rewind 3s"
@export var evidence_id: String = "evidence_1"
@export var background_texture: Texture2D

var hud: Control
var exit_door: Node2D
var evidence_node: Node2D
var player: CharacterBody2D
var level_evidence_collected: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	RewindManager.clear_history()

	player = get_node_or_null("Player")
	if player:
		player.process_mode = Node.PROCESS_MODE_PAUSABLE

	exit_door = get_node_or_null("ExitDoor")
	if exit_door:
		exit_door.exit_reached.connect(_on_exit_reached)
		exit_door.set_unlocked(false)

	evidence_node = get_node_or_null("Evidence")
	if evidence_node:
		evidence_node.evidence_collected.connect(_on_evidence_collected)

	_setup_hud()
	build_level_geometry()
	queue_redraw()

func _setup_hud() -> void:
	var hud_scene = load("res://scenes/ui/hud.tscn")
	if hud_scene:
		var canvas = CanvasLayer.new()
		add_child(canvas)
		hud = hud_scene.instantiate()
		canvas.add_child(hud)
		hud.set_stage_name(stage_title)
		hud.set_hint(level_hint)
		hud.set_evidence(GameManager.evidence_count, 5)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused

	if hud:
		hud.set_paused(get_tree().paused)
		var rewind_frac := RewindManager.available_seconds() / 3.0
		hud.set_rewind_fraction(rewind_frac)
		hud.set_evidence(GameManager.evidence_count + (1 if level_evidence_collected else 0), 5)
		if player:
			hud.set_death_visible(player.dead)

func _on_evidence_collected(id: String) -> void:
	level_evidence_collected = true
	if exit_door:
		exit_door.set_unlocked(true)
	if hud:
		hud.set_hint("EVIDENCE RETRIEVED! HEAD TO THE EXIT DOOR.")

func _on_exit_reached() -> void:
	if not level_evidence_collected:
		if hud:
			hud.set_hint("DOOR LOCKED: YOU MUST COLLECT THE EVIDENCE FIRST!")
		return
	# Commit evidence permanently to global game manager
	GameManager.register_evidence(evidence_id)
	GameManager.complete_level()

func add_floor(center: Vector2, size: Vector2, col: Color = Color("233145")) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 6
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		-size / 2,
		Vector2(size.x / 2, -size.y / 2),
		size / 2,
		Vector2(-size.x / 2, size.y / 2)
	])
	visual.color = col
	body.add_child(visual)
	add_child(body)
	return body

# Virtual method overridden by individual levels
func build_level_geometry() -> void:
	pass

func _draw() -> void:
	if background_texture:
		draw_texture_rect(background_texture, Rect2(0, 0, 1280, 720), false)
	else:
		# Neo-noir default atmospheric background pillars
		for i in range(10):
			draw_rect(Rect2(i * 140, 100, 70, 520), Color("09121f"))
