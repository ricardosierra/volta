---
wave: 3
depends_on: [02-powerup-effects-PLAN]
files_modified:
  - apps/mobile/src/ui/hud/power_up_indicator.gd
  - apps/mobile/src/ui/hud/hud.gd
  - apps/mobile/src/ai/actions/collect_powerup.gd
  - apps/mobile/src/ai/bot_brain.gd
autonomous: true
requirements:
  - PU-06
  - PU-07
---

# 03-powerup-ui-ai-PLAN.md

## Objective
Present the power-ups via the HUD and teach bots to collect them.

## Tasks

<task>
  <objective>PWUP-006: HUD and Feedback</objective>
  <read_first>
    - .gsd/phases/14-power-ups/TASKS.md
  </read_first>
  <action>
    Create `power_up_indicator.gd` in the HUD to display the current active power-up with a radial timer. Hook up VFX/SFX calls.
  </action>
  <acceptance_criteria>
    - The player knows instantly when they have an effect and when it will expire.
  </acceptance_criteria>
</task>

<task>
  <objective>PWUP-007: AI and Power-ups</objective>
  <read_first>
    - .gsd/phases/14-power-ups/TASKS.md
  </read_first>
  <action>
    Add `collect_powerup.gd` as an AI action. Bots score this action based on distance to orb and their aggression profile.
  </action>
  <acceptance_criteria>
    - Bots actively seek out power-ups if they are close or if their profile dictates.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game remains balanced and readable.
