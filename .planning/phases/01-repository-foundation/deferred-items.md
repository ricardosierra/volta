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
