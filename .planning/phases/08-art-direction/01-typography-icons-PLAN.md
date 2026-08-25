---
wave: 1
depends_on: []
files_modified:
  - resources/themes/typography.tres
  - src/ui/components/v_icon.gd
autonomous: true
requirements:
  - ART-01
  - ART-07
---

# 01-typography-icons-PLAN.md

## Objective
Implement definitive typography settings and integrate the imported raw static assets (Runner, Icons, Button bases).

## Tasks

<task>
  <objective>ART-001: Typography</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Create `resources/themes/typography.tres` defining tabular numbers for the HUD. (Using default fonts as placeholders for the actual `.ttf`).
  </action>
  <acceptance_criteria>
    - Typography resource exists.
  </acceptance_criteria>
</task>

<task>
  <objective>ART-007: Icons and UI Assets</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Create `src/ui/components/v_icon.gd` to wrap the imported JPG assets (`button_base.jpg`, `icon_play.jpg`, etc.) from `assets/raw/sprites/` and apply additive blending material to remove the black background programmatically.
  </action>
  <acceptance_criteria>
    - Raw JPGs are usable in UI with transparent backgrounds via shaders.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Typography is configured. Icons can be rendered transparently using additive blending.
