---
wave: 2
depends_on: [01-arena-definition-PLAN]
files_modified:
  - apps/mobile/resources/arenas/archipelago.tres
  - apps/mobile/resources/arenas/rift.tres
  - apps/mobile/resources/arenas/crossroads.tres
  - apps/mobile/resources/arenas/halo.tres
autonomous: true
requirements:
  - MAP-02
  - MAP-03
  - MAP-04
  - MAP-05
---

# 02-arena-layouts-PLAN.md

## Objective
Create the 4 concrete Arena configurations.

## Tasks

<task>
  <objective>MAPS-002 to MAPS-005: Map Data</objective>
  <read_first>
    - .gsd/phases/13-maps-arenas/TASKS.md
  </read_first>
  <action>
    Create `.tres` files for Archipelago (islands/bridges), Rift (deadly center), Crossroads (cross), and Halo (donut). Use strings/arrays in the resources to represent the masks.
  </action>
  <acceptance_criteria>
    - The grid parses these masks correctly.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The grid properly respects the topology defined by these 4 distinct resources.
