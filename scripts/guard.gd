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
		# Crime Boss silhouette: wider, distinct coat and hat/glow
		var body_col := Color("1e182e") if not disabled else Color("443c55")
		var accent_col := Color("993850") if not disabled else Color("554a5a")
		draw_rect(Rect2(-24, -50, 48, 50), body_col)
		draw_circle(Vector2(0, -56), 16, accent_col)
		# Eyes or hat rim
		draw_line(Vector2(-18, -50), Vector2(18, -50), Color("c49a45"), 4.0)
		if disabled:
			# Stun indicator
			draw_arc(Vector2(0, -80), 10, 0, 6.28, 12, Color("e8d07a"), 2.0)
	else:
		# Standard Guard: Navy/charcoal silhouette with red visor/accent
		var body_col := Color("141c2c") if not disabled else Color("323a48")
		var visor_col := Color("d64747") if not disabled else Color("6e5959")
		draw_rect(Rect2(-16, -42, 32, 42), body_col)
		draw_circle(Vector2(0, -48), 12, body_col)
		draw_line(Vector2(-10, -48), Vector2(10, -48), visor_col, 3.0)
		if disabled:
			draw_arc(Vector2(0, -68), 8, 0, 6.28, 8, Color("e8d07a"), 2.0)
