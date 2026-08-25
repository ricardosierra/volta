---
wave: 3
depends_on: [02-scheduler-archetypes-PLAN]
files_modified:
  - src/ai/debug/bot_intent_overlay.gd
  - tools/dev/simulate.gd
  - docs/design/balance.md
  - resources/config/modes/classic.tres
  - src/gameplay/match_director.gd
autonomous: true
requirements:
  - BOT-05
  - BOT-06
---

# 03-ai-polish-PLAN.md

## Objective
Implement Intent Overlay, conduct stress testing, and configure the playable classic match.

## Tasks

<task>
  <objective>BOTS-009: Intent Overlay</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `src/ai/debug/bot_intent_overlay.gd` (Control) that draws text above bots showing their chosen action, score, and runner ID, but only if `OS.is_debug_build()` is true.
  </action>
  <acceptance_criteria>
    - `src/ai/debug/bot_intent_overlay.gd` visualizes AI state for debugging.
  </acceptance_criteria>
</task>

<task>
  <objective>BOTS-010: Stress Testing and Balance</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Update `tools/dev/simulate.gd` to use the actual `BotBrain` and `AIScheduler` instead of random walks.
    Log win rates for archetypes. Update `docs/design/balance.md` with findings.
  </action>
  <acceptance_criteria>
    - Simulator runs headless matches using the real AI.
    - `docs/design/balance.md` contains AI balance records.
  </acceptance_criteria>
</task>

<task>
  <objective>BOTS-011: Playable Match</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `resources/config/modes/classic.tres` specifying 5 bots.
    Update `src/gameplay/match_director.gd` to read the mode config, instantiate 5 bots, assign them archetypes, and inject them into the simulation loop.
  </action>
  <acceptance_criteria>
    - `src/gameplay/match_director.gd` populates the arena with bots.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Debug overlay helps diagnose bots. Simulator uses real AI. MatchDirector automatically populates the game with AI opponents.
