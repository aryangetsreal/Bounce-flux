# BounceFlux — Manual Editing Guide (Godot Editor)

This guide documents how to manually adjust, edit, and theme BounceFlux levels and mechanics inside the Godot 4.x 2D editor.

---

## 1. Scene Structure & Reusable Templates
All levels reside in `res://scenes/levels/`:
- `apartment.tscn` (Stage 1)
- `warehouse.tscn` (Stage 2)
- `power_station.tscn` (Stage 3)
- `rooftops.tscn` (Stage 4)
- `headquarters.tscn` (Stage 5)

Each level scene is composed of independent, reusable nodes:
- `Player`: `res://scenes/player.tscn`
- `Evidence`: `res://scenes/evidence.tscn`
- `ExitDoor`: `res://scenes/exit_door.tscn`
- `Guard` / `BossGuard`: `res://scenes/guard.tscn`
- `Trap` (Crate, Electric, Crush Block): `res://scenes/trap.tscn`
- Static platforms and interactive moving platforms.

---

## 2. Moving Platforms & Geometry

### In the 2D Viewport:
- **Move platforms / floors**: Select any `StaticBody2D` or `AnimatableBody2D` node in the Scene tree and drag or use the Inspector's `Transform > Position`.
- **Resize collision & visuals**:
  1. Expand the platform node and click `CollisionShape2D`.
  2. In the Inspector under `Shape > Size`, set `(x, y)` to your desired dimensions.
  3. Update the matching `Polygon2D` visual polygon points or drag the handles directly in the 2D viewport.

---

## 3. Adjusting Player Jump & Movement Parameters
Open `res://scenes/player.tscn` or `res://scripts/player.gd`:
- **Speed**: In `scripts/player.gd`, change `const SPEED: float = 330.0`
- **Jump Height / Speed**: Change `const JUMP_SPEED: float = -570.0` (more negative = higher jump)
- **Gravity**: Change `const GRAVITY: float = 1500.0`
- **Acceleration**: Change `const ACCELERATION: float = 1800.0`
- **Forgiveness**: Coyote time and jump buffer are configured at `0.10s` (adjust in `_physics_process`).

---

## 4. Repositioning Enemies & Setting Patrol Bounds
Select any `Guard` instance in a level:
- **Position**: Drag the guard node to the initial placement.
- **Inspector Properties**:
  - `Patrol Distance`: Radius in pixels from the start point (e.g. `180.0` for 360px total patrol span).
  - `Speed`: Horizontal patrol speed (default `110.0`).
  - `Is Boss`: Set to `true` to switch to Crime Boss silhouette and wider collision profile.

---

## 5. Editing Evidence Placement & IDs
Select the `Evidence` node in any level:
- **Position**: Drag to wherever the evidence should appear.
- **Inspector Property**:
  - `Evidence Id`: Set to `"evidence_1"`, `"evidence_2"`, etc.
  - Matches the level's progression milestone.

---

## 6. Changing Traps & Hazards
Select any `Trap` node in a level:
- **`Trap Type` dropdown**:
  - `0`: `CRATE` (Falls when triggered, knocks out guards on impact or crushes player)
  - `1`: `ELECTRICAL` (Pulses hazard arcs periodically)
  - `2`: `CRUSH_BLOCK` (Vertical piston hazard)
- **`Cycle Time`**: Pulse cycle interval in seconds (e.g. `2.0`s or `2.4`s).
- **`Trigger Delay`**: Pause before drop upon activation.

---

## 7. Replacing Sprites with Hand-Crafted Pixel Art
Every gameplay object has visual decoupling with a dedicated export property:
1. Save your `.png` file into `res://assets/characters/`, `res://assets/props/`, or `res://assets/backgrounds/`.
2. Select the node in the scene tree (`Player`, `Guard`, `Evidence`, `Trap`, `Apartment`).
3. In the Inspector, drag your `.png` into the `Texture` (or `Background Texture`) slot.
4. If left blank, the built-in procedural neo-noir minimalist pixel graphics render automatically. No gameplay code needs to be modified.

---

## 8. Palette Quick Reference
- Background: `#101827`
- Secondary Background / Buildings: `#1D2940`
- Time / Rewind glow: `#48D9E8`
- Evidence Dossiers: `#F0C674`
- Hazards / Danger: `#E66B55`
- Text / Off-white typography: `#E9EDF2`
