---
wave: 3
depends_on: [02-ios-icons-privacy-PLAN]
files_modified:
  - apps/mobile/src/presentation/audio/sfx_service.gd
  - apps/mobile/src/core/bootstrap.gd
autonomous: true
requirements:
  - IOS-05
---

# 03-ios-system-behaviors-PLAN.md

## Objective
Ensure the game behaves correctly during iOS system interruptions.

## Tasks

<task>
  <objective>IOS-005: System Behaviors</objective>
  <read_first>
    - .gsd/phases/22-ios-release/TASKS.md
  </read_first>
  <action>
    Update Audio logic to resume properly after phone calls. Ensure the main loop pauses and saves state instantly upon entering the background.
  </action>
  <acceptance_criteria>
    - The game does not crash or lose audio when receiving a notification or call.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A seamless experience when multitasking.
