---
wave: 1
depends_on: []
files_modified:
  - apps/mobile/tools/ci/make_export_presets.sh
  - apps/mobile/tools/ci/check_release_build.sh
  - apps/mobile/src/core/build_config.gd
autonomous: true
requirements:
  - ANDR-01
  - ANDR-02
  - ANDR-03
---

# 01-android-build-PLAN.md

## Objective
Configure the Android release pipeline to guarantee a clean, signed, and debug-free build.

## Tasks

<task>
  <objective>ANDR-001 & ANDR-002: Config and Signing</objective>
  <read_first>
    - .gsd/phases/21-android-release/TASKS.md
  </read_first>
  <action>
    Create `build_config.gd` to toggle debug features based on `OS.is_debug_build()`. Create `make_export_presets.sh` to dynamically insert CI secrets for the keystore.
  </action>
  <acceptance_criteria>
    - The build pipeline can sign APK/AABs without exposing credentials in the repository.
  </acceptance_criteria>
</task>

<task>
  <objective>ANDR-003: Clean Build Script</objective>
  <read_first>
    - .gsd/phases/21-android-release/TASKS.md
  </read_first>
  <action>
    Create `check_release_build.sh` to fail the CI if any `addons/gut`, debug scenes, or unresolved TODOs are detected in the export payload.
  </action>
  <acceptance_criteria>
    - It is mechanically impossible to ship debugging tools to production.
  </acceptance_criteria>
</task>

## Verification
- Must Haves: A bulletproof CI configuration for release artifacts.
