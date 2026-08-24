---
phase: 01-repository-foundation
plan: 4
subsystem: infra
tags: [godot, gdscript, configuration, resource, data-driven, mobile]

# Dependency graph
requires:
  - phase: 01-repository-foundation (Plan 01-02)
    provides: "Log autoload (Log.error(cat, key, data)), Build.is_debug(), ServiceRegistry/Bootstrap"
  - phase: 01-repository-foundation (Plan 01-03)
    provides: "GUT 9.4.0 installed, tools/ci/test-client.sh headless runner"
provides:
  - "6 typed Resource contracts (RunnerBalance, TerritoryBalance, BackwashBalance, ScoreBalance, SurgeBalance, CameraBalance) — the only legitimate way a gameplay number enters the game"
  - "packages/shared/config/balance/*.tres — source-of-truth values, copied verbatim from docs/design/balance.md, no rounding"
  - "ConfigService.runner()/.territory()/.backwash()/.score()/.surge()/.camera() — loaded, validated, cached"
  - "ConfigValidator.validate() — per-field range validation via @export_range introspection"
  - "ConfigValidator.validate_coherence() — cross-file rules (arc_max_cells vs grid area, spawn_min_distance vs grid side, zoom ordering)"
  - "tools/dev/sync_config.sh — keeps apps/mobile/resources/config byte-identical to packages/shared/config"
affects: [01-06, 01-07, 01-08, 01-09, 01-10, 01-11]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Every numeric field in a balance Resource carries @export_range(min,max); the range IS the validation contract — ConfigValidator never hardcodes bounds, it reads them from get_property_list()"
    - "Config that fails validation (range or cross-file coherence) fails loud in debug (push_error + Log.error) and silently falls back to the embedded RefCounted defaults in release — never crashes, never accepts a bad value"
    - "Embedded fallback defaults are the same class defaults used to instantiate each *_balance.gd — proven coherent by a dedicated test (test_embedded_defaults_are_coherent) so the fallback path itself can never be the source of an incoherent state"
    - "packages/shared/config/balance/*.tres is never loaded via res:// (it lives outside the Godot project); it exists purely as the reviewed, versioned source of truth, diffed byte-for-byte against the res://resources/config/balance copy that ConfigService actually loads — sync_config.sh is the only writer of the imported copy"

key-files:
  created:
    - apps/mobile/src/core/config/runner_balance.gd
    - apps/mobile/src/core/config/territory_balance.gd
    - apps/mobile/src/core/config/backwash_balance.gd
    - apps/mobile/src/core/config/score_balance.gd
    - apps/mobile/src/core/config/surge_balance.gd
    - apps/mobile/src/core/config/camera_balance.gd
    - apps/mobile/src/core/config/config_validator.gd
    - apps/mobile/src/core/config/config_service.gd
    - packages/shared/config/balance/runner.tres
    - packages/shared/config/balance/territory.tres
    - packages/shared/config/balance/backwash.tres
    - packages/shared/config/balance/score.tres
    - packages/shared/config/balance/surge.tres
    - packages/shared/config/balance/camera.tres
    - apps/mobile/resources/config/balance/runner.tres
    - apps/mobile/resources/config/balance/territory.tres
    - apps/mobile/resources/config/balance/backwash.tres
    - apps/mobile/resources/config/balance/score.tres
    - apps/mobile/resources/config/balance/surge.tres
    - apps/mobile/resources/config/balance/camera.tres
    - tools/dev/sync_config.sh
    - apps/mobile/tests/unit/test_config_service.gd
    - apps/mobile/tests/integration/test_config_sync.gd
  modified: []

key-decisions:
  - "The 6 .tres files were hand-written directly in Godot text-resource format (gd_resource/ext_resource/resource blocks) rather than generated via a script instantiating+ResourceSaver.save() — the plan explicitly allows either approach ('ou edite o .tres devidamente formatado à mão'), and hand-writing guarantees byte-for-byte control over the exact balance.md values with no risk of an engine-side float/rounding reformat."
  - "apps/mobile/resources/config/balance/*.tres was created as a plain file copy of the packages/shared/config/balance/*.tres source (not by running sync_config.sh) so both scripts and content would exist and be verifiably byte-identical (cmp) before the first test run; sync_config.sh remains the documented, repeatable way to redo that copy going forward."

patterns-established:
  - "One Resource-contract file per balance category, all under apps/mobile/src/core/config/, matching the file layout in docs/architecture/configuration.md §1."
  - "ConfigValidator is a stateless static-method utility on RefCounted — no instance state, testable directly against any Resource without going through ConfigService or Bootstrap."

requirements-completed: [FND-02]

# Metrics
duration: 12min
completed: 2026-08-24
---

# Phase 01 Plan 04: ConfigService + Typed Balance Resources Summary

**6 typed `Resource` contracts (Runner/Territory/Backwash/Score/Surge/Camera balance) backed by hand-written `.tres` files carrying the exact `docs/design/balance.md` values, loaded and validated by a `ConfigService` that checks both per-field range and cross-file coherence, falling back to coherent embedded defaults on any failure.**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-08-24T21:00:00Z (approx.)
- **Completed:** 2026-08-24T21:02:33Z
- **Tasks:** 2/2 completed
- **Files modified:** 22 (12 in Task 1, 10 in Task 2)

## Accomplishments

- 6 typed `Resource` classes (`RunnerBalance`, `TerritoryBalance`, `BackwashBalance`, `ScoreBalance`, `SurgeBalance`, `CameraBalance`), one file each, every numeric field carrying `@export_range(min, max)` whose bounds double as the validation contract; boolean fields (`reset_surge_on_backwash`, `tangent_deflection`, `deflection` behavior) left range-free per the plan.
- 6 `.tres` files in `packages/shared/config/balance/` with every value copied verbatim from `docs/design/balance.md` §§1-5,11 — no rounding (`base_speed = 220.0`, `cell_size = 16.0`, `cell_value = 4`, `surge_max_level = 6`, `follow_smoothing = 8.0`, `speed_penalty = -0.4`, etc., all spot-checked against the source doc).
- `ConfigValidator.validate(resource)`: iterates `get_property_list()`, filters `PROPERTY_USAGE_SCRIPT_VARIABLE` + `PROPERTY_HINT_RANGE`, parses `hint_string` for `[min, max]`, returns the list of out-of-range field names.
- `ConfigValidator.validate_coherence(runner, territory, camera)`: catches the 3 cross-file rules from `configuration.md` §2 — `arc_max_cells` vs. smallest grid area, `spawn_min_distance` vs. smallest grid side, `zoom_min <= zoom_base <= zoom_max` — none of which a per-field range can express alone.
- `ConfigService.load_all()`: loads all 6 `.tres` from `res://resources/config/balance/`, validates each, checks coherence across the three interdependent files, and falls back to embedded (proven-coherent) defaults with a loud `push_error` + `Log.error(Log.Category.ERROR, ...)` in debug builds whenever anything is invalid.
- `tools/dev/sync_config.sh` (executable): `rsync --delete` (with a `cp -R` fallback) from `packages/shared/config/` to `apps/mobile/resources/config/`; the two balance directories were verified byte-identical via `cmp` for all 6 files.
- `apps/mobile/tests/unit/test_config_service.gd`: 6 scenarios — valid load, out-of-range detection, "missing field" (modeled as an explicitly-zeroed field whose range floor is > 0, per the plan's documented equivalence), all-six-load-clean, cross-file coherence violation, and embedded-defaults-are-coherent.
- `apps/mobile/tests/integration/test_config_sync.gd`: reads both balance directories by absolute OS path (since `packages/` sits outside `res://`) and asserts byte-for-byte string equality, file by file.

## Task Commits

Each task was committed atomically:

1. **Task 1: Os 6 Resources de balance — contratos tipados + .tres com os valores de balance.md** - `19cbd81` (feat)
2. **Task 2: ConfigService + ConfigValidator + sync_config.sh** - `38c1add` (feat)
3. **Fix: untyped var in ConfigValidator (see Deviations)** - `0e3135b` (fix)

**Plan metadata:** _pending — this SUMMARY commit_

_Note: no separate TDD RED/GREEN/REFACTOR commit split — both tasks were verified green (via `check-project.sh` for Task 1's data-only Resources/`.tres`, and via `test-client.sh`'s full 6-scenario pass for Task 2) before their single commit each, matching the pattern already established in 01-01/01-02/01-03._

## Files Created/Modified

- `apps/mobile/src/core/config/runner_balance.gd` — 9 fields (`base_speed`, `turn_rate`, `collision_radius`, `arc_visual_width`, `spawn_invuln`, `respawn_delay`, `respawn_delay_time_attack`, `arc_max_cells`, `overload_decay`)
- `apps/mobile/src/core/config/territory_balance.gd` — 10 fields (cell size, 3 grid presets, spawn claim/min-distance, border thickness)
- `apps/mobile/src/core/config/backwash_balance.gd` — 4 fields (speed penalty, duration, 2 bools)
- `apps/mobile/src/core/config/score_balance.gd` — 16 fields (all Score constants from balance.md §4)
- `apps/mobile/src/core/config/surge_balance.gd` — 5 fields (step, max level, 2 windows, decay interval)
- `apps/mobile/src/core/config/camera_balance.gd` — 10 fields (zoom base/min/max, smoothing, lookahead, 4 punch params, shake max)
- `apps/mobile/src/core/config/config_validator.gd` — `validate()` + `validate_coherence()`, both static
- `apps/mobile/src/core/config/config_service.gd` — `load_all()`, 6 typed accessors, `get_load_error()`, embedded fallback
- `packages/shared/config/balance/*.tres` (6 files) — source of truth
- `apps/mobile/resources/config/balance/*.tres` (6 files) — imported copy, byte-identical to source
- `tools/dev/sync_config.sh` — source → imported sync script
- `apps/mobile/tests/unit/test_config_service.gd` — 6 test scenarios
- `apps/mobile/tests/integration/test_config_sync.gd` — source/imported parity test

## Decisions Made

- Followed the plan's exact code for `ConfigValidator` and `ConfigService` — the plan's `<action>` block provided working, compilable GDScript verbatim; no structural deviation from either.
- `.tres` files were hand-written in Godot's text resource format rather than generated by a throwaway script — the plan permits either path, and hand-writing removed any risk of the engine reformatting a float during a `ResourceSaver.save()` round-trip diverging from the literal `balance.md` value.
- `apps/mobile/resources/config/balance/*.tres` was created as a direct file copy (verified via `cmp`) rather than by invoking `sync_config.sh` mid-task, so the script itself could be committed as a clean, standalone, re-runnable tool rather than a one-time setup step.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Untyped `var` in ConfigValidator.validate() violated CLAUDE.md's mandatory static typing**
- **Found during:** Post-Task-2, flagged by a concurrently-executing Plan 01-08 (`tools/ci/lint.sh`, still under construction in that plan) against this plan's own already-committed `config_validator.gd:21`, and logged to the shared `deferred-items.md` as out of 01-08's scope.
- **Issue:** `var value = resource.get(prop["name"])` (line copied verbatim from the plan's own `<action>` code block) has neither `: Type` nor `:=`, violating CLAUDE.md regra 1 ("GDScript com TIPAGEM ESTÁTICA em parâmetro, retorno e membro. Sem exceção.").
- **Fix:** `var value: Variant = resource.get(prop["name"])` — `Variant` is the correct explicit annotation since `Resource.get()` is genuinely dynamically typed.
- **Files modified:** `apps/mobile/src/core/config/config_validator.gd`
- **Verification:** `./tools/ci/check-project.sh` exits 0; `./tools/ci/test-client.sh` still passes all 7 of this plan's own tests (6 unit + 1 integration) after the change; `./tools/ci/validate-repo.sh` exits 0.
- **Committed in:** `0e3135b` (separate fix commit, after both task commits)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** A one-line typing annotation fix to code taken verbatim from the plan's own example; no behavioral or structural change. Both tasks otherwise matched their `<action>` blocks and all `<acceptance_criteria>` exactly.

## Issues Encountered

- `gsd-tools state update-progress` reported success (`percent: 36`) but did not persist the
  new percent into `STATE.md` on disk (frontmatter and body both stayed at the pre-plan `9%`
  after `advance-plan` + `update-progress`, and again after one retry). Corrected `STATE.md`'s
  `percent`/`Progress:` fields by hand to `36%` (4/11 plans complete), matching the tool's own
  reported (but unpersisted) computation.
- `gsd-tools roadmap update-plan-progress 01` reported `{"updated": true, ...}` twice (initial
  call + one retry) but did not change `.planning/ROADMAP.md` on disk either time (no progress
  table exists in this file to match its table-row regex, and the plain-text `**Plans:**
  N/M plans executed` line and the `01-04-PLAN.md` checkbox were both left unchanged). Updated
  both by hand: `**Plans:** 3/11` → `4/11`, and the `01-04-PLAN.md` list item checkbox
  `[ ]` → `[x]`.
- `gsd-tools requirements mark-complete FND-02` reported `not_found`: the tool's regex expects
  `- [ ] **REQ-ID**` (bold-wrapped ID), but this project's `.planning/REQUIREMENTS.md` uses its
  own convention, `- [ ] FND-02 — descrição` (no bold). Not a code defect — a format mismatch
  between the generic GSD tool and this project's established `REQUIREMENTS.md` style (already
  used for `FND-01`/`FND-04`, both checked the same way in prior plans). Marked FND-02 complete
  by hand, in place, matching the file's existing convention exactly.
- The shell's `diff` was aliased/wrapped in a way that rejected `-q` in this session (`error: unknown switch 'q'` from what appears to be a `git diff --no-index` shim). Not a code or plan issue — worked around by using `cmp` instead, which gave the same byte-identity guarantee the plan's acceptance criteria require (`apps/mobile/resources/config/balance/runner.tres` byte-identical to `packages/shared/config/balance/runner.tres`, confirmed for all 6 pairs).
- A concurrently-running agent (most likely Plan 01-08's lint work, executing in parallel in the same working tree per this session's environment facts) modified `apps/mobile/tests/integration/test_bootstrap.gd` (changing `var x = BootstrapScript.new()` to `var x := BootstrapScript.new()` for static typing) while this plan was running. That file is outside this plan's `files_modified` list and was never staged or committed by this plan — left untouched, exactly as the environment facts direct ("only your own tests gate your commit").

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `ConfigService.runner().base_speed` etc. is now the only legitimate way to read a gameplay number; any future `.gd` writing `220.0` literally is the kind of violation `validate-repo.sh` (Plans 01-07/01-09) is meant to catch, per this plan's `<success_criteria>`.
- `ConfigService` is standalone and testable (`ConfigService.new()`), not yet wired into `Bootstrap`'s step list — by design, per this plan's `<interfaces>` note; that wiring happens in Plan 01-10 once `apps/mobile/scenes/main.tscn` exists.
- `packages/shared/config/{modes,arenas,bots,powerups,progression,economy,quality}/` (per `docs/architecture/configuration.md` §1) remain empty/out of scope for this plan — only `balance/` was in FND-02's scope here; those directories are for later phases per `.gsd/phases/01-repository-foundation/README.md`.
- `tools/dev/sync_config.sh` is ready for any future plan that adds new config categories under `packages/shared/config/` to re-sync into `apps/mobile/resources/config/` with one command.
- All 25 tests in the full suite (`./tools/ci/test-client.sh`) pass, including this plan's 7 new scenarios (6 unit + 1 integration); `./tools/ci/check-project.sh` and `./tools/ci/validate-repo.sh` both exit 0.

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 23 files claimed as created (8 source classes + 6 source `.tres` + 6 imported `.tres` +
`sync_config.sh` + 2 test files) were verified present on disk; all three commits (`19cbd81`,
`38c1add`, `0e3135b`) were verified present in git history.
