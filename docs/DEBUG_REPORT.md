# BounceFlux gameplay debug report

Validated with Godot 4.7.2 on 2026-11-14, branch feature/core.

## Fixes

- Increased jump speed from -570 to -720: maximum theoretical rise increases from 108 to 173 pixels, enough for the 157-pixel power-station gantry.
- Thin generated ledges and moving platforms allow jumping through from below. Floors and walls remain solid.
- Moved warehouse and headquarters crates into gaps between catwalks, so they reach the lower patrol area instead of landing above guards.
- Initialized rooftop moving platforms at their actual starting position, avoiding a first-tick move from the world origin.
- Paused world actors explicitly; the controller remains active for Escape input.
- Prevented exits from committing during rewind, death, or an already pending completion, and checked the restored evidence state directly.
- Preserved living rewind snapshots during the death prompt instead of replacing them with three seconds of dead snapshots.

## Exact validation commands

Run from the repository root. Each command below exited 0 on its final run.

```sh
/Users/aryanverma/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path . --import --quit --log-file /tmp/bounceflux-import.log
/Users/aryanverma/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/core_smoke.gd --fixed-fps 60 --log-file /tmp/bounceflux-core_smoke.log
/Users/aryanverma/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/five_stages_smoke.gd --fixed-fps 60 --log-file /tmp/bounceflux-five_stages_smoke.log
/Users/aryanverma/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/gameplay_components_smoke.gd --fixed-fps 60 --log-file /tmp/bounceflux-gameplay_components_smoke.log
/Users/aryanverma/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/physical_interaction_smoke.gd --fixed-fps 60 --log-file /tmp/bounceflux-physical_interaction_smoke.log
/Users/aryanverma/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/level_routes.gd --fixed-fps 60 --log-file /tmp/bounceflux-level_routes.log
/Users/aryanverma/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/gameplay_regressions.gd --fixed-fps 60 --log-file /tmp/bounceflux-gameplay_regressions.log
git diff --check
```

All six test suites reported zero failures. Route tests physically complete each stage with movement/jump actions, collection and exit overlap, without teleporting the player or emitting collection/exit signals. Each stage is loaded separately; the existing progression suite checks five-stage continuity and ending. Regression tests isolate contacts by repositioning actors and check pause, crate shafts, guard knockout/contact death, active/inactive electricity, rewind restrictions, reversible evidence, and delayed death recovery.

Some sandboxed Godot invocations emitted a macOS system-certificate lookup error; successful final tests still returned 0 with no script/parser errors. This is separate from gameplay assertions.

## Touched paths

Gameplay: scripts/player.gd, scripts/level_manager.gd, scripts/rewind_manager.gd, scripts/levels/apartment.gd, scripts/levels/rooftops.gd, scenes/levels/warehouse.tscn, scenes/levels/headquarters.tscn.

Tests: tests/level_routes.gd, tests/gameplay_regressions.gd and their Godot UID files.

Documentation: docs/MANUAL_EDITING.md (jump setting), this report.

## Limits and remaining risks

- No manual gameplay, visual inspection, browser export, or subjective difficulty testing was performed.
- Routes verify a successful deterministic timing per stage, not every possible moving-platform or hazard phase. Crate knockout depends on patrol timing; regression tests isolate alignment to verify the mechanic.
- Jump height and one-way ledges change game feel and should receive a human playthrough.
- Level geometry is still built at runtime; editor drag-and-drop geometry editing remains a separate task.
- No changes were made to the guard/trap/evidence files owned by other agents. Unused crush-block behavior and the exported crate trigger-delay setting were not modified or validated.
