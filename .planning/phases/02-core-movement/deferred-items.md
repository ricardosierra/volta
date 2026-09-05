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
