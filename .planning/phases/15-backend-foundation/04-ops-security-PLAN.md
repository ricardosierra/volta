---
wave: 4
depends_on: [03-social-progression-PLAN]
files_modified:
  - services/api/app/Http/Controllers/ConfigController.php
  - services/api/routes/api.php
  - .github/workflows/api-ci.yml
  - docs/deployment/api-deploy.md
autonomous: true
requirements:
  - API-09
  - API-10
  - API-11
  - API-12
---

# 04-ops-security-PLAN.md

## Objective
Implement Remote Config, Security rules, CI pipeline, and Deployment docs.

## Tasks

<task>
  <objective>API-009: Remote Config</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Implement `GET /config` with ETags. Config values must be constrained within safe bands.
  </action>
  <acceptance_criteria>
    - 304 Not Modified returned for unchanged ETags.
  </acceptance_criteria>
</task>

<task>
  <objective>API-010 & API-011 & API-012: Ops & Security</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Set up rate limiting routes, create GitHub Actions CI (`api-ci.yml`) for tests and static analysis. Document deployment in `api-deploy.md`.
  </action>
  <acceptance_criteria>
    - Rate limits block abuse. CI passes. Deployment is thoroughly documented.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The backend is production-ready, secure, and continuously tested.
