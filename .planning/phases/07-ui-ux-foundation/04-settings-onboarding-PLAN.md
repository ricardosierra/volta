---
wave: 4
depends_on: [03-screens-i18n-PLAN]
files_modified:
  - src/ui/screens/settings_screen.gd
  - src/ui/onboarding/tutorial_director.gd
  - src/presentation/haptics/haptic_service.gd
  - src/presentation/audio/ui_audio.gd
autonomous: true
requirements:
  - UIX-09
  - UIX-10
  - UIX-11
---

# 04-settings-onboarding-PLAN.md

## Objective
Implement Settings screen, Onboarding flow, and Audio/Haptic UI feedback.

## Tasks

<task>
  <objective>UIUX-009: Settings</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `src/ui/screens/settings_screen.gd` with tabs for Audio, Controls, Graphics.
  </action>
  <acceptance_criteria>
    - Settings save automatically via SaveService.
  </acceptance_criteria>
</task>

<task>
  <objective>UIUX-010: Onboarding</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `src/ui/onboarding/tutorial_director.gd`.
  </action>
  <acceptance_criteria>
    - First launch triggers a structured match against rookies with tips.
  </acceptance_criteria>
</task>

<task>
  <objective>UIUX-011: Audio & Haptics</objective>
  <read_first>
    - .gsd/phases/07-ui-ux-foundation/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/haptics/haptic_service.gd` and `src/presentation/audio/ui_audio.gd`.
  </action>
  <acceptance_criteria>
    - Button clicks trigger unified audio and haptic feedback safely.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Haptics fire on mobile, settings persist, onboarding guides the player.
