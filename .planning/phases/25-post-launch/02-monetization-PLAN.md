---
wave: 2
depends_on: [01-balance-fixes-PLAN]
files_modified:
  - apps/mobile/src/platform/monetization_service.gd
  - services/api/app/Http/Controllers/ReceiptValidationController.php
autonomous: true
requirements:
  - POST-03
---

# 02-monetization-PLAN.md

## Objective
Implement ethical monetization through Rewarded Ads and validated IAPs.

## Tasks

<task>
  <objective>POST-003: Monetization</objective>
  <read_first>
    - .gsd/phases/25-post-launch/TASKS.md
  </read_first>
  <action>
    Create `monetization_service.gd` outlining the client structure for ads and IAPs. Create `ReceiptValidationController.php` for server-side verification.
  </action>
  <acceptance_criteria>
    - No artificial friction, purely cosmetic/optional purchases, securely validated.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A sustainable business model that respects the player.
