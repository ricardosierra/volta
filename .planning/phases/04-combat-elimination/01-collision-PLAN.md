---
wave: 1
depends_on: []
files_modified:
  - src/gameplay/collision_resolver.gd
  - src/runner/movement.gd
  - src/runner/runner.gd
autonomous: true
requirements:
  - CMBT-001
  - CMBT-004
---

# 01-collision-PLAN.md

## Objective
Implement core grid-based collision detection and wall/boundary collisions.

## Tasks

<task>
  <objective>CMBT-001: Grid Collision Detection</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Create `src/gameplay/collision_resolver.gd`.
    In tick, for each runner, check its current cell `arc_owner_of`.
    If another runner's arc, mark for Break event.
    If own arc while drawing, mark for Backwash event.
    Collect events before resolving to handle simultaneity.
    Add basic repulse logic if runners get too close (direct distance check).
  </action>
  <acceptance_criteria>
    - `src/gameplay/collision_resolver.gd` exists and detects Arc collisions.
    - Uses territory grid, not Area2D.
  </acceptance_criteria>
</task>

<task>
  <objective>CMBT-004: Wall and Obstacle Collision</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Update `src/gameplay/collision_resolver.gd` to handle edge collisions.
    If in DrawingTrail and hits a boundary/blocked cell, trigger Backwash with tangential deflection.
    If in Safe mode, only slide (handled by Arena, ensure no Backwash is triggered).
  </action>
  <acceptance_criteria>
    - Hitting border while drawing triggers Backwash event.
    - Hitting border while safe does not trigger Backwash.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Collision logic detects arc breaks and self-intersections using the TerritoryGrid efficiently without Godot physics nodes.
