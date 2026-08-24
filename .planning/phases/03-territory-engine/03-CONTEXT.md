# Phase 3: Territory Engine - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Sair do Claim desenha um Arc e voltar captura exatamente a região cercada — correto em todos os casos topológicos, dentro do orçamento de CPU e com render de custo constante

**Requisitos cobertos:** TER-01, TER-02, TER-03, TER-04, TER-05, TER-06, TER-07

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Colisão com Arc inimigo, Break, morte, Backwash (é 04 — aqui só a mecânica de captura)
- Bots (é 05)
- Score (é 06)
- Arte final (é 08)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/03-territory-engine/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Ordem de trabalho (normativa)
- O `SealSolver` é escrito e provado **isolado** antes de encostar no jogo. Não integre (TERR-008) antes dos 30 casos de mesa estarem verdes.
- A rasterização do Arc (TERR-003) vem **antes** do solver — é a primeira defesa contra o bug de "capturou o mapa inteiro".

### Estrutura de dados
- Dois `PackedByteArray` paralelos: `_owner` e `_arc`, indexados por `y * width + x`. `255` = bloqueada.
- `_claim_count: PackedInt32Array` mantido incrementalmente em toda escrita — nunca recontado por varredura.
- Buffers do solver pré-alocados; `_visited` usa **epoch** (número de geração) em vez de `fill(0)` por Seal.

### Algoritmo
- Flood fill de 4 vizinhos **a partir do exterior**: o que não alcança a borda foi cercado.
- Região de busca = união da bbox do Arc com a porção adjacente do Claim, expandida em 1 e cortada pelo Field. O caso de Claim côncavo (B13) é tratado explicitamente.
- Barreiras = Claim próprio ∪ Arc próprio. Ordem entre Seals no mesmo tick: `runner_id` crescente.
- `SealSolver` é **função pura**: recebe grid, devolve `SealResult`, não emite sinal, não escreve.

### Render
- Textura `Image`/`ImageTexture` do tamanho do grid, atualizada só no `dirty_rect`, filtro nearest, **1 draw call**.
- Arc por `MultiMesh`/`Line2D` alimentado pela lista ordenada de células — nunca um nó por célula.
- A animação de captura é apresentação: a simulação já concluiu o Seal no mesmo tick.

### Medição
- Benchmarks B01–B15 rodam em **dispositivo Android real**, não em desktop. Baseline versionado em `tests/baselines/territory/`.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/03-territory-engine/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/03-territory-engine/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/03-territory-engine/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/03-territory-engine/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/03-territory-engine/TESTS.md` — os testes que precisam existir
- `.gsd/phases/03-territory-engine/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/03-territory-engine/`
- `docs/architecture/territory-system.md` (inteiro)
- `docs/decisions/ADR-0002-territory-representation.md`
- `docs/gameplay/rules.md` §4 e §9
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

*Phase: 03-territory-engine*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
