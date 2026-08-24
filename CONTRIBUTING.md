# Contribuindo com VOLTA

Este repositório é executado **por fases GSD**. Antes de escrever qualquer linha de código,
leia [`.gsd/MASTER_PLAN.md`](.gsd/MASTER_PLAN.md) e [`.gsd/STATUS.md`](.gsd/STATUS.md).

---

## 1. Fluxo de trabalho

```text
master     ← só recebe merge de release/*  (sempre publicável, sempre com tag)
develop    ← integração contínua das fases
feature/*  ← uma fase ou uma tarefa grande: feature/gsd-03-territory-engine
fix/*      ← correção: fix/territory-edge-seal
release/*  ← congelamento e bump de versão: release/v0.1.0
```

Regras (ver [`ADR-0012`](docs/decisions/ADR-0012-branching-and-release-flow.md)):

- Uma fase GSD = um branch `feature/gsd-XX-nome` = um PR para `develop`.
- Commits atômicos e semânticos dentro do branch. Nada de "wip" no histórico final.
- `master` nunca recebe commit direto.
- Nenhum `Co-Authored-By` de IA nas mensagens de commit.

## 2. Commits

```text
<tipo>(<escopo>): <resumo no imperativo, minúsculo, sem ponto final>
```

Tipos: `feat` `fix` `perf` `refactor` `test` `docs` `chore` `build` `ci`.
Escopos: `gameplay` `territory` `runner` `ai` `arena` `camera` `audio` `vfx` `ui` `input`
`progression` `save` `analytics` `net` `config` `android` `ios` `api` `gsd` `tools`.

```text
feat(territory): implement incremental flood fill seal
fix(territory): handle edge-connected capture on arena border
perf(territory): reuse scanline buffers between seals
test(gameplay): cover arc collision against enemy runners
docs(gsd): complete phase 03 handoff
```

## 3. Estilo de código

**GDScript** (detalhes em [`docs/architecture/overview.md`](docs/architecture/overview.md#convenções-de-código)):

- `class_name` em PascalCase, arquivos em `snake_case.gd`, um tipo por arquivo.
- **Tipagem estática obrigatória** em parâmetros, retornos e membros. `Variant` só com comentário justificando.
- Ordem no arquivo: `class_name` → `extends` → docstring → `signal` → `enum` → `const` → `@export` → vars → `_ready` → públicos → privados (`_prefixo`).
- Sem `get_node()` espalhado: `@onready` ou injeção.
- Sem arquivos-depósito: `Utils.gd`, `Helpers.gd`, `Manager.gd`, `Global.gd`, `Misc.gd` são **proibidos** e checados no CI.
- Arquivo > 400 linhas exige justificativa no PR.
- Simulação (`territory/`, `runner/`, `ai/`, `gameplay/`) **não pode importar** `presentation/` ou `ui/`. Checado no CI.

**PHP/Laravel:** PSR-12, Pint, PHPStan nível 6+, form requests para validação, nada de lógica em controller.

## 4. Regras invioláveis do repositório

| Regra | Formato exigido | Verificação |
|---|---|---|
| **TODO** sempre com dono | `# TODO(GSD-15/API-003): substituir leaderboard local` | `tools/ci/validate-repo.sh` |
| **Mock** sempre com fase de substituição | bloco `## MOCK` com `Replacement Phase` + `Replacement Task` | CI |
| **Placeholder de arte** rastreado | `PLACEHOLDER-ART-001` + `Replacement: GSD 08` | CI + `.gsd/BACKLOG.md` |
| **Valor mágico** | proibido: vai para `packages/shared/config` ou um `Resource` de balance | code review |
| **Debug tool em release** | proibido: tudo atrás de `Build.is_debug()` | CI + checklist de release |

## 5. Antes de abrir PR

```bash
./tools/ci/lint.sh
./tools/ci/test-client.sh
./tools/ci/validate-repo.sh
```

E marque o quality gate da fase em [`.gsd/QUALITY_GATES.md`](.gsd/QUALITY_GATES.md).

## 6. Definition of Done

Uma tarefa só está pronta quando: o código existe, funciona, foi testado, cobre edge cases,
tem documentação atualizada, não deixou TODO sem tarefa, não introduziu regressão, respeita a
arquitetura e funciona no contexto real do jogo. Nada disso é opcional.

## 7. Versionamento

O projeto começa em `v0.1.0`. `v1.0.0` fica reservado para maturidade em produção com base
de usuários real. Bump `minor` para features, `patch` para correções. Fechar versão =
bump em `project.godot` + `CHANGELOG.md` + tag anotada `vX.Y.Z`.
O CHANGELOG segue o formato **Release Notes** deste repositório — não use Keep-a-Changelog.
