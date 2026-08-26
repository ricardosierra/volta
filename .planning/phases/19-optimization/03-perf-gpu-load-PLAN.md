---
wave: 3
depends_on: [02-perf-logic-PLAN]
files_modified:
  - apps/mobile/src/presentation/vfx_pool.gd
  - apps/mobile/src/core/resource_loader.gd
autonomous: true
requirements:
  - PERF-05
  - PERF-07
---

# 03-perf-gpu-load-PLAN.md

## Objective
Optimize GPU rendering and reduce cold start times.

## Tasks

<task>
  <objective>PERF-005 & PERF-007: GPU and Loading</objective>
  <read_first>
    - .gsd/phases/19-optimization/TASKS.md
  </read_first>
  <action>
    Review `vfx_pool.gd` to ensure particle counts scale down strictly on Low presets. Create `resource_loader.gd` for background async loading of heavy assets to keep boot under 3 seconds.
  </action>
  <acceptance_criteria>
    - 60fps on mid-range devices. Boot to menu in < 3s.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Immediate feedback upon launching the app. Smooth visual performance.
