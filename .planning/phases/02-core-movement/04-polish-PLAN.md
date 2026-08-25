---
wave: 4
depends_on: [03-input-interp-PLAN]
files_modified:
  - src/input/input_buffer.gd
  - src/input/drivers/joystick_driver.gd
  - src/input/drivers/relative_driver.gd
  - src/ui/screens/settings_controls.gd
  - src/presentation/camera/game_camera.gd
autonomous: true
requirements:
  - MOV-06
  - MOV-07
---

# 04-polish-PLAN.md

## Objective
Implement Input Buffer, Joystick/Relative Input drivers, and Game Camera.

## Tasks

<task>
  <objective>MOVE-006: Input Buffer</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
  </read_first>
  <action>
    Create `src/input/input_buffer.gd` (class_name InputBuffer).
    Maintain a queue of desired directions. When a new valid direction arrives, enqueue if currently turning, but discard old queued commands based on age limit.
    Discard redundant commands that are too similar to existing desired targets.
  </action>
  <acceptance_criteria>
    - `src/input/input_buffer.gd` implements queueing and age-based eviction.
  </acceptance_criteria>
</task>

<task>
  <objective>MOVE-007: Joystick and Relative Drivers</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
  </read_first>
  <action>
    Create `src/input/drivers/joystick_driver.gd` for floating joystick (configurable radius and deadzone).
    Create `src/input/drivers/relative_driver.gd` for relative horizontal swiping.
    Create `src/ui/screens/settings_controls.gd` with rudimentary UI for switching between Swipe, Joystick, and Relative during runtime.
  </action>
  <acceptance_criteria>
    - `src/input/drivers/joystick_driver.gd` and `src/input/drivers/relative_driver.gd` extend `InputDriver`.
    - `src/ui/screens/settings_controls.gd` changes the active driver in runtime.
  </acceptance_criteria>
</task>

<task>
  <objective>MOVE-009: Game Camera</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/camera/game_camera.gd` (class_name GameCamera extends Camera2D).
    Implement exponential smoothing and movement direction lookahead in `_process` acting on the interpolated visual position of the Runner.
    Clamp camera to field bounds defined by `Arena`.
    Expose zooming API for future phases.
  </action>
  <acceptance_criteria>
    - `src/presentation/camera/game_camera.gd` applies smoothing in `_process` and respects limits.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Input buffer queues concurrent commands. Alternative control drivers work and can be switched. Game camera follows interpolated target without jitter.
