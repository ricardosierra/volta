---
wave: 4
depends_on: [03-end-hud-PLAN]
files_modified:
  - src/ui/screens/results_screen.gd
  - src/progression/leaderboard/leaderboard_repository.gd
  - src/progression/leaderboard/local_leaderboard_repository.gd
  - src/platform/analytics/analytics_service.gd
  - src/platform/analytics/noop_analytics.gd
  - src/gameplay/analytics_bridge.gd
autonomous: true
requirements:
  - LOP-08
  - LOP-09
  - LOP-10
---

# 04-results-analytics-PLAN.md

## Objective
Implement Results Screen, Local Leaderboards, and Analytics hooks.

## Tasks

<task>
  <objective>LOOP-008: Results Screen and Restart</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Create `src/ui/screens/results_screen.gd`.
    Display final ranking, claim, score, and personal record highlight.
    Implement "PLAY AGAIN" button that restarts seamlessly. Pre-load the next match during animation.
  </action>
  <acceptance_criteria>
    - Results screen displays accurately and restarts the game quickly.
  </acceptance_criteria>
</task>

<task>
  <objective>LOOP-009: Local Leaderboard</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Create interface `src/progression/leaderboard/leaderboard_repository.gd` and implementation `src/progression/leaderboard/local_leaderboard_repository.gd`.
    Persist the top 20 personal scores using the SaveService framework.
    Add mock marker for remote leaderboard in GSD 16.
  </action>
  <acceptance_criteria>
    - Local leaderboard saves and loads scores correctly between sessions.
  </acceptance_criteria>
</task>

<task>
  <objective>LOOP-010: Analytics Abstraction</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Create `src/platform/analytics/analytics_service.gd` interface and `src/platform/analytics/noop_analytics.gd` (MOCK-002).
    Create `src/gameplay/analytics_bridge.gd` to listen to match events and pipe them to the analytics service.
  </action>
  <acceptance_criteria>
    - Gameplay code has zero direct dependencies on analytics logic.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Players can see their result and restart effortlessly. Leaderboard saves locally. Analytics events are cleanly abstracted.
