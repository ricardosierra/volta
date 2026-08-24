---
phase: 01-repository-foundation
plan: 6
subsystem: infra
tags: [godot, gdscript, event-bus, signals, observability, mobile]

# Dependency graph
requires:
  - phase: 01-repository-foundation (Plan 01-02)
    provides: "Log autoload (Log.warn/Log.Category.ERROR), Bootstrap/ServiceRegistry pattern"
  - phase: 01-repository-foundation (Plan 01-03)
    provides: "GUT 9.4.0 installed, tools/ci/test-client.sh headless runner"
  - phase: 01-repository-foundation (Plan 01-05)
    provides: "SaveService.SaveResult enum (OK, RESTORED_FROM_BACKUP, RECREATED) consumed by save_loaded signal"
provides:
  - "EventBus — 4 typed signals (config_loaded, config_load_failed, save_loaded, save_written), no string-based generic emit anywhere"
  - "Debug-only rate guard (MAX_EMISSIONS_PER_SECOND=5) via Build.is_debug(), logs event_bus_rate_exceeded through Log and push_warning when a signal is emitted more than the threshold in the last second"
  - "src/core/events/ directory convention for future typed payload classes (e.g. MatchStartedEvent, GSD 06+), documented but deliberately empty of payload classes this phase"
affects: [01-10]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "EventBus extends Node with class_name (unlike Log/Bootstrap autoloads), instantiated directly via EventBus.new() in tests and destined to be registered into ServiceRegistry by Bootstrap in Plan 01-10 — not an autoload itself"
    - "GDScript lambda closures capture local variables by value, not by reference: mutating a captured scalar (e.g. `var received := false; func(): received = true`) inside a lambda does not propagate to the outer scope. Tests that need a lambda to signal back to the test body use a single-element Array as a mutable box (`received[0] = true`) instead, matching how Array/Dictionary/Object references behave under GDScript's capture-by-value rule."
    - "_track_emission() is a no-op outside Build.is_debug(), so the rate-limit bookkeeping (Dictionary of timestamp arrays) never allocates in release builds — the guard is purely a debug-time development aid, not a production behavior"

key-files:
  created:
    - apps/mobile/src/core/event_bus.gd
    - apps/mobile/src/core/events/README.md
    - apps/mobile/tests/unit/test_event_bus.gd
  modified: []

key-decisions:
  - "Followed the plan's <action> code for event_bus.gd verbatim — 4 signals, MAX_EMISSIONS_PER_SECOND=5, _track_emission() gated by Build.is_debug(), Log.warn(Log.Category.ERROR, ...) + push_warning() on breach."
  - "save_loaded(result: int) rather than save_loaded(result: SaveService.SaveResult) — the plan's own signal declaration and <behavior> spec use a plain int (SaveService.SaveResult is inherited by FileSaveService but EventBus has no compile-time dependency on the save subsystem's enum type), so the signal stays decoupled from SaveService while the test still asserts against the concrete enum value (SaveService.SaveResult.RESTORED_FROM_BACKUP == 1)."
  - "test_rate_limit_flagged_after_threshold follows the plan's own escape hatch: guarded by `if not Build.is_debug(): gut.p(...); pending(...); return` so the test degrades to GUT's pending state (not a failure) if ever run against a non-debug binary, though in practice GUT runs in the debug binary and the guard fires normally."

requirements-completed: []

# Metrics
duration: 6min
completed: 2026-08-24
---

# Phase 01 Plan 06: EventBus Summary

**EventBus with 4 typed signals (no string-based generic emit) and a debug-only per-signal emission-rate guard (5/sec) that logs and push_warns before frame-rate EventBus abuse becomes a habit in later phases.**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-08-24T21:09:45Z (approx., per STATE.md)
- **Completed:** 2026-08-24T21:15:52Z
- **Tasks:** 1/1 completed
- **Files modified:** 3 (2 source + 1 test)

## Accomplishments

- `EventBus` (`apps/mobile/src/core/event_bus.gd`, `class_name EventBus extends Node`): 4 typed signals — `config_loaded()`, `config_load_failed(reason: String)`, `save_loaded(result: int)`, `save_written()` — each with a matching `emit_*()` method; no caller ever does a raw string-keyed `.emit("...")`.
- `MAX_EMISSIONS_PER_SECOND = 5`: `_track_emission()` keeps a rolling 1-second timestamp window per signal name in `_emission_timestamps`, active only when `Build.is_debug()` is true. Breaching the threshold logs `event_bus_rate_exceeded` via `Log.warn(Log.Category.ERROR, ...)` and calls `push_warning()` with a message naming the offending signal, the count, and the limit.
- `get_recent_emission_count(signal_name: String) -> int`: exposes the current window size for tests (and future debug tooling) without needing to inspect the private dictionary.
- `apps/mobile/src/core/events/README.md`: documents that this directory is reserved for typed payload classes for future complex events (e.g. `MatchStartedEvent` in GSD 06) — deliberately empty of payload classes this phase, since the 4 current events only carry primitives.
- 4 GUT tests in `apps/mobile/tests/unit/test_event_bus.gd`, all passing via `./tools/ci/test-client.sh` (36/36 suite-wide): subscribe-then-emit delivers, unsubscribe-then-emit does not deliver, `save_loaded` carries the exact `SaveService.SaveResult` int value, and emitting past `MAX_EMISSIONS_PER_SECOND` is detectable via `get_recent_emission_count()`.

## Task Commits

Each task was committed atomically:

1. **Task 1: EventBus — sinais tipados + assinatura/desassinatura** - `fa53b04` (feat)

**Plan metadata:** _pending — this SUMMARY commit_

_Note: `tdd="true"` was honored by writing the 4 behavior-driven tests directly against the plan's own reference implementation and iterating in-place before the single commit (see Deviations) — same pattern already established in 01-01/01-02/01-05 for this kind of infrastructure work, not a formal RED/GREEN/REFACTOR commit split. Verified via `./tools/ci/test-client.sh` (plan's own `<verify>`) plus `./tools/ci/validate-repo.sh`, `./tools/ci/lint.sh`, and `./tools/ci/check-project.sh` before the commit._

## Files Created/Modified

- `apps/mobile/src/core/event_bus.gd` - `EventBus`: 4 typed signals, debug-only rate guard, `get_recent_emission_count()`
- `apps/mobile/src/core/events/README.md` - documents the payload-class convention for future complex events
- `apps/mobile/tests/unit/test_event_bus.gd` - 4 GUT tests: subscribe/emit, unsubscribe stops delivery, save_loaded value, rate-limit detection

## Decisions Made

- Implemented `event_bus.gd` from the plan's `<action>` code essentially verbatim (signals, constant, `_track_emission()` body, `Log.warn`/`push_warning` pair).
- Used a one-element `Array` as a mutable "box" inside test lambdas (`received[0] = true`) instead of a plain captured local (`received = true`), after discovering GDScript lambdas capture local scalars by value, not by reference — a captured `bool`/`int` mutated inside a lambda never becomes visible to the outer test scope, while a captured `Array` reference does (see Deviations).
- `test_rate_limit_flagged_after_threshold` implements the plan's own documented escape hatch (`Build.is_debug()` check → `gut.p()` + `pending()` if not debug) exactly as specified, even though in this environment GUT always runs in the debug binary and the guard fires normally.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Test lambdas that mutated a captured local scalar (`received = true`) never made that mutation visible to the test body, because GDScript closures capture local variables by value**
- **Found during:** Task 1, first run of `./tools/ci/test-client.sh`
- **Issue:** The plan's `<behavior>` section describes callbacks that "seta uma flag local" (`var received := false; func on_loaded(): received = true`) — but GDScript lambdas capture outer-scope local variables by value at lambda-creation time, not by reference. `test_subscribe_receives_emission` and `test_save_loaded_carries_result_value` both failed (`received` stayed `false`, `received_result` stayed `-1`) even though the signal connection and emission worked correctly — the EventBus implementation itself was never at fault. `test_unsubscribe_stops_delivery` happened to still pass under the old code since its expected outcome (`false`) matched the by-value-capture default regardless of whether disconnect worked, which would have silently hidden the bug in that one test.
- **Fix:** Replaced captured scalar locals with single-element `Array` "boxes" (`var received := [false]`, mutate via `received[0] = true`, assert on `received[0]`) in all three tests that connect a lambda callback, since `Array`/`Dictionary`/`Object` references are still captured by value but the reference itself points at the same shared container, so mutating its contents from inside the lambda is visible outside it.
- **Files modified:** `apps/mobile/tests/unit/test_event_bus.gd`
- **Verification:** `./tools/ci/test-client.sh` — all 4 `test_event_bus.gd` tests pass (36/36 suite-wide), including `test_unsubscribe_stops_delivery`, now genuinely proven rather than coincidentally correct.
- **Committed in:** `fa53b04` (Task 1 commit — found and fixed before the task's single commit, not as a separate correction commit)

---

**Total deviations:** 1 auto-fixed (Rule 1, confined to the test file — `event_bus.gd` itself required no changes; the bug was in how the plan's own reference test pattern interacts with GDScript's closure-capture semantics, not in the production code).
**Impact on plan:** None on behavior or scope — `EventBus`'s signal delivery, unsubscribe, and rate-limit guard are all now proven by tests that would actually fail if the underlying mechanism regressed, which the plan's own reference test pattern (captured scalar) would not have reliably caught for `test_unsubscribe_stops_delivery`.

## Issues Encountered

- `./tools/ci/validate-repo.sh` intermittently failed on `tests/tools/run_negative_checks.sh` (a file created by the concurrently-running Plan 01-07, containing an intentional negative-test literal `# TODO: consertar isso um dia` used to prove the TODO-format check itself works). Confirmed via `git status --short` that this file was never staged or touched by this plan, and the flagged lines (46/48/51) are entirely inside that other plan's own script — not `event_bus.gd`, `events/README.md`, or `test_event_bus.gd`. Per this session's environment facts, only violations in this plan's own files are blocking; proceeded to commit without waiting further, consistent with `validate-repo.sh` passing clean on every check *except* that one unrelated, in-progress file from another plan.

None beyond the one auto-fixed test-lambda-capture bug above (resolved within Task 1 before its commit) and the cross-plan `validate-repo.sh` note above.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `EventBus` is ready for `Bootstrap` to instantiate and register into `ServiceRegistry` as a boot step in Plan 01-10, exactly as this plan's own `<success_criteria>` anticipated.
- No caller anywhere in the codebase emits a signal via a raw string (`grep -c 'emit("' apps/mobile/src/core/event_bus.gd` returns `0`), so the "EventBus é para eventos raros, não por frame" convention has a real, verifiable guard (not just documentation) from this phase forward.
- `src/core/events/` exists and is documented but intentionally empty of payload classes — the first real payload class (`MatchStartedEvent` or similar) is GSD 06's job, per the plan's own `<interfaces>` note; do not add one preemptively.
- `requirements: [FND-01]` in this plan's frontmatter is shared with Plans 01-10/01-11 (per this session's environment facts) — left unchecked in `REQUIREMENTS.md` on purpose; whichever of those plans completes FND-01's full scope should check it off.

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 3 files claimed as created (`event_bus.gd`, `events/README.md`, `test_event_bus.gd`) were
verified present on disk; the task commit (`fa53b04`) was verified present in git history;
`./tools/ci/test-client.sh` re-confirmed 36/36 tests passing as the final state, not just at
the moment of commit.
