---
wave: 2
depends_on: [01-ios-build-PLAN]
files_modified:
  - apps/mobile/project.godot
  - docs/legal/PrivacyInfo.xcprivacy
autonomous: true
requirements:
  - IOS-03
  - IOS-04
---

# 02-ios-icons-privacy-PLAN.md

## Objective
Finalize iOS icons, Launch Screen settings, and the Privacy Manifest.

## Tasks

<task>
  <objective>IOS-003: Icons</objective>
  <read_first>
    - .gsd/phases/22-ios-release/TASKS.md
  </read_first>
  <action>
    Ensure `project.godot` specifies the correct 1024x1024 icon without alpha channel for iOS.
  </action>
  <acceptance_criteria>
    - No alpha channel warnings from Xcode.
  </acceptance_criteria>
</task>

<task>
  <objective>IOS-004: Privacy Manifest</objective>
  <read_first>
    - .gsd/phases/22-ios-release/TASKS.md
  </read_first>
  <action>
    Create a stub `PrivacyInfo.xcprivacy` declaring our use of Crash Data and Analytics without cross-app tracking.
  </action>
  <acceptance_criteria>
    - The App Store accepts the privacy manifest without flagging ATT violations.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: App conforms to Apple's strict privacy and aesthetic guidelines.
