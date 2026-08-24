# Phase 13: Maps & Arena Variations - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Quatro arenas novas que mudam a estratégia sem mudar as regras, com o solver correto em topologias adversas

**Requisitos cobertos:** MTC-06

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/13-maps-arenas/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Arena é dado
- `ArenaDefinition` com máscara de células bloqueadas, spawns, zonas de perigo e metadados. Nenhuma linha de código por arena.
- Validação obrigatória: arena com região jogável isolada é **rejeitada**.
- Arena **herda a paleta do tema ativo** — nenhuma traz cor própria, senão a leitura entre partidas quebra.

### Topologia
- Células bloqueadas nunca são capturadas nem entram no percentual, e funcionam como barreira de Seal igual à borda.
- `Halo` (buraco central grande) é a topologia mais adversa do jogo: precisa de casos de mesa novos **e** de benchmark próprio.
- Cada arena nova acrescenta casos de mesa ao `test_seal_solver.gd` antes de ser considerada pronta.

### `Rift`
- A fenda é a **única** exceção da lista fechada de causas de morte. Por isso exige telegrafia forte: borda pulsante, som de alerta ao se aproximar, e travessias seguras nas extremidades.
- Os bots também precisam evitá-la — o anti-suicídio passa a considerar zona de perigo.

### Bots e obstáculos
- Desvio **local**, sem pathfinding global. Anti-travamento reforçado para corredores estreitos.

### Balanceamento
- Caçar ativamente estratégia degenerada (canto inexpugnável) no stress test de 500 partidas por arena; corrigir por máscara e spawns.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/13-maps-arenas/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/13-maps-arenas/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/13-maps-arenas/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/13-maps-arenas/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/13-maps-arenas/TESTS.md` — os testes que precisam existir
- `.gsd/phases/13-maps-arenas/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/13-maps-arenas/`
- `docs/art/themes.md` §Arenas
- `docs/architecture/territory-system.md` §7
- `docs/gameplay/rules.md` §9

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

*Phase: 13-maps-arenas*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
