---
wave: 3
depends_on: [02-core-shaders-PLAN]
files_modified:
  - resources/themes/monochrome.tres
  - src/presentation/seal_animation.gd
  - src/presentation/hit_animation.gd
  - src/presentation/backwash_animation.gd
  - src/presentation/video_vfx_player.gd
autonomous: true
requirements:
  - ART-06
  - ART-08
---

# 03-themes-vfx-PLAN.md

## Objective
Implement color themes and integrate the imported MP4 VFX (Seal, Break, Backwash).

## Tasks

<task>
  <objective>ART-006: Themes</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Create additional themes like `resources/themes/monochrome.tres`.
  </action>
  <acceptance_criteria>
    - Multiple palettes exist.
  </acceptance_criteria>
</task>

<task>
  <objective>ART-008: VFX Integration</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Create `src/presentation/video_vfx_player.gd` that plays `assets/raw/vfx/*.mp4` using `VideoStreamPlayer` with a custom `CanvasItemMaterial` set to `BLEND_MODE_ADD`. 
    Create `seal_animation.gd`, `hit_animation.gd`, and `backwash_animation.gd` to orchestrate triggering these videos over the gameplay layer.
  </action>
  <acceptance_criteria>
    - MP4 effects play flawlessly over the game without a black background blocking view.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: VFX videos play correctly in engine using additive blending. Themes can be swapped.
