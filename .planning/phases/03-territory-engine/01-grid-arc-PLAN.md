---
wave: 1
depends_on: []
files_modified:
  - src/territory/territory_grid.gd
  - tests/unit/test_territory_grid.gd
  - src/territory/grid_space.gd
  - src/territory/arc_rasterizer.gd
  - src/territory/arc_tracker.gd
autonomous: true
requirements:
  - TER-01
  - TER-02
  - TER-03
---

# 01-grid-arc-PLAN.md

## Objective
Implement TerritoryGrid data structure, World-to-Cell translation, Supercover Arc Rasterizer, and ArcTracker.

## Tasks

<task>
  <objective>TERR-001: TerritoryGrid structure and queries</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/territory/territory_grid.gd`. Use PackedByteArray for `_owner` and `_arc` (255=blocked). Use PackedInt32Array for `_claim_count`.
    Implement `cell_index`, `cell_at`, `owner_of`, `arc_owner_of`, `is_blocked`.
    Implement `setup`, `reset`, `seed_claim`, `release_claim`, and `claim_percent`.
    Create `tests/unit/test_territory_grid.gd` to verify queries, seed_claim creating exact area, and release_claim resetting cleanly.
  </action>
  <acceptance_criteria>
    - `src/territory/territory_grid.gd` uses `PackedByteArray` for grids.
    - `tests/unit/test_territory_grid.gd` passes all basic assertions.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-002: World to Cell conversion</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/territory/grid_space.gd` (class_name GridSpace).
    Implement `world_to_cell`, `cell_to_world_center`, and `cell_rect` considering cell_size.
    Implement explicit rounding (e.g. `floor()`) and bounds clamping.
  </action>
  <acceptance_criteria>
    - `src/territory/grid_space.gd` provides conversion methods with explicit rounding.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-003: Arc Rasterization (supercover)</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/territory/arc_rasterizer.gd` (class_name ArcRasterizer).
    Implement supercover line drawing algorithm that generates 4-connected cells between start and end.
    Create `tests/unit/test_arc_rasterizer.gd` with cases: horizontal, vertical, diagonal 45, almost diagonal, and 20-cell jump.
  </action>
  <acceptance_criteria>
    - `src/territory/arc_rasterizer.gd` ensures 4-connected cells.
    - `tests/unit/test_arc_rasterizer.gd` checks 4-connected property.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-004: ArcTracker</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/territory/arc_tracker.gd` (class_name ArcTracker).
    Maintain a `PackedInt32Array` of cell indices per runner for draw order.
    Implement `mark`, `clear`, `length`, `contains`.
    Detect self-intersection and emit `self_intersect`.
  </action>
  <acceptance_criteria>
    - `src/territory/arc_tracker.gd` maintains cell index arrays.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Grid memory layout is packed and 1D. Rasterizer prevents diagonal leaks (4-connected). Arc Tracker correctly detects self intersection.
