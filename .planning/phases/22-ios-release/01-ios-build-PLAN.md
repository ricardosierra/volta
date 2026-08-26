---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/tools/ci/build_ios.sh
  - apps/mobile/tools/ci/archive_ios.sh
  - docs/mobile/ios.md
autonomous: true
requirements:
  - IOS-01
  - IOS-02
---

# 01-ios-build-PLAN.md

## Objective
Configure the iOS export and archiving scripts.

## Tasks

<task>
  <objective>IOS-001 & IOS-002: Build and Archive</objective>
  <read_first>
    - .gsd/phases/22-ios-release/TASKS.md
  </read_first>
  <action>
    Create `build_ios.sh` to export the Xcode project from Godot. Create `archive_ios.sh` to run `xcodebuild archive` and generate the IPA. Document the provisioning profile requirements in `ios.md`.
  </action>
  <acceptance_criteria>
    - The Xcode project and IPA can be generated via shell scripts.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A reproducible iOS build pipeline.
