---
wave: 2
depends_on: [01-client-analytics-PLAN]
files_modified:
  - services/api/app/Http/Controllers/TelemetryController.php
  - services/api/routes/api.php
  - services/api/database/migrations/2026_01_01_000002_create_telemetry_table.php
autonomous: true
requirements:
  - ANLT-03
  - ANLT-07
---

# 02-api-telemetry-PLAN.md

## Objective
Implement API ingestion and define dashboard queries.

## Tasks

<task>
  <objective>ANLT-03: Ingestion API</objective>
  <read_first>
    - .gsd/phases/18-analytics/TASKS.md
  </read_first>
  <action>
    Create `TelemetryController.php` and its migration to accept batch events and store them. Apply strict rate limits.
  </action>
  <acceptance_criteria>
    - The API handles batches efficiently and drops malformed data.
  </acceptance_criteria>
</task>

<task>
  <objective>ANLT-07: Dashboard Queries</objective>
  <read_first>
    - .gsd/phases/18-analytics/TASKS.md
  </read_first>
  <action>
    Write a stub dashboard controller or document the SQL queries needed to extract retention, crashes, and performance metrics.
  </action>
  <acceptance_criteria>
    - We have a clear path to answering product questions using the ingested data.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Ingestion scales horizontally.
