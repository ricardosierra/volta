---
wave: 1
depends_on: []
files_modified:
  - tests/qa/release_checklist.md
  - .github/workflows/automated_regression.yml
autonomous: true
requirements:
  - PROD-01
  - PROD-02
---

# 01-qa-regression-PLAN.md

## Objective
Establish the manual QA checklist and lock in the automated regression suite.

## Tasks

<task>
  <objective>PROD-001: Manual QA</objective>
  <read_first>
    - .gsd/phases/23-production-readiness/TASKS.md
  </read_first>
  <action>
    Create `tests/qa/release_checklist.md` documenting every screen, mode, and edge case to be tested manually before release.
  </action>
  <acceptance_criteria>
    - QA Script is exhaustive.
  </acceptance_criteria>
</task>

<task>
  <objective>PROD-002: Automated Regression</objective>
  <read_first>
    - .gsd/phases/23-production-readiness/TASKS.md
  </read_first>
  <action>
    Create `automated_regression.yml` to formalize the CI run of all tests and benchmarks before any merge to main.
  </action>
  <acceptance_criteria>
    - The repository cannot accept regressions.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Quality gates are strictly enforced.
