---
wave: 1
depends_on: []
files_modified:
  - src/ai/bot_profile.gd
  - resources/config/bots/rookie.tres
  - src/ai/perception/perception.gd
  - src/ai/perception/threat_map.gd
  - src/ai/perception/opportunity_map.gd
  - src/ai/actions/bot_action.gd
  - src/ai/bot_brain.gd
  - src/ai/bot_steering.gd
autonomous: true
requirements:
  - BOT-01
  - BOT-02
  - BOT-03
---

# 01-bot-brain-PLAN.md

## Objective
Implement Bot Profiles, Perception maps, Actions utility interface, and Bot Steering logic.

## Tasks

<task>
  <objective>BOTS-001: Bot Profiles</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `src/ai/bot_profile.gd` (class_name BotProfile extends Resource) with difficulty parameters.
    Create `resources/config/bots/rookie.tres` using the profile resource.
  </action>
  <acceptance_criteria>
    - `src/ai/bot_profile.gd` exposes exported variables for reaction time, error rate, and action weights.
  </acceptance_criteria>
</task>

<task>
  <objective>BOTS-002: Perception</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `src/ai/perception/threat_map.gd` and `src/ai/perception/opportunity_map.gd`.
    Create `src/ai/perception/perception.gd` to compile visibility into a context object without looking at private runner states.
  </action>
  <acceptance_criteria>
    - Perception builds a map based on a restricted visibility radius.
  </acceptance_criteria>
</task>

<task>
  <objective>BOTS-003: Actions and Utility</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `src/ai/actions/bot_action.gd` (class_name BotAction) with `score(ctx)` and `direction(ctx)`.
    Create `src/ai/bot_brain.gd` to score all actions, apply hysteresis, and pick the best one.
  </action>
  <acceptance_criteria>
    - `src/ai/bot_brain.gd` correctly applies weights and hysteresis to select actions.
  </acceptance_criteria>
</task>

<task>
  <objective>BOTS-004 & BOTS-005: Steering and Errors</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `src/ai/bot_steering.gd`. Convert suggested direction into actual movement input, avoiding walls locally.
    Update `src/ai/bot_brain.gd` to use `error_rate` (chance to pick 2nd best) and `reaction_delay_ms`.
  </action>
  <acceptance_criteria>
    - Steering feeds directions to the standard movement pipeline without cheating.
    - Error rate correctly falls back to the second best option.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Bot Brain evaluates actions based on perception maps and feeds steering identical to human input.
