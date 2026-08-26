---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/ui/components/safe_area_container.gd
  - apps/mobile/src/ui/hud/hud.gd
autonomous: true
requirements:
  - A11Y-01
  - A11Y-02
  - A11Y-03
---

# 01-layout-compat-PLAN.md

## Objective
Ensure the UI respects device safe areas (notches) and reflows gracefully on Tablets.

## Tasks

<task>
  <objective>A11Y-001 & A11Y-002 & A11Y-003: Safe Areas & Tablets</objective>
  <read_first>
    - .gsd/phases/20-accessibility-compat/TASKS.md
  </read_first>
  <action>
    Create `safe_area_container.gd` that uses `DisplayServer.get_display_safe_area()` to add margins dynamically. Update the HUD and Screen constraints to anchor properly on 4:3 (iPad) ratios.
  </action>
  <acceptance_criteria>
    - The UI is never obscured by a device notch or rounded corners. Tablets don't stretch the UI awkwardly.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game looks native on any mobile aspect ratio.
