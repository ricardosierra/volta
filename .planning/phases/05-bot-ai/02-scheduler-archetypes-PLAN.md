---
wave: 2
depends_on: [01-bot-brain-PLAN]
files_modified:
  - src/ai/bot_safety.gd
  - src/ai/ai_scheduler.gd
  - resources/config/bots/archetypes/grazer.tres
  - resources/config/bots/archetypes/raider.tres
  - resources/config/bots/archetypes/hunter.tres
  - resources/config/bots/archetypes/warden.tres
autonomous: true
requirements:
  - BOT-04
---

# 02-scheduler-archetypes-PLAN.md

## Objective
Implement safety fallbacks, CPU round-robin scheduler, and define the 4 MVP archetypes.

## Tasks

<task>
  <objective>BOTS-006: Safety Fallbacks</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `src/ai/bot_safety.gd`. Detect stuck bots (no cell change for 1.5s) and trigger emergency direction. 
    Add anti-suicide checks before committing to a steering path (except for Rookies).
  </action>
  <acceptance_criteria>
    - Bots detect being stuck and override their brain with an emergency escape vector.
  </acceptance_criteria>
</task>

<task>
  <objective>BOTS-007: AI Scheduler</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `src/ai/ai_scheduler.gd` (class_name AIScheduler).
    Limit decision making to max 2 bots per tick via round-robin. Ensure decision cycles meet CPU budget (< 1.5ms).
  </action>
  <acceptance_criteria>
    - AI scheduler limits concurrent bot brain updates.
  </acceptance_criteria>
</task>

<task>
  <objective>BOTS-008: Archetypes</objective>
  <read_first>
    - .gsd/phases/05-bot-ai/TASKS.md
  </read_first>
  <action>
    Create `resources/config/bots/archetypes/grazer.tres`, `raider.tres`, `hunter.tres`, and `warden.tres`.
    Configure their weights based on the described behavior goals (Grazer = safe expansion, Raider = cuts arcs, Hunter = chases players, Warden = defends).
  </action>
  <acceptance_criteria>
    - Archetype resources are created and loadable.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Bots never get permanently stuck. Scheduler keeps CPU usage flat. Archetypes provide distinct behaviors.
