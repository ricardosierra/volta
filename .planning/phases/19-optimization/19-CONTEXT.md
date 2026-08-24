# Phase 19: Optimization - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

O jogo cabe no orçamento em Low, Mid e High — com medição antes e depois de cada mudança, sem alterar comportamento

**Requisitos cobertos:** QLT-01

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/19-optimization/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Método
- **Baseline primeiro.** Medir tudo nos 3 tiers com build de release **antes** de mudar qualquer linha. Sem a foto do "antes", nenhuma otimização pode ser provada.
- Lista de gargalos priorizada por (custo atual × facilidade de corrigir). Otimizar o que não é gargalo é desperdício.
- Toda otimização entra no PR com antes/depois medido. Sem número, é opinião.

### Território
- Aplicar as estratégias de `docs/performance/territory-benchmarks.md` **na ordem de preferência** e só se necessário: bbox mais justa → scanline → cache de alcance → amortização em 2 ticks → chunks → GDExtension.
- GDExtension em C++ é o **último** recurso e exige ADR novo, por causa do custo de build multiplataforma.

### Restrição absoluta
- Otimização **não pode mudar comportamento**: após cada rodada, 2 000 partidas precisam manter distribuição de vitórias e duração equivalentes ao baseline.
- Os 30 casos de mesa do `SealSolver` continuam verdes depois de qualquer mudança no solver.

### Escopo
- Nenhuma feature nova. Nenhuma reescrita arquitetural sem medição que a justifique.
- Se o orçamento não fechar no tier Low nem com preset Low, a resposta é elevar o mínimo suportado — decisão de produto documentada, não silêncio.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/19-optimization/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/19-optimization/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/19-optimization/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/19-optimization/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/19-optimization/TESTS.md` — os testes que precisam existir
- `.gsd/phases/19-optimization/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/19-optimization/`
- `docs/performance/performance-budget.md`
- `docs/performance/territory-benchmarks.md`

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

*Phase: 19-optimization*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
