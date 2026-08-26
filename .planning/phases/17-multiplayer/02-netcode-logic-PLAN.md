---
wave: 2
depends_on: [01-server-protocol-transport-PLAN]
files_modified:
  - apps/mobile/src/network/client_prediction.gd
  - apps/mobile/src/network/interpolation.gd
  - apps/mobile/src/server/input_validator.gd
autonomous: true
requirements:
  - MPLY-04
  - MPLY-05
  - MPLY-06
---

# 02-netcode-logic-PLAN.md

## Objective
Implement prediction, reconciliation, interpolation, and server-side validation.

## Tasks

<task>
  <objective>MPLY-004 & MPLY-005: Client Netcode</objective>
  <read_first>
    - .gsd/phases/17-multiplayer/TASKS.md
  </read_first>
  <action>
    Create `client_prediction.gd` to apply local inputs and reconcile with server snapshots. Create `interpolation.gd` to smoothly animate remote runners based on a 100ms snapshot buffer.
  </action>
  <acceptance_criteria>
    - Movement feels instant locally. Remote runners do not teleport under normal packet loss.
  </acceptance_criteria>
</task>

<task>
  <objective>MPLY-006: Input Validation</objective>
  <read_first>
    - .gsd/phases/17-multiplayer/TASKS.md
  </read_first>
  <action>
    Create `input_validator.gd` on the server to discard malformed, fast-forwarded, or out-of-order inputs.
  </action>
  <acceptance_criteria>
    - Malicious inputs are dropped silently without crashing the server.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The game remains playable under latency.
