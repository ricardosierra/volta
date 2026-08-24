# Phase 10: Progression - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Motivo para voltar amanhã — perfil, XP, ranks, estatísticas, conquistas e desafios — sem que nada disso toque a simulação

**Requisitos cobertos:** PRG-01, PRG-02, PRG-03

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/10-progression/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Princípio
- Progressão dá **motivo de voltar**, nunca vantagem. Nenhuma classe de `progression/` pode ser importada por `gameplay/`, `runner/` ou `territory/` — a checagem de camadas verifica.

### XP e rank
- Toda partida dá XP, inclusive derrota. Punir tempo jogado é o caminho mais curto para o desinstalar.
- O primeiro nível sobe na primeira partida, sempre. Sem nível máximo.
- Recompensa a cada nível; cosmético garantido a cada 5; título a cada 10.

### Desafios
- Gerados por **seed diária determinística** — os mesmos o dia inteiro para o jogador.
- Nunca dois do mesmo tipo no mesmo dia. Todo desafio cumprível em ≤ 4 partidas por jogador mediano.
- Nenhum desafio pode exigir comportamento antidivertido (ficar parado, perder de propósito, farmar 20 partidas).
- Expiração calculada por **data local**, não por timer — precisa sobreviver a fuso e a relógio alterado.

### Carteira
- Toda entrada e saída passa pela carteira, com histórico de fonte e destino. Sem atalho.
- Teto de Sparks por partida evita farm degenerado em Endless. Saldo nunca negativo.

### Persistência
- O progresso é gravado no fim da partida, em mudança de settings e em `NOTIFICATION_APPLICATION_PAUSED`. Nunca por frame.
- Save alvo abaixo de 100 KB com tudo desbloqueado — conquista guarda progresso, não histórico.

### Repositórios
- `ProfileRepository` e `ChallengeRepository` já nascem com a forma final; implementação `Local*` agora, `Remote*` na fase 16 (MOCK registrado).

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/10-progression/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/10-progression/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/10-progression/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/10-progression/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/10-progression/TESTS.md` — os testes que precisam existir
- `.gsd/phases/10-progression/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/10-progression/`
- `docs/design/progression.md`
- `docs/design/economy.md`
- `docs/design/balance.md` §10
- `docs/architecture/save-system.md`

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

*Phase: 10-progression*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
