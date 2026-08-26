---
wave: 2
depends_on: [01-layout-compat-PLAN]
files_modified:
  - apps/mobile/resources/themes/colorblind.tres
  - apps/mobile/src/presentation/quality_service.gd
autonomous: true
requirements:
  - A11Y-04
  - A11Y-05
---

# 02-refresh-colorblind-PLAN.md

## Objective
Support high refresh rates and implement colorblind/high-contrast visual themes.

## Tasks

<task>
  <objective>A11Y-04: Refresh Rate</objective>
  <read_first>
    - .gsd/phases/20-accessibility-compat/TASKS.md
  </read_first>
  <action>
    Update `quality_service.gd` to decouple logic (60Hz fixed tick) from rendering (unlocked/90Hz/120Hz via `Engine.max_fps`).
  </action>
  <acceptance_criteria>
    - Gameplay speed is completely independent of the framerate limit.
  </acceptance_criteria>
</task>

<task>
  <objective>A11Y-05: Colorblind Themes</objective>
  <read_first>
    - .gsd/phases/20-accessibility-compat/TASKS.md
  </read_first>
  <action>
    Create a `colorblind.tres` ThemePalette that uses deuteranopia, protanopia, and tritanopia-safe colors. High-contrast shapes must also be emphasized.
  </action>
  <acceptance_criteria>
    - Information is conveyed via shape + pattern, never color alone.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Total visual clarity for all players.
