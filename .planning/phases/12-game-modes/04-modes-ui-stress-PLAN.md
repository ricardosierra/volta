---
wave: 4
depends_on: [03-survival-endless-PLAN]
files_modified:
  - src/ui/screens/mode_select_screen.gd
  - src/progression/leaderboard/leaderboard_repository.gd
  - tools/dev/simulate.gd
autonomous: true
requirements:
  - MOD-07
  - MOD-08
  - MOD-09
---

# 04-modes-ui-stress-PLAN.md

## Objective
Build UI for Mode Selection, integrate Leaderboards per mode, and perform stress testing.

## Tasks

<task>
  <objective>MODE-007 & MODE-008: Selection UI and Leaderboards</objective>
  <read_first>
    - .gsd/phases/12-game-modes/TASKS.md
  </read_first>
  <action>
    Create `mode_select_screen.gd` showing available modes, rules, and personal bests. Update `leaderboard_repository.gd` to store scores keyed by mode ID.
  </action>
  <acceptance_criteria>
    - Records update correctly according to the mode's win criteria (time survived vs max area).
  </acceptance_criteria>
</task>

<task>
  <objective>MODE-009: Stress Test</objective>
  <read_first>
    - .gsd/phases/12-game-modes/TASKS.md
  </read_first>
  <action>
    Use `simulate.gd` to run thousands of fast-forwarded matches testing edge cases in these 5 modes.
  </action>
  <acceptance_criteria>
    - Zero invariants violated.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The player can select a mode and play it smoothly.
