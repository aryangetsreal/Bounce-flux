extends CharacterBody2D

signal player_touched

@export var patrol_distance: float = 180.0
@export var speed: float = 110.0
@export var is_boss: bool = false
@export var texture: Texture2D

var origin_x: float = 0.0
var direction: float = 1.0
var disabled: bool = false
var anim_phase: float = 0.0

func _ready() -> void:
	add_to_group("rewindable")
	add_to_group("guards")
	origin_x = position.x

func _physics_process(delta: float) -> void:
	if RewindManager.is_rewinding:
		queue_redraw()
		return

	if disabled:
		velocity = Vector2.ZERO
		queue_redraw()
		return

	anim_phase += delta * 6.0
	velocity.x = direction * speed
	velocity.y = 900.0 * delta # light gravity in case placed on uneven ground

	var moved := move_and_slide()

	if position.x > origin_x + patrol_distance:
		direction = -1.0
	elif position.x < origin_x - patrol_distance:
		direction = 1.0
	elif is_on_wall():
		direction *= -1.0

	# Check collision with player
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and (collider.is_in_group("player") or collider.name == "Player"):
			player_touched.emit()
			if collider.has_method("die"):
				collider.die()
			elif "dead" in collider:
				collider.dead = true

	queue_redraw()

func knock_out() -> void:
	if not disabled:
		disabled = true
		velocity = Vector2.ZERO
		queue_redraw()

func capture_rewind_state() -> Dictionary:
	return {
		"position": position,
		"velocity": velocity,
		"direction": direction,
		"disabled": disabled,
		"anim_phase": anim_phase
	}

func restore_rewind_state(state: Dictionary) -> void:
	position = state.position
	velocity = state.velocity
	direction = state.direction
	disabled = state.disabled
	anim_phase = state.anim_phase
	queue_redraw()

func _draw() -> void:
	if texture:
		var size_rect := Rect2(-30, -50, 60, 60) if is_boss else Rect2(-20, -40, 40, 40)
		draw_texture_rect(texture, size_rect, false)
		return

	if is_boss:
		# Pixelated Crime Boss silhouette
		var coat_col := Color("181224") if not disabled else Color("383244")
		var lapel_col := Color("912c48") if not disabled else Color("4d313c")
		var hat_col := Color("120d1c") if not disabled else Color("2c2635")
		var gold_trim := Color("e8d07a")

		# Trenchcoat torso
		draw_rect(Rect2(-22, -44, 44, 44), coat_col)
		# Red lapels
		draw_rect(Rect2(-6, -40, 12, 34), lapel_col)
		# Shoulders
		draw_rect(Rect2(-26, -44, 52, 14), coat_col)
		# Boss Fedora (stepped pixels)
		draw_rect(Rect2(-24, -48, 48, 4), hat_col) # brim
		draw_rect(Rect2(-16, -58, 32, 10), hat_col) # crown
		draw_rect(Rect2(-16, -50, 32, 2), gold_trim) # hatband
		# Eyes / shadow
		draw_rect(Rect2(-10, -46, 20, 2), Color("000000"))
		if disabled:
			# Pixel stun stars
			draw_rect(Rect2(-8, -66, 4, 4), gold_trim)
			draw_rect(Rect2(4, -68, 4, 4), gold_trim)
	else:
		# Pixelated Standard Guard
		var armor_col := Color("182333") if not disabled else Color("2a3442")
		var visor_col := Color("e04545") if not disabled else Color("594040")
		var shadow_col := Color("0d141e")

		# Boots / legs
		draw_rect(Rect2(-12, -8, 8, 8), shadow_col)
		draw_rect(Rect2(4, -8, 8, 8), shadow_col)
		# Torso / tactical vest
		draw_rect(Rect2(-14, -36, 28, 28), armor_col)
		draw_rect(Rect2(-10, -32, 20, 18), shadow_col)
		# Helmet
		draw_rect(Rect2(-12, -48, 24, 12), armor_col)
		# Red visor horizontal pixel slit
		draw_rect(Rect2(-10, -42, 20, 4), visor_col)
		if disabled:
			draw_rect(Rect2(-2, -56, 4, 4), Color("e8d07a"))
