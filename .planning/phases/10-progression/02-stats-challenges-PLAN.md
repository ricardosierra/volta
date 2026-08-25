---
wave: 2
depends_on: [01-core-progression-PLAN]
files_modified:
  - src/progression/stats_service.gd
  - src/progression/achievements/achievement.gd
  - src/progression/achievements/achievement_service.gd
  - src/progression/challenges/challenge.gd
  - src/progression/challenges/challenge_service.gd
autonomous: true
requirements:
  - PRG-03
  - PRG-04
  - PRG-05
---

# 02-stats-challenges-PLAN.md

## Objective
Track stats, implement Achievements definitions, and Daily/Weekly challenges.

## Tasks

<task>
  <objective>PROG-003: Stats</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/progression/stats_service.gd`. Aggregate data like kills, deaths, captures, play time.
  </action>
  <acceptance_criteria>
    - Stats update accurately and handle edge cases (div/0).
  </acceptance_criteria>
</task>

<task>
  <objective>PROG-004: Achievements</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/progression/achievements/achievement_service.gd`. Listens to stats and triggers unlock popups.
  </action>
  <acceptance_criteria>
    - Unlocks trigger exactly once.
  </acceptance_criteria>
</task>

<task>
  <objective>PROG-005: Challenges</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/progression/challenges/challenge_service.gd`. Generate seed-based daily/weekly challenges (MOCK-004).
  </action>
  <acceptance_criteria>
    - Same seed produces same challenges. Resets at midnight.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Playing the game completes goals. Challenges refresh predictably.
