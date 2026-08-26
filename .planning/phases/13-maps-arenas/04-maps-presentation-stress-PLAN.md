---
wave: 4
depends_on: [03-ai-navigation-PLAN]
files_modified:
  - apps/mobile/src/presentation/territory_renderer.gd
  - apps/mobile/tools/dev/simulate.gd
autonomous: true
requirements:
  - MAP-07
  - MAP-08
---

# 04-maps-presentation-stress-PLAN.md

## Objective
Render the map hazards properly and stress test the engine.

## Tasks

<task>
  <objective>MAPS-007: Visuals</objective>
  <read_first>
    - .gsd/phases/13-maps-arenas/TASKS.md
  </read_first>
  <action>
    Update `territory_renderer.gd` to visually differentiate walls and hazards using shaders. Add icons to arena resources.
  </action>
  <acceptance_criteria>
    - Hazards have a distinct visual representation.
  </acceptance_criteria>
</task>

<task>
  <objective>MAPS-008: Stress Testing</objective>
  <read_first>
    - .gsd/phases/13-maps-arenas/TASKS.md
  </read_first>
  <action>
    Update `simulate.gd` to test combinations of modes and arenas.
  </action>
  <acceptance_criteria>
    - Reports confirm no invariants are violated across topologies.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The engine handles arbitrary topologies effortlessly visually and logically.
