---
wave: 2
depends_on: [01-api-client-PLAN]
files_modified:
  - apps/mobile/src/progression/leaderboard/remote_leaderboard_repository.gd
  - apps/mobile/src/progression/challenges/remote_challenge_repository.gd
  - apps/mobile/src/ui/screens/leaderboard_screen.gd
autonomous: true
requirements:
  - ONLN-003
  - ONLN-004
  - ONLN-007
---

# 02-remote-repos-ui-PLAN.md

## Objective
Implement Remote Leaderboards, Remote Challenges, and the Leaderboard UI.

## Tasks

<task>
  <objective>ONLN-003 & ONLN-004: Remote Repositories</objective>
  <read_first>
    - .gsd/phases/16-online-services/TASKS.md
  </read_first>
  <action>
    Create `remote_leaderboard_repository.gd` and `remote_challenge_repository.gd`. Use `ApiClient` to fetch data. Provide fallbacks to local data if the API fails, satisfying MOCK-001 and MOCK-004.
  </action>
  <acceptance_criteria>
    - Leaderboards and Challenges load from the server and fall back gracefully.
  </acceptance_criteria>
</task>

<task>
  <objective>ONLN-007: Leaderboard UI</objective>
  <read_first>
    - .gsd/phases/16-online-services/TASKS.md
  </read_first>
  <action>
    Create `leaderboard_screen.gd` featuring tabs for different timeframes and fixing the player's rank at the bottom. Show loading/offline states.
  </action>
  <acceptance_criteria>
    - The screen is responsive and clearly communicates network state to the user.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The UI is completely decoupled from network latency.
