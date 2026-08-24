# Phase 2: Core Movement - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

O Runner navega pela arena com controle que responde — latência abaixo de 50 ms, simulação determinística a 60 Hz e câmera que ninguém percebe

**Requisitos cobertos:** MOV-01, MOV-02, MOV-03, MOV-04, MOV-05, MOV-06, MOV-07

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Grid, Claim, Arc, Seal (é 03)
- Colisão, morte, respawn (é 04)
- Bots (é 05)
- Arte e UI de verdade (é 07/08)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/02-core-movement/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Modelo de movimento
- Ângulo livre com taxa máxima de giro (ADR-0006). Não é grid-locked, não é 8 direções.
- Velocidade e taxa de giro vêm de `RunnerBalance` — nenhum literal no código.
- O Runner **mantém** a direção ao soltar o dedo (configurável, padrão ligado).

### Tick e interpolação
- Simulação em `_physics_process` a 60 Hz fixo, ordem fixa: input → IA → movimento → grid → seals → regras → eventos.
- Um único componente `InterpolatedVisual` guarda `prev`/`curr` e interpola em `_process`. Ninguém implementa interpolação duas vezes.
- Proibido `await` e proibido depender de `delta` variável dentro da simulação.

### Input
- `InputDriver.poll(delta) -> Vector2` é a única saída; nenhum `InputEvent` chega ao Runner.
- Zona morta do swipe em **milímetros físicos**, convertida pelo DPI da tela — não em pixels.
- Buffer de input: comando que chega durante uma virada entra na fila, não substitui; descarte por idade.
- Toque que começa sobre UI não vira movimento.

### Câmera
- Follow com suavização exponencial + lookahead, atualizada sobre a posição **interpolada**.
- API pronta para zoom dinâmico (fase 3) e punches (fase 9), mas sem implementá-los agora.

### FSM
- Transições declaradas na construção da máquina; transição inválida dá assert em debug e log em release.
- Nesta fase o Runner só precisa de `Spawn`, `Safe` e `Eliminated`.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/02-core-movement/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/02-core-movement/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/02-core-movement/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/02-core-movement/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/02-core-movement/TESTS.md` — os testes que precisam existir
- `.gsd/phases/02-core-movement/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/02-core-movement/`
- `docs/gameplay/controls.md`
- `docs/architecture/state-machines.md`
- `docs/decisions/ADR-0006-movement-model.md`
- `docs/decisions/ADR-0014-simulation-tick-model.md`
- `docs/design/balance.md` §2 e §11

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

*Phase: 02-core-movement*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
