# Phase 12: Additional Game Modes - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Cinco modos sobre a mesma simulação, definidos por dado — Time Attack, Survival, Domination e Endless somam ao Classic

**Requisitos cobertos:** MTC-05, BOT-02

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/12-game-modes/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Modo é dado
- Todo modo é um `MatchRulesResource`. Critério de aceite literal: `grep -r "if mode ==" src/` retorna vazio.
- Condição nova de modo vira **campo** do recurso, nunca ramo no código.
- Nenhum modo pode introduzir causa de morte nova (R5.7 continua fechada).

### Regras por modo
- **Time Attack:** Seal adiciona tempo (`2 s + 0,4 s por 1 %`, teto 8 s). Relógio nunca negativo.
- **Survival:** sem respawn; dificuldade sobe por **composição de arquétipos por onda**, com velocidade base constante. O jogador precisa perceber *o que* mudou.
- **Domination:** único modo com progresso de todos visível na HUD; sem power-ups; teto de segurança de tempo.
- **Endless:** *Reset Pulse* a cada 120 s com 5 s de aviso, devolvendo ao neutro as células mais antigas de quem passar de 45 % — **nunca** zera o Claim de alguém (não pode causar Squeeze acidental).

### Arquétipos novos
- `Vulture` reage a território recém-liberado por morte; `Nemesis` guarda o id de quem o matou e prioriza esse alvo; `Baron` mira liderança com arcos longos.

### Validação
- 500 partidas por modo (2 500 no total), verificando duração dentro da janela, ausência de partida infinita e distribuição de vitórias saudável.
- Endless precisa de um teste de 30 minutos sem queda de FPS nem crescimento de memória.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/12-game-modes/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/12-game-modes/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/12-game-modes/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/12-game-modes/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/12-game-modes/TESTS.md` — os testes que precisam existir
- `.gsd/phases/12-game-modes/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/12-game-modes/`
- `docs/gameplay/game-modes.md`
- `docs/design/balance.md` §7
- `docs/gameplay/bots.md`

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

*Phase: 12-game-modes*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
