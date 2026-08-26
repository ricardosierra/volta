---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/server/server_main.gd
  - apps/mobile/src/network/protocol.gd
  - apps/mobile/src/network/network_transport.gd
autonomous: true
requirements:
  - MPLY-01
  - MPLY-02
  - MPLY-03
---

# 01-server-protocol-transport-PLAN.md

## Objective
Establish the headless server entrypoint, define the binary protocol, and configure the transport layer.

## Tasks

<task>
  <objective>MPLY-001: Headless Server</objective>
  <read_first>
    - .gsd/phases/17-multiplayer/TASKS.md
  </read_first>
  <action>
    Create `server_main.gd` that instantiates `MatchDirector` without visuals when run with `--server`.
  </action>
  <acceptance_criteria>
    - Server boots and runs a match entirely in headless mode.
  </acceptance_criteria>
</task>

<task>
  <objective>MPLY-002 & MPLY-003: Protocol and Transport</objective>
  <read_first>
    - .gsd/phases/17-multiplayer/TASKS.md
  </read_first>
  <action>
    Create `protocol.gd` to serialize/deserialize binary inputs and snapshots. Create `network_transport.gd` using Godot's High-Level Multiplayer API (ENet) for low-latency UDP communication.
  </action>
  <acceptance_criteria>
    - Messages serialize symmetrically. ENet connects, authenticates, and detects disconnects.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: The server and client can communicate binary payloads with minimal overhead.
