Send to Claude with current scripts/ui/hud.gd, scenes/ui/hud.tscn and docs/INTERFACES.md. Bring back all three complete HUD files and validation report. This supersedes older HUD method names and smooth-art instructions.

```text
1. Objective
Return the existing pixel HUD you previously produced if available. Otherwise adapt the supplied working HUD to a CanvasLayer root and minimalist neo-noir pixel styling. Preserve functionality; fix real errors only.

2. Existing interfaces
Exactly these public update methods:
set_stage_name(title: String)
set_evidence(count: int, total: int = 5)
set_rewind_fraction(val: float)
set_hint(text: String)
set_death_visible(is_dead: bool)
set_paused(is_paused: bool)
No gameplay singleton dependencies. Clamp rewind to 0..1. HUD updates while paused. Every Control descendant uses MOUSE_FILTER_IGNORE; CanvasLayer has no mouse_filter property. The level controller accepts CanvasLayer directly and temporarily supports the existing Control HUD.

3. Allowed files
scripts/ui/hud.gd, scripts/ui/pixel_theme.gd, scenes/ui/hud.tscn only.

4. Forbidden files/actions
All other files, including menus, levels, managers, player, components, tests and project.godot. No shared-directory edits, push, publication or main merge.

5. Output
Complete files with full repository paths, each in its own code block; no partial snippets. Built-in Godot nodes/fonts/styles only, no required assets. Include root/child structure, exact tested commands and real output if Godot is available; label untested work.

6. Acceptance
CanvasLayer root, all six methods callable, evidence and long stage names fit at 1280x720, readable hint/death/pause states, every Control ignores mouse, no missing resources or parser errors. Palette: #101827 background, #1D2940 secondary, #48D9E8 rewind, #F0C674 evidence, #E66B55 hazards, #E9EDF2 text. Keyboard-only game.

7. Integration
Human returns all three files to Codex. Codex reviews ownership, resources and interfaces, runs headless import and HUD/gameplay checks, then commits compatible work. Do not replace other functioning systems.
```
