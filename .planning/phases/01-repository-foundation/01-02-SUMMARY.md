---
phase: 01-repository-foundation
plan: 2
subsystem: infra
tags: [godot, gdscript, logging, dependency-injection, bootstrap, mobile]

# Dependency graph
requires:
  - phase: 01-repository-foundation (Plan 01-01)
    provides: "apps/mobile Godot 4.3 project, Build.is_debug()/version()/commit()/env(), tools/ci/check-project.sh"
provides:
  - "Log autoload — Log.info/warn/error/debug(cat, key, data) by LogCategory.Category, per-category minimum level, DEBUG stripped in release via Build.is_debug()"
  - "FileLogSink — user://logs/ rotation, 5 files x 2MB, oldest discarded on rotation"
  - "ServiceRegistry — register()/resolve()/has() with readable, testable errors via get_last_error()"
  - "Bootstrap autoload — boot() over a configurable, deterministic step list; non-essential failure continues, essential failure stops boot"
  - "project.godot [autoload]: exactly Log then Bootstrap, no others"
affects: [01-04, 01-05, 01-06, 01-07, 01-08, 01-09, 01-10, 01-11]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Autoload scripts referenced by singleton name have no class_name (engine rejects 'class_name X hides an autoload singleton' for X==autoload name); documented with a first-line comment in log.gd and bootstrap.gd, per <autoload_rules> in the plan"
    - "Test code that must instantiate an autoload-only script (Bootstrap) does so via preload(path).new(), with the resulting local var left untyped (Variant) since the script has no class_name to statically type against — an accepted consequence of the autoload exception, not a typing shortcut"
    - "Log level gating happens before any dictionary/string construction (enabled() checked first in _log()), so a disabled log call never allocates or touches a sink"
    - "Godot 4.3 headless --import occasionally needs to run twice to fully resolve a batch of new global class_name scripts added in the same pass (cold/partial global_script_class_cache.cfg); this self-resolves on retry and reproduces cleanly from a truly fresh checkout — treated as transient tooling noise, not a code or script bug (see Issues Encountered)"

key-files:
  created:
    - apps/mobile/src/core/log/log_category.gd
    - apps/mobile/src/core/log/log_sink.gd
    - apps/mobile/src/core/log/file_log_sink.gd
    - apps/mobile/src/core/log/log.gd
    - apps/mobile/src/core/service_registry.gd
    - apps/mobile/src/core/bootstrap.gd
    - apps/mobile/tests/unit/test_log.gd
    - apps/mobile/tests/unit/test_service_registry.gd
    - apps/mobile/tests/integration/test_bootstrap.gd
  modified:
    - apps/mobile/project.godot

key-decisions:
  - "Log and Bootstrap have no class_name (engine constraint verified empirically on this 4.3.stable build), documented via a comment on the first line of each file, exactly as <autoload_rules> in the plan requires."
  - "project.godot [autoload] section closed at exactly two entries, Log then Bootstrap, in that order — no other autoload was added or will be, per A01-15."
  - "Bootstrap._default_steps() re-registers only 'log' as a boot step in this phase; Config/Save/EventBus steps are left for Plans 01-04/01-05/01-06 to add via configure_steps(), as the plan's own action text specifies."

patterns-established:
  - "LogSink abstract base (push_error if write() not overridden) with concrete sinks (FileLogSink) as separate one-type-per-file classes."
  - "ServiceRegistry errors are readable via get_last_error() in a stable 'reason:subject' string format (service_not_found:<name>, service_already_registered:<name>), not just via push_error, so tests can assert on them without capturing engine console output."

requirements-completed: [FND-01, FND-04]

# Metrics
duration: 20min
completed: 2026-08-24
---

# Phase 01 Plan 02: Log + ServiceRegistry + Bootstrap Summary

**Structured per-category/per-level Log with rotating file sink, plus a ServiceRegistry + Bootstrap that boots a deterministic, configurable service list — the two autoloads (`Log`, `Bootstrap`) that close `project.godot`'s `[autoload]` section for the rest of the project.**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-08-24T20:38:00Z (approx.)
- **Completed:** 2026-08-24T20:45:26Z
- **Tasks:** 2/2 completed
- **Files modified:** 10 (6 created in Task 1 + `project.godot`, 4 created in Task 2 + `project.godot` again)

## Accomplishments
- `LogCategory` (`apps/mobile/src/core/log/log_category.gd`): single source of truth for the 10 categories from `docs/architecture/logging.md` (`GAMEPLAY..ERROR`); `Log.Category` is an alias (`const Category := LogCategory.Category`), not a redeclaration.
- `LogSink` abstract interface + `FileLogSink`: rotates `user://logs/volta_N.log` at 2 MB, keeps at most 5 files, discards the oldest beyond that via an index shift (`_N` → `_N+1`, oldest removed first).
- `Log` autoload (first in `[autoload]`): `debug/info/warn/error(cat, key, data)`, `set_min_level(cat, lvl)`, `enabled(cat, lvl)` — `DEBUG` unconditionally disabled when `Build.is_debug()` is false (release strips it, matching the "removido, não só desligado" rule in `docs/architecture/logging.md`); a disabled call returns before building the data dict or touching any sink.
- `ServiceRegistry` (`apps/mobile/src/core/service_registry.gd`): `register/resolve/has`, plus `get_last_error()` returning a stable, testable string (`service_not_found:<name>`, `service_already_registered:<name>`) — `resolve()` of a missing name never returns a silent, unexplained `null`; `register()` of a duplicate name keeps the original instance.
- `Bootstrap` autoload (second and last in `[autoload]`): `configure_steps()` + `boot()` runs a configurable, ordered list of `{name, essential, factory}` steps, registering each into `ServiceRegistry`; a non-essential step whose factory returns `null` emits `boot_failed` and continues to the next step; an essential step whose factory returns `null` emits `boot_failed` and stops immediately (no further steps run, nothing further registered).
- `project.godot`'s `[autoload]` section closed at exactly two entries in the required order: `Log="*res://src/core/log/log.gd"` then `Bootstrap="*res://src/core/bootstrap.gd"`.
- 3 GUT test files written (`test_log.gd`, `test_service_registry.gd`, `test_bootstrap.gd`), one scenario per required behavior from the plan; `test_bootstrap.gd` instantiates fresh `Bootstrap` instances via `preload("res://src/core/bootstrap.gd").new()`, never `Bootstrap.new()`, as `<autoload_rules>` requires.

## Task Commits

Each task was committed atomically:

1. **Task 1: Log — logging estruturado por categoria e nível** - `89cd3a3` (feat)
2. **Task 2: ServiceRegistry + Bootstrap** - `b98c983` (feat)

**Plan metadata:** _pending — this SUMMARY commit_

_Note: neither task required RED/GREEN/REFACTOR TDD commit splitting — GUT was installed by the concurrent Plan 01-03 partway through this plan's execution (confirmed via `git log`), but running the actual test suite (`tools/ci/test-client.sh`) is that plan's responsibility, not this one's `<verify>`. Both tasks here were verified via `./tools/ci/check-project.sh` (compiles clean, no autoload/parse errors) exactly as the plan's `<verify>` specifies, and committed together with their tests, matching the pattern already established in 01-01._

## Files Created/Modified

- `apps/mobile/src/core/log/log_category.gd` - `LogCategory.Category` enum, the 10 categories
- `apps/mobile/src/core/log/log_sink.gd` - `LogSink` abstract base (`write()`, fails loud if not overridden)
- `apps/mobile/src/core/log/file_log_sink.gd` - `FileLogSink`: rotating file sink, 5 x 2MB in `user://logs/`
- `apps/mobile/src/core/log/log.gd` - `Log` autoload: category/level API, min-level gating, sink fan-out
- `apps/mobile/src/core/service_registry.gd` - `ServiceRegistry`: register/resolve/has + readable `get_last_error()`
- `apps/mobile/src/core/bootstrap.gd` - `Bootstrap` autoload: deterministic `boot()` over configurable steps
- `apps/mobile/tests/unit/test_log.gd` - disabled-level-skips-sink, per-category min level, file rotation
- `apps/mobile/tests/unit/test_service_registry.gd` - register/resolve, missing-service error, duplicate register
- `apps/mobile/tests/integration/test_bootstrap.gd` - deterministic order, non-essential vs essential failure
- `apps/mobile/project.godot` - `[autoload]` section: `Log` (Task 1), then `Bootstrap` (Task 2)

## Decisions Made

- Followed the plan's exact code for all six new source files (`log_category.gd`, `log_sink.gd`, `file_log_sink.gd`, `log.gd`, `service_registry.gd`, `bootstrap.gd`) — the plan's `<action>` blocks provided working, compilable GDScript verbatim; no structural deviation.
- `FileLogSink._ensure_open()` uses the plan's exact `FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE` ternary (compiles clean in 4.3, confirmed via `check-project.sh`).
- Test files use inline `before_each`/`after_each` (`test_log.gd`) or direct fresh instances (`test_service_registry.gd`, `test_bootstrap.gd`) to avoid cross-test state leakage on the `Log`/`Bootstrap` singletons, since GUT runs all test scripts against the same running engine/autoload instances.
- `test_bootstrap.gd` local variables holding `BootstrapScript.new()` instances are deliberately left without a static type annotation (plain `var x = ...`), since `Bootstrap` has no `class_name` by design (see `<autoload_rules>`) and typing them as `Node` would make `check-project.sh` fail on member-access warnings for `boot_order`/`registry`/`configure_steps()`, which aren't part of `Node`'s own interface.

## Deviations from Plan

None — plan executed exactly as written. No Rule 1-3 auto-fixes were needed to any source file; the only anomaly encountered was transient tooling flakiness during verification, addressed by retrying rather than modifying any script (see Issues Encountered below).

## Issues Encountered

- `./tools/ci/check-project.sh` intermittently reported `SCRIPT ERROR`/parse failures after each task's new `class_name` scripts were added (first around the newly-installed GUT addon files from the concurrent Plan 01-03, then again after adding `ServiceRegistry`/`Bootstrap`). Investigated by reproducing from a fully cold cache (`rm -rf apps/mobile/.godot`, gitignored) and confirming a single clean `--import` + `--quit` pass succeeds from scratch — meaning the flakiness was **not** a cold-cache issue nor a defect in `check-project.sh` or in this plan's code. The most consistent explanation is a race between this agent and the concurrently-running Plan 01-03 agent both invoking Godot headless imports against the same shared `apps/mobile/.godot` cache directory at the same time (both plans operate on the same working tree, per this session's environment facts). Resolved each time by re-running the import/verify step until it settled, exactly as the environment facts direct for `git commit`/`index.lock` races. No code or script was modified to work around this — `tools/ci/check-project.sh` is untouched and still belongs entirely to Plan 01-01.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `Log` and `Bootstrap` are the two, and only two, autoloads in `project.godot`, in the required order, both without `class_name` per the documented engine exception.
- `ServiceRegistry` is ready for `Config` (01-04), `Save` (01-05), and `EventBus` (01-06) to register themselves as boot steps via `Bootstrap.configure_steps()`, extending `_default_steps()`'s current single `"log"` entry.
- `Log` is ready for any future module to report success/failure of loading (`Log.info`/`Log.error` by category), including the modules that consume it starting in 01-04.
- `apps/mobile/tests/unit/test_log.gd`, `test_service_registry.gd`, and `apps/mobile/tests/integration/test_bootstrap.gd` exist and are syntax-clean per `check-project.sh`; Plan 01-03 (running concurrently, already landed GUT v9.7.1 per `git log`) should confirm these tests actually pass once `tools/ci/test-client.sh` is run against them.

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 9 files claimed as created (6 source + 3 test) were verified present on disk; both task
commits (`89cd3a3`, `b98c983`) were verified present in git history.
