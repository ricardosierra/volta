---
wave: 2
depends_on: [01-collision-PLAN]
files_modified:
  - src/gameplay/elimination_service.gd
  - src/runner/states/hit_state.gd
  - src/runner/states/backwash_state.gd
  - src/runner/states/respawning_state.gd
  - src/arena/spawner.gd
  - src/gameplay/match_director.gd
autonomous: true
requirements:
  - CMBT-002
  - CMBT-003
  - CMBT-005
  - CMBT-006
---

# 02-elimination-PLAN.md

## Objective
Implement Break, Backwash, Squeeze, and Respawn mechanics.

## Tasks

<task>
  <objective>CMBT-002: Break and Release</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Create `src/gameplay/elimination_service.gd` to process Break events.
    Create `src/runner/states/hit_state.gd`.
    When hit: clear arc, release claim, enter Hit state. Emit `runner_broken(victim, killer, cause)`.
    Handle mutual death (both in Hit, no credit).
  </action>
  <acceptance_criteria>
    - `src/gameplay/elimination_service.gd` handles eliminations and releases territory cleanly.
  </acceptance_criteria>
</task>

<task>
  <objective>CMBT-003: Backwash</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Create `src/runner/states/backwash_state.gd`.
    On self-intersection or wall hit: clear arc, start new arc instantly. Apply speed penalty via StatBlock.
  </action>
  <acceptance_criteria>
    - Backwash clears arc but leaves claim intact and keeps runner active.
  </acceptance_criteria>
</task>

<task>
  <objective>CMBT-005: Squeeze</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Update `src/gameplay/elimination_service.gd` to listen to `squeezed` signal from Grid/SealApplier.
    Route to elimination flow: credit the sealer, enter Hit state.
  </action>
  <acceptance_criteria>
    - Squeezed signal triggers elimination flow.
  </acceptance_criteria>
</task>

<task>
  <objective>CMBT-006: Respawn</objective>
  <read_first>
    - .gsd/phases/04-combat-elimination/TASKS.md
  </read_first>
  <action>
    Create `src/arena/spawner.gd` to find valid neutral spawn points.
    Create `src/runner/states/respawning_state.gd`.
    After hit state delay, use spawner to find spot, call `seed_claim`, and set brief invulnerability.
  </action>
  <acceptance_criteria>
    - Spawner finds empty cells for respawn.
    - Respawn seeds initial claim correctly.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Players can be eliminated, their territory is cleared, and they respawn correctly. Backwash applies penalties without elimination.
