---
wave: 2
depends_on: [01-powerup-infrastructure-PLAN]
files_modified:
  - apps/mobile/src/gameplay/powerups/effects/bulwark_effect.gd
  - apps/mobile/src/gameplay/powerups/effects/overdrive_effect.gd
  - apps/mobile/src/gameplay/powerups/effects/arc_guard_effect.gd
  - apps/mobile/src/gameplay/powerups/effects/pulse_effect.gd
  - apps/mobile/src/gameplay/powerups/effects/amplify_effect.gd
  - apps/mobile/src/gameplay/powerups/effects/drag_field_effect.gd
  - apps/mobile/src/gameplay/collision_resolver.gd
autonomous: true
requirements:
  - PU-03
  - PU-04
  - PU-05
---

# 02-powerup-effects-PLAN.md

## Objective
Implement all 6 concrete power-ups.

## Tasks

<task>
  <objective>PWUP-003, PWUP-004, PWUP-005: Effect Implementations</objective>
  <read_first>
    - .gsd/phases/14-power-ups/TASKS.md
  </read_first>
  <action>
    Create effect scripts for Bulwark (absorbs 1 break in `collision_resolver.gd`), Overdrive (speed boost), Arc Guard (older arc segments become uncuttable), Pulse (minimap reveal), Amplify (bonus score on next seal), Drag Field (drops a slow zone). 
  </action>
  <acceptance_criteria>
    - Each power-up correctly influences the gameplay state and expires when its condition or time limit is met.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Collision logic respects Bulwark and Arc Guard rules perfectly.
