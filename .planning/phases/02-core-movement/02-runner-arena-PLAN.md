---
wave: 2
depends_on: [01-sim-loop-PLAN]
files_modified:
  - src/runner/runner.gd
  - src/runner/runner_state.gd
  - src/runner/movement.gd
  - src/runner/stat_block.gd
  - src/arena/arena_definition.gd
  - src/arena/arena.gd
  - resources/arenas/open_field.tres
autonomous: true
requirements:
  - MOV-03
---

# 02-runner-arena-PLAN.md

## Objective
Implement Runner simulation entity and Arena data definition.

## Tasks

<task>
  <objective>MOVE-003: Implement Runner entity</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
  </read_first>
  <action>
    Create `src/runner/stat_block.gd` (class_name StatBlock) with modifiers stack for speed and turn rate.
    Create `src/runner/runner_state.gd` (class_name RunnerState) to hold id, position (Vector2), direction (Vector2), desired_direction (Vector2), velocity, and FSM state (Spawn, Safe, Eliminated).
    Create `src/runner/movement.gd` to handle movement math: rotating towards desired direction based on `turn_rate`, advancing based on `speed`.
    Create `src/runner/runner.gd` (class_name Runner) combining these pieces without visual nodes.
  </action>
  <acceptance_criteria>
    - `src/runner/runner.gd` exists and has no visual Node imports.
    - `src/runner/stat_block.gd` manages speed and turn_rate modifiers.
  </acceptance_criteria>
</task>

<task>
  <objective>MOVE-008: Implement Arena limits</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
  </read_first>
  <action>
    Create `src/arena/arena_definition.gd` (class_name ArenaDefinition extends Resource) for width/height in cells, cell_size, spawn points.
    Create `resources/arenas/open_field.tres` using the ArenaDefinition.
    Create `src/arena/arena.gd` (class_name Arena) that holds limits and resolves boundaries.
    Implement sliding logic: if Runner hits border, remove velocity perpendicular to the normal (slide).
  </action>
  <acceptance_criteria>
    - `src/arena/arena.gd` exists and implements boundary sliding.
    - `resources/arenas/open_field.tres` exists.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Runner moves and turns correctly without visual components. Arena clamps and slides Runner at boundaries.
