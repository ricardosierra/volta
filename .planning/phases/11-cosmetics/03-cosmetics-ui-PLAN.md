---
wave: 3
depends_on: [02-cosmetic-assets-PLAN]
files_modified:
  - src/progression/cosmetics/unlock_service.gd
  - src/ui/screens/character_screen.gd
  - src/ui/screens/skins_screen.gd
autonomous: true
requirements:
  - CSM-06
  - CSM-07
---

# 03-cosmetics-ui-PLAN.md

## Objective
Implement the logic to buy/unlock items and the UI to equip them.

## Tasks

<task>
  <objective>COSM-006: Unlock and Purchase</objective>
  <read_first>
    - .gsd/phases/11-cosmetics/TASKS.md
  </read_first>
  <action>
    Create `src/progression/cosmetics/unlock_service.gd`. Handles transactions with the Wallet to unlock items and adds them to Inventory.
  </action>
  <acceptance_criteria>
    - Cannot buy items already owned or without sufficient funds.
  </acceptance_criteria>
</task>

<task>
  <objective>COSM-007: UI Screens</objective>
  <read_first>
    - .gsd/phases/11-cosmetics/TASKS.md
  </read_first>
  <action>
    Create `src/ui/screens/character_screen.gd` (overview) and `src/ui/screens/skins_screen.gd` (grid of items). 
  </action>
  <acceptance_criteria>
    - Screens correctly read from the catalog and inventory to show lock/unlock states.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Players can spend sparks to unlock a skin and equip it.
