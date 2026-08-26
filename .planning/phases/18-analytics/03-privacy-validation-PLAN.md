---
wave: 3
depends_on: [02-api-telemetry-PLAN]
files_modified:
  - apps/mobile/src/ui/screens/settings_screen.gd
  - docs/reports/analytics-validation.md
autonomous: true
requirements:
  - ANLT-06
  - ANLT-08
---

# 03-privacy-validation-PLAN.md

## Objective
Implement Privacy opt-out controls and validate the entire analytics pipeline.

## Tasks

<task>
  <objective>ANLT-06: Privacy Opt-out</objective>
  <read_first>
    - .gsd/phases/18-analytics/TASKS.md
  </read_first>
  <action>
    Update `settings_screen.gd` to include a clear privacy toggle. Ensure the analytics adapter drops batches if consent is revoked.
  </action>
  <acceptance_criteria>
    - Re-toggling deletes the local UUID and issues a new one. Data flow stops completely when opted out.
  </acceptance_criteria>
</task>

<task>
  <objective>ANLT-08: Validation Report</objective>
  <read_first>
    - .gsd/phases/18-analytics/TASKS.md
  </read_first>
  <action>
    Document the end-to-end validation results in `analytics-validation.md`.
  </action>
  <acceptance_criteria>
    - Proof that telemetry is both useful and respectful of bandwidth and battery.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A fully GDPR/CCPA compliant telemetry pipeline.
