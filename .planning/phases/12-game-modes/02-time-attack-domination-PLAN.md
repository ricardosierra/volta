---
wave: 2
depends_on: [01-match-rules-archetypes-PLAN]
files_modified:
  - resources/config/modes/time_attack.tres
  - src/gameplay/modes/rules/time_bonus_rule.gd
  - resources/config/modes/domination.tres
  - src/ui/hud/domination_bars.gd
autonomous: true
requirements:
  - MOD-02
  - MOD-05
---

# 02-time-attack-domination-PLAN.md

## Objective
Implement Time Attack (time granted on seal) and Domination (first to 50%).

## Tasks

<task>
  <objective>MODE-002: Time Attack</objective>
  <read_first>
    - .gsd/phases/12-game-modes/TASKS.md
  </read_first>
  <action>
    Create `time_bonus_rule.gd` that hooks into match events to grant clock time. Create `time_attack.tres`.
  </action>
  <acceptance_criteria>
    - Making a seal grants time, maxing at 8s per capture.
  </acceptance_criteria>
</task>

<task>
  <objective>MODE-005: Domination</objective>
  <read_first>
    - .gsd/phases/12-game-modes/TASKS.md
  </read_first>
  <action>
    Create `domination.tres` specifying a win_condition of 50%. Create `domination_bars.gd` HUD element to show global percent claims.
  </action>
  <acceptance_criteria>
    - Reaching 50% territory instantly ends the match and declares the winner.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Playing these modes obeys the specific data rules flawlessly.
