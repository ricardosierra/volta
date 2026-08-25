---
wave: 4
depends_on: [03-progression-ui-PLAN]
files_modified:
  - src/progression/progression_bridge.gd
  - tools/dev/economy_sim.gd
  - docs/design/economy.md
autonomous: true
requirements:
  - PRG-09
  - PRG-10
---

# 04-match-end-economy-PLAN.md

## Objective
Connect match end results to the progression engine and simulate the economy.

## Tasks

<task>
  <objective>PROG-009: Match End Integration</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/progression/progression_bridge.gd`. When `MatchDirector` emits match end, pass `MatchResult` into Stats, XP, and Wallet.
  </action>
  <acceptance_criteria>
    - XP and coins correctly accrue.
  </acceptance_criteria>
</task>

<task>
  <objective>PROG-010: Economy Sim</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `tools/dev/economy_sim.gd` (as a Godot editor tool script instead of PHP for portability). Simulate 30 days of typical play and log the resulting Spark balances. Document in `docs/design/economy.md`.
  </action>
  <acceptance_criteria>
    - Output validates that casual players don't starve and hardcore players don't break the bank.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Playing a full match actually gives rewards. Economy is mathematically sound.
