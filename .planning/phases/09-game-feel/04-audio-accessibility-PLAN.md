---
wave: 4
depends_on: [03-camera-haptics-PLAN]
files_modified:
  - src/presentation/audio/sfx_service.gd
  - src/presentation/audio/adaptive_music.gd
  - src/presentation/accessibility_settings.gd
autonomous: true
requirements:
  - FEL-06
  - FEL-07
  - FEL-09
  - FEL-10
---

# 04-audio-accessibility-PLAN.md

## Objective
Stub out SFX and Music services, and centralize accessibility settings.

## Tasks

<task>
  <objective>FEEL-006 & FEEL-007: Audio Infrastructure</objective>
  <read_first>
    - .gsd/phases/09-game-feel/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/audio/sfx_service.gd` and `src/presentation/audio/adaptive_music.gd`.
    Mock the audio players and mix channels. Implement pitch randomization logic.
  </action>
  <acceptance_criteria>
    - Audio framework is ready for real sound assets (GSD 10+).
  </acceptance_criteria>
</task>

<task>
  <objective>FEEL-009 & FEEL-010: Accessibility Settings</objective>
  <read_first>
    - .gsd/phases/09-game-feel/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/accessibility_settings.gd`. Add properties for `reduce_shake` and `reduce_flashes`.
    Ensure `VfxService` and `CameraReactions` read from this centralized state.
  </action>
  <acceptance_criteria>
    - Visual intensity is globally scalable by the user.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Audio system logic is in place. Accessibility toggles demonstrably limit flashes and shakes.
