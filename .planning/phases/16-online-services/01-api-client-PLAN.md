---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/platform/api/api_client.gd
  - apps/mobile/src/platform/api/offline_queue.gd
  - apps/mobile/src/progression/remote_profile_repository.gd
autonomous: true
requirements:
  - ONLN-001
  - ONLN-002
---

# 01-api-client-PLAN.md

## Objective
Implement the resilient `ApiClient` and `OfflineQueue` for offline-first architecture.

## Tasks

<task>
  <objective>ONLN-001: ApiClient</objective>
  <read_first>
    - .gsd/phases/16-online-services/TASKS.md
  </read_first>
  <action>
    Create `api_client.gd` wrapping `HTTPRequest`. Implement retries with exponential backoff and jitter. Add automatic `Idempotency-Key` headers to POST/PUT requests.
  </action>
  <acceptance_criteria>
    - Network calls do not block the main thread and automatically retry on 5xx but not 4xx.
  </acceptance_criteria>
</task>

<task>
  <objective>ONLN-002: Offline Queue</objective>
  <read_first>
    - .gsd/phases/16-online-services/TASKS.md
  </read_first>
  <action>
    Create `offline_queue.gd` that persists requests to `user://queue.json`. Opportunistically drain the queue when online. Implement `RemoteProfileRepository` leveraging this queue for saves.
  </action>
  <acceptance_criteria>
    - The queue persists across game reboots and processes sequentially when network is restored.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A robust networking layer that respects the offline-first mandate.
