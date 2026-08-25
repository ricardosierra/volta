---
wave: 4
depends_on: [03-themes-vfx-PLAN]
files_modified:
  - resources/config/quality/low.tres
  - resources/config/quality/medium.tres
  - resources/config/quality/high.tres
  - src/presentation/quality_service.gd
  - docs/performance/device-results.md
autonomous: true
requirements:
  - ART-09
  - ART-10
  - ART-11
---

# 04-quality-performance-PLAN.md

## Objective
Implement Quality Presets, ensure readability, and document performance.

## Tasks

<task>
  <objective>ART-009: Quality Presets</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Create `resources/config/quality/*.tres` and `src/presentation/quality_service.gd` to disable expensive shaders or VFX on low-end devices.
  </action>
  <acceptance_criteria>
    - Quality scaling works.
  </acceptance_criteria>
</task>

<task>
  <objective>ART-010 & ART-011: Audit and Performance</objective>
  <read_first>
    - .gsd/phases/08-art-direction/TASKS.md
  </read_first>
  <action>
    Create/Update `docs/performance/device-results.md` logging the GPU cost of the new additive blending video approach.
  </action>
  <acceptance_criteria>
    - Performance is documented.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game remains performant with the new VFX and shaders.
