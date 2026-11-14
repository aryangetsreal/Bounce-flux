extends CharacterBody2D

@export var texture: Texture2D
const SPEED: float = 330.0
const ACCELERATION: float = 1800.0
const GRAVITY: float = 1500.0
# The tallest required step is the power-station gantry (157 px).
const JUMP_SPEED: float = -720.0

@export_group("Movement")
@export var move_speed: float = SPEED
@export var acceleration: float = ACCELERATION
@export var gravity: float = GRAVITY
@export var jump_speed: float = JUMP_SPEED

var coyote: float = 0.0
var jump_buffer: float = 0.0
var dead: bool = false
var visual_angle: float = 0.0
var stretch := Vector2.ONE
var checkpoint := Vector2(100, 560)

func _ready() -> void:
	add_to_group("rewindable")
	add_to_group("player")
	checkpoint = position

func _physics_process(delta: float) -> void:
	if RewindManager.is_rewinding:
		queue_redraw()
		return
	if dead:
		if RewindManager.history.is_empty() or Input.is_action_just_pressed("jump"):
			reset_checkpoint()
		return

	coyote = 0.10 if is_on_floor() else maxf(0.0, coyote - delta)
	jump_buffer = 0.10 if Input.is_action_just_pressed("jump") else maxf(0.0, jump_buffer - delta)
	var axis := Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, axis * move_speed, acceleration * delta)
	velocity.y += gravity * delta
	if coyote > 0.0 and jump_buffer > 0.0:
		velocity.y = jump_speed
		coyote = 0.0
		jump_buffer = 0.0
		stretch = Vector2(0.78, 1.22)

	var was_grounded := is_on_floor()
	move_and_slide()
	if not was_grounded and is_on_floor():
		stretch = Vector2(1.25, 0.75)
	stretch = stretch.lerp(Vector2.ONE, minf(delta * 12.0, 1.0))
	visual_angle += velocity.x * delta / 22.0

	if position.y > 850:
		die()

	queue_redraw()

func die() -> void:
	if not dead:
		dead = true
		velocity = Vector2.ZERO
		queue_redraw()

func reset_checkpoint() -> void:
	position = checkpoint
	velocity = Vector2.ZERO
	dead = false
	coyote = 0.0
	jump_buffer = 0.0
	RewindManager.clear_history()

func capture_rewind_state() -> Dictionary:
	return {
		"position": position,
		"velocity": velocity,
		"dead": dead,
		"angle": visual_angle,
		"stretch": stretch,
		"coyote": coyote,
		"buffer": jump_buffer
	}

func restore_rewind_state(state: Dictionary) -> void:
	position = state.position
	velocity = state.velocity
	dead = state.dead
	visual_angle = state.angle
	stretch = state.stretch
	coyote = state.coyote
	jump_buffer = state.buffer
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, visual_angle, stretch)
	if texture:
		draw_texture_rect(texture, Rect2(-22, -22, 44, 44), false)
	else:
		# 2D Pixelated minimalist ball
		var body_col := Color("4deeea") if not dead else Color("e0536c")
		var shadow_col := Color("1f5c6b") if not dead else Color("6e2433")
		var eye_col := Color("0b1726")
		var glint_col := Color("d8ffff")
		
		# Stepped pixel-circle silhouette (radius ~22)
		draw_rect(Rect2(-14, -22, 28, 44), body_col)
		draw_rect(Rect2(-20, -18, 40, 36), body_col)
		draw_rect(Rect2(-22, -14, 44, 28), body_col)
		
		# Pixel bottom shadow / bevel
		draw_rect(Rect2(-12, 16, 24, 4), shadow_col)
		draw_rect(Rect2(-18, 12, 36, 4), shadow_col)
		
		# Detective fedora / visor glint line (pixel-aligned)
		draw_rect(Rect2(-6, -14, 8, 4), glint_col)
		# Slit gaze / investigator eye band
		draw_rect(Rect2(-10, -4, 20, 6), eye_col)
		draw_rect(Rect2(-6, -2, 6, 4), Color("e8d07a")) # amber focus glint
	draw_set_transform(Vector2.ZERO)
