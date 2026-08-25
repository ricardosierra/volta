---
wave: 2
depends_on: [01-vfx-pool-PLAN]
files_modified:
  - src/presentation/seal_animation.gd
  - src/presentation/hit_animation.gd
  - src/ui/hud/bonus_popup.gd
autonomous: true
requirements:
  - FEL-02
  - FEL-03
  - FEL-08
---

# 02-combat-vfx-PLAN.md

## Objective
Refactor existing MP4 VFX to use the pool and implement UI bonus popups.

## Tasks

<task>
  <objective>FEEL-002 & FEEL-003: VFX of Capture and Combat</objective>
  <read_first>
    - .gsd/phases/09-game-feel/TASKS.md
  </read_first>
  <action>
    Update `seal_animation.gd` and `hit_animation.gd` to fetch their `VideoVFXPlayer` instances from `VfxService` rather than instantiating them.
  </action>
  <acceptance_criteria>
    - Gameplay events trigger pool-managed videos.
  </acceptance_criteria>
</task>

<task>
  <objective>FEEL-008: Popups</objective>
  <read_first>
    - .gsd/phases/09-game-feel/TASKS.md
  </read_first>
  <action>
    Create `src/ui/hud/bonus_popup.gd` that animates floating text (e.g. "+500") upwards from the point of action.
  </action>
  <acceptance_criteria>
    - Floating text uses Tween with ease_out_back.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Seal, Break, and Backwash visually fire from the pool. Popups float out elegantly.
