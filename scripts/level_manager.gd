extends Node2D

@export var is_menu: bool = false
@export var background_texture: Texture2D
var hud: Label
var platform: MovingPlatform

class MovingPlatform extends AnimatableBody2D:
	var phase: float = 0.0
	func _ready() -> void:
		add_to_group("rewindable")
		sync_to_physics = false
		var collider := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(150, 22)
		collider.shape = shape
		add_child(collider)
	func _physics_process(delta: float) -> void:
		if not RewindManager.is_rewinding:
			phase += delta
			position = Vector2(625 + sin(phase) * 95, 475)
		queue_redraw()
	func capture_rewind_state() -> Dictionary:
		return {"position": position, "phase": phase}
	func restore_rewind_state(state: Dictionary) -> void:
		position = state.position
		phase = state.phase
	func _draw() -> void:
		draw_rect(Rect2(-75, -11, 150, 22), Color("e9ae55"))

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not is_menu:
		RewindManager.clear_history()
		add_floor(Vector2(210, 650), Vector2(420, 100))
		add_floor(Vector2(1050, 650), Vector2(460, 100))
		add_floor(Vector2(350, 520), Vector2(160, 24))
		add_floor(Vector2(945, 470), Vector2(180, 24))
		platform = MovingPlatform.new()
		platform.position = Vector2(625, 475)
		platform.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(platform)
		$Player.process_mode = Node.PROCESS_MODE_PAUSABLE
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(40, 30)
	hud.add_theme_font_size_override("font_size", 23)
	layer.add_child(hud)
	if is_menu:
		hud.text = "BOUNCEFLUX\n\nA soul trapped in a ball. A three-second temporal anchor.\n\nEnter / Space — begin\nA/D or arrows — move    Space — jump\nHold R — rewind    Esc — pause\n\nApartment • playable foundation"
	queue_redraw()

func add_floor(center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([-size / 2, Vector2(size.x / 2, -size.y / 2), size / 2, Vector2(-size.x / 2, size.y / 2)])
	visual.color = Color("31445e")
	body.add_child(visual)
	add_child(body)

func _process(_delta: float) -> void:
	if is_menu:
		if Input.is_action_just_pressed("ui_accept"):
			GameManager.new_game()
		return
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
	var status := "PAUSED • Esc to resume" if get_tree().paused else "Apartment • A/D move • Space jump • hold R rewind"
	if $Player.dead:
		status = "Fell into the void • Hold R to recover • Space resets checkpoint"
	hud.text = "%s\nRewind %.1f / 3.0 s • Evidence %d / 5\nCross the gap on the amber platform. Rewind reverses both you and the platform." % [status, RewindManager.available_seconds(), GameManager.evidence_count]

func _draw() -> void:
	if background_texture:
		draw_texture_rect(background_texture, Rect2(0, 0, 1280, 720), false)
	else:
		for i in range(8):
			draw_rect(Rect2(i * 180, 160, 100, 440), Color("0c172b"))
