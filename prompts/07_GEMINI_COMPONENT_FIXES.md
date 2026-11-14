Send to Gemini in a separate clone. Supply the current component files and docs/INTERFACES.md. Bring back complete changed files, the defect report and actual validation output. This is an audit of existing components, not a request to rebuild them.

```text
1. Objective
Audit and fix reproducible defects in BounceFlux's existing guard, trap and evidence components. Preserve working behavior; no new mechanics. Inspect trigger_delay being unused, electrical collision/query alignment under parent transforms, interaction suppression during rewind, and dead-player pickup. Change only verified defects.

2. Existing interfaces
Baseline bcd2996 in github.com/aryangetsreal/Bounce-flux. Read AGENTS.md, docs/GAME_SPEC.md and supplied docs/INTERFACES.md. Work in your separate clone on feature/gameplay-fixes. Groups: player/guards/traps/rewindable. Rewindables implement capture_rewind_state() -> Dictionary and restore_rewind_state(state: Dictionary) -> void. RewindManager.is_rewinding suppresses simulation/interactions. Player exposes die(), dead. Guard emits player_touched and exposes knock_out(). Trap enum CRATE=0/ELECTRICAL=1/CRUSH_BLOCK=2; trigger_trap(), trap_triggered, trap_landed. Evidence emits evidence_collected(id: String); never commits global evidence. Keep existing exports, defaults and public names. Current visuals are minimalist neo-noir pixel art.

3. Allowed files
scripts/guard.gd, scripts/trap.gd, scripts/evidence.gd, scenes/guard.tscn, scenes/trap.tscn, scenes/evidence.tscn. May create tests/specialist_components.gd and docs/reviews/gameplay_fixes.md.

4. Forbidden files/actions
All other files: especially project.godot, player/managers, level scripts/scenes, UI, menus and existing tests. No shared-directory edits, pushes, main merge, publication or deletion of important files.

5. Output
Complete changed files with full repository paths, each in its own code block, no partial snippets. Built-in Godot nodes only; optional textures, no required assets. Include verified-defects table, exact validation commands and actual output, and a commit hash if committed locally. Explicitly label untested claims.

6. Acceptance
Existing interfaces preserved; no collection or trigger during rewind; no dead-player pickup; deterministic rewindable timers; guard/crate/electric behavior still works; no parser errors or missing resources. Do not rewrite functioning systems.

7. Integration
Return files and report through the human. Codex reviews ownership, diff and contracts, runs headless import, component regressions and five-stage routes, then commits compatible changes on its working branch. Human approval is required before push or main merge.
```
