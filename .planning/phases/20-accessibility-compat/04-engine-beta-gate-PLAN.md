---
wave: 4
depends_on: [03-motor-cognitive-PLAN]
files_modified:
  - docs/architecture/adr-0006-engine-upgrade.md
  - .planning/STATUS.md
autonomous: true
requirements:
  - A11Y-08
  - A11Y-09
---

# 04-engine-beta-gate-PLAN.md

## Objective
Evaluate Godot 4.3 upgrade and pass the Beta Quality Gate.

## Tasks

<task>
  <objective>A11Y-08: Engine Upgrade ADR</objective>
  <read_first>
    - .gsd/phases/20-accessibility-compat/TASKS.md
  </read_first>
  <action>
    Write `adr-0006-engine-upgrade.md` documenting the decision whether to stay on Godot 4.2 or upgrade to 4.3 (or 4.4).
  </action>
  <acceptance_criteria>
    - Decision is documented logically with risk/reward.
  </acceptance_criteria>
</task>

<task>
  <objective>A11Y-09: Beta Gate</objective>
  <read_first>
    - .gsd/phases/20-accessibility-compat/TASKS.md
  </read_first>
  <action>
    Complete the Beta milestone by asserting a 99% crash-free rate and 30+ device coverage. Update `STATUS.md`.
  </action>
  <acceptance_criteria>
    - Beta milestone achieved.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A Beta candidate ready for public testing.
