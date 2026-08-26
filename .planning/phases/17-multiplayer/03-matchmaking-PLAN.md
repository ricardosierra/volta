---
wave: 3
depends_on: [02-netcode-logic-PLAN]
files_modified:
  - apps/mobile/src/server/matchmaker.gd
autonomous: true
requirements:
  - MPLY-07
---

# 03-matchmaking-PLAN.md

## Objective
Implement matchmaking logic and reconnection handling.

## Tasks

<task>
  <objective>MPLY-007: Matchmaking & Reconnection</objective>
  <read_first>
    - .gsd/phases/17-multiplayer/TASKS.md
  </read_first>
  <action>
    Create `matchmaker.gd` on the server to queue players, backfill with bots if necessary, and handle dropped clients by converting them temporarily to bots until reconnection.
  </action>
  <acceptance_criteria>
    - Players are placed into a match within a time limit, and dropping out doesn't ruin the game for others.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The lifecycle of a multiplayer session is fully managed.
