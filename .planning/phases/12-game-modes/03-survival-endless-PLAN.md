---
wave: 3
depends_on: [02-time-attack-domination-PLAN]
files_modified:
  - resources/config/modes/survival.tres
  - src/gameplay/modes/rules/wave_rule.gd
  - resources/config/modes/endless.tres
  - src/gameplay/modes/rules/reset_pulse_rule.gd
autonomous: true
requirements:
  - MOD-04
  - MOD-06
---

# 03-survival-endless-PLAN.md

## Objective
Implement Survival (waves) and Endless (reset pulse).

## Tasks

<task>
  <objective>MODE-004: Survival</objective>
  <read_first>
    - .gsd/phases/12-game-modes/TASKS.md
  </read_first>
  <action>
    Create `wave_rule.gd` which spawns harder bots at intervals and disables player respawn. Create `survival.tres`.
  </action>
  <acceptance_criteria>
    - Difficulty increases via perception buffs without speed changes.
  </acceptance_criteria>
</task>

<task>
  <objective>MODE-006: Endless & Reset Pulse</objective>
  <read_first>
    - .gsd/phases/12-game-modes/TASKS.md
  </read_first>
  <action>
    Create `reset_pulse_rule.gd` which periodically neuters the grid to prevent memory/territory exhaustion, ensuring infinite playtime. Create `endless.tres`.
  </action>
  <acceptance_criteria>
    - Pulses wipe huge territories but leave enough to not kill the owner.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Infinite modes don't crash after 10+ minutes.
