---
wave: 3
depends_on: [02-elimination-PLAN]
files_modified:
  - src/gameplay/match_director.gd
  - src/ui/hud/threat_indicator.gd
  - tools/dev/simulate.gd
  - src/territory/territory_invariants.gd
autonomous: true
requirements:
  - CMBT-007
  - CMBT-008
  - CMBT-009
---

# 03-combat-polish-PLAN.md

## Objective
Establish deterministic tick order, Threat Indicator UI, and stress test invariants.

## Tasks

<task>
  <objective>CMBT-007: Tick Resolution Order</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Update `src/gameplay/match_director.gd` to strictly enforce:
    1. Input
    2. Movement
    3. Arc raster marking
    4. Collision detection (collecting events)
    5. Seals (ordered by runner_id)
    6. Eliminations (Break/Backwash/Squeeze)
    7. Respawns
  </action>
  <acceptance_criteria>
    - `src/gameplay/match_director.gd` executes steps in exact deterministic order.
  </acceptance_criteria>
</task>

<task>
  <objective>CMBT-008: Threat Indicator</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Create `src/ui/hud/threat_indicator.gd` (Control).
    While runner is in DrawingTrail, if enemy runner is near the local runner's ARC, draw an arrow pointing to the threat.
    Opacity scales with proximity. Limit to top 2 threats.
  </action>
  <acceptance_criteria>
    - `src/ui/hud/threat_indicator.gd` displays warning arrows when enemies approach the arc.
  </acceptance_criteria>
</task>

<task>
  <objective>CMBT-009: Stress Test Invariants</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Create `src/territory/territory_invariants.gd` holding validation rules (e.g., dead runners have 0 claim).
    Update `tools/dev/simulate.gd` to run with aggressive bots and check invariants on every tick.
  </action>
  <acceptance_criteria>
    - `tools/dev/simulate.gd` verifies no invalid states (e.g. orphan arcs) occur in a simulated match.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Simulation tick order resolves all simultaneous combat logically. Threat indicators appear for incoming attacks. Headless stress testing passes invariant checks.
