---
wave: 1
depends_on: []
files_modified:
  - src/progression/cosmetics/cosmetic_item.gd
  - src/progression/cosmetics/catalog.gd
  - src/progression/cosmetics/inventory.gd
  - src/progression/cosmetics/loadout.gd
autonomous: true
requirements:
  - CSM-01
  - CSM-02
---

# 01-cosmetics-core-PLAN.md

## Objective
Establish the core data models for cosmetic items, the global catalog, and the player's inventory/loadout state.

## Tasks

<task>
  <objective>COSM-001: Catalog and Item Model</objective>
  <read_first>
    - .gsd/phases/11-cosmetics/TASKS.md
  </read_first>
  <action>
    Create `src/progression/cosmetics/cosmetic_item.gd` as a Resource. It must contain id, type (enum: SKIN, ARC, SEAL_FX, TITLE, FRAME, THEME), rarity, cost in sparks/prisms, and resource paths.
    Create `src/progression/cosmetics/catalog.gd` which loads all `.tres` items at boot.
  </action>
  <acceptance_criteria>
    - No gameplay properties exist on the item schema.
  </acceptance_criteria>
</task>

<task>
  <objective>COSM-002: Inventory and Loadout</objective>
  <read_first>
    - .gsd/phases/11-cosmetics/TASKS.md
  </read_first>
  <action>
    Create `src/progression/cosmetics/inventory.gd` (list of owned item IDs) and `loadout.gd` (dictionary of currently equipped item IDs per slot).
  </action>
  <acceptance_criteria>
    - Default items are always equipped if a slot is empty.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game loads the catalog successfully and applies defaults to the loadout.
