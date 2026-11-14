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

	# If rewind restored evidence to uncollected state, re-sync local level state
	if evidence_node and "collected" in evidence_node:
		if level_evidence_collected and not evidence_node.collected:
			level_evidence_collected = false
			if exit_door:
				exit_door.set_unlocked(false)
			if hud:
				hud.set_hint(level_hint)

	if hud:
		hud.set_paused(get_tree().paused)
		var rewind_frac := RewindManager.available_seconds() / 3.0
		hud.set_rewind_fraction(rewind_frac)
		hud.set_evidence(GameManager.evidence_count + (1 if level_evidence_collected else 0), 5)
		if player:
			hud.set_death_visible(player.dead)

func _on_evidence_collected(id: String) -> void:
	level_evidence_collected = true
	if evidence_node and "collected" in evidence_node:
		evidence_node.collected = true
	if exit_door:
		exit_door.set_unlocked(true)
	if hud:
		hud.set_hint("EVIDENCE RETRIEVED! HEAD TO THE EXIT DOOR.")

func _on_exit_reached() -> void:
	if not level_evidence_collected:
		if hud:
			hud.set_hint("DOOR LOCKED: YOU MUST COLLECT THE EVIDENCE FIRST!")
		return
	# Commit evidence permanently to global game manager and complete level deferred
	GameManager.register_evidence(evidence_id)
	GameManager.call_deferred("complete_level")

func add_floor(center: Vector2, size: Vector2, col: Color = Color("1a2436")) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 6
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	
	# Pixelated platform styling with top edge highlight and underside shadow
	var visual := Node2D.new()
	var top_highlight := Color("2c3b54")
	var dark_shadow := Color("0d141e")
	
	var base_poly := Polygon2D.new()
	base_poly.polygon = PackedVector2Array([
		-size / 2,
		Vector2(size.x / 2, -size.y / 2),
		size / 2,
		Vector2(-size.x / 2, size.y / 2)
	])
	base_poly.color = col
	visual.add_child(base_poly)

	# Stepped pixel border highlight on top edge
	if size.y >= 8:
		var edge_poly := Polygon2D.new()
		edge_poly.polygon = PackedVector2Array([
			-size / 2,
			Vector2(size.x / 2, -size.y / 2),
			Vector2(size.x / 2, -size.y / 2 + 4),
			Vector2(-size.x / 2, -size.y / 2 + 4)
		])
		edge_poly.color = top_highlight
		visual.add_child(edge_poly)

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
		# Pixelated minimalist skyline / silhouettes
		var building_dark := Color("0a0f17")
		var building_light := Color("101824")
		var window_dim := Color("1c2b3d")
		var window_lit := Color("2d4663")
		
		# Far building silhouettes
		for b in range(12):
			var bx: float = b * 115 - 30
			var bw: float = 90
			var bh: float = 320 + ((b * 37) % 220)
			draw_rect(Rect2(bx, 720 - bh, bw, bh), building_dark)
			# Small pixel windows (checkerboard)
			for wy in range(int(720 - bh + 20), 680, 28):
				for wx in range(int(bx + 12), int(bx + bw - 16), 20):
					var lit: bool = ((wy * 7 + wx * 13) % 5) == 0
					draw_rect(Rect2(wx, wy, 8, 12), window_lit if lit else window_dim)
