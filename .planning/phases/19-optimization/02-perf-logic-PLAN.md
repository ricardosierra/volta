---
wave: 2
depends_on: [01-perf-baseline-cpu-PLAN]
files_modified:
  - apps/mobile/src/gameplay/territory_grid.gd
  - apps/mobile/src/ai/bot_brain.gd
autonomous: true
requirements:
  - PERF-03
  - PERF-04
---

# 02-perf-logic-PLAN.md

## Objective
Optimize the two heaviest CPU systems: Territory resolution and AI.

## Tasks

<task>
  <objective>PERF-003 & PERF-004: Logic Optimization</objective>
  <read_first>
    - .gsd/phases/19-optimization/TASKS.md
  </read_first>
  <action>
    Optimize `territory_grid.gd` using bounding box scanline fills instead of unconstrained flood fill. Update `bot_brain.gd` to cache decisions and only re-evaluate when necessary (e.g. state change).
  </action>
  <acceptance_criteria>
    - Large territory captures don't cause frame spikes. Bots use <1ms per tick.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game logic comfortably fits within the 16ms frame budget (preferably under 5ms).
