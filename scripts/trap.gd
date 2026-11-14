extends CharacterBody2D

signal trap_triggered
signal trap_landed

enum TrapType { CRATE, ELECTRICAL, CRUSH_BLOCK }

@export var trap_type: TrapType = TrapType.CRATE
@export var trigger_delay: float = 0.2
@export var fall_speed: float = 750.0
@export var cycle_time: float = 2.0
@export var texture: Texture2D

var initial_position: Vector2 = Vector2.ZERO
var triggered: bool = false
var landed: bool = false
var time_elapsed: float = 0.0
var active_hazard: bool = false

func _ready() -> void:
	add_to_group("rewindable")
	add_to_group("traps")
	initial_position = position

func _physics_process(delta: float) -> void:
	if RewindManager.is_rewinding:
		queue_redraw()
		return

	time_elapsed += delta

	match trap_type:
		TrapType.CRATE:
			_process_crate(delta)
		TrapType.ELECTRICAL:
			_process_electrical(delta)
		TrapType.CRUSH_BLOCK:
			_process_crush_block(delta)

	queue_redraw()

func _process_crate(delta: float) -> void:
	if triggered and not landed:
		velocity.y = move_toward(velocity.y, fall_speed, 1200.0 * delta)
		var collision := move_and_collide(velocity * delta)
		if collision:
			landed = true
			velocity = Vector2.ZERO
			trap_landed.emit()
			var collider := collision.get_collider()
			if collider:
				if collider.has_method("knock_out"):
					collider.knock_out()
				elif collider.is_in_group("player") or collider.name == "Player":
					if "dead" in collider:
						collider.dead = true
	else:
		velocity = Vector2.ZERO

func _process_electrical(delta: float) -> void:
	# Cycles on and off deterministically based on cycle_time
	var cycle_pos: float = fmod(time_elapsed, cycle_time)
	var was_active := active_hazard
	active_hazard = cycle_pos < (cycle_time * 0.5)

	if active_hazard:
		# Check overlap with player
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsShapeQueryParameters2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(40, 60)
		query.shape = shape
		query.transform = transform
		query.collision_mask = 2 # Player layer
		var results := space_state.intersect_shape(query, 1)
		for res in results:
			var collider = res.collider
			if collider and (collider.is_in_group("player") or collider.name == "Player"):
				if "dead" in collider:
					collider.dead = true

func _process_crush_block(delta: float) -> void:
	# Periodic descending block (e.g. Headquarters / rooftops)
	var t: float = sin(time_elapsed * 2.0)
	var target_y := initial_position.y + maxf(0.0, t) * 160.0
	position.y = target_y
	
	# Check collision with player below
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and (collider.is_in_group("player") or collider.name == "Player"):
			if collision.get_normal().y < -0.5: # Crushing down
				if "dead" in collider:
					collider.dead = true

func trigger_trap() -> void:
	if not triggered:
		triggered = true
		trap_triggered.emit()

func capture_rewind_state() -> Dictionary:
	return {
		"position": position,
		"velocity": velocity,
		"triggered": triggered,
		"landed": landed,
		"time_elapsed": time_elapsed,
		"active_hazard": active_hazard
	}

func restore_rewind_state(state: Dictionary) -> void:
	position = state.position
	velocity = state.velocity
	triggered = state.triggered
	landed = state.landed
	time_elapsed = state.time_elapsed
	active_hazard = state.active_hazard
	queue_redraw()

func _draw() -> void:
	if texture:
		draw_texture_rect(texture, Rect2(-24, -24, 48, 48), false)
		return

	match trap_type:
		TrapType.CRATE:
			# Wooden warehouse cargo crate
			draw_rect(Rect2(-24, -24, 48, 48), Color("82542a"))
			draw_rect(Rect2(-20, -20, 40, 40), Color("a66d3b"))
			draw_line(Vector2(-20, -20), Vector2(20, 20), Color("5c3818"), 3.0)
			draw_line(Vector2(20, -20), Vector2(-20, 20), Color("5c3818"), 3.0)
		TrapType.ELECTRICAL:
			# Neon/cyan electrical arcs when active, dark metal pylons when dormant
			draw_rect(Rect2(-20, -30, 40, 60), Color("1a2233"))
			if active_hazard:
				# Electric sparks
				var col := Color("61e3ec")
				draw_rect(Rect2(-16, -26, 32, 52), Color(0.2, 0.8, 1.0, 0.25))
				draw_line(Vector2(-12, -20), Vector2(6, -6), col, 3.0)
				draw_line(Vector2(6, -6), Vector2(-8, 8), col, 3.0)
				draw_line(Vector2(-8, 8), Vector2(10, 22), col, 3.0)
			else:
				draw_line(Vector2(-12, 0), Vector2(12, 0), Color("3d4b63"), 2.0)
		TrapType.CRUSH_BLOCK:
			# Heavy industrial metal piston block
			draw_rect(Rect2(-32, -32, 64, 64), Color("3a4659"))
			draw_rect(Rect2(-28, -28, 56, 56), Color("242d3d"))
			# Amber warning hazard stripes
			for x in range(-24, 24, 16):
				draw_line(Vector2(x, -20), Vector2(x + 10, 20), Color("e9ae55"), 3.0)
