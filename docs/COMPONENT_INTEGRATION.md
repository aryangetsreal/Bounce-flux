# Component Integration Guide

## Shared Components for BounceFlux

### 1. Evidence (`scripts/evidence.gd` / `scenes/evidence.tscn`)
- **Group:** `rewindable`
- **Properties:**
  - `evidence_id: String` (e.g. `"evidence_1"`, `"evidence_2"`)
  - `texture: Texture2D` (optional, falls back to neo-noir gold dossier)
- **Signals:**
  - `evidence_collected(id: String)`
- **Behavior:**
  - Area2D pickup by player.
  - Rewind restores pickup state and visibility seamlessly.
  - Progression is committed upon level exit completion by `GameManager.register_evidence(id)`.

### 2. Guard (`scripts/guard.gd` / `scenes/guard.tscn`)
- **Group:** `rewindable`, `guards`
- **Properties:**
  - `patrol_distance: float` (default `180.0`)
  - `speed: float` (default `110.0`)
  - `is_boss: bool` (default `false`)
  - `texture: Texture2D` (optional)
- **Signals:**
  - `player_touched`
- **Behavior:**
  - Deterministic back-and-forth patrol.
  - Contact kills player.
  - `knock_out()` disables the guard (e.g. when struck by falling crate).
  - Rewind restores guard positions, directions, and disabled states.

### 3. Trap (`scripts/trap.gd` / `scenes/trap.tscn`)
- **Group:** `rewindable`, `traps`
- **Properties:**
  - `trap_type`: `CRATE` (0), `ELECTRICAL` (1), `CRUSH_BLOCK` (2)
  - `trigger_delay: float`
  - `cycle_time: float`
  - `fall_speed: float`
- **Signals:**
  - `trap_triggered`
  - `trap_landed`
- **Behavior:**
  - Crate falls when `trigger_trap()` is called or triggered via level area; knocks out guards or crushes player.
  - Electrical arcs cycle periodically on/off.
  - Crush blocks cycle up/down.
  - Rewind restores positions, trigger states, timers, and hazards.
