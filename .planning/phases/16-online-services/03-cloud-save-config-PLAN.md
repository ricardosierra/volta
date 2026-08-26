---
wave: 3
depends_on: [02-remote-repos-ui-PLAN]
files_modified:
  - apps/mobile/src/progression/cloud_save_service.gd
  - apps/mobile/src/core/config/http_remote_config.gd
autonomous: true
requirements:
  - ONLN-005
  - ONLN-006
---

# 03-cloud-save-config-PLAN.md

## Objective
Implement Cloud Save sync and Remote Config parsing.

## Tasks

<task>
  <objective>ONLN-005: Cloud Save</objective>
  <read_first>
    - .gsd/phases/16-online-services/TASKS.md
  </read_first>
  <action>
    Create `cloud_save_service.gd` that serializes Profile, Stats, Inventory, and ships it via `ApiClient`. It should parse incoming saves and merge monotonically.
  </action>
  <acceptance_criteria>
    - Syncing preserves the highest XP and union of inventory items in conflict scenarios.
  </acceptance_criteria>
</task>

<task>
  <objective>ONLN-006: HttpRemoteConfig</objective>
  <read_first>
    - .gsd/phases/16-online-services/TASKS.md
  </read_first>
  <action>
    Create `http_remote_config.gd` that fetches JSON from the server on boot, validates boundaries, and falls back to local. Resolves MOCK-003.
  </action>
  <acceptance_criteria>
    - Remote config never crashes the client if the JSON is malformed.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Data integrity across devices and safe dynamic configurations.
