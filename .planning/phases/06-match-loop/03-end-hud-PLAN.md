---
wave: 3
depends_on: [02-surge-bonus-PLAN]
files_modified:
  - src/gameplay/match_director.gd
  - src/gameplay/match_result.gd
  - src/ui/hud/hud.gd
  - src/ui/hud/territory_label.gd
  - src/ui/hud/position_label.gd
  - src/ui/hud/timer_label.gd
  - src/ui/hud/risk_indicator.gd
  - src/ui/hud/surge_meter.gd
  - src/ui/hud/pause_button.gd
autonomous: true
requirements:
  - LOP-06
  - LOP-07
---

# 03-end-hud-PLAN.md

## Objective
Establish end match logic and fully functional UI HUD.

## Tasks

<task>
  <objective>LOOP-006: End Match and Ranking</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Create `src/gameplay/match_result.gd`.
    Update `src/gameplay/match_director.gd` to end the match via Time, Domination limit, or Last Man Standing.
    Rank players primarily by claim percentage, resolve ties by score, then largest seal.
  </action>
  <acceptance_criteria>
    - Match correctly ends and calculates deterministic final standings.
  </acceptance_criteria>
</task>

<task>
  <objective>LOOP-007: Functional HUD</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Create `src/ui/hud/hud.gd` encompassing components: `territory_label.gd`, `position_label.gd`, `timer_label.gd`, `risk_indicator.gd`, `surge_meter.gd`, and `pause_button.gd`.
    Keep the UI minimal and constrained to safe areas using tabular font numbers.
  </action>
  <acceptance_criteria>
    - HUD elements display live gameplay data without occluding action.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The match ends gracefully and determines a winner. HUD operates smoothly without framerate drops.
