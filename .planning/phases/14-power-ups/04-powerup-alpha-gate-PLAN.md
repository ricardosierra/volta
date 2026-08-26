---
wave: 4
depends_on: [03-powerup-ui-ai-PLAN]
files_modified:
  - apps/mobile/tools/dev/simulate.gd
  - .planning/STATUS.md
autonomous: true
requirements:
  - PU-08
---

# 04-powerup-alpha-gate-PLAN.md

## Objective
Balance the power-ups and pass the Alpha gate.

## Tasks

<task>
  <objective>PWUP-008: Balance and Alpha Gate</objective>
  <read_first>
    - .gsd/phases/14-power-ups/TASKS.md
  </read_first>
  <action>
    Update `simulate.gd` to include power-up data collection. Ensure winrate of first-orb collector is within bounds. Update `STATUS.md` to reflect Alpha completion.
  </action>
  <acceptance_criteria>
    - Overpowered elements are caught and nerfed. The Alpha gate is officially passed.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Data validates the gameplay loop.
