---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/project.godot
  - CHANGELOG.md
  - docs/reports/release_checklist_execution.md
autonomous: true
requirements:
  - LNCH-01
  - LNCH-02
---

# 01-version-checklist-PLAN.md

## Objective
Bump the version to `v0.1.0` and execute the release checklist.

## Tasks

<task>
  <objective>LNCH-001: Version Bump</objective>
  <read_first>
    - .gsd/phases/24-launch/TASKS.md
  </read_first>
  <action>
    Update `project.godot` to version `v0.1.0`. Update `CHANGELOG.md` with release notes.
  </action>
  <acceptance_criteria>
    - The repository is frozen for the v0.1.0 release.
  </acceptance_criteria>
</task>

<task>
  <objective>LNCH-002: Release Checklist</objective>
  <read_first>
    - .gsd/phases/24-launch/TASKS.md
  </read_first>
  <action>
    Create `docs/reports/release_checklist_execution.md` logging the sign-off for every required pre-launch check.
  </action>
  <acceptance_criteria>
    - No skipped steps.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A formally approved release candidate.
