---
wave: 2
depends_on: [01-qa-regression-PLAN]
files_modified:
  - tests/fixtures/saves/v0.1.0-alpha.json
  - docs/reports/crash_recovery.md
autonomous: true
requirements:
  - PROD-03
  - PROD-04
---

# 02-saves-crash-PLAN.md

## Objective
Verify save game migration and crash recovery mechanisms.

## Tasks

<task>
  <objective>PROD-003: Save Migration</objective>
  <read_first>
    - .gsd/phases/23-production-readiness/TASKS.md
  </read_first>
  <action>
    Create a fixture save file `v0.1.0-alpha.json` and document the migration test protocol.
  </action>
  <acceptance_criteria>
    - Players from alpha/beta will not lose progress upon updating.
  </acceptance_criteria>
</task>

<task>
  <objective>PROD-004: Crash Recovery</objective>
  <read_first>
    - .gsd/phases/23-production-readiness/TASKS.md
  </read_first>
  <action>
    Document the crash recovery tests (force killing the app during loading, saving, gameplay) in `crash_recovery.md`.
  </action>
  <acceptance_criteria>
    - Data corruption is impossible.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Bulletproof data integrity.
