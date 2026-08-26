---
wave: 2
depends_on: [01-backend-setup-PLAN]
files_modified:
  - services/api/app/Http/Controllers/AuthController.php
  - services/api/app/Http/Controllers/ProfileController.php
  - services/api/app/Http/Controllers/MatchController.php
  - services/api/app/Services/AntiCheatService.php
autonomous: true
requirements:
  - API-03
  - API-04
  - API-05
---

# 02-auth-matches-PLAN.md

## Objective
Implement Device Auth, Profiles, and Match Submission with Anti-cheat validation.

## Tasks

<task>
  <objective>API-003 & API-004: Auth & Profiles</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Implement `POST /auth/device` using Sanctum tokens. Implement `GET/PATCH /profile` with nickname sanitization (homoglyph/blocklist).
  </action>
  <acceptance_criteria>
    - Players can authenticate and edit profiles securely.
  </acceptance_criteria>
</task>

<task>
  <objective>API-005: Match Submission</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Implement `POST /matches` with idempotency. Implement `AntiCheatService` to validate payload signatures (HMAC), match duration plausibility, and flag suspicious data instead of auto-banning.
  </action>
  <acceptance_criteria>
    - Valid matches are accepted, duplicates ignored, forged scores flagged.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A robust pipeline for match ingestion that protects the integrity of the leaderboard.
