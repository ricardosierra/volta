---
wave: 3
depends_on: [02-arena-layouts-PLAN]
files_modified:
  - apps/mobile/src/ai/bot_steering.gd
  - apps/mobile/src/ai/bot_safety.gd
autonomous: true
requirements:
  - MAP-06
---

# 03-ai-navigation-PLAN.md

## Objective
Make bots aware of walls and hazards so they don't get stuck or suicided.

## Tasks

<task>
  <objective>MAPS-006: AI & Obstacles</objective>
  <read_first>
    - .gsd/phases/13-maps-arenas/TASKS.md
  </read_first>
  <action>
    Update `bot_steering.gd` and `bot_safety.gd` to sample the `ArenaDefinition` masks. Rays cast forward must detect hazards and walls and steer away.
  </action>
  <acceptance_criteria>
    - Zero bot lockups in narrow corridors. Bots avoid the Rift.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Bots gracefully navigate complex topologies without breaking.
