---
wave: 4
depends_on: [03-perf-gpu-load-PLAN]
files_modified:
  - docs/performance/device-results.md
  - .github/workflows/godot-ci.yml
autonomous: true
requirements:
  - PERF-08
  - PERF-09
---

# 04-perf-battery-ci-PLAN.md

## Objective
Finalize battery tuning and lock the performance gains in CI.

## Tasks

<task>
  <objective>PERF-008 & PERF-009: Battery and CI</objective>
  <read_first>
    - .gsd/phases/19-optimization/TASKS.md
  </read_first>
  <action>
    Document battery usage. Update `godot-ci.yml` (mocked or real) to assert that benchmarks do not regress. Finalize `device-results.md` with After metrics.
  </action>
  <acceptance_criteria>
    - Before/After proof of optimizations. No thermal throttling.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A game that respects the player's device limits.
