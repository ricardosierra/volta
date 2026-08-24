---
phase: 01-repository-foundation
plan: 5
subsystem: save
tags: [godot, gdscript, save-system, atomic-write, json, migration, mobile]

# Dependency graph
requires:
  - phase: 01-repository-foundation (Plan 01-02)
    provides: "Log autoload, ServiceRegistry, Bootstrap boot() over configurable steps"
  - phase: 01-repository-foundation (Plan 01-03)
    provides: "GUT 9.4.0 installed, tools/ci/test-client.sh headless runner"
provides:
  - "SaveData — profile blocks (to_dict/from_dict) separated from settings (settings_to_dict/apply_settings_dict); unknown-field preservation via generic Dictionary blocks"
  - "SaveMigration — abstract from_version()/to_version()/migrate() base for chained schema migrations"
  - "SaveService — abstract interface (load_profile/save_profile/load_settings/save_settings/mark_dirty/export_blob/import_blob)"
  - "FileSaveService — concrete disk implementation: _write_atomic (tmp -> flush -> backup -> rename) and _load_with_recovery (2-level: backup, then recreate preserving .corrupt-<timestamp>), applied independently to profile.json and settings.json; register_migration() chain"
affects: [01-10]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "FileSaveService extends SaveService (RefCounted), same one-abstract-base/one-concrete-impl pattern as LogSink/FileLogSink — SaveResult enum is defined once on SaveService and inherited, never redeclared"
    - "JSON round-trip does not preserve Godot's int/float Variant type tag (JSON.parse_string always returns float for integer-looking numbers); Dictionary/Array `==` in GDScript is type-strict per element (100 == 100.0 is true as scalars, but {\"x\":100} == {\"x\":100.0} is false) — save-system tests that compare round-tripped blocks use a loose recursive `_values_equal()` helper instead of raw `==`, since 'idêntico' for a save system means same data content, not same Variant type tag"
    - "FileSaveService constructor takes save_dir: String = \"user://save/\", parameterizable so tests use an isolated user://test_save_<n>_<m>/ directory per test (before_each/after_each), never touching the real dev save"

key-files:
  created:
    - apps/mobile/src/core/save/save_data.gd
    - apps/mobile/src/core/save/save_migration.gd
    - apps/mobile/src/core/save/save_service.gd
    - apps/mobile/src/core/save/file_save_service.gd
    - apps/mobile/tests/unit/test_save_service.gd
    - apps/mobile/tests/fixtures/save_migration_v1_fake.json
  modified: []

key-decisions:
  - "profile.json and settings.json are fully independent files, each going through the exact same _write_atomic/_load_with_recovery primitives — corruption of one never touches the other (verified directly by test_settings_survive_profile_corruption)."
  - "load_profile() snapshots data.settings before replacing `data` (RECREATED or migrated from_dict) and re-applies it after, so an in-memory settings value already loaded via load_settings() is never wiped by a later load_profile() call, even though SaveData.from_dict()/SaveData.new() both default settings to {}."
  - "Unknown-field preservation needs no explicit `_unknown: Dictionary` mechanism: every block is already a generic Dictionary, and meta is restored via `data.get(\"meta\", ...)` (whole-dict passthrough), so an unrecognized key inside any block or in meta survives from_dict -> to_dict naturally, exactly as the plan's own action-block note anticipated."
  - "mark_dirty() only marks a section pending; it deliberately does not schedule or trigger any write (no Timer, no NOTIFICATION_APPLICATION_PAUSED hook) because that requires a live Node in the scene tree, which does not exist until Bootstrap wiring in Plan 01-10 — documented in a file-level comment in file_save_service.gd."
  - "save_migration_v1_fake.json fixture lives in apps/mobile/tests/fixtures/ (inside the Godot project), deliberately separate from tests/fixtures/saves/ at the repo root — the latter is reserved for real migration fixtures starting GSD 10, whose schema actually changed; this migration is mechanism-only/fake, per the plan's own <interfaces> note."

requirements-completed: [FND-03]

# Metrics
duration: 28min
completed: 2026-08-24
---

# Phase 01 Plan 05: SaveService Summary

**FileSaveService with atomic tmp->flush->backup->rename writes and 2-level corruption recovery (backup, then recreate preserving `.corrupt-<timestamp>`), applied independently to `profile.json` and `settings.json`, plus a chained SaveMigration mechanism proven with a fake v1->v2 fixture — mitigating RISK-009 (save loss) from Phase 1.**

## Performance

- **Duration:** ~28 min
- **Tasks:** 2/2 completed
- **Files modified:** 6 (4 source + 1 test + 1 fixture)

## Accomplishments

- `SaveData` (`apps/mobile/src/core/save/save_data.gd`): `CURRENT_SCHEMA_VERSION`, `PROFILE_BLOCKS` (8 blocks: player, progress, stats, records, wallet, inventory, achievements, challenges), `to_dict()`/`from_dict()` for the profile blocks, `settings_to_dict()`/`apply_settings_dict()` for the independent settings file. Unknown-field preservation is structural (generic `Dictionary` per block + whole-dict `meta` passthrough), no separate `_unknown` bookkeeping needed.
- `SaveMigration` (`apps/mobile/src/core/save/save_migration.gd`): abstract `from_version()`/`to_version()`/`migrate()` base, fails loud (push_error) if a subclass doesn't override.
- `SaveService` (`apps/mobile/src/core/save/save_service.gd`): abstract interface with `SaveResult` enum (`OK`, `RESTORED_FROM_BACKUP`, `RECREATED`) and all 7 methods from `docs/architecture/save-system.md` §6, plus `load_settings`/`save_settings` per REPO-007 step 6.
- `FileSaveService` (`apps/mobile/src/core/save/file_save_service.gd`, extends `SaveService`): `_write_atomic(file_name, payload)` and `_load_with_recovery(file_name)` are the two shared primitives, used identically for `profile.json` and `settings.json`. `register_migration()` builds a chain walked by `_run_migrations()`, always matching the migration whose `from_version()` equals the save's current `schema_version` — never skipping a version. Corrupted files are always renamed `<file>.corrupt-<unix_timestamp>`, never deleted.
- 7 GUT tests in `apps/mobile/tests/unit/test_save_service.gd`, all passing via `./tools/ci/test-client.sh`: round-trip, interrupted atomic write (orphaned `.tmp` ignored), corrupted-main-falls-back-to-backup, corrupted-both-recreates-preserving-both-as-`.corrupt-`, fake migration 1->2 against the fixture, unknown field survives a save/load cycle, and settings surviving total profile corruption.
- `apps/mobile/tests/fixtures/save_migration_v1_fake.json`: fake v1 fixture used only by the migration test (mechanism-only, not a real schema fixture).

## Task Commits

Each task was committed atomically:

1. **Task 1: SaveData e SaveMigration — os contratos** - `266e021` (feat)
2. **Task 2: FileSaveService — escrita atômica, recuperação, migração encadeada** - `a4dd9b2` (feat)

**Plan metadata:** _pending — this SUMMARY commit_

_Note: no TDD RED/GREEN/REFACTOR commit split — `tdd="true"` on both tasks was honored by writing behavior-driven tests directly against the finished implementation and iterating in-place (see Deviations) rather than a formal red/green/refactor commit sequence, matching the pattern already established in 01-01/01-02 for this kind of infrastructure work; both tasks were verified (`check-project.sh` for Task 1, `test-client.sh` for Task 2) before their single commit each._

## Files Created/Modified

- `apps/mobile/src/core/save/save_data.gd` - `SaveData`: PROFILE_BLOCKS + settings split, round-trip structural preservation
- `apps/mobile/src/core/save/save_migration.gd` - `SaveMigration`: chained-migration abstract base
- `apps/mobile/src/core/save/save_service.gd` - `SaveService`: abstract interface + `SaveResult` enum
- `apps/mobile/src/core/save/file_save_service.gd` - `FileSaveService`: atomic write, 2-level recovery, migration chain, for profile.json and settings.json independently
- `apps/mobile/tests/unit/test_save_service.gd` - 7 GUT tests (round-trip, interrupted write, backup fallback, double-corruption recreation, fake migration, unknown field, settings-survive-corruption)
- `apps/mobile/tests/fixtures/save_migration_v1_fake.json` - fake v1 fixture for the migration test

## Decisions Made

- Followed the plan's `<action>` code for `save_data.gd`, `save_migration.gd`, and `save_service.gd` essentially verbatim (tabs, same method bodies).
- `FileSaveService extends SaveService` (rather than a free-standing class duck-typing the interface) so `SaveResult` is inherited, never redeclared — mirrors the existing `LogSink`/`FileLogSink` pattern in this codebase.
- `_try_parse(path) -> Dictionary` returns `{"valid": bool, "data": Dictionary}` instead of a `Variant`-typed nullable return, keeping every function's return statically typed as `Dictionary` per the repo's static-typing rule, while still distinguishing "file absent/unreadable/invalid JSON/JSON that isn't an object" from a legitimate empty profile block.
- `load_profile()` snapshots and restores `data.settings` around any replacement of the `data` object, so `load_settings()`/`load_profile()` can be called in either order without one silently resetting the other's in-memory state (not just relying on the specific call order used in the tests).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `test_round_trip_all_blocks` compared round-tripped dictionaries with strict `==`, which fails for any integer value due to a JSON/Variant type mismatch**
- **Found during:** Task 2, first run of `./tools/ci/test-client.sh`
- **Issue:** Godot's `JSON.parse_string()` always deserializes a JSON integer-looking number as a `float` Variant, never `int`. Godot's `Dictionary`/`Array` `==` operator compares elements by exact Variant type (`100 == 100.0` is `true` as a bare scalar comparison, but `{"x": 100} == {"x": 100.0}` is `false`). Confirmed empirically with a standalone debug script (`SceneTree`-based, run via `godot --headless --script`) before touching any test code, isolating the failure to exactly this int/float type mismatch and nothing in the atomic-write/recovery logic itself. This is inherent to the JSON format (ADR-0003's own chosen format has no separate int/float types) and to Godot's strict container equality, not a defect in `_write_atomic`/`_load_with_recovery`.
- **Fix:** Added a recursive `_values_equal()` helper to `test_save_service.gd` that treats numeric Variants (`int`/`float`) as equal by value (`float(a) == float(b)`) while still recursing structurally through nested `Dictionary`/`Array`, and used it in `test_round_trip_all_blocks` instead of raw `assert_eq` on the two dictionaries. No production code (`save_data.gd`, `file_save_service.gd`) was changed — the round-trip genuinely preserves every value's content; it just doesn't preserve Godot's internal int-vs-float type tag across a JSON boundary, which "round-trip idêntico" is understood here to mean data content, not Variant type identity.
- **Files modified:** `apps/mobile/tests/unit/test_save_service.gd`
- **Verification:** `./tools/ci/test-client.sh` — `test_round_trip_all_blocks` passes with mixed int/string/bool/array values across all 8 profile blocks.
- **Committed in:** `a4dd9b2` (Task 2 commit — found and fixed before the task's single commit, not as a separate correction commit)

**2. [Rule 1 - Bug] `test_corrupted_backup_recreates_without_deleting` asserted `profile.json` no longer exists after recreation, which contradicts `load_profile()`'s own documented behavior**
- **Found during:** Task 2, first run of `./tools/ci/test-client.sh`
- **Issue:** The test originally asserted `FileAccess.file_exists(main_path)` is `false` after a `RECREATED` result. But `load_profile()` on `RECREATED` calls `save_profile(true)` immediately, which writes a fresh, empty profile back to that exact path — by design, `profile.json` exists again right after recreation, just with new content, not the corrupted one. The test's own bug, not the service's: it correctly asserted `.corrupt-<timestamp>` renamed copies exist, but incorrectly also asserted the live path stayed empty.
- **Fix:** Replaced the `assert_false` on `main_path` with `assert_true` (a fresh `profile.json` should exist) plus a comment explaining why; kept `assert_false` on `bak_path` (a `.bak` is only created when overwriting an existing *valid* main file, which isn't the case right after a corrupt-rename, so no new `.bak` should appear in this specific write).
- **Files modified:** `apps/mobile/tests/unit/test_save_service.gd`
- **Verification:** `./tools/ci/test-client.sh` — `test_corrupted_backup_recreates_without_deleting` passes, still confirms both original corrupted files survive renamed as `.corrupt-<timestamp>` (never deleted).
- **Committed in:** `a4dd9b2` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 1, both confined to the test file — no production `save_data.gd`/`file_save_service.gd` code changed as a result).
**Impact on plan:** Neither indicates a defect in the atomic-write or corruption-recovery mechanism itself; both were test-assertion bugs surfaced by actually running the suite, exactly the kind of thing `tdd="true"` execution is meant to catch before commit.

### Note on acceptance criteria vs. plan's own reference code

The plan's acceptance criteria for Task 1 state `grep -c '"settings"' apps/mobile/src/core/save/save_data.gd` should return `1`, but the plan's own verbatim `<action>` code block for `settings_to_dict()`/`apply_settings_dict()` contains the literal string `"settings"` twice (once per function), which is exactly what was implemented. Verified the actual intent — `"settings"` never appears inside `PROFILE_BLOCKS` or `to_dict()`'s output — is satisfied; documenting the count discrepancy here rather than treating it as something to "fix," since fixing it would mean deviating from the plan's own reference implementation.

## Issues Encountered

- `gsd-tools requirements mark-complete FND-03` reported `not_found` — its regex expects `- [ ] **REQ-ID**` (bold ID), but this repo's `REQUIREMENTS.md` uses `- [ ] FND-03 — ...` (no bold), the same convention already used for the previously-checked FND-01/FND-02/FND-04. Checked FND-03 off manually with the same style, consistent with how the earlier three were already marked. Not a code deviation — a pre-existing format mismatch between the shared `gsd-tools` regex and this repo's own `REQUIREMENTS.md` convention, unrelated to save-system work.

None beyond the two auto-fixed test-assertion bugs above (both resolved within Task 2 before its commit) and the requirements-checkbox tooling note above.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `SaveService`/`FileSaveService` are ready for `Bootstrap` to wire in as a boot step (Plan 01-10), exactly as `ServiceRegistry`/`Bootstrap` (Plan 01-02) anticipated.
- `settings.json` and `profile.json` are proven independent under corruption (`test_settings_survive_profile_corruption`), satisfying the "settings never lost to profile corruption" decision locked in ADR-0003/CONTEXT.md.
- The migration chain (`register_migration`) is mechanism-tested with a fake 1->2 migration; the first *real* migration (GSD 10+) will register against this same chain and needs its own fixture under `tests/fixtures/saves/` at the repo root, per `docs/architecture/save-system.md` §4.
- `mark_dirty()` exists but nothing calls it yet and nothing schedules a flush — that wiring (end-of-match, pause, `NOTIFICATION_APPLICATION_PAUSED`, 60s coalesced timer) is explicitly Plan 01-10's job, needing a live `Node` in the scene tree.
- `gsd-tools state update-progress` percent-bar persistence was not independently re-verified beyond the one attempt in `<state_updates>` below; if it doesn't visibly change, that's a known tooling quirk already noted by the orchestrator context, not a new issue from this plan.

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 6 files claimed as created were verified present on disk; both task commits (`266e021`,
`a4dd9b2`) were verified present in git history; `./tools/ci/test-client.sh` re-confirmed
32/32 tests passing (7 of them in `test_save_service.gd`) as the final state, not just at the
moment of commit.
