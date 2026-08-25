---
wave: 3
depends_on: [02-stats-challenges-PLAN]
files_modified:
  - src/ui/screens/profile_screen.gd
  - src/ui/screens/challenges_screen.gd
autonomous: true
requirements:
  - PRG-07
  - PRG-08
---

# 03-progression-ui-PLAN.md

## Objective
Build the screens where players view their progress and claim rewards.

## Tasks

<task>
  <objective>PROG-007: Profile Screen</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/ui/screens/profile_screen.gd`. Display stats, level bar, avatar, and match history summary.
  </action>
  <acceptance_criteria>
    - Screen is cleanly laid out and uses tokens.
  </acceptance_criteria>
</task>

<task>
  <objective>PROG-008: Challenges Screen</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/ui/screens/challenges_screen.gd`. Show active dailies/weeklies with progress bars and a reroll button.
  </action>
  <acceptance_criteria>
    - Claim buttons function properly.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The UI accurately reflects internal progression state.
