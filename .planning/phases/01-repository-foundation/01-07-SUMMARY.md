---
phase: 01-repository-foundation
plan: 7
subsystem: testing
tags: [bash, ci, static-checks, negative-testing, gdscript]

# Dependency graph
requires:
  - phase: 01-03
    provides: "validate-repo.sh vendor-path exclusion pattern (apps/mobile/addons/** pruned from naming/TODO/size checks)"
  - phase: 01-04
    provides: "packages/shared/config and apps/mobile/resources/config, byte-identical, the pair checked by the new sync rule"
provides:
  - "validate-repo.sh with all 10 structural rules complete: the 8 from TESTS.md plus function>50 lines and packages/shared/config <-> apps/mobile/resources/config sync"
  - "exclude_fixtures() helper chained into every scan (banned, bad_todo, mock_files, ph, viol, big, big_func) so tests/tools/fixtures/ never trips the normal scan"
  - "tests/tools/run_negative_checks.sh — injects all 10 real violations one at a time, asserts validate-repo.sh fails with the right message, cleans up via trap, re-confirms clean at the end"
  - "tests/tools/README.md — documents the harness"
affects: [01-09, 01-10, 01-11]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "PLACEHOLDER-XXX-NNN / Replacement: GSD NN convention is same-line (confirmed against real usage in .gsd/phases/*/TASKS.md, e.g. 'PLACEHOLDER-ART-006 / Replacement: GSD 08') — validate-repo.sh's rule 6 same-line check was correct as-is; the new expired-phase check (rule 6b) reuses that same $ph variable rather than re-scanning"
    - "Any script committed under tests/tools/ that embeds literal violation text (TODO, PLACEHOLDER, etc.) as check-harness fixtures needs a self-exclusion in validate-repo.sh's own scan, same pattern already used for validate-repo.sh itself"
    - "Negative-proof pattern (established in 01-08, reused here): inject real violation into a scanned path prefixed __negtest_, run target script, assert non-zero exit + expected message substring via grep -q, remove via trap cleanup EXIT, re-run to confirm clean"

key-files:
  created:
    - tests/tools/run_negative_checks.sh
    - tests/tools/README.md
  modified:
    - tools/ci/validate-repo.sh

key-decisions:
  - "big_func (new function-size heuristic) is pruned with VENDOR_PRUNE (excludes addons/**) even though the plan's literal <action> code omitted this — apps/mobile/addons/gut/ (GUT 9.4.0) genuinely contains 12 functions >50 lines (gut.gd, test.gd, etc.), all third-party and none of it ours. Without the prune, validate-repo.sh would fail permanently on a clean repo, contradicting this same task's own acceptance criterion ('./tools/ci/validate-repo.sh exits 0 on the current clean repo state'). Kept consistent with the existing addons/ exclusion pattern from 01-03 for rules 3/4/8."
  - "Case 5's injected content ('PLACEHOLDER com fase de destino já fechada') uses the same-line convention 'PLACEHOLDER-ART-050 / Replacement: GSD 00' instead of the plan's literal two-line example — matches the real convention already used across .gsd/phases/*/TASKS.md, and validate-repo.sh's pre-existing rule 6 logic (unchanged) only ever matched PLACEHOLDER + Replacement on the same grep -n line. Using the two-line form as literally written in the plan would have made rule 6 (unrelated to this task) falsely fail the case for the wrong reason ('sem Replacement') before ever reaching the new expired-phase check."
  - "validate-repo.sh's rule 4 (TODO format) additionally excludes tests/tools/run_negative_checks.sh from its own scan — the harness's check_case 2 embeds the literal string '# TODO: consertar isso um dia' as example content, which the *.sh-inclusive TODO scan matches against the harness's own permanent source, not just the temporary injected file. Same self-exclusion pattern already applied to tools/ci/validate-repo.sh itself."

requirements-completed: [FND-06]

# Metrics
duration: ~12min
completed: 2026-08-24
---

# Phase 01 Plan 07: validate-repo.sh — 10 Rules + Real Negative Proof Summary

**`tools/ci/validate-repo.sh` completed to all 10 structural rules (8 from TESTS.md + function-size + config-sync), each proven by a real injected-and-removed violation in `tests/tools/run_negative_checks.sh`, with the repo verified clean before and after.**

## Performance

- **Duration:** ~12 min
- **Started:** ~2026-08-24T18:05:00-03:00 (approx.)
- **Completed:** 2026-08-24T18:16:54-03:00
- **Tasks:** 2/2 completed
- **Files modified:** 3 (1 modified, 2 created)

## Accomplishments

- `validate-repo.sh` rule 6 extended: a `PLACEHOLDER-XXX-NNN / Replacement: GSD NN` referencing a phase already marked `✅ fechado` in `.gsd/QUALITY_GATES.md`'s registry now fails the build.
- `validate-repo.sh` rule 8 extended: a new function-size heuristic (distance between consecutive `func`/`static func` declarations) flags any function over 50 lines, documented in-script as a heuristic (doesn't handle nested funcs or long multi-line lambdas inside a short func).
- `validate-repo.sh` rule 10 (new): `diff -rq packages/shared/config apps/mobile/resources/config` fails the build if the two config trees diverge byte-for-byte; skips gracefully (`note`) if either directory doesn't exist yet.
- `exclude_fixtures()` helper added and chained into all 7 relevant scans (`banned`, `bad_todo`, `mock_files`, `ph`, `viol`, `big`, `big_func`) so `tests/tools/fixtures/` (static reference fixtures, e.g. Plan 01-08's `fixtures/lint/`) is defensively excluded from the normal scan.
- `tests/tools/run_negative_checks.sh` created: 10 `check_case` calls (8 canonical from `TESTS.md` + 2 extra — function>50 lines and config desync), each injecting a real violation, asserting `validate-repo.sh` fails with the exact expected message substring, removing the injection (via `trap cleanup EXIT`, safe even on interruption), then re-running `validate-repo.sh` once more at the end to prove the repo returns to a genuinely clean state.
- `tests/tools/README.md` created documenting the harness and its purpose.
- Full verification loop run clean end-to-end: `validate-repo.sh` (exit 0) → `run_negative_checks.sh` (all 10 cases pass, exit 0, both ✅ lines printed) → `validate-repo.sh` again (exit 0) → `git status --porcelain` shows zero `__negtest_` leftovers → `tests/tools/run_lint_negative_checks.sh` (01-08's harness) still exits 0, confirming no regression.

## Task Commits

Each task was committed atomically:

1. **Task 1: Completar as 2 regras faltantes em validate-repo.sh** - `106e9dc` (feat)
2. **Task 2: Provar as 10 regras com casos negativos injetados e removidos** - `96b9069` (test)

**Plan metadata:** _pending — this SUMMARY commit_

_Note: no TDD RED/GREEN/REFACTOR split — this plan builds CI tooling and its own negative-proof harness, not application code under test; Task 2's injected-violation harness serves the same "prove it fails correctly" purpose as TDD's RED phase, applied to a bash tool._

## Files Created/Modified

- `tools/ci/validate-repo.sh` — added rule 6b (expired placeholder phase), rule 8b (function>50 lines, addons-pruned), rule 10 (config sync), `exclude_fixtures()` chained into 7 scans, self-exclusion of `tests/tools/run_negative_checks.sh` from rule 4
- `tests/tools/run_negative_checks.sh` — new, 10 `check_case` calls proving each rule fails for real, executable
- `tests/tools/README.md` — new, documents the harness

## Decisions Made

See `key-decisions` in frontmatter. In short: (1) pruned `addons/**` from the new function-size check — required for the repo to stay clean given GUT's real >50-line functions; (2) used the codebase's actual same-line `PLACEHOLDER-XXX / Replacement: GSD NN` convention for case 5's injected content instead of the plan's literal two-line example, since the pre-existing rule 6 logic (correctly, per real usage elsewhere in `.gsd/`) only matches same-line; (3) added a second self-exclusion (alongside the existing one for `validate-repo.sh` itself) so the harness's own embedded example text doesn't trip rule 4 permanently.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Plan's literal `big_func` code (no `addons/` prune) would fail the repo permanently**
- **Found during:** Task 1, first run of `./tools/ci/validate-repo.sh` after adding the function-size rule
- **Issue:** The plan's `<action>` code for rule 8b used `find apps packages services -name '*.gd'` with no vendor exclusion. `apps/mobile/addons/gut/` (GUT 9.4.0, third-party, pinned in Plan 01-03) contains 12 functions over 50 lines (confirmed by running the exact unpruned heuristic). This would make the repo fail its own new rule permanently, contradicting the task's stated acceptance criterion.
- **Fix:** Added `"${VENDOR_PRUNE[@]}"` (the same `-path '*/addons/*' -prune -o` guard already used for rules 3/4/8a since Plan 01-03) to the `big_func` `find` invocation.
- **Files modified:** `tools/ci/validate-repo.sh`
- **Verification:** `./tools/ci/validate-repo.sh` exits 0 on the clean repo with the rule active; manually re-ran the unpruned heuristic against `addons/` in isolation and confirmed 12 real >50-line matches, proving the prune was necessary, not cosmetic.
- **Committed in:** `106e9dc` (Task 1 commit)

**2. [Rule 1 - Bug] Plan's literal case-5 content (two-line PLACEHOLDER/Replacement) never matched the pre-existing same-line rule 6 check**
- **Found during:** Task 2, first run of `./tests/tools/run_negative_checks.sh`
- **Issue:** The plan's `<action>` code for `check_case "5. ..."` wrote `PLACEHOLDER-ART-050` and `Replacement: GSD 00` on separate lines. `validate-repo.sh`'s pre-existing rule 6 (unchanged, written before this plan) only ever considered a placeholder "tracked" if `Replacement: GSD NN` appeared on the *same* `grep -n` line as the `PLACEHOLDER-...` marker — which matches real usage across the repo (e.g. `.gsd/phases/02-core-movement/TASKS.md`: `` `PLACEHOLDER-ART-001 / Replacement: GSD 08` ``). With the plan's literal two-line content, rule 6's existing "sem Replacement" check fired first (wrong reason), so the expected message `"fase de destino já fechada"` never appeared and the case failed the harness's own assertion.
- **Fix:** Changed case 5's injected content to the single-line form `# PLACEHOLDER-ART-050 / Replacement: GSD 00`, matching the codebase's real, established convention. Rule 6 itself (already-existing logic) was not changed.
- **Files modified:** `tests/tools/run_negative_checks.sh`
- **Verification:** Ran the case in isolation before and after — before: rule 6 fired with `"PLACEHOLDER sem 'Replacement: GSD XX'"` (wrong message); after: rule 6 passes clean and the new rule 6b fires with the exact expected `"fase de destino já fechada"` substring.
- **Committed in:** `96b9069` (Task 2 commit)

**3. [Rule 1 - Bug] Harness's own embedded TODO-format example text tripped rule 4 permanently**
- **Found during:** Task 2, first full run of `./tests/tools/run_negative_checks.sh` followed by the final `./tools/ci/validate-repo.sh` re-check
- **Issue:** `check_case`'s call for case 2 embeds the literal string `"# TODO: consertar isso um dia"` as example content — this string exists permanently in `tests/tools/run_negative_checks.sh`'s own committed source, not just in the temporary injected file. Rule 4's scan (`--include='*.sh'`) matched it directly, so `validate-repo.sh` failed *after* the harness's own cleanup step, breaking this task's stated acceptance criterion ("validate-repo.sh exits 0 immediately after the harness runs").
- **Fix:** Added `| grep -v 'tests/tools/run_negative_checks.sh'` to rule 4's `bad_todo` pipeline, alongside the pre-existing self-exclusion for `tools/ci/validate-repo.sh` itself.
- **Files modified:** `tools/ci/validate-repo.sh`
- **Verification:** `./tools/ci/validate-repo.sh` exits 0 both immediately and after a full `run_negative_checks.sh` cycle; confirmed rule 4 still correctly flags real untracked TODOs elsewhere (unchanged for all other files).
- **Committed in:** `96b9069` (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (3 bugs)
**Impact on plan:** All three were required for this plan's own literal, explicitly-stated acceptance criteria to be achievable at all (a clean repo after Task 1's new rule; case 5 asserting the correct message; the harness leaving the repo clean per Task 2's own criteria). No architectural change, no scope creep — two are scoping fixes to `find`/`grep` pipelines, one is a single-line content correction to match an already-established repo convention.

## Issues Encountered

None beyond the three auto-fixed deviations above, all resolved within task and verified before moving on.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `./tools/ci/validate-repo.sh` now genuinely enforces all 10 structural rules the phase's `TASKS.md`/`TESTS.md` require, and `./tests/tools/run_negative_checks.sh` is a real, reusable regression check any future plan can run before committing (alongside `./tools/ci/lint.sh` and `./tools/ci/test-client.sh`).
- The negative-proof pattern (inject → assert → `trap` cleanup → re-confirm clean) is now established for two separate tools (`lint.sh` in 01-08, `validate-repo.sh` here) — 01-09's CI workflow (`validate.yml`) can call both harnesses directly as a pre-merge gate.
- `apps/mobile/addons/gut/` and any future vendored dependency under `*/addons/*` are exempt from validate-repo.sh's function-size rule (rule 8b), consistent with the existing exemption from rules 3/4/8a.
- `PLACEHOLDER-XXX-NNN / Replacement: GSD NN` is now confirmed and documented (in this plan's key-decisions) as the required same-line format — any future plan writing a placeholder with the marker and its Replacement tag on separate lines will silently fail rule 6 ("sem Replacement") even though a phase reference exists; worth keeping in mind for Phase 08 (art direction) when placeholders start getting replaced for real.
- FND-06 ("Verificadores de convenção que falham de verdade (8 regras)") is satisfied by this plan alone — all 8 canonical TESTS.md violations plus the 2 additional REPO-009 rules are proven, not presumed.

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 4 files claimed as created/modified (`tests/tools/run_negative_checks.sh`,
`tests/tools/README.md`, `tools/ci/validate-repo.sh`, this summary) were verified present on
disk; both task commits (`106e9dc`, `96b9069`) were verified present in git history.
