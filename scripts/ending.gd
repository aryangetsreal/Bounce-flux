extends Control

func _ready() -> void:
	$Center/VBox/RestartBtn.grab_focus()
	$Center/VBox/RestartBtn.pressed.connect(_on_restart_pressed)
	$Center/VBox/MenuBtn.pressed.connect(_on_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_restart_pressed()

func _on_restart_pressed() -> void:
	GameManager.new_game()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
