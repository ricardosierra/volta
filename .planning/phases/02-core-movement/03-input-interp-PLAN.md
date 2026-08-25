---
wave: 3
depends_on: [02-runner-arena-PLAN]
files_modified:
  - src/presentation/interpolated_visual.gd
  - src/presentation/runner_view.gd
  - src/input/input_router.gd
  - src/input/input_driver.gd
  - src/input/drivers/swipe_driver.gd
autonomous: true
requirements:
  - MOV-04
  - MOV-05
---

# 03-input-interp-PLAN.md

## Objective
Implement Visual Interpolation for 120Hz rendering on 60Hz physics, and Swipe Input Router.

## Tasks

<task>
  <objective>MOVE-004: Visual Interpolation</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/interpolated_visual.gd` (class_name InterpolatedVisual extends Node2D).
    Store `prev_position`, `prev_rotation`, `curr_position`, `curr_rotation`.
    In `_process`, use `Engine.get_physics_interpolation_fraction()` to `lerp` between prev and curr for smooth rendering.
    Create `src/presentation/runner_view.gd` which uses this to draw a placeholder circle (PLACEHOLDER-ART-001 / Replacement: GSD 08).
  </action>
  <acceptance_criteria>
    - `src/presentation/interpolated_visual.gd` calls `Engine.get_physics_interpolation_fraction()`.
    - `src/presentation/runner_view.gd` draws a placeholder circle.
  </acceptance_criteria>
</task>

<task>
  <objective>MOVE-005: Input Router and Swipe Driver</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
    - docs/gameplay/controls.md
  </read_first>
  <action>
    Create `src/input/input_driver.gd` (class_name InputDriver extends RefCounted) with `poll(delta: float) -> Vector2`.
    Create `src/input/drivers/swipe_driver.gd` (extends InputDriver) for physical mm deadzone swipe input. Ensure touches on UI do not trigger movement. Keep direction upon release.
    Create `src/input/input_router.gd` (class_name InputRouter) to collect driver output without passing InputEvents to the simulation.
  </action>
  <acceptance_criteria>
    - `src/input/drivers/swipe_driver.gd` implements `poll` returning `Vector2`.
    - `src/input/input_router.gd` abstracts all InputEvent handling from simulation.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Runner moves smoothly across frames due to InterpolatedVisual. Swipe input is polled correctly and respects physical deadzone.
