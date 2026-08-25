---
phase: 01-repository-foundation
plan: 9
subsystem: infra
tags: [github-actions, ci, godot, bash, yaml]

# Dependency graph
requires:
  - phase: 01-04
    provides: "packages/shared/config sync check used by validate-repo.sh"
  - phase: 01-05
    provides: "no direct coupling — declared dependency only"
  - phase: 01-06
    provides: "no direct coupling — declared dependency only"
  - phase: 01-07
    provides: "tools/ci/validate-repo.sh (10-rule structural check), tools/ci/check_links.sh"
  - phase: 01-08
    provides: "tools/ci/lint.sh, tools/ci/lint_docs.sh, tools/ci/lint_gdscript.sh"
provides:
  - "tools/ci/setup_godot.sh — installs pinned Godot editor + export templates with cache, exposes godot via GITHUB_PATH/GODOT_BIN"
  - "validate.yml — validate-repo.sh + lint_docs.sh, runs on every push/PR with no Godot project required"
  - "client-ci.yml — full client pipeline (cache Godot, install, import, check-project, lint, GUT tests), guarded, no reference to not-yet-existing scripts"
  - "README.md CI status badges (inactive until repo has a git remote and CI has run)"
affects: [01-10, 01-11]

# Tech tracking
tech-stack:
  added: ["actions/cache@v4 (GitHub Actions cache for the Godot editor+templates download)"]
  patterns:
    - "setup_godot.sh separates the GitHub release TAG (dashed, e.g. 4.3-stable) from the export-templates directory VERSION (dotted, e.g. 4.3.stable) via VERSION/.stable/-stable — never interchange them"
    - "client-ci.yml keeps every Godot-dependent step behind steps.guard.outputs.ready == 'true' (project.godot existence check from GSD 00), so the workflow is a documented no-op until apps/mobile/project.godot exists — it already does as of Plan 01-01, so all steps are live now"
    - "workflows that reference scripts not yet written for a future GSD phase (tools/dev/simulate.sh, GSD 03) are commented out with an explicit 'chega em GSD NN' pointer, not silently deleted or left broken"

key-files:
  created:
    - tools/ci/setup_godot.sh
  modified:
    - .github/workflows/validate.yml
    - .github/workflows/client-ci.yml
    - README.md
    - tools/README.md

key-decisions:
  - "Added a 'Verificar projeto' step (./tools/ci/check-project.sh) to client-ci.yml, between asset import and lint — not explicitly listed in the plan's Task 2 action steps, but check-project.sh already exists (Plan 01-01) and every prior plan in this phase used it as its own local verification gate; wiring it into CI closes the gap between 'the pipeline runs the same checks everyone runs locally' (this plan's own objective) and what CI actually executes. Rule 2 (missing critical functionality) — the objective explicitly promises 'client-ci.yml roda o pipeline completo do cliente', and the completo pipeline as practiced by every other plan in this phase includes check-project.sh."
  - "No git remote exists in this repository (git remote -v empty). Did not run gh repo create or attempt to configure branch protection — documented as an explicit pending human step below, per this plan's own <interfaces> instruction not to create the remote repository without a user decision."
  - "README badges point at the ricardosierra/volta slug (matching ANDROID_PACKAGE_NAME=com.ricardosierra.volta) exactly as instructed, and are documented here as inactive/not-yet-live rather than presented as proof CI has run."

requirements-completed: [FND-05]

# Metrics
duration: 6min
completed: 2026-08-24
---

# Phase 01 Plan 09: CI Automation — setup_godot.sh + validate.yml + client-ci.yml Summary

**`tools/ci/setup_godot.sh` installs the `.godot-version`-pinned Godot editor and export templates with GitHub Actions cache; `validate.yml` now also lints docs; `client-ci.yml` caches the Godot download, verifies the project opens clean, and no longer references the not-yet-existing `tools/dev/simulate.sh`.**

## Performance

- **Duration:** ~6 min (commit-to-commit; excludes the initial multi-file context read)
- **Started:** 2026-08-24T21:20:00Z (approx.)
- **Completed:** 2026-08-24T21:23:56Z
- **Tasks:** 2/2 completed
- **Files modified:** 5 (1 created, 4 modified)

## Accomplishments

- `tools/ci/setup_godot.sh` created exactly per plan: takes the pinned version (`4.3.stable`) as `$1`, derives the GitHub release `TAG` (`4.3-stable`) via `VERSION/.stable/-stable`, downloads and caches the editor zip and export-templates `.tpz` from `github.com/godotengine/godot/releases/download/${TAG}/...`, extracts templates into the dotted `${VERSION}` directory Godot actually looks in, symlinks `godot` into `~/.local/bin`, and appends to `GITHUB_PATH`/`GITHUB_ENV` when running under Actions (both env vars degrade to `/dev/null` harmlessly outside CI). Executable, `bash -n` clean, contains every string the plan's acceptance criteria require and none of the forbidden `Godot_v${VERSION}` form.
- `.github/workflows/validate.yml` extended with a `lint de docs` step (`./tools/ci/lint_docs.sh`) after `validate-repo` — the repo-wide structural/convention gate now also lints every doc's H1 title, with no dependency on the Godot project existing.
- `.github/workflows/client-ci.yml` extended with: an `actions/cache@v4` step (keyed on `hashFiles('.godot-version')`, caching `~/.cache/godot-ci`) placed before `Instalar Godot`; a `Verificar projeto` step calling `./tools/ci/check-project.sh` right after asset import (see Decisions); and the `Amostra de gameplay (20 partidas)` step removed and replaced with a dated comment pointing at GSD 03 / TERR-014, since `tools/dev/simulate.sh` does not exist yet and referencing it would break this phase's CI for a script that isn't this phase's responsibility.
- `README.md` gained `validate` and `client-ci` status badges under the title block, pointing at the `ricardosierra/volta` slug — explicitly documented below as inactive until the repository has a remote and the workflows have run at least once.
- `tools/README.md`'s `ci/setup_godot.sh` row marked `✅ GSD 01 / REPO-011`, matching the table's existing convention for finished tools (small doc-consistency fix, not in the plan's `files_modified` but zero functional risk).
- Both workflow files confirmed valid YAML via `python3 -c "import yaml,sys; yaml.safe_load(...)"` (PyYAML was available; no fallback needed).
- `./tools/ci/validate-repo.sh` and `./tools/ci/lint.sh` both exit 0 after every task, as CLAUDE.md §3 requires.

## Task Commits

Each task was committed atomically:

1. **Task 1: setup_godot.sh — instala a engine pinada com cache** - `93a2e72` (ci)
2. **Task 2: Estender validate.yml e client-ci.yml** - `8c5430e` (ci)
3. **Doc-consistency follow-up: tools/README.md row marked done** - `4096102` (docs)

**Plan metadata:** _pending — this SUMMARY commit_

_Note: no TDD RED/GREEN/REFACTOR split — this plan builds CI configuration and a bash installer, not application code under test; verification is `bash -n` + YAML parse + the plan's own literal grep-based acceptance criteria, all run and passing before each commit._

## Files Created/Modified

- `tools/ci/setup_godot.sh` - new; downloads/caches pinned Godot editor + export templates, exposes `godot` to the runner
- `.github/workflows/validate.yml` - added `lint de docs` step
- `.github/workflows/client-ci.yml` - added Godot cache step, `Verificar projeto` step, removed the `simulate.sh` step (commented pointer left in its place)
- `README.md` - added `validate`/`client-ci` status badges
- `tools/README.md` - `ci/setup_godot.sh` row marked done

## Decisions Made

See `key-decisions` in frontmatter. In short: added a `check-project.sh` CI step beyond the plan's literal Task 2 text because it directly serves the plan's own stated objective (the pipeline runs "o pipeline completo do cliente", and check-project.sh has been every prior plan's own verification gate); left branch protection and repository creation as an explicit pending human step, per the plan's own instruction not to create the remote without a user decision; kept badges pointed at the plan-specified slug but documented them as not-yet-live.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added `Verificar projeto` (check-project.sh) step to client-ci.yml**
- **Found during:** Task 2, while extending `client-ci.yml`
- **Issue:** The plan's objective states client-ci.yml should run "o pipeline completo do cliente" (import, lint, GUT tests), but `tools/ci/check-project.sh` — the executable form of "the project opens headless without error/warning", used as the local verification gate by every one of Plans 01-01 through 01-08 — was never wired into CI itself. Without it, a script-parse regression that `--import` alone tolerates (it doesn't fail loudly the same way) could slip past CI undetected until `lint.sh`/`test-client.sh` happened to also fail.
- **Fix:** Added a `Verificar projeto (abre sem erro/warning)` step calling `./tools/ci/check-project.sh`, placed after asset import and before lint, guarded by the same `steps.guard.outputs.ready == 'true'` condition as every other Godot-dependent step.
- **Files modified:** `.github/workflows/client-ci.yml`
- **Verification:** `client-ci.yml` parses as valid YAML; the new step follows the exact same guard pattern as its neighbors; `check-project.sh` is confirmed present, executable, and already proven (Plans 01-01 through 01-08) to correctly fail on real script errors and pass otherwise.
- **Committed in:** `8c5430e` (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 missing critical functionality)
**Impact on plan:** Strengthens CI coverage in line with the plan's own stated objective; no scope creep — no new script was written, only an existing, already-proven script was wired into the pipeline it was always meant to guard.

## Issues Encountered

None. No auth gates, no architectural questions — both tasks matched the plan's literal text almost exactly (Task 1 verbatim; Task 2 with the one Rule 2 addition documented above).

## User Setup Required

**Branch protection / merge gate cannot be configured yet — no external service call was made, and none is required right now.** This repository has no `git remote` configured (`git remote -v` is empty), so the "gate de merge com os dois workflows obrigatórios" described in REPO-011 cannot be set up via `gh api` today. When the repository owner decides to publish this repository:

1. `gh repo create ricardosierra/volta --private --source=. --push` (or the public equivalent) — a human decision (publishing to a hosting service), not something this executor should decide or trigger.
2. Configure branch protection on `develop`/`master` in the new remote's settings (or via `gh api repos/ricardosierra/volta/branches/master/protection`) requiring the `validate` and `client-ci` workflows to pass before merge.
3. The `README.md` badges added in this plan will start rendering real pass/fail status only after step 1 exists and each workflow has run at least once — they are correctly documented as inactive/aspirational right now, not fabricated as already working.

No credentials, dashboards, or other manual configuration are required for anything actually delivered in this plan (both workflow files and `setup_godot.sh` are self-contained and require no secrets).

## Next Phase Readiness

- `validate.yml` and `client-ci.yml` are both self-contained: `validate.yml` needs nothing but a checkout; `client-ci.yml` needs nothing but a checkout plus (once it has a remote) GitHub's own Actions cache — no Godot license, no secrets.
- `setup_godot.sh` is Linux-runner-specific by design (matches `ubuntu-latest`) and was verified only via `bash -n` + acceptance-criteria greps in this macOS development environment, exactly as this plan's `environment_facts` directed — it was never executed locally, since doing so would attempt to download a Linux Godot binary into this machine's cache.
- FND-05 ("CI com lint, validação de convenções e testes headless") was claimed by three plans in this phase (01-03 delivered "testes headless", 01-08 delivered "lint", this plan delivers the "roda sozinho em todo push" automation that ties both together with `validate-repo.sh`'s convention checks). All three legs are now complete. `requirements mark-complete FND-05` is expected to still report a format mismatch (per 01-08's SUMMARY: `REQUIREMENTS.md` uses `- [ ] FND-05 — descrição`, not `- [ ] **FND-05**`) — checked off by hand in `.planning/REQUIREMENTS.md` as part of this plan's state-update step, per this plan's own `environment_facts` instruction.
- Plans 01-10 and 01-11 (the two remaining plans in this phase) can now assume `validate-repo.sh`, `lint.sh`, and `test-client.sh` all run automatically on every push once the repository has a remote — no further CI wiring should be needed from them for anything already built in Phase 01.

---
*Phase: 01-repository-foundation*
*Completed: 2026-08-24*

## Self-Check: PASSED

All 6 files claimed as created/modified (`tools/ci/setup_godot.sh`,
`.github/workflows/validate.yml`, `.github/workflows/client-ci.yml`, `README.md`,
`tools/README.md`, this SUMMARY) were verified present on disk; all 3 commits
(`93a2e72`, `8c5430e`, `4096102`) were verified present in git history.
