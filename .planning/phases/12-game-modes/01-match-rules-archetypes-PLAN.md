---
wave: 1
depends_on: []
files_modified:
  - src/gameplay/modes/match_rules.gd
  - resources/config/modes/classic.tres
  - src/ai/bot_profile.gd
  - resources/config/bots/archetypes/vulture.tres
  - resources/config/bots/archetypes/nemesis.tres
  - resources/config/bots/archetypes/baron.tres
autonomous: true
requirements:
  - MOD-01
  - MOD-03
---

# 01-match-rules-archetypes-PLAN.md

## Objective
Introduce the `MatchRules` data structure to drive match behaviors dynamically without hardcoding, and implement advanced AI archetypes.

## Tasks

<task>
  <objective>MODE-001: MatchRulesResource</objective>
  <read_first>
    - .gsd/phases/12-game-modes/TASKS.md
  </read_first>
  <action>
    Create `src/gameplay/modes/match_rules.gd` containing config properties: time_limit, bot_count, respawn_time, win_condition (enum), special_rules (Array of Rule Nodes). Refactor `MatchDirector` to strictly obey `MatchRules` instead of hardcoded logic.
  </action>
  <acceptance_criteria>
    - `MatchDirector` does not contain `if mode ==` statements.
  </acceptance_criteria>
</task>

<task>
  <objective>MODE-003: Archetypes Vulture, Nemesis, Baron</objective>
  <read_first>
    - .gsd/phases/12-game-modes/TASKS.md
  </read_first>
  <action>
    Update `src/ai/bot_profile.gd` and create `.tres` files for new archetypes with custom weights to target vulnerabilities or revenge.
  </action>
  <acceptance_criteria>
    - Archetypes are usable by the AIScheduler.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The Classic mode works exactly as before, but driven entirely by `classic.tres`.
