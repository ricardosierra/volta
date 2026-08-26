---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/arena/arena_definition.gd
  - apps/mobile/tools/dev/arena_editor.gd
autonomous: true
requirements:
  - MAP-01
---

# 01-arena-definition-PLAN.md

## Objective
Enhance `ArenaDefinition` to support layout masks, unplayable zones, hazards, and specific spawn points. 

## Tasks

<task>
  <objective>MAPS-001: Arena Definition</objective>
  <read_first>
    - .gsd/phases/13-maps-arenas/TASKS.md
  </read_first>
  <action>
    Update `src/arena/arena_definition.gd` with properties for `blocked_cells_mask`, `hazard_cells_mask`, and `spawn_points`. Add a validation method to ensure no playable zones are isolated (flood fill).
  </action>
  <acceptance_criteria>
    - Arenas can have walls and holes. Validation rejects invalid topologies.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A structured way to author maps via resource properties instead of hardcoding dimensions.
