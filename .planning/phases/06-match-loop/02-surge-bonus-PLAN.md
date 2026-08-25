---
wave: 2
depends_on: [01-countdown-score-PLAN]
files_modified:
  - src/gameplay/score/surge_service.gd
  - resources/config/balance/surge.tres
  - src/gameplay/score/bonus_detector.gd
  - resources/config/balance/bonuses.tres
  - src/gameplay/match_director.gd
  - src/ui/hud/final_push_banner.gd
autonomous: true
requirements:
  - LOP-03
  - LOP-04
  - LOP-05
---

# 02-surge-bonus-PLAN.md

## Objective
Implement the Surge combo system, named bonuses, and the Final Push mechanic.

## Tasks

<task>
  <objective>LOOP-003: Surge Combo System</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Create `resources/config/balance/surge.tres` (decay rates, windows, max multiplier).
    Create `src/gameplay/score/surge_service.gd`. Increase level on seals and breaks.
    Decay over time (tick). Zero out on hit/backwash. Provide multiplier to `ScoreService`.
  </action>
  <acceptance_criteria>
    - Surge increases correctly and decays over time without activity.
  </acceptance_criteria>
</task>

<task>
  <objective>LOOP-004: Named Bonuses</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Create `resources/config/balance/bonuses.tres`.
    Create `src/gameplay/score/bonus_detector.gd`. Identify events like "Double Seal", "Squeeze", "Close Call".
    Emit signals used by UI popups.
  </action>
  <acceptance_criteria>
    - Bonus events trigger when their logical conditions are met in the simulation.
  </acceptance_criteria>
</task>

<task>
  <objective>LOOP-005: Final Push</objective>
  <read_first>
    - .gsd/phases/06-match-loop/TASKS.md
  </read_first>
  <action>
    Update `src/gameplay/match_director.gd` to identify the last 30 seconds of a match.
    Create `src/ui/hud/final_push_banner.gd`.
    During Final Push, `ScoreService` uses a PUSH_MULT multiplier.
  </action>
  <acceptance_criteria>
    - Final Push engages dynamically at the 30s remaining mark.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Combo multiplier affects scoring. Unique actions generate bonuses. The last 30s dramatically scales points.
