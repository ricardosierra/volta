---
wave: 3
depends_on: [02-combat-vfx-PLAN]
files_modified:
  - src/presentation/camera/camera_reactions.gd
  - src/presentation/haptics/haptic_service.gd
autonomous: true
requirements:
  - FEL-04
  - FEL-05
---

# 03-camera-haptics-PLAN.md

## Objective
Implement Camera Shake and enhance Haptics based on gameplay events.

## Tasks

<task>
  <objective>FEEL-004: Camera Reactions</objective>
  <read_first>
    - .gsd/phases/09-game-feel/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/camera/camera_reactions.gd` applying screen shake based on event intensity (Break, Mega Seal).
    Respect user accessibility settings.
  </action>
  <acceptance_criteria>
    - Camera shakes dynamically but never permanently drifts.
  </acceptance_criteria>
</task>

<task>
  <objective>FEEL-005: Haptic Feedback</objective>
  <read_first>
    - .gsd/phases/09-game-feel/TASKS.md
  </read_first>
  <action>
    Update `haptic_service.gd` to include specific event profiles (e.g. `play_seal()`, `play_break()`) mapping to varying vibration durations/intensities.
  </action>
  <acceptance_criteria>
    - Haptics reflect game events clearly.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game "feels" weighty through screen shake and vibration, but both can be disabled.
