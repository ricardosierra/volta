---
wave: 3
depends_on: [02-refresh-colorblind-PLAN]
files_modified:
  - apps/mobile/src/presentation/accessibility_settings.gd
  - apps/mobile/src/ui/screens/settings_screen.gd
autonomous: true
requirements:
  - A11Y-06
  - A11Y-07
---

# 03-motor-cognitive-PLAN.md

## Objective
Finalize motor, cognitive, and sensory accessibility toggles.

## Tasks

<task>
  <objective>A11Y-06 & A11Y-07: Accessibility Toggles</objective>
  <read_first>
    - .gsd/phases/20-accessibility-compat/TASKS.md
  </read_first>
  <action>
    Expand `accessibility_settings.gd` with "Minimal HUD" and "Hold direction to move" modes. Expose them in `settings_screen.gd`.
  </action>
  <acceptance_criteria>
    - Players can strip down the sensory load and simplify inputs without disadvantage.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A 100% pass rate on the accessibility checklist.
