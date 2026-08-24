---
phase: 01-repository-foundation
plan: 8
subsystem: tooling
tags: [bash, ci, lint, gdscript, static-typing, markdown]

# Dependency graph
requires:
  - phase: 01-03
    provides: "GUT test framework installed (declared dependency only — no real coupling; lint.sh is pure bash and does not touch GUT)"
provides:
  - "tools/ci/lint.sh — orchestrates lint_gdscript.sh + lint_docs.sh, propagates combined exit code"
  - "tools/ci/lint_gdscript.sh — heuristic enforcing CLAUDE.md rule 1 (mandatory static typing on var/param/return), excludes addons/ and tests/tools/fixtures/"
  - "tools/ci/lint_docs.sh — enforces H1 title as first non-blank line for every docs/ and .gsd/ markdown file, usable standalone by future validate.yml (Plan 01-09)"
  - "tests/tools/fixtures/lint/{untyped_var,untyped_param,untyped_return}.gd — static fixtures proving each FALHA branch"
  - "tests/tools/run_lint_negative_checks.sh — injects each fixture, asserts lint.sh fails with the right message, cleans up, re-confirms lint.sh passes"
affects: [01-09]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "lint scripts follow the same bash conventions as validate-repo.sh: set -uo pipefail, cd to repo root, FAIL=0 accumulator, exit $FAIL"
    - "Negative-proof pattern (established in this plan, reusable for 01-07/01-09): copy a static fixture into a real scanned path, run the target script, assert non-zero exit + expected message substring, remove the injected file via trap cleanup, re-run to confirm clean state again"
    - "lint_gdscript.sh is documented in its own header as a heuristic, not a full parser — 3 grep/awk-based checks (var without : or :=, func without ->, any comma-separated param without :)"

key-files:
  created:
    - tools/ci/lint.sh
    - tools/ci/lint_gdscript.sh
    - tools/ci/lint_docs.sh
    - tests/tools/fixtures/lint/untyped_var.gd
    - tests/tools/fixtures/lint/untyped_param.gd
    - tests/tools/fixtures/lint/untyped_return.gd
    - tests/tools/run_lint_negative_checks.sh
  modified:
    - apps/mobile/tests/integration/test_bootstrap.gd (typed 4 previously-untyped `var X = BootstrapScript.new()` locals via `:=` inference; Plan 01-02 file, real violation caught by the new lint)
    - .planning/phases/01-repository-foundation/deferred-items.md (logged and later marked resolved: config_validator.gd:21, Plan 01-04's file, out of scope)

key-decisions:
  - "Fixed the pre-existing untyped-var violation in apps/mobile/tests/integration/test_bootstrap.gd (Plan 01-02, already fully committed and sequential, not concurrently running) rather than deferring it — a trivial, non-architectural, single-line := fix directly required for this plan's own stated acceptance criterion ('lint.sh exits 0 on current repo state'), and outside the explicit 'plans running in parallel right now' carve-out in this plan's environment_facts."
  - "Did NOT fix the untyped-var violation found in apps/mobile/src/core/config/config_validator.gd — that file belongs to Plan 01-04, one of the two plans explicitly named as running concurrently in this plan's environment_facts, which explicitly instructs reporting rather than editing another plan's files even once committed. Logged to deferred-items.md instead; the concurrent 01-04 execution independently applied the exact same fix (var value: Variant = ...) before this plan finished, so no conflict resulted."

requirements-completed: [FND-05]

# Metrics
duration: 8min
completed: 2026-08-24
---

# Phase 01 Plan 08: lint.sh — Static Typing + Docs H1 Lint Summary

**`tools/ci/lint.sh` combining a GDScript static-typing heuristic (var/param/return, per CLAUDE.md rule 1) and a docs H1-title check, proven against 3 real negative fixtures that each independently trip the correct FALHA branch.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-08-24T20:59:35Z
- **Completed:** 2026-08-24T21:07:12Z
- **Tasks:** 2/2 completed
- **Files modified:** 9 (7 created, 2 modified)

## Accomplishments

- `tools/ci/lint_gdscript.sh` created: 3 distinct FALHA branches (untyped `var`, missing `->` return type, untyped function parameter), excludes `addons/` (vendored GUT) and `tests/tools/fixtures/` (intentionally-broken proof fixtures) from normal scanning.
- `tools/ci/lint_docs.sh` created as a genuinely separate, standalone script (per the plan's `<interfaces>` note) — every `.md` under `docs/` and `.gsd/` must start with `# ` on its first non-blank line. Will be callable directly by `validate.yml` in Plan 01-09 without pulling in the GDScript check.
- `tools/ci/lint.sh` created: runs both, accumulates `FAIL`, propagates the combined exit code.
- `./tools/ci/lint.sh` exits 0 on the final repository state.
- 3 static fixtures (`untyped_var.gd`, `untyped_param.gd`, `untyped_return.gd`) and `tests/tools/run_lint_negative_checks.sh` prove — not presume — that each of the 3 FALHA branches actually fires: each fixture is copied into a real scanned path (`apps/mobile/src/core/__negtest_lint_*.gd`), `lint.sh` is run and asserted non-zero with the expected message substring, the injected file is removed (via `trap cleanup EXIT`, so it's removed even on script failure), and `lint.sh` is re-run to confirm the repo returns to a clean state. `git status --porcelain` after the run shows zero leftover `__negtest_lint_` files.

## Task Commits

Each task was committed atomically:

1. **Task 1: lint_gdscript.sh + lint_docs.sh + lint.sh** - `fa1db0f` (feat)
2. **Task 2: Provar lint.sh com fixtures que devem falhar** - `3109b29` (test)

**Plan metadata:** _pending — this SUMMARY commit_

_Note: no TDD RED/GREEN/REFACTOR split — this plan builds CI tooling, not application code under test; Task 2's negative-fixture harness serves the same "prove it fails correctly" purpose as TDD's RED phase, applied to a bash tool instead of application code._

## Files Created/Modified

- `tools/ci/lint_gdscript.sh` - static-typing heuristic (var/param/return), excludes addons/ and tests/tools/fixtures/
- `tools/ci/lint_docs.sh` - H1-title check for docs/ and .gsd/ markdown
- `tools/ci/lint.sh` - orchestrates both, propagates combined exit code
- `tests/tools/fixtures/lint/untyped_var.gd` - static fixture: `var broken = 5`
- `tests/tools/fixtures/lint/untyped_param.gd` - static fixture: `func broken(x) -> void:`
- `tests/tools/fixtures/lint/untyped_return.gd` - static fixture: `func broken():`
- `tests/tools/run_lint_negative_checks.sh` - injects each fixture, asserts failure + message, cleans up, re-confirms clean
- `apps/mobile/tests/integration/test_bootstrap.gd` - 4 untyped `var X = BootstrapScript.new()` → `var X := BootstrapScript.new()`, comment updated to describe `:=` inference instead of "no static type" (see Decisions)
- `.planning/phases/01-repository-foundation/deferred-items.md` - logged, then marked resolved, the out-of-scope violation found in Plan 01-04's `config_validator.gd`

## Decisions Made

See `key-decisions` in frontmatter. In short: fixed the sequential, already-fully-committed Plan 01-02 violation myself (trivial, in-scope for this plan's own acceptance criterion); deferred the concurrently-being-written Plan 01-04 violation per this plan's explicit `environment_facts` instruction, and confirmed via `deferred-items.md` that the concurrent plan resolved it independently and identically before this plan's final verification.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `apps/mobile/tests/integration/test_bootstrap.gd` had 4 untyped `var` locals**
- **Found during:** Task 1, first run of `./tools/ci/lint.sh` on the current repo state
- **Issue:** `var first = BootstrapScript.new()` (and 3 similar lines) violate CLAUDE.md rule 1 (mandatory static typing, no exception). This file was written by Plan 01-02, already fully committed before this plan started (not one of the two plans — 01-04/01-05 — this plan's `environment_facts` named as running concurrently).
- **Fix:** Changed `=` to `:=` (Godot 4 type inference works on a preloaded anonymous script's `.new()` even without `class_name`) on all 4 lines; updated the file's header comment, which had previously asserted these locals were untyped "por exceção de engine" — now accurate again, describing inferred typing instead.
- **Files modified:** `apps/mobile/tests/integration/test_bootstrap.gd`
- **Verification:** `./tools/ci/lint.sh` no longer flags this file; `./tools/ci/test-client.sh` re-run — all 3 `test_bootstrap.gd` tests (`test_boot_order_is_deterministic`, `test_non_essential_failure_does_not_abort_boot`, `test_essential_failure_stops_boot`) still pass, no `[Failed]` markers under that suite.
- **Committed in:** `fa1db0f` (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Necessary to reach this plan's own stated acceptance criterion ("lint.sh exits 0 on current repo state") for a file outside this plan's `files_modified` but safely and unambiguously fixable (sequential prior plan, single-line, non-architectural). No scope creep — did not touch application logic, only added type annotations. The one other violation found (`config_validator.gd`, Plan 01-04) was correctly left alone per this plan's explicit instructions and resolved independently by that plan's own execution — see Issues Encountered.

## Issues Encountered

- **Concurrent-execution race on `lint.sh`'s first clean run:** `apps/mobile/src/core/config/config_validator.gd` (Plan 01-04, running in parallel with this plan per `environment_facts`) briefly contained `var value = resource.get(prop["name"])` — a real, correct catch by the new `lint_gdscript.sh`. Per this plan's explicit instructions, this file was not edited: waited ~90s (bounded poll, not indefinite), re-checked, found it had since been committed by Plan 01-04 (`38c1add`) still with the violation present, logged it to `deferred-items.md` with a suggested one-line fix (`var value: Variant = resource.get(prop["name"])`). By the time Task 2's fixture harness ran, Plan 01-04 had independently applied that exact fix (uncommitted at the time, in its own working-tree edit) — `deferred-items.md` was updated to record the resolution. No conflict occurred; no file owned by another plan was modified by this executor.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `./tools/ci/lint.sh` is now a real, working command any subsequent plan can reference in its own `<verify>` block, alongside `./tools/ci/validate-repo.sh` and `./tools/ci/test-client.sh`.
- `tools/ci/lint_docs.sh` is confirmed genuinely standalone (not merged into `lint.sh`'s body) — Plan 01-09 (CI workflow) can call it directly before any `.gd` code exists, per this plan's `<interfaces>` note.
- The negative-fixture-injection pattern established in `tests/tools/run_lint_negative_checks.sh` (copy fixture → run → assert → `trap cleanup EXIT` → re-confirm clean) is directly reusable by Plan 01-07's `run_negative_checks.sh` (for `validate-repo.sh`) and Plan 01-09, if not already written by the time those plans execute.
- **FND-05** ("CI com lint, validação de convenções e testes headless") is claimed by 3 plans in this phase (01-03, 01-08, 01-09). This plan delivers the "lint" third. `requirements mark-complete FND-05` returned `not_found` — not because it's semantically incomplete (it correctly is: 01-09 hasn't run yet), but because `gsd-tools`' checkbox pattern expects `- [ ] **FND-05**` (bold ID) while this project's `REQUIREMENTS.md` uses `- [ ] FND-05 — descrição` (no bold, em-dash description). Did not hand-edit the checkbox — FND-05 genuinely isn't complete yet. Noted here per the one-retry guidance in this plan's `environment_facts` rather than spending further effort on the tool/format mismatch.

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 8 files claimed as created (7) / this summary (1) were verified present on disk; both
task commits (`fa1db0f`, `3109b29`) were verified present in git history.
