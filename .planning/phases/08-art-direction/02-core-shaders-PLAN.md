---
wave: 2
depends_on: [01-typography-icons-PLAN]
files_modified:
  - assets/shaders/runner.gdshader
  - assets/shaders/territory.gdshader
  - assets/shaders/arc.gdshader
  - assets/shaders/field_background.gdshader
autonomous: true
requirements:
  - ART-02
  - ART-03
  - ART-04
  - ART-05
---

# 02-core-shaders-PLAN.md

## Objective
Finalize the shaders for Runner, Territory Claim, Arc, and Background.

## Tasks

<task>
  <objective>ART-002: Runner Shader</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Create `assets/shaders/runner.gdshader` that integrates `assets/raw/sprites/runner.jpg` and applies color tinting and additive blending.
  </action>
  <acceptance_criteria>
    - Runner renders cleanly without the black box.
  </acceptance_criteria>
</task>

<task>
  <objective>ART-003 & ART-004: Territory and Arc</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Refine `assets/shaders/territory.gdshader` and `assets/shaders/arc.gdshader` to add geometric patterns and pulse based on length/overload.
  </action>
  <acceptance_criteria>
    - Claims and Arcs look polished and dynamic.
  </acceptance_criteria>
</task>

<task>
  <objective>ART-005: Background</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Create `assets/shaders/field_background.gdshader`. Add vignette and subtle grid.
  </action>
  <acceptance_criteria>
    - Background is atmospheric but non-distracting.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: All core gameplay visuals are shader-driven and performant.
