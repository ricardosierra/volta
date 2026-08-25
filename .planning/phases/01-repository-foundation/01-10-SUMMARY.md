---
phase: 01-repository-foundation
plan: 10
subsystem: infra
tags: [godot, android, export, ci, dev-overlay]

# Dependency graph
requires:
  - phase: 01-repository-foundation (plans 01-01..01-09)
    provides: Godot project scaffold, Build/Log/Bootstrap/ServiceRegistry, GUT, validate-repo/lint/test-client CI scripts, pinned Godot 4.3 setup
provides:
  - "apps/mobile/scenes/main.tscn: minimal main scene (background + VOLTA title + DevOverlay), reachable from boot.tscn via Bootstrap.next_scene_path"
  - "apps/mobile/src/core/dev_overlay.gd: FPS/memory/tier debug overlay behind Build.is_debug()"
  - "tools/ci/build_android.sh debug: single-command Android debug APK export via Godot CLI"
  - "tools/ci/make_export_presets.sh + export_presets.template.cfg: generates gitignored apps/mobile/export_presets.cfg"
  - "docs/performance/device-results.md: ready-to-fill table for Plan 01-11's real-device measurement"
  - "apps/mobile/project.godot: rendering/textures/vram_compression/import_etc2_astc=true (required for Android export to validate at all)"
affects: [01-11-device-checkpoint]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Debug-only UI (DevOverlay) as a CanvasLayer child that self-queue_free()s when Build.is_debug() is false, never touching production code paths"
    - "Export presets generated from a versioned template (tools/ci/export_presets.template.cfg) + env var substitution, output gitignored"

key-files:
  created:
    - apps/mobile/scenes/main.tscn
    - apps/mobile/src/core/dev_overlay.gd
    - tools/ci/export_presets.template.cfg
    - tools/ci/make_export_presets.sh
    - tools/ci/build_android.sh
    - docs/performance/device-results.md
  modified:
    - apps/mobile/src/core/bootstrap.gd
    - apps/mobile/project.godot

key-decisions:
  - "export_presets.template.cfg needs export_filter/include_filter/exclude_filter/script_export_mode keys (not in the plan's literal template text) because Godot 4.3's base EditorExportPreset parser reads them with no default and errors out otherwise"
  - "project.godot needs rendering/textures/vram_compression/import_etc2_astc=true or Android export silently fails validation with an EMPTY error message (Godot 4.3 bug: has_valid_project_configuration sets valid=false with no err text appended for this specific check) -- traced by downloading and reading godotengine/godot 4.3-stable export_plugin.cpp/editor_export_platform.cpp source"
  - "PLACEHOLDER-ART-006 note placed in dev_overlay.gd (not main.tscn) per the plan's own fallback -- Godot .tscn resource format does not support arbitrary comment lines"

requirements-completed: [FND-01]

# Metrics
duration: 20min
completed: 2026-08-24
---

# Phase 01 Plan 10: Main Scene + Android Debug Build Summary

**Minimal main.tscn with FPS/tier DevOverlay behind Build.is_debug(), plus a working one-command `tools/ci/build_android.sh debug` that produces a real signed 47 MB APK — proving the whole Godot 4.3 Android export pipeline end to end, headless, with no editor GUI.**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-08-24T21:53:00-03:00 (approx.)
- **Completed:** 2026-08-24T22:12:00-03:00
- **Tasks:** 3/3 completed
- **Files modified:** 8 (6 created, 2 modified)

## Accomplishments

- `apps/mobile/scenes/main.tscn` exists, is reachable from `boot.tscn` (via `Bootstrap.next_scene_path`), and shows a provisional background, the "VOLTA" title, and a debug overlay
- `DevOverlay` (`apps/mobile/src/core/dev_overlay.gd`) shows version/FPS/memory/tier and disappears entirely (via `queue_free()`) when `Build.is_debug()` is false
- `tools/ci/build_android.sh debug` runs end to end on this machine and produces `dist/android/volta-debug.apk` — signed, 47 MB, containing `classes.dex` and `lib/{arm64-v8a,armeabi-v7a}/libgodot_android.so`
- `docs/performance/device-results.md` created with the exact table structure Plan 01-11 needs to fill in on real hardware

## Task Commits

1. **Task 1: main.tscn + DevOverlay** - `6e4a744` (feat)
2. **Task 2: Export presets + build_android.sh debug** - `2a9e539` (ci)
3. **Task 3: docs/performance/device-results.md** - `caeb966` (docs)

## Files Created/Modified

- `apps/mobile/scenes/main.tscn` - minimal main scene: `Node2D` root, full-screen `ColorRect` background, centered `Label` ("VOLTA"), `DevOverlay` child
- `apps/mobile/src/core/dev_overlay.gd` - `CanvasLayer` debug overlay: version/FPS/memory/tier text, gated by `Build.is_debug()`; carries the `PLACEHOLDER-ART-006` note for main.tscn's background color (`.tscn` can't hold a plain comment)
- `apps/mobile/src/core/bootstrap.gd` - `next_scene_path` now `"res://scenes/main.tscn"` (one-line data edit, no new logic)
- `tools/ci/export_presets.template.cfg` - versioned Android preset template (arm64-v8a + armeabi-v7a, portrait, package placeholder); includes the required `export_filter`/`include_filter`/`exclude_filter`/`script_export_mode` keys
- `tools/ci/make_export_presets.sh` - generates `apps/mobile/export_presets.cfg` from the template + `ANDROID_PACKAGE_NAME` env var (output gitignored, script executable)
- `tools/ci/build_android.sh` - resolves the Godot binary the same way as other `tools/ci` scripts, runs `make_export_presets.sh`, then `--export-debug "Android"` to `dist/android/volta-debug.apk`
- `apps/mobile/project.godot` - added `rendering/textures/vram_compression/import_etc2_astc=true` (required by Godot 4.3's Android export validation; see Deviations below)
- `docs/performance/device-results.md` - new file: "Phase 1" pending-measurement table + empty "Histórico" table, ready for Plan 01-11

## Decisions Made

- Added the `export_filter`/`include_filter`/`exclude_filter`/`script_export_mode` keys to `export_presets.template.cfg` beyond what the plan's literal template text specified — Godot 4.3's generic `EditorExportPreset` reader calls `get_value()` for these with no default argument and hard-errors ("Couldn't find the given section... and no default was given") if they're absent from any `[preset.N]` section, regardless of platform.
- Enabled `rendering/textures/vram_compression/import_etc2_astc` in `project.godot`. Without it, `EditorExportPlatformAndroid::has_valid_project_configuration` (Godot 4.3 `platform/android/export/export_plugin.cpp`) sets `valid = false` but appends **no text** to the error string for this specific check, so the CLI just prints "Cannot export project with preset due to configuration errors:" followed by a blank line and exits 1 — no actionable message. Confirmed by downloading and reading `godotengine/godot` 4.3-stable source (`editor_export_platform.cpp` + `export_plugin.cpp`) rather than guessing. This also happens to be exactly what `docs/mobile/android.md` already mandates ("Texturas em ETC2/ASTC; nada de PNG cru em runtime"), so the fix is a doc-mandated setting that was simply never added in Plan 01-01.
- Kept `PLACEHOLDER-ART-006` as a comment in `dev_overlay.gd` rather than in `main.tscn`, per the plan's own documented fallback: Godot's `.tscn` text-resource format has no comment syntax for arbitrary lines inside a node's property block.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] export_presets.template.cfg missing required generic preset keys**
- **Found during:** Task 2, first run of `./tools/ci/build_android.sh debug`
- **Issue:** Godot 4.3 failed the export immediately with `ERROR: Couldn't find the given section "preset.0" and key "export_filter", and no default was given.` (same for `include_filter`, `exclude_filter`) — these keys are read by the platform-agnostic preset loader (not Android-specific) and have no fallback default.
- **Fix:** Added `advanced_options=false`, `dedicated_server=false`, `custom_features=""`, `export_filter="all_resources"`, `include_filter=""`, `exclude_filter=""`, `encrypt_pck=false`, `encrypt_directory=false`, `script_export_mode=1` to `[preset.0]` in `tools/ci/export_presets.template.cfg`.
- **Files modified:** `tools/ci/export_presets.template.cfg`
- **Verification:** Re-ran `./tools/ci/build_android.sh debug`; this specific error no longer appeared (a different, unrelated error appeared next — see item 2).
- **Committed in:** `2a9e539` (Task 2 commit)

**2. [Rule 3 - Blocking] Android export requires ETC2/ASTC texture compression enabled in project.godot**
- **Found during:** Task 2, second run of `./tools/ci/build_android.sh debug`
- **Issue:** Export still failed with an empty configuration-error message (`Cannot export project with preset "Android" due to configuration errors:` followed by nothing). Traced to `ResourceImporterTextureSettings::should_import_etc2_astc()` returning `false` (checked via `GLOBAL_GET("rendering/textures/vram_compression/import_etc2_astc")`, absent from `project.godot`), which the Android export plugin's `has_valid_project_configuration()` treats as a hard failure (`valid = false`) without adding any explanatory text to the error string — a message-formatting gap in Godot 4.3 itself, not something a template/script change could fix.
- **Fix:** Added `textures/vram_compression/import_etc2_astc=true` to the `[rendering]` section of `apps/mobile/project.godot` — the same setting `docs/mobile/android.md` already documents as required ("Texturas em ETC2/ASTC").
- **Files modified:** `apps/mobile/project.godot`
- **Verification:** Re-ran `./tools/ci/build_android.sh debug`; export proceeded to completion, produced and signed `dist/android/volta-debug.apk` (47 MB), exit code 0.
- **Committed in:** `2a9e539` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 3 - blocking issues preventing the plan's explicit "run the real export in this task" requirement from succeeding)
**Impact on plan:** Both fixes were required just to make `tools/ci/build_android.sh debug` produce a real APK, which is the plan's own stated bar for Task 2 ("não invente sucesso"). No scope creep beyond that; no gameplay code, no architecture change.

## Issues Encountered

- The export log also printed two non-fatal errors during the "Agregando archivos" step, unrelated to this plan's files: `apps/mobile/addons/gut/gut_loader_the_scene.tscn` references a `gut_loader_the_scene.gd` that does not exist in the vendored GUT v9.4.0 package. The export completed successfully anyway (exit 0, valid signed APK). This is third-party vendored code (`addons/gut/**`, already excluded from `validate-repo.sh` per a Plan 01-01 decision) and out of this plan's `files_modified` scope — logged in `.planning/phases/01-repository-foundation/deferred-items.md` under "Plan 01-10" rather than fixed here.
- The export also prints `ERROR: No project icon specified.` — expected and out of scope: app icon art belongs to GSD 08 per the phase README's own "NÃO entra: Arte é 08" scope boundary. Godot falls back to its default icon; this doesn't block the export or affect any acceptance criterion of this plan.

## User Setup Required

None - no external service configuration required. (Android SDK, JDK, Godot export templates, and debug keystore were already present on this machine per the plan's `<environment_facts>`.)

## Next Phase Readiness

- `dist/android/volta-debug.apk` exists locally and is ready to `adb install` on a real device for Plan 01-11's human-verify checkpoint (cold start < 1.5s, 60 FPS, safe area, version match).
- `docs/performance/device-results.md` is ready for Plan 01-11 to fill in with real numbers.
- No blockers introduced. The one remaining gap for Plan 01-11 is exactly what it's scoped for: a physical Android device (none attached to this machine, `adb devices` empty, as expected — the plan explicitly defers this).

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 10 files claimed (main.tscn, dev_overlay.gd, export_presets.template.cfg,
make_export_presets.sh, build_android.sh, device-results.md, bootstrap.gd, project.godot,
dist/android/volta-debug.apk, this SUMMARY.md) confirmed present on disk. All 3 task commits
(`6e4a744`, `2a9e539`, `caeb966`) confirmed present in git history.
