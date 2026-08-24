# tests/tools/

Prova, com casos negativos reais (injetados e removidos), que `tools/ci/validate-repo.sh`
detecta de verdade as 10 regras que promete. Rode com:

```bash
./tests/tools/run_negative_checks.sh
```

Um verificador que não falha quando deve é pior que não existir — ver
`.gsd/phases/01-repository-foundation/TESTS.md`.

`fixtures/` fica reservado para fixtures estáticas (ex.: `fixtures/lint/` do Plano 01-08); é
excluído do escaneamento normal de `validate-repo.sh` via `exclude_fixtures()`.
