---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/tools/dev/profiler.gd
  - apps/mobile/tools/dev/leak_detector.gd
  - docs/performance/device-results.md
autonomous: true
requirements:
  - PERF-01
  - PERF-02
  - PERF-06
---

# 01-perf-baseline-cpu-PLAN.md

## Objective
Establish the performance baseline, create CPU profiling tools, and hunt memory leaks.

## Tasks

<task>
  <objective>PERF-001 & PERF-002 & PERF-006: CPU Profiling and Leaks</objective>
  <read_first>
    - .gsd/phases/19-optimization/TASKS.md
  </read_first>
  <action>
    Create `profiler.gd` to trace tick times for AI, Territory, and Core. Create `leak_detector.gd` to monitor RSS and orphan nodes. Write the initial `device-results.md` report.
  </action>
  <acceptance_criteria>
    - We have hard numbers on where the frame time goes and a flat memory curve.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Empirical data before any optimization code is written.
