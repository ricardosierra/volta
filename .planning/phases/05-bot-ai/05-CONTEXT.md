# Phase 5: Bot AI - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Adversários com intenção legível — o jogador consegue dizer "ele está me caçando" — com dificuldade que sobe por comportamento e nunca por velocidade

**Requisitos cobertos:** BOT-01, BOT-02, BOT-03, BOT-04, BOT-05

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- `Vulture`, `Nemesis`, `Baron` (é 12, junto com os modos que os pedem)
- Dificuldade adaptativa de Survival (é 12)
- Score (é 06)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/05-bot-ai/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Arquitetura da IA (ADR-0008)
- Utilidade: 8 ações candidatas pontuadas por ciclo; a maior vence. Sem FSM, sem behavior tree.
- Perfil é `BotProfileResource` (`.tres`): arquétipo = pesos, dificuldade = percepção, reação e erro.
- Histerese: a ação atual ganha bônus, e há tempo mínimo de compromisso — senão o bot oscila entre duas opções empatadas.

### Justiça (inegociável)
- Mesma velocidade base do jogador em **todos** os níveis. `enemySpeed *= 2` é proibido (R8.1).
- O bot só enxerga dentro do raio de percepção do perfil (R8.2) e nunca lê estado privado de outro Runner.
- Imperfeição é proposital: `reaction_delay_ms` e `error_rate` fazem o bot escolher a **segunda** melhor ação — erro plausível, não burrice aleatória.

### Orçamento
- No máximo **2 decisões de bot por tick**, em round-robin; ciclo de ~150 ms por bot.
- Nenhuma busca de caminho global por frame. `OpportunityMap` é atualizado por evento (`cells_changed`), nunca por varredura.
- Buffers reutilizados; zero alocação por decisão.

### Segurança comportamental
- Anti-travamento (sem mudar de célula por 1,5 s → reavaliar; 3× → direção de emergência).
- Anti-suicídio: valida rota de retorno estimada antes de aceitar direção. Rookie pula essa checagem com frequência — é por isso que ele morre.
- Anti-estagnação: todos em `Safe` por 20 s → o `MatchDirector` aumenta a pressão de expansão.

### Validação
- O overlay de intenção (ação escolhida, score, segunda colocada) é a ferramenta que transforma "o bot está burro" em diagnóstico.
- Critério objetivo de balanceamento: nenhum arquétipo entre < 8 % ou > 45 % de vitórias em 500 partidas.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/05-bot-ai/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/05-bot-ai/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/05-bot-ai/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/05-bot-ai/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/05-bot-ai/TESTS.md` — os testes que precisam existir
- `.gsd/phases/05-bot-ai/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/05-bot-ai/`
- `docs/gameplay/bots.md`
- `docs/decisions/ADR-0008-bot-ai-architecture.md`
- `docs/design/balance.md` §8

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

*Phase: 05-bot-ai*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
