# BounceFlux frozen public interfaces

Baseline: bcd2996; frozen for editor-level integration on 2026-11-14. Existing five stages, input actions and collision layers remain unchanged. The current user direction is minimalist neo-noir pixel art, overriding older smooth-art prompts.

## Ownership and handoff

Codex: project.godot, player, rewind/game/level managers, level scripts/scenes, reusable level geometry, triggers, backgrounds, editor guide, integration and exports. Gemini: scripts/{guard,trap,evidence}.gd and scenes/{guard,trap,evidence}.tscn. Claude: scripts/ui/{hud,pixel_theme}.gd and scenes/ui/hud.tscn. Specialist work is relayed by the human; no shared working directory edits. Contributions require review, actual Godot validation and focused commits. No push, main merge or publication without fresh explicit human approval for that action.

## Rewind

Autoload RewindManager at res://scripts/rewind_manager.gd:

- is_rewinding: bool (read by gameplay; no normal simulation/interactions while true)
- history: Array[Array], MAX_SNAPSHOTS = 180; 60 Hz, up to three seconds
- clear_history() -> void
- available_seconds() -> float
- capture_after_tick() -> void (manager-owned scheduling; components must not call it)

Each actor joins rewindable and implements capture_rewind_state() -> Dictionary and restore_rewind_state(state: Dictionary) -> void. Snapshot dictionaries are private to that actor, deep-copied by the manager. Do not free rewindable nodes before leaving a level. Restore does not emit collection/contact/trigger signals. Stable instance IDs identify actors within one active level. Consumed future history is discarded. Preserve available living history at death.

## Player

CharacterBody2D; groups player and rewindable. Public die() -> void, reset_checkpoint() -> void, dead: bool, velocity: Vector2, and rewind methods above. No player signals currently exist: do not assume or introduce signal names. Existing components may call die(); guard also emits player_touched. Optional texture: Texture2D. Movement defaults: SPEED 330, ACCELERATION 1800, GRAVITY 1500, JUMP_SPEED -720. Inspector overrides may be added without renaming these constants or changing defaults.

## Collision layers and input

World/platforms layer 1; player layer 2/mask 5; guards/traps layer 4. Guard mask 3, trap mask 7. Collectibles/exits detect layer 2. Actions: move_left (A/Left), move_right (D/Right), jump (Space/Up/W), rewind (R), pause (Escape); ui_accept handles menu selection.

## Guard

scripts/guard.gd, scenes/guard.tscn; CharacterBody2D, groups guards and rewindable. Signal player_touched (no arguments). knock_out() -> void. Exports patrol_distance: float = 180, speed: float = 110, is_boss: bool = false, texture: Texture2D. Public disabled: bool, direction: float, origin_x: float, anim_phase: float and rewind methods. Rewind covers transform, velocity, patrol direction, disabled state and animation. No health/combat/pathfinding additions.

## Trap

scripts/trap.gd, scenes/trap.tscn; CharacterBody2D, groups traps and rewindable. enum TrapType { CRATE = 0, ELECTRICAL = 1, CRUSH_BLOCK = 2 }. Signals trap_triggered and trap_landed (no arguments). trigger_trap() -> void. Exports trap_type, trigger_delay: float = 0.2, fall_speed: float = 750, cycle_time: float = 2, texture: Texture2D. Public initial_position: Vector2, triggered: bool, landed: bool, time_elapsed: float, active_hazard: bool. Rewind restores position/velocity, trigger/landed flags, cycle timer and active state. Add private state only if needed to implement existing behavior; no new mechanics.

## Evidence and exit

Evidence: Area2D, group rewindable, signal evidence_collected(id: String); exports evidence_id: String and optional texture: Texture2D; public collected: bool, pulse_time: float. Rewind restores collection/monitoring/pulse. No global progression writes in this component. No collection during rewind or death.

Exit: Area2D, signal exit_reached (no arguments), set_unlocked(val: bool) -> void, locked: bool. Level controller owns validation, defers transition and rejects rewind/dead/duplicate completion. Keep Player, Evidence, ExitDoor root child names in all level scenes.

## Progression

GameManager autoload: evidence_count: int, current_level: int, committed_evidence: Dictionary; signals evidence_updated(count: int, total: int), level_changed(level_index: int). new_game(), load_level(level_num: int), register_evidence(id: String), complete_level(), restart_current_level(). Evidence remains local/reversible until exit; only the controller commits it. Five stage paths remain apartment, warehouse, power_station, rooftops, headquarters; then ending.

## HUD — authoritative current contract

Target root CanvasLayer, scripts/ui/hud.gd, optional scripts/ui/pixel_theme.gd, scenes/ui/hud.tscn. Exactly these six public update methods, no gameplay dependencies:

- set_stage_name(title: String)
- set_evidence(count: int, total: int = 5)
- set_rewind_fraction(val: float) (clamp to 0..1)
- set_hint(text: String)
- set_death_visible(is_dead: bool)
- set_paused(is_paused: bool)

All Control descendants use MOUSE_FILTER_IGNORE; HUD processes while paused. CanvasLayer itself has no mouse_filter property. Existing Control-root HUD remains accepted temporarily through a controller adapter, until Claude's CanvasLayer version is handed over. Codex changes hud's internal type from Control to Node to support both roots without renaming any methods. Older prompts' set_evidence_count/show_hint are obsolete; do not implement those instead.

Palette: background #101827, secondary #1D2940, rewind #48D9E8, evidence #F0C674, hazard #E66B55, text #E9EDF2. Built-in nodes/fonts/drawing; all external textures optional.
