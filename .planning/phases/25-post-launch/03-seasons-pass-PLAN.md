---
wave: 3
depends_on: [02-monetization-PLAN]
files_modified:
  - apps/mobile/src/progression/season_service.gd
autonomous: true
requirements:
  - POST-04
  - POST-05
---

# 03-seasons-pass-PLAN.md

## Objective
Establish the architecture for Live-Ops seasons and a cosmetic battle pass.

## Tasks

<task>
  <objective>POST-004 & POST-005: Seasons</objective>
  <read_first>
    - .gsd/phases/25-post-launch/TASKS.md
  </read_first>
  <action>
    Create `season_service.gd` that pulls current season config and parses the Season Pass reward tracks.
  </action>
  <acceptance_criteria>
    - Seasons can rotate without client updates.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Long-term engagement hooks.
