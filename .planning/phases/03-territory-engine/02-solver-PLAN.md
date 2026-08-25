---
wave: 2
depends_on: [01-grid-arc-PLAN]
files_modified:
  - src/territory/seal_result.gd
  - src/territory/seal_solver.gd
  - tests/unit/test_seal_solver.gd
  - src/territory/seal_applier.gd
  - src/gameplay/match_director.gd
  - src/runner/runner.gd
  - src/runner/states/safe_state.gd
  - src/runner/states/drawing_trail_state.gd
  - src/runner/states/sealing_state.gd
autonomous: true
requirements:
  - TER-04
  - TER-05
---

# 02-solver-PLAN.md

## Objective
Implement SealSolver pure function, apply seals to the grid, and integrate with Runner FSM.

## Tasks

<task>
  <objective>TERR-006: SealSolver</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/territory/seal_result.gd` to hold captured cells array, stolen count, bounding box.
    Create `src/territory/seal_solver.gd` (class_name SealSolver) as a static pure function that performs an exterior 4-way flood-fill from the bounding box of the Arc+Claim. 
    Barriers are the player's own claim and arc. Non-barrier, unvisited cells after flood-fill are captured.
    Create `tests/unit/test_seal_solver.gd` with tests for basic shapes (rectangle, L-shape, touching border).
  </action>
  <acceptance_criteria>
    - `src/territory/seal_solver.gd` does not modify the grid or emit signals.
    - `tests/unit/test_seal_solver.gd` passes with basic shape test cases.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-007: Apply Seal to Grid</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/territory/seal_applier.gd` (class_name SealApplier).
    Given a SealResult, apply it to the TerritoryGrid, update owners, increment/decrement counts, and emit `seal_completed`, `arc_swallowed`, and `squeezed` signals.
  </action>
  <acceptance_criteria>
    - `src/territory/seal_applier.gd` writes to TerritoryGrid and emits appropriate signals.
  </acceptance_criteria>
</task>

<task>
  <objective>TERR-008: Runner FSM Integration</objective>
  <read_first>
    - .gsd/phases/03-territory-engine/TASKS.md
  </read_first>
  <action>
    Create `src/runner/states/safe_state.gd`, `src/runner/states/drawing_trail_state.gd`, and `src/runner/states/sealing_state.gd`.
    Update `src/runner/runner.gd` to handle state transitions: leaving claim enters DrawingTrail, returning to claim enters Sealing.
    Update `src/gameplay/match_director.gd` to call SealSolver and SealApplier when a runner enters Sealing state.
  </action>
  <acceptance_criteria>
    - Runner enters `DrawingTrail` when outside its claim.
    - MatchDirector resolves seals in the same tick without blocking input.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: SealSolver identifies enclosed regions perfectly using exterior flood-fill. FSM handles transition from safe -> drawing -> sealing.
