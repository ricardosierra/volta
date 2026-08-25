---
wave: 1
depends_on: []
files_modified:
  - src/progression/profile.gd
  - src/progression/profile_repository.gd
  - src/progression/local_profile_repository.gd
  - src/progression/xp_service.gd
  - src/progression/wallet.gd
autonomous: true
requirements:
  - PRG-01
  - PRG-02
  - PRG-06
---

# 01-core-progression-PLAN.md

## Objective
Implement core player identity, XP scaling, and economy wallet.

## Tasks

<task>
  <objective>PROG-001: Player Profile</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/progression/profile.gd`, `profile_repository.gd` interface, and `local_profile_repository.gd` implementation relying on local persistence.
  </action>
  <acceptance_criteria>
    - Profile generates default name on first launch and saves correctly.
  </acceptance_criteria>
</task>

<task>
  <objective>PROG-002: XP and Ranks</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/progression/xp_service.gd`. Calculate level from XP based on formula `100 * (level ^ 1.35)`.
  </action>
  <acceptance_criteria>
    - Level caps do not exist. Curve is strictly monotonic.
  </acceptance_criteria>
</task>

<task>
  <objective>PROG-006: Wallet</objective>
  <read_first>
    - .gsd/phases/10-progression/TASKS.md
  </read_first>
  <action>
    Create `src/progression/wallet.gd`. Track Sparks (soft) and Prisms (hard). Handle caps per match.
  </action>
  <acceptance_criteria>
    - Balance never dips below zero.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The player has an identity, levels up, and earns currency reliably.
