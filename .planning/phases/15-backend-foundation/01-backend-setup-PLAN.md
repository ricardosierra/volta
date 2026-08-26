---
wave: 1
depends_on: []
files_modified:
  - services/api/
  - docker-compose.yml
autonomous: true
requirements:
  - API-01
  - API-02
---

# 01-backend-setup-PLAN.md

## Objective
Initialize the Laravel 11 backend project in `services/api/` with Docker, Postgres, Redis, and create the initial database schema (Migrations, Models, Factories).

## Tasks

<task>
  <objective>API-001: Project Setup</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Create a new Laravel project in `services/api/`. Set up `docker-compose.yml` for Postgres 16 and Redis 7. Configure PHPStan and Pest. Create `tools/dev/api_up.sh`.
  </action>
  <acceptance_criteria>
    - `docker compose up -d` brings up the DBs and the Laravel app correctly. `php artisan test` works.
  </acceptance_criteria>
</task>

<task>
  <objective>API-002: Migrations and Models</objective>
  <read_first>
    - .gsd/phases/15-backend-foundation/TASKS.md
  </read_first>
  <action>
    Create migrations for Users/Profiles, Matches, Leaderboards, CloudSaves. Create eloquent models, factories, and seeders.
  </action>
  <acceptance_criteria>
    - `php artisan migrate:fresh --seed` populates the database without errors.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The backend repository structure is robust, containerized, and strictly typed via PHPStan level 6.
