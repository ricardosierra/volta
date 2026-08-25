---
wave: 5
depends_on: [04-polish-PLAN]
files_modified:
  - tools/dev/latency_test.gd
  - docs/performance/device-results.md
autonomous: true
requirements:
  - MOV-02
---

# 05-latency-PLAN.md

## Objective
Implement latency measurement tool and document baseline performance.

## Tasks

<task>
  <objective>MOVE-010: Latency test tool</objective>
  <read_first>
    - .gsd/phases/02-core-movement/TASKS.md
  </read_first>
  <action>
    Create `tools/dev/latency_test.gd` to run an automated suite measuring input latency.
    The tool must track from InputEvent timestamp to the frame the visual direction visibly changes, over 100 samples, calculating p50/p95.
    Update `docs/performance/device-results.md` to add placeholder rows for Phase 2 results across Swipe, Joystick, Relative drivers.
  </action>
  <acceptance_criteria>
    - `tools/dev/latency_test.gd` generates p50 and p95 metrics for latency.
    - `docs/performance/device-results.md` contains entries for Phase 2 Core Movement latency.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A dedicated tool script exists to measure input-to-screen latency.
