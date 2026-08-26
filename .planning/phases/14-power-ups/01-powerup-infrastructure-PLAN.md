---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/gameplay/powerups/power_up_effect.gd
  - apps/mobile/src/gameplay/powerups/power_up_descriptor.gd
  - apps/mobile/src/gameplay/powerups/power_up_service.gd
  - apps/mobile/src/gameplay/powerups/power_up_spawner.gd
  - apps/mobile/src/runner/stat_block.gd
autonomous: true
requirements:
  - PU-01
  - PU-02
---

# 01-powerup-infrastructure-PLAN.md

## Objective
Build the underlying systems for power-up application and spawning.

## Tasks

<task>
  <objective>PWUP-001: Infrastructure</objective>
  <read_first>
    - .gsd/phases/14-power-ups/TASKS.md
  </read_first>
  <action>
    Create `PowerUpEffect` and `PowerUpDescriptor`. Update `StatBlock` (or create `StatModifiers`) to support stacking flat/multiplier changes. Create `PowerUpService` to manage active effects per runner.
  </action>
  <acceptance_criteria>
    - Applying a new power-up removes the old one cleanly. Stat modifiers compute correctly.
  </acceptance_criteria>
</task>

<task>
  <objective>PWUP-002: Orb Spawning</objective>
  <read_first>
    - .gsd/phases/14-power-ups/TASKS.md
  </read_first>
  <action>
    Create `PowerUpSpawner` that periodically spawns orbs on the grid, avoiding players. Orbs must be collectable via distance checks.
  </action>
  <acceptance_criteria>
    - Orbs spawn deterministically based on seed and are never too close to a runner.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The backend system works without visual glitches and handles memory cleanly.
