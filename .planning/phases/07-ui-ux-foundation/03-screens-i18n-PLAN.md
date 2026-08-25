---
wave: 3
depends_on: [02-components-nav-PLAN]
files_modified:
  - resources/i18n/en.csv
  - resources/i18n/pt_BR.csv
  - src/ui/screens/splash_screen.gd
  - src/ui/screens/main_menu_screen.gd
  - src/ui/screens/pause_screen.gd
autonomous: true
requirements:
  - UIX-06
  - UIX-07
  - UIX-08
---

# 03-screens-i18n-PLAN.md

## Objective
Implement i18n localization and core game screens (Splash, Main Menu, Pause).

## Tasks

<task>
  <objective>UIUX-006: i18n</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create translation files `resources/i18n/en.csv` and `pt_BR.csv`.
  </action>
  <acceptance_criteria>
    - Hardcoded text is moved to translation keys.
  </acceptance_criteria>
</task>

<task>
  <objective>UIUX-007 & UIUX-008: Core Screens</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `splash_screen.gd`, `main_menu_screen.gd`, and `pause_screen.gd` extending `Screen`.
  </action>
  <acceptance_criteria>
    - Screens integrate with the ScreenStack and display i18n keys.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Game boots through Splash to Main Menu. Pausing works. Text is localized.
