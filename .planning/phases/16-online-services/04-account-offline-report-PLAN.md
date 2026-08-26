---
wave: 4
depends_on: [03-cloud-save-config-PLAN]
files_modified:
  - apps/mobile/src/ui/screens/settings_screen.gd
  - docs/reports/offline-first-report.md
autonomous: true
requirements:
  - ONLN-008
  - ONLN-009
---

# 04-account-offline-report-PLAN.md

## Objective
Add Account Linking to the UI and generate the Offline-First validation report.

## Tasks

<task>
  <objective>ONLN-008: Account Linking</objective>
  <read_first>
    - .gsd/phases/16-online-services/TASKS.md
  </read_first>
  <action>
    Update `settings_screen.gd` with an "Account" section to link Google/Apple (mocked interface for now).
  </action>
  <acceptance_criteria>
    - User can link/unlink without breaking local progression.
  </acceptance_criteria>
</task>

<task>
  <objective>ONLN-009: Offline Validation</objective>
  <read_first>
    - .gsd/phases/16-online-services/TASKS.md
  </read_first>
  <action>
    Document the testing results in `offline-first-report.md` simulating a full plane ride (offline) and subsequent sync.
  </action>
  <acceptance_criteria>
    - Report proves that offline play is identical to online play.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game's network architecture is formally validated.
