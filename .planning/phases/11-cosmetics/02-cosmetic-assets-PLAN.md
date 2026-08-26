---
wave: 2
depends_on: [01-cosmetics-core-PLAN]
files_modified:
  - resources/cosmetics/skins/default_skin.tres
  - resources/cosmetics/skins/stealth_skin.tres
  - resources/cosmetics/arcs/default_arc.tres
  - resources/cosmetics/arcs/dashed_arc.tres
  - resources/cosmetics/seal_fx/default_seal.tres
  - resources/cosmetics/seal_fx/pixel_seal.tres
  - src/presentation/runner_view.gd
autonomous: true
requirements:
  - CSM-03
  - CSM-04
  - CSM-05
---

# 02-cosmetic-assets-PLAN.md

## Objective
Define the concrete cosmetic items and ensure the rendering layers respect the equipped items.

## Tasks

<task>
  <objective>COSM-003, COSM-004, COSM-005: Item Definitions</objective>
  <read_first>
    - .gsd/phases/11-cosmetics/TASKS.md
  </read_first>
  <action>
    Create stub `.tres` resources for skins, arcs, and seal effects in `resources/cosmetics/*`.
  </action>
  <acceptance_criteria>
    - Base resources exist and are parsed by the catalog.
  </acceptance_criteria>
</task>

<task>
  <objective>Applying Cosmetics to Gameplay</objective>
  <read_first>
    - .gsd/phases/11-cosmetics/TASKS.md
  </read_first>
  <action>
    Update `src/presentation/runner_view.gd` and shader bridges to swap materials or shader params based on the local player's Loadout.
  </action>
  <acceptance_criteria>
    - Changing loadout changes the visual output dynamically.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The player can equip different items and see them in-game without any hitbox/speed changes.
