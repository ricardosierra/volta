---
wave: 2
depends_on: [01-android-build-PLAN]
files_modified:
  - apps/mobile/project.godot
  - docs/mobile/android.md
autonomous: true
requirements:
  - ANDR-04
  - ANDR-05
---

# 02-icons-permissions-PLAN.md

## Objective
Finalize the Android manifest and app iconography.

## Tasks

<task>
  <objective>ANDR-004: Icons and Splash</objective>
  <read_first>
    - .gsd/phases/21-android-release/TASKS.md
  </read_first>
  <action>
    Update `project.godot` to reference adaptive icons and the unified splash screen.
  </action>
  <acceptance_criteria>
    - The game boots cleanly and looks native on the Android home screen.
  </acceptance_criteria>
</task>

<task>
  <objective>ANDR-005: Permissions</objective>
  <read_first>
    - .gsd/phases/21-android-release/TASKS.md
  </read_first>
  <action>
    Document the explicit Android permissions (`INTERNET`, `VIBRATE`) in `android.md`. Ensure Godot's export settings reflect these minimally.
  </action>
  <acceptance_criteria>
    - No unnecessary permissions are requested from the user.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A professional application footprint on the OS.
