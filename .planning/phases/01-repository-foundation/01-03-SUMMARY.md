---
phase: 01-repository-foundation
plan: 3
subsystem: testing
tags: [gut, godot, gdscript, headless-testing, ci]

# Dependency graph
requires:
  - phase: 01-01
    provides: "apps/mobile Godot 4.3 project, tools/ci/check-project.sh, test_build.gd (written but inert)"
provides:
  - "apps/mobile/addons/gut/ — GUT 9.4.0, pinned and committed, isolated in addons/"
  - "tools/ci/test-client.sh — GUT headless runner (unit+integration+gameplay), propagates real exit code"
  - "apps/mobile/tests/{unit,integration,gameplay}/test_example.gd — trivial passing proof tests"
  - "tools/ci/check-project.sh with the temporary GutTest filter removed"
affects: [01-04, 01-05, 01-06, 01-07, 01-08, 01-09, 01-10, 01-11]

# Tech tracking
tech-stack:
  added: ["GUT 9.4.0 (bitwes/Gut, Godot testing framework, headless CLI)"]
  patterns:
    - "GUT headless invocation: --headless --path apps/mobile -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit (subdirs required — GUT does not recurse by default; our suites live under tests/{unit,integration,gameplay}/, not directly in tests/)"
    - "validate-repo.sh excludes apps/mobile/addons/** (third-party vendored code) from naming/TODO/file-size checks via a find -prune guard"

key-files:
  created:
    - apps/mobile/addons/gut/ (GUT 9.4.0, ~220 files)
    - tools/ci/test-client.sh
    - apps/mobile/tests/unit/test_example.gd
    - apps/mobile/tests/integration/test_example.gd
    - apps/mobile/tests/gameplay/test_example.gd
  modified:
    - tools/ci/check-project.sh (temporary GutTest filter removed)
    - tools/ci/validate-repo.sh (vendor path exclusion added)
    - tools/README.md (test-client.sh marked as existing)

key-decisions:
  - "Plan pinned GUT v9.7.1, but v9.7.1's own versions.json requires Godot 4.7-4.7.999 and uses ScriptBacktrace (a Godot 4.4+ type) — it hangs on our pinned Godot 4.3.stable. Installed GUT 9.4.0 instead (godot_min 4.3 / godot_max 4.4.999 per its versions.json, non-prerelease, published 2025-06-11), which matches our engine. Documented per the plan's own instruction to record the real version used."
  - "validate-repo.sh's naming/TODO/file-size checks were extended to prune apps/mobile/addons/** — GUT is third-party vendored code (utils.gd, files >600 lines, undocumented TODOs are upstream, not ours) and was never meant to be held to our own-code conventions."

requirements-completed: [FND-05]

# Metrics
duration: 21min
completed: 2026-08-24
---

# Phase 01 Plan 03: GUT Test Framework Installation Summary

**GUT 9.4.0 (not the plan's pinned 9.7.1, which is Godot-4.7-only) installed isolated in `apps/mobile/addons/gut/`, with `tools/ci/test-client.sh` running all three suites headless and correctly propagating pass/fail exit codes.**

## Performance

- **Duration:** ~21 min
- **Started:** 2026-08-24T20:26:00Z (approx.)
- **Completed:** 2026-08-24T20:47:00Z
- **Tasks:** 2/2 completed
- **Files modified:** ~223 (220 in the GUT install/version-correction, 3 in test-client.sh + check-project.sh + tools/README.md; validate-repo.sh touched as part of Task 1)

## Accomplishments

- GUT installed isolated in `apps/mobile/addons/gut/`, committed (not a build-time download), confirmed not excluded by `.gitignore`.
- 3 trivial passing example tests created, one per suite: `apps/mobile/tests/{unit,integration,gameplay}/test_example.gd`.
- `tools/ci/test-client.sh` created: resolves `GODOT_BIN` the same way as `check-project.sh`, runs `--import` first (class cache), then GUT headless with `-gdir=res://tests -ginclude_subdirs -gexit`, and propagates the real exit code.
- Exit-code propagation proven empirically: with a deliberately planted `test_deliberately_fails` in `test_example.gd`, the suite ran 19 tests (18 passing, 1 failing) and `test-client.sh` exited 1; after removing it, the suite ran 18 tests (18 passing) and exited 0. The planted test is not present in the committed state.
- `tools/ci/check-project.sh`'s temporary "GutTest not found" filter (added in Plan 01-01, before GUT existed) removed; `check-project.sh` confirmed to still exit 0 unfiltered now that GUT is installed and `extends GutTest` resolves.
- `tools/README.md`'s `ci/test-client.sh` row updated from "GSD 01 / REPO-006" (pending) to "✅ GSD 01 / REPO-006" (done), matching the table's convention for finished tools.
- As a side effect of GUT now being installed and `check-project.sh`'s filter removed, `apps/mobile/tests/unit/test_build.gd` (written inert in Plan 01-01) and Plan 01-02's `test_log.gd`, `test_bootstrap.gd`, `test_service_registry.gd` (written concurrently by the parallel agent) all ran for the first time as part of the final `test-client.sh` verification — all passed (18/18 total across 7 scripts in the final clean run).

## Task Commits

Each task was committed atomically; one additional correction commit was needed between them:

1. **Task 1: Instalar GUT isolado em addons/** - `1d5e670` (feat) — installed GUT v9.7.1 per the plan's literal pin, plus the 3 example tests and the `validate-repo.sh` vendor-path exclusion (needed immediately, see Deviations).
2. **Correction: replace GUT v9.7.1 with v9.4.0** - `66e8c3a` (fix) — discovered while starting Task 2's verification that v9.7.1 is incompatible with Godot 4.3; see Deviations.
3. **Task 2: tools/ci/test-client.sh — GUT headless com exit code correto** - `179e32e` (feat) — test-client.sh, check-project.sh filter removal, tools/README.md update.

**Plan metadata:** _pending — this SUMMARY commit_

_Note: no TDD RED/GREEN/REFACTOR split — this plan installs tooling and infrastructure, not application code under test._

## Files Created/Modified

- `apps/mobile/addons/gut/` - GUT 9.4.0, ~220 files, pinned and committed (not build-time download)
- `apps/mobile/tests/unit/test_example.gd` - 1 trivial passing test (`test_arithmetic_sanity`)
- `apps/mobile/tests/integration/test_example.gd` - 1 trivial passing test (`test_integration_sanity`)
- `apps/mobile/tests/gameplay/test_example.gd` - 1 trivial passing test (`test_gameplay_sanity`)
- `tools/ci/test-client.sh` - new; GUT headless runner, propagates exit code
- `tools/ci/check-project.sh` - temporary GutTest-not-found filter removed (GUT now installed)
- `tools/ci/validate-repo.sh` - excludes `apps/mobile/addons/**` from naming/TODO/file-size checks (vendored third-party code)
- `tools/README.md` - `ci/test-client.sh` row marked done

## Decisions Made

- **GUT version correction (v9.7.1 → v9.4.0):** The plan's `environment_facts` asserted v9.7.1 was "compatible with Godot 4.x," but v9.7.1's own `versions.json` states `godot_min: 4.7, godot_max: 4.7.999`, and its `error_tracker.gd` references `ScriptBacktrace`, a type that does not exist in Godot 4.3 (introduced 4.4+). Running `test-client.sh` against v9.7.1 produced a chain of `SCRIPT ERROR: Parse Error: Could not resolve class "GutErrorTracker"` and hung indefinitely (never reached `-gexit`). Installed v9.4.0 instead — confirmed via its `versions.json` (`godot_min: 4.3, godot_max: 4.4.999`) and via GitHub release metadata (non-prerelease, published 2025-06-11) that it is a legitimate, stable release matching our pinned Godot 4.3.stable engine. This is a correction to an incorrect assumption in the plan, not a change of testing framework — GUT (ADR-0013's decision) is unchanged, only the specific pinned version.
- **`-ginclude_subdirs` added to `test-client.sh`:** the plan's literal script listed `-gdir=res://tests -gexit` only. Running it produced "Nothing was run" — GUT's `-gdir` does not recurse into subdirectories by default, and our 3 suites live in `tests/unit/`, `tests/integration/`, `tests/gameplay/`, not directly in `tests/`. Added `-ginclude_subdirs` (a real GUT CLI flag, confirmed in `addons/gut/cli/gut_cli.gd`) to fix this — a straightforward bug fix to the script written in this same task, not a deviation from the plan's intent.
- **`validate-repo.sh` vendor exclusion:** installing GUT (Task 1) immediately broke `validate-repo.sh` (banned filenames `utils.gd`, undocumented `TODO`s, files >600 lines — all inside vendored GUT source, none of it ours). Added a `find ... -path '*/addons/*' -prune -o ...` guard to sections 3, 4, and 8 so third-party vendored code under any `addons/` directory is exempt from our own-code conventions, while leaving the checks fully active for our own code. Verified `validate-repo.sh` still exits 0 with this change and still catches naming/TODO/size violations outside `addons/`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `validate-repo.sh` failed immediately after installing GUT (vendored code fails our own-code conventions)**
- **Found during:** Task 1, running the mandatory `./tools/ci/validate-repo.sh` before commit
- **Issue:** GUT ships `utils.gd` (a banned filename per our rule 3), several files >600 lines (`gut.gd` at 1278, `test.gd` at 2923, etc.), and undocumented `TODO`s — all legitimate upstream code we don't control and shouldn't be forced to rewrite.
- **Fix:** Added a `VENDOR_PRUNE=(-path '*/addons/*' -prune -o)` guard, applied to sections 3 (banned filenames), 4 (TODO format), and 8 (file size) of `validate-repo.sh`.
- **Files modified:** `tools/ci/validate-repo.sh`
- **Verification:** `./tools/ci/validate-repo.sh` exits 0 with GUT installed; sections 3/4/8 still correctly flag violations in non-`addons/` paths (unchanged logic, just path-pruned).
- **Committed in:** `1d5e670` (Task 1 commit)

**2. [Rule 1 - Bug] Plan's pinned GUT v9.7.1 is incompatible with Godot 4.3, hangs indefinitely**
- **Found during:** Task 2, first run of `./tools/ci/test-client.sh`
- **Issue:** v9.7.1 requires Godot 4.7+ (per its own `versions.json`) and references `ScriptBacktrace`, a Godot 4.4+-only type. Against our pinned Godot 4.3.stable, GUT's own class-loading chain fails to parse (`Could not resolve class "GutErrorTracker"`) and the process never reaches `-gexit`, hanging past a 120s timeout.
- **Fix:** Replaced the installed addon with GUT 9.4.0 (confirmed compatible: `versions.json` states `godot_min: 4.3, godot_max: 4.4.999`; confirmed via GitHub API as a real, non-prerelease, dated release).
- **Files modified:** `apps/mobile/addons/gut/` (full replacement, same location)
- **Verification:** `./tools/ci/test-client.sh` completes in under 1s of test time, exits 0, runs all example + pre-existing tests.
- **Committed in:** `66e8c3a` (correction commit between Task 1 and Task 2)

**3. [Rule 1 - Bug] `-gdir=res://tests` alone does not find tests in subdirectories**
- **Found during:** Task 2, second run of `./tools/ci/test-client.sh` (after fixing the GUT version)
- **Issue:** GUT reported "Nothing was run" — `-gdir` without `-ginclude_subdirs` only looks directly inside the given directory; our suites live one level deeper (`tests/unit/`, `tests/integration/`, `tests/gameplay/`).
- **Fix:** Added `-ginclude_subdirs` to the GUT invocation in `test-client.sh` (confirmed as a real, documented GUT CLI option in `addons/gut/cli/gut_cli.gd`).
- **Files modified:** `tools/ci/test-client.sh`
- **Verification:** Same run then found and ran all 7 test scripts (18 tests) correctly.
- **Committed in:** `179e32e` (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (1 blocking, 2 bugs)
**Impact on plan:** All three were necessary for the plan's own stated done-criteria (a working, correctly-propagating `test-client.sh`) to be achievable at all — the plan's pinned version simply does not run on our engine. No scope creep: GUT (the ADR-0013 decision) is unchanged, only its exact version and the two CLI flags needed to make it actually run our suite.

## Issues Encountered

None beyond the three auto-fixed deviations above, all resolved within task.

## User Setup Required

None - no external service configuration required. GUT was downloaded from a public GitHub release tarball; no credentials needed.

## Next Phase Readiness

- `./tools/ci/test-client.sh` is now a real, working command any subsequent plan in this phase can reference in its own `<verify><automated>` block instead of "MISSING."
- `apps/mobile/addons/gut/` is pinned at v9.4.0 (not v9.7.1) — any future plan or documentation referencing "GUT v9.7.1" should be corrected to v9.4.0; ADR-0013 itself does not pin a version number, so no ADR update is needed.
- Plan 01-02's tests (`test_log.gd`, `test_bootstrap.gd`, `test_service_registry.gd`) and Plan 01-01's `test_build.gd` all ran and passed as a side effect of this plan's final verification — confirming both prior plans' test suites are genuinely green, not just written.
- `tools/ci/check-project.sh` no longer carries any GUT-related temporary filter; it is a clean, permanent check going forward.
- **FND-05 not marked complete in REQUIREMENTS.md** — it is a multi-plan requirement ("CI com lint, validação de convenções e testes headless"), also claimed by 01-08-PLAN.md and 01-09-PLAN.md (`requirements: [FND-05]`), neither of which has executed yet. This plan delivers the "testes headless" third; lint and the fuller convention-validation story land in 01-08/01-09. Left unchecked intentionally — `requirements mark-complete FND-05` correctly reported it not-yet-satisfiable and no manual override was applied.

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 10 files claimed as created/modified were verified present on disk (including
`apps/mobile/addons/gut/plugin.cfg` confirming `version="9.4.0"`); all 3 commits
(`1d5e670`, `66e8c3a`, `179e32e`) were verified present in git history.
