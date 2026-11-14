# BounceFlux — Locked 4-hour game specification (v1)

## Identity
Working title: BounceFlux (rename display title only if team agrees). Genre: 2D side-view puzzle platformer. Theme: Bouncing Back. Target: 5–8 minutes, desktop keyboard, browser on itch.io. Engine: a single installed Godot 4.x stable version on both Macs; GDScript only; Compatibility renderer; 1280×720 landscape.

## Story
Murdered investigator's soul inhabits a bouncing ball after a temporal book malfunction. A three-second temporal anchor prevents undoing his murder. Collect five records exposing a crime boss. Tell story with 3–4 short static panels and sparse in-game captions, no cutscene engine.

## Non-negotiable gameplay
- Left/Right or A/D: horizontal movement; Space: jump with satisfying bounce squash/stretch; hold R: rewind up to 3 seconds, release R: resume; Esc: pause; Enter or Space: menu selection.
- A controllable CharacterBody2D with horizontal acceleration, friction, gravity, jump forgiveness (coyote time ~0.10s) and jump buffer (~0.10s). Visual sprite rotates independent of physical collider. No mandatory mouse interaction or complicated charge mechanic.
- Snapshot rewind at physics ticks (60 Hz, up to 180 snapshots per rewindable instance). Restore state while physics actions are suppressed, including player position/velocity, enemy position/state, trap states, and evidence active status. During rewind, no new snapshots or interactions. On release, discard future history. `queue_free` prohibited for rewindable instances before the level is completed. On death: offer R if history exists, otherwise reset to checkpoint.
- Five micro-stages, each with one evidence and one exit, reusing existing mechanics and components: (1) apartment — movement and rewind tutorial; (2) warehouse — one patrolling guard and falling crate; (3) power station — timed electrical hazard; (4) rooftops — short precision bounce/platform sequence; (5) headquarters — combine an existing timed hazard with two switches or two traps; boss is a simple guard with a distinct silhouette. Target ~1–2 minutes per stage; keep layouts compact and reuse scenes/props rather than building new systems.
- Evidence is acquired by touch; no RPG inventory. HUD shows evidence count and rewind availability. Evidence remains reversible until a level exit is reached; stage completion commits progress in GameManager. No manual evidence-carrying animation.
- Guard: simple patrol with deterministic direction and bounds, collision with player causes death, falling crate can disable it. No full stealth, pathfinding, complex shooting or combat AI.
- A level is completed by reaching its exit after collecting evidence. Last level shows ending and restart/main menu.
- Must run with placeholders: all gameplay collisions use shapes independent of art. Scene layout cannot require AI images. Use flat gradients/polygons and ColorRect/Polygon2D placeholders; hot-swappable Sprite2D art later.

## Art contract
- Art is optional and swappable at any moment; never merge gameplay collider and visuals.
- Asset path conventions: res://assets/characters/ball.png, guard.png, boss.png; res://assets/backgrounds/apartment.png, warehouse.png, power_station.png, rooftops.png, headquarters.png; res://assets/props/crate.png, evidence.png; res://assets/ui/ (all optional).
- Absence of asset MUST NOT prevent project import or play. Use procedural drawings/placeholders by default. Future generated images must require only replacing a texture or assigning an exported property, not reauthoring scenes.
- Minimalist neo-noir 2D pixel art (current coordinator override): background #101827, secondary #1D2940, time/rewind #48D9E8, evidence #F0C674, hazards #E66B55, light text #E9EDF2. Use readable pixel silhouettes and replaceable placeholders; visuals never change gameplay interfaces. Parallax is optional and cosmetic.
- Audio optional; all AudioStreamPlayer references null-safe and game runs silently without files. CC0/compatible licenses only; track provenance in docs/ASSET_CREDITS.md.

## Fixed interface contracts
- Every rewindable instance belongs to group `rewindable`, has `func capture_rewind_state() -> Dictionary` and `func restore_rewind_state(state: Dictionary) -> void`; manager identifies nodes by stable instance ID and stores references only during a single active level. If object is unavailable, skip safely.
- RewindManager is an autoload at res://scripts/rewind_manager.gd with `is_rewinding: bool`; script APIs `register`/`unregister` are optional if group scan is used. Single owner: Codex. Rewind snapshots grouped per physics tick and applied in reverse sequence. Node state restoration order deterministic.
- GameManager autoload at res://scripts/game_manager.gd; exposes `evidence_count: int`, `current_level: int`, `register_evidence(id: String)`, `complete_level()`; reset on new game. Do not count same evidence twice. Single owner: Codex.
- Collectible emits `evidence_collected(id: String)`, triggers GameManager only on level completion via level controller to avoid rewind paradoxes. If a local evidence marker is needed use a per-level flag.
- All scripts use Godot 4 style typing where practical. Avoid `get_node` paths across scenes; favor exported NodePath, signals, groups, or parent-owned references.

## Folder ownership
- Codex owns project.godot, scripts/player.gd, scripts/rewind_manager.gd, scripts/game_manager.gd, scripts/level_manager.gd, scenes/player.tscn, scenes/game.tscn, scenes/main_menu.tscn, scenes/levels/*.tscn and final integration.
- Gemini owns scripts/guard.gd, scripts/trap.gd, scripts/evidence.gd and isolated scenes/guard.tscn, scenes/trap.tscn, scenes/evidence.tscn. No edits to Codex-owned files; submit branch for integration.
- Claude supplies code suggestions or isolated scripts/scenes under ui/, scripts/ui/ and docs/reviews/, only via human copy or isolated feature branch. No shared project.godot edits.
- ChatGPT provides strategy, prompt revisions and reviews; it is not an automatic repo collaborator.

## Definition of done
- Fresh clone imports in the chosen Godot version without parser errors.
- Keyboard-only game starts, player jumps/rolls, R rewinds visible player AND at least one independently moving environmental object, and resumes correctly.
- Player death has working recovery or checkpoint reset; guards/traps functional.
- Five evidence pieces and five exits lead to win/ending; menu restart works.
- No missing image/audio breaks the game.
- Browser export runs on itch.io in a normal desktop browser and source pushed to fork main.

## Scope guardrails
NO online multiplayer, inventory RPG, dialogue branching, pathfinding, seven stages, complex character animation sheets, shader dependency, new plugins, boss health system, save files, procedural world generation or additional time powers.

## Failure policy
At t=90min if rewind still broken, reduce to player-only rewind plus one movable trap. At t=150min if stage 2 is not complete, reuse a level scene with new hazard positions; prioritize a complete playable experience over unfinished levels; reuse compact level templates for stages 3–5. Stop new features at t=180min. Reserve last 45–60min for export and test. Never claim tested unless Godot was run and logs reviewed.
