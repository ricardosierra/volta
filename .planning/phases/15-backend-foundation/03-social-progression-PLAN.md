---
wave: 3
depends_on: [02-auth-matches-PLAN]
files_modified:
  - services/api/app/Http/Controllers/LeaderboardController.php
  - services/api/app/Http/Controllers/CloudSaveController.php
  - services/api/app/Http/Controllers/ChallengeController.php
autonomous: true
requirements:
  - API-06
  - API-07
  - API-08
---

# 03-social-progression-PLAN.md

## Objective
Implement Leaderboards (Redis-backed), Cloud Saves, and Daily Challenges.

## Tasks

<task>
  <objective>API-006: Leaderboards</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Implement `GET /leaderboards/{board}`. Use Redis ZSET for fast reads and Postgres for durable source of truth. Implement reconciliation jobs.
  </action>
  <acceptance_criteria>
    - Read latency < 50ms, accurate ranking.
  </acceptance_criteria>
</task>

<task>
  <objective>API-007: Cloud Save</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Implement `GET/PUT /save`. Handle conflict resolution monotonically (e.g. max XP wins). Keep the last 3 versions.
  </action>
  <acceptance_criteria>
    - No progress is lost during out-of-order syncs.
  </acceptance_criteria>
</task>

<task>
  <objective>API-008: Daily Challenges</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Implement daily rotating challenges via a cron job and `GET /challenges/daily`, `POST /challenges/{id}/claim`.
  </action>
  <acceptance_criteria>
    - Claims are idempotent and validated against match history.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Scalable player progression systems.
