extends Node2D

@export var level_index: int = 1
@export var stage_title: String = "STAGE 1: DETECTIVE'S APARTMENT"
@export var level_hint: String = "A/D to move • Space to jump • Hold R to rewind 3s"
@export var evidence_id: String = "evidence_1"

var hud: Node
var exit_door: Node2D
var evidence_node: Node2D
var player: CharacterBody2D
var level_evidence_collected: bool = false
var completing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# F6 runs a level directly, bypassing GameManager.load_level().
	GameManager.current_level = level_index
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
	# This controller stays active to handle Escape; world actors must pause.
	for child in get_children():
		if child is Node2D:
			child.process_mode = Node.PROCESS_MODE_PAUSABLE
	queue_redraw()

func _setup_hud() -> void:
	var hud_scene = load("res://scenes/ui/hud.tscn")
	if hud_scene:
		hud = hud_scene.instantiate()
		if hud is CanvasLayer:
			add_child(hud)
		else:
			# Compatibility with the current Control HUD until Claude hands over.
			var canvas := CanvasLayer.new()
			add_child(canvas)
			canvas.add_child(hud)
		_ignore_hud_mouse(hud)
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
	if RewindManager.is_rewinding or (player and player.dead):
		return
	level_evidence_collected = true
	if evidence_node and "collected" in evidence_node:
		evidence_node.collected = true
	if exit_door:
		exit_door.set_unlocked(true)
	if hud:
		hud.set_hint("EVIDENCE RETRIEVED! HEAD TO THE EXIT DOOR.")

func _on_exit_reached() -> void:
	if completing or RewindManager.is_rewinding or (player and player.dead):
		return
	if not level_evidence_collected or not evidence_node.collected:
		if hud:
			hud.set_hint("DOOR LOCKED: YOU MUST COLLECT THE EVIDENCE FIRST!")
		return
	# Commit evidence permanently to global game manager and complete level deferred
	completing = true
	GameManager.register_evidence(evidence_id)
	GameManager.call_deferred("complete_level")

func _ignore_hud_mouse(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_hud_mouse(child)
