# Deferred Items — Phase 02 Core Movement

Itens fora do escopo do plano em execução no momento em que foram encontrados. Não corrigidos
de propósito (Scope Boundary do executor GSD) — registrados aqui para o plano/fase certo tratar.

## [02-03] test_build.gd::test_version_matches_project_settings falhando (pré-existente)

- **Encontrado durante:** Plano 02-03 (input-buffer-router), rodada de `./tools/ci/test-client.sh`
- **Sintoma:** `assert_eq(Build.version(), "0.1.0")` falha — `Build.version()` retorna `"0.1.2"`.
- **Causa:** `apps/mobile/project.godot:14` tem `config/version="0.1.2"` (bump feito no release
  F-Droid, commit `480eef0` / `0bc5208`), mas `test_build.gd` nunca foi atualizado para acompanhar.
- **Por que não corrigido aqui:** não tem nenhuma relação com `apps/mobile/src/input/` (escopo
  deste plano). Decidir se o teste devia ser `"0.1.2"` ou se o `project.godot` deveria voltar para
  `"0.1.0"` é uma decisão de versionamento (CLAUDE.md raiz: "Versionamento — começa em v0.1.0"),
  não uma correção de bug de input.
- **Ação recomendada:** o plano/fase que fechar o próximo release deve alinhar
  `test_build.gd` com `project.godot` (ou vice-versa) e documentar a versão real no CHANGELOG.

## [02-05] `./tools/ci/lint.sh` falhando em arquivos fora do escopo deste plano (pré-existente)

- **Encontrado durante:** Plano 02-05 (match-director-composition-root), rodada de
  `./tools/ci/lint.sh` após a Task 3.
- **Sintoma:** dezenas de `var sem tipo` e 6 `func _init()` sem `-> void` explícito em
  `apps/mobile/src/gameplay/score/*.gd`, `apps/mobile/src/progression/**`,
  `apps/mobile/src/presentation/**` (exceto os arquivos deste plano), `apps/mobile/src/arena/arena.gd`,
  `apps/mobile/src/input/input_buffer.gd` e `apps/mobile/src/runner/states/*_state.gd`.
- **Causa:** débito de tipagem estática pré-existente, confirmado idêntico em `HEAD` antes
  deste plano (`git stash` + `./tools/ci/lint.sh` reproduz a mesma lista, exit não-zero).
  Nenhum desses arquivos está em `files_modified` deste plano.
- **Por que não corrigido aqui:** Scope Boundary do executor GSD — só corrige o que a tarefa
  atual tocou; `match_director.gd`, `root.gd` e os 5 arquivos de teste deste plano passam
  limpos no lint (conferido isoladamente).
- **Ação recomendada:** uma fase/plano de qualidade (QLT) deve varrer `var` sem tipo e `_init`
  sem `-> void` no restante da árvore e fechar a Regra 1 (CLAUDE.md §3) de ponta a ponta.
