---
wave: 1
depends_on: []
files_modified:
  - src/presentation/vfx/vfx_service.gd
  - src/presentation/vfx/vfx_pool.gd
autonomous: true
requirements:
  - FEL-01
---

# 01-vfx-pool-PLAN.md

## Objective
Establish the VFX infrastructure and pooling system to avoid allocations during the match.

## Tasks

<task>
  <objective>FEEL-001: VFX Infrastructure</objective>
  <read_first>
    - .gsd/phases/09-game-feel/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/vfx/vfx_pool.gd` (generic pre-allocated pool) and `vfx_service.gd` (the global API for requesting effects).
    The service must respect quality presets to size the pools.
  </action>
  <acceptance_criteria>
    - Zero `instantiate()` calls during gameplay. Effects are reused.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game boots and pre-allocates standard effect counts. Requesting an effect grabs from the pool.
