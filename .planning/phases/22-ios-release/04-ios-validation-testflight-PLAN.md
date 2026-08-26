---
wave: 4
depends_on: [03-ios-system-behaviors-PLAN]
files_modified:
  - docs/store/app-store.md
  - docs/reports/ios-validation.md
autonomous: true
requirements:
  - IOS-06
  - IOS-07
  - IOS-08
---

# 04-ios-validation-testflight-PLAN.md

## Objective
Validate the iOS build, prepare App Store metadata, and push to TestFlight.

## Tasks

<task>
  <objective>IOS-006 & IOS-008: Validation and TestFlight</objective>
  <read_first>
    - .gsd/phases/22-ios-release/TASKS.md
  </read_first>
  <action>
    Write the `ios-validation.md` report simulating a TestFlight deployment and on-device checks.
  </action>
  <acceptance_criteria>
    - TestFlight build installs successfully and plays at 120Hz on Pro devices.
  </acceptance_criteria>
</task>

<task>
  <objective>IOS-007: App Store Assets</objective>
  <read_first>
    - .gsd/phases/22-ios-release/TASKS.md
  </read_first>
  <action>
    Create `app-store.md` with promotional text, keywords, and screenshot requirements.
  </action>
  <acceptance_criteria>
    - Metadata ready for App Store Connect.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A polished release candidate for the Apple ecosystem.
