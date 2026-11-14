@tool
extends Node2D

# A replaceable visual; the independently editable collider owns platform size.
@export var collider_path: NodePath = ^"../Collider"
@export var texture: Texture2D:
	set(value):
		texture = value
		queue_redraw()
@export var base_color: Color = Color("1a2436"):
	set(value):
		base_color = value
		queue_redraw()
@export var edge_color: Color = Color("2c3b54"):
	set(value):
		edge_color = value
		queue_redraw()
@export var rivets: bool = false:
	set(value):
		rivets = value
		queue_redraw()

func _ready() -> void:
	set_process(Engine.is_editor_hint())
	queue_redraw()

func _process(_delta: float) -> void:
	# Reflect shape-handle edits in the 2D editor without running gameplay.
	queue_redraw()

func _draw() -> void:
	var collider := get_node_or_null(collider_path) as CollisionShape2D
	if not collider or not collider.shape is RectangleShape2D:
		return
	var size: Vector2 = collider.shape.size
	var bounds := Rect2(-size / 2, size)
	if texture:
		draw_texture_rect(texture, bounds, false)
		return
	draw_rect(bounds, base_color)
	if size.y >= 8:
		draw_rect(Rect2(bounds.position, Vector2(size.x, 4)), edge_color)
	if rivets:
		for x in range(int(-size.x / 2 + 12), int(size.x / 2 - 8), 24):
			draw_rect(Rect2(x, -2, 4, 4), base_color.darkened(0.4))
