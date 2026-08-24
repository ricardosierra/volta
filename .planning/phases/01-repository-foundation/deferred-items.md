# Deferred items — Phase 01 (Repository Foundation)

Items discovered during plan execution that are out of scope for the current task/plan
(pre-existing, in files not touched by the executing plan). Logged per the executor's scope
boundary rule — not fixed here.

## Plan 01-01 — `./tools/ci/validate-repo.sh` section 9 (links de documentação)

**Found during:** Task 1 verification (`./tools/ci/validate-repo.sh` run before commit).

**Issue:** `tools/ci/check_links.sh` scans every `*.md` in the repo, including
`.planning/phases/*/*.md`. Two future plan files in this same phase embed literal example
Markdown (heredoc content meant for files that don't exist yet, or whose relative path only
resolves correctly from the *target* file's future location) that the checker misreads as
broken links from the plan file's own location:

- `.planning/phases/01-repository-foundation/01-07-PLAN.md`, line 271 — heredoc content for a
  planted negative-test file (`docs/__negtest_broken_link.md`), whose whole point is a
  literal broken markdown link (target filename `este-arquivo-nao-existe.md`) that Plan 01-07
  uses to prove `validate-repo.sh` catches broken links. Not a real broken link in real docs.
- `.planning/phases/01-repository-foundation/01-10-PLAN.md`, line 301 — heredoc content for
  the future `docs/performance/device-results.md`, containing a relative markdown link whose
  target is `../mobile/device-matrix.md` — a path valid from `docs/performance/` (where the
  real file will live) but not from `.planning/phases/01-repository-foundation/` (where the
  plan file lives today). The real target, `docs/mobile/device-matrix.md`, already exists.

**Why deferred, not fixed:** both occurrences are in files outside Plan 01-01's
`files_modified` scope (they belong to Plans 01-07 and 01-10, not yet executed). Editing
either plan's example content risks breaking that plan's own acceptance criteria; editing
`check_links.sh` to exclude `.planning/` is a change to a shared, already-validated CI script
and is arguably in scope for REPO-009 (verifiers), not REPO-001/002 (this plan).

**Verified:** with both offending lines temporarily neutralized (then restored byte-identical
— confirmed via `diff`), `./tools/ci/validate-repo.sh` section 9 passes
(`OK: nenhum link relativo quebrado`), confirming sections 1-8 (the checks relevant to Plan
01-01's own artifacts) are clean and the failure is isolated to this false positive.

**Suggested resolution:** when Plan 01-09 (REPO-009 — verificadores) is executed, either
scope `check_links.sh` to `docs/`, `.gsd/`, and the repo root (matching its own header
comment, which already says its intended scope is docs/, .gsd/ and the root — `.planning/`
was never meant to be in scope), or teach it to skip fenced code blocks / heredocs inside
`.planning/phases/*/*.md`.

**Replacement Phase:** GSD 01
**Replacement Task:** 01-09 (REPO-009 — verificadores de arquitetura e repositório)

**Resolvido (orquestrador, após 01-01):** `tools/ci/check_links.sh` agora ignora blocos de código cercados; os dois "links" eram exemplos dentro de heredocs/templates em `01-07-PLAN.md` e `01-10-PLAN.md`. `validate-repo.sh` volta a exit 0.

## Plan 01-04 — `apps/mobile/src/core/config/config_validator.gd:21` (var sem tipagem estática)

**Found during:** Plan 01-08, Task 1, `./tools/ci/lint.sh` verification run.

**Issue:** `lint_gdscript.sh`'s new heuristic (created in this plan) correctly flags
`var value = resource.get(prop["name"])` (line 21) — a `var` with neither `: Tipo` nem `:=`,
violating CLAUDE.md regra 1 (tipagem estática obrigatória, sem exceção). At the moment this
was found, the file was still untracked (`??`, Plan 01-04 mid-execution); after waiting
~90s and re-checking, Plan 01-04 had committed it (`38c1add feat(config): implement
ConfigService, ConfigValidator, sync_config.sh`), so it is now a real, persistent violation
in committed code.

**Why deferred, not fixed:** `apps/mobile/src/core/config/config_validator.gd` is entirely
outside Plan 01-08's `files_modified` scope — it belongs to Plan 01-04, which was executing
concurrently with this plan in the same working tree (per this plan's own
`<environment_facts>`, which explicitly instructs: "if it persists on committed code, report
it in SUMMARY.md rather than editing another plan's files"). Not fixed here.

**Verified:** with only this one file excluded, a manual tracked-files-only scan using the
same heuristic (`git ls-files ... | xargs grep -nE '\bvar[[:space:]]+...' | grep -vE ':='`)
shows zero other untyped-var/return/param violations anywhere else in the tracked codebase —
confirming `lint_gdscript.sh`'s logic is sound and this is the only real violation, not a
false positive.

**Suggested resolution:** change line 21 to `var value: Variant = resource.get(prop["name"])`
(the value's type is genuinely dynamic — `resource.get()` returns `Variant` — so an explicit
`Variant` annotation, not `:=`, is the correct fix, since `:=` on a `Variant`-returning call
still infers `Variant` but the explicit form is clearer intent). Any future plan touching
`config_validator.gd` (or a dedicated lint-cleanup task) should apply this one-line fix and
confirm `./tools/ci/lint.sh` exits 0 again.

**Replacement Phase:** GSD 01
**Replacement Task:** next plan that touches `apps/mobile/src/core/config/config_validator.gd`, or a dedicated follow-up lint-cleanup task
