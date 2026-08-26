---
wave: 3
depends_on: [02-icons-permissions-PLAN]
files_modified:
  - docs/legal/privacy-policy.md
  - docs/store/google-play.md
autonomous: true
requirements:
  - ANDR-06
  - ANDR-07
---

# 03-privacy-store-PLAN.md

## Objective
Prepare the legal and marketing texts required for Google Play.

## Tasks

<task>
  <objective>ANDR-006 & ANDR-007: Privacy & Store Metadata</objective>
  <read_first>
    - .gsd/phases/21-android-release/TASKS.md
  </read_first>
  <action>
    Draft `privacy-policy.md` focusing on telemetry opt-out. Draft `google-play.md` containing the short/long descriptions (en, pt-BR) and the list of required graphic assets.
  </action>
  <acceptance_criteria>
    - We have the text and requirements ready to paste into the Google Play Console.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: Total alignment between app behavior and its public declarations.
