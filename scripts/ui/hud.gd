extends Control

@onready var evidence_label: Label = $TopBar/HBox/EvidenceLabel
@onready var rewind_bar: ProgressBar = $TopBar/HBox/RewindBar
@onready var stage_label: Label = $TopBar/HBox/StageLabel
@onready var hint_label: Label = $HintLabel
@onready var death_banner: Label = $DeathBanner
@onready var pause_overlay: Panel = $PauseOverlay

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if pause_overlay:
		pause_overlay.visible = false
	if death_banner:
		death_banner.visible = false

func set_stage_name(title: String) -> void:
	if stage_label:
		stage_label.text = title

func set_evidence(count: int, total: int = 5) -> void:
	if evidence_label:
		evidence_label.text = "EVIDENCE: %d / %d" % [count, total]

func set_rewind_fraction(val: float) -> void:
	if rewind_bar:
		rewind_bar.value = clampf(val, 0.0, 1.0) * 100.0

func set_hint(text: String) -> void:
	if hint_label:
		hint_label.text = text

func set_death_visible(is_dead: bool) -> void:
	if death_banner:
		death_banner.visible = is_dead

func set_paused(is_paused: bool) -> void:
	if pause_overlay:
		pause_overlay.visible = is_paused
