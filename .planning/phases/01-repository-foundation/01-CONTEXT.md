# Phase 1: Repository Foundation - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

O projeto Godot abre, roda num Android real, tem configuração orientada a dados, save resiliente, logging estruturado, testes headless e CI que reprova quem quebra as convenções

**Requisitos cobertos:** FND-01, FND-02, FND-03, FND-04, FND-05, FND-06

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Qualquer mecânica de jogo (Runner, grid, Arc — isso é 02 e 03)
- Design system e telas (é 07)
- Arte (é 08)
- Backend (é 15)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/01-repository-foundation/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Projeto e engine
- Godot **4.3 stable**, versão pinada em `.godot-version` na raiz e usada igualmente por dev e CI.
- Renderer `mobile`, resolução base 1080×1920, stretch `canvas_items`/`expand`, portrait travado.
- `physics_ticks_per_second = 60`, `max_physics_steps_per_frame = 4`.
- Estrutura de `src/` exatamente como `docs/architecture/overview.md` §8, com um README curto por pasta.

### Autoloads e injeção
- No máximo **dois** autoloads: `Bootstrap` e `Log`. Nada de `Global.gd`.
- `Bootstrap` monta o grafo de serviços em ordem determinística e injeta por construtor/`setup()`.
- `ServiceRegistry.resolve()` falha com erro tipado e legível quando o serviço não existe.

### Configuração
- Classes de `Resource` tipadas com faixa mínima/máxima declarada por campo.
- Valores iniciais vêm de `docs/design/balance.md` — copiar valor a valor, sem arredondar.
- Config inválida: falha alto em debug, cai no embutido e loga `ERROR` em release.
- Fonte única em `packages/shared/config/`, sincronizada para `apps/mobile/resources/config/`.

### Save
- JSON em `user://save/`, `profile.json` separado de `settings.json`.
- Escrita atômica: tmp → flush → backup → rename. Corrupção **nunca** apaga: renomeia para `.corrupt-<timestamp>`.
- Migrações encadeadas (1→2→3), nunca pulando versão; a mecânica entra agora mesmo sem migração real.

### Verificadores
- As 8 regras de `CONTRIBUTING.md` viram falha de CI, e cada uma precisa de um **teste negativo** plantado que faça o script falhar. Verificador que não falha quando deve é pior que não existir.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/01-repository-foundation/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/01-repository-foundation/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/01-repository-foundation/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/01-repository-foundation/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/01-repository-foundation/TESTS.md` — os testes que precisam existir
- `.gsd/phases/01-repository-foundation/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/01-repository-foundation/`
- `docs/architecture/overview.md`
- `docs/architecture/save-system.md`
- `docs/architecture/configuration.md`
- `docs/architecture/logging.md`
- `docs/decisions/ADR-0001-engine.md`
- `docs/decisions/ADR-0003-save-system.md`
- `docs/decisions/ADR-0013-testing-stack.md`

### Regras que valem em toda fase
- `CLAUDE.md` — as 10 regras de código verificadas por máquina
- `docs/architecture/overview.md` — camadas, convenções, o que não fazer
- `docs/design/balance.md` — **o único lugar com números de gameplay**
- `.gsd/QUALITY_GATES.md` — o que precisa ser verdade para a fase fechar

</canonical_refs>

<code_context>
## Existing Code Insights

### Padrões estabelecidos
- Simulação (`territory/`, `runner/`, `ai/`, `gameplay/`) **não importa** `presentation/` nem `ui/` — verificado pelo CI.
- Toda dependência externa entra por interface (`*Repository`, `*Service`), com implementação `Local*` antes de `Remote*`.
- Nenhum número de gameplay no código: tudo em `.tres` sob `packages/shared/config/`.
- Nenhum arquivo-depósito (`utils.gd`, `manager.gd`, `global.gd`…) — o CI reprova pelo nome.

### Verificação antes de fechar qualquer tarefa
```bash
./tools/ci/validate-repo.sh
./tools/ci/lint.sh
./tools/ci/test-client.sh
```

</code_context>

<deferred>
## Deferred Ideas

Tudo que estiver fora do escopo declarado acima vai para `.gsd/BACKLOG.md` com uma linha —
nunca para o código desta fase. O backlog já contém 18 itens deliberadamente adiados,
7 placeholders e 5 mocks, todos com fase de destino.

</deferred>

---

*Phase: 01-repository-foundation*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
