---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/platform/analytics/remote_analytics.gd
  - apps/mobile/src/platform/analytics/crash_reporter.gd
  - apps/mobile/src/platform/analytics/performance_sampler.gd
autonomous: true
requirements:
  - ANLT-01
  - ANLT-02
  - ANLT-04
  - ANLT-05
---

# 01-client-analytics-PLAN.md

## Objective
Implement client-side analytics capture, including remote adapters, crash reporting, and performance sampling.

## Tasks

<task>
  <objective>ANLT-002: Remote Analytics</objective>
  <read_first>
    - .gsd/phases/18-analytics/TASKS.md
  </read_first>
  <action>
    Create `remote_analytics.gd` that batches events and leverages `OfflineQueue` for transmission. Resolves MOCK-002.
  </action>
  <acceptance_criteria>
    - Events are batched and deduplicated.
  </acceptance_criteria>
</task>

<task>
  <objective>ANLT-004 & ANLT-005: Crash & Performance</objective>
  <read_first>
    - .gsd/phases/18-analytics/TASKS.md
  </read_first>
  <action>
    Create `crash_reporter.gd` that hooks into Godot's error signals. Create `performance_sampler.gd` to record FPS and memory every 15s.
  </action>
  <acceptance_criteria>
    - Crashes and perf drops are converted into telemetry events automatically.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Telemetry logic does not cause game stuttering.
