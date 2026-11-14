@tool
extends Node2D

@export var texture: Texture2D:
	set(value):
		texture = value
		queue_redraw()
@export var background_color: Color = Color("101827"):
	set(value):
		background_color = value
		queue_redraw()
@export var near_color: Color = Color("1d2940"):
	set(value):
		near_color = value
		queue_redraw()
@export var far_color: Color = Color("0a0f17"):
	set(value):
		far_color = value
		queue_redraw()

func _draw() -> void:
	if texture:
		draw_texture_rect(texture, Rect2(0, 0, 1280, 720), false)
		return
	draw_rect(Rect2(0, 0, 1280, 720), background_color)
	for building in range(12):
		var x: float = building * 115 - 30
		var height: float = 320 + ((building * 37) % 220)
		draw_rect(Rect2(x, 720 - height, 90, height), far_color)
		for y in range(int(720 - height + 20), 680, 28):
			for window_x in range(int(x + 12), int(x + 74), 20):
				var lit: bool = ((y * 7 + window_x * 13) % 5) == 0
				draw_rect(Rect2(window_x, y, 8, 12), near_color.lightened(0.1) if lit else near_color)
