---
wave: 1
depends_on: []
files_modified:
  - src/gameplay/states/countdown_state.gd
  - src/ui/hud/countdown_view.gd
  - src/gameplay/score/score_service.gd
  - src/gameplay/score/score_state.gd
  - resources/config/balance/score.tres
autonomous: true
requirements:
  - LOP-01
  - LOP-02
---

# 01-countdown-score-PLAN.md

## Objective
Implement Match Countdown state and base Score Service.

## Tasks

<task>
  <objective>LOOP-001: Countdown and start</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Update `src/gameplay/states/countdown_state.gd` to run a 3s timer.
    Create `src/ui/hud/countdown_view.gd` to display the timer.
    Ensure input is processed but movement is blocked. Transition smoothly to `PlayingState`.
  </action>
  <acceptance_criteria>
    - `src/gameplay/states/countdown_state.gd` transitions to `Playing` after 3s.
    - Movement is blocked during countdown.
  </acceptance_criteria>
</task>

<task>
  <objective>LOOP-002: Base ScoreService</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Create `src/gameplay/score/score_state.gd` to hold points data.
    Create `resources/config/balance/score.tres` with base multipliers.
    Create `src/gameplay/score/score_service.gd`. Connect to `seal_completed` and `runner_broken` signals.
    Calculate base territory points, stolen points, and break points.
  </action>
  <acceptance_criteria>
    - `src/gameplay/score/score_service.gd` computes points strictly based on rules.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Match starts smoothly after a 3s countdown. Sealing territory awards score based on configuration multipliers.
