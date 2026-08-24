# Phase 4: Combat & Elimination - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

O Arc passa a ser perigoso — cortar elimina, tocar o próprio dá Backwash sem virar rota de fuga, e nenhuma morte parece arbitrária

**Requisitos cobertos:** CMB-01, CMB-02, CMB-03, CMB-04, CMB-05

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Bots (é 05) — os testes usam Runners controlados por script
- Score e Surge (é 06)
- VFX, SFX e háptico definitivos (é 09)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/04-combat-elimination/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Colisão
- Toda colisão é consulta ao grid — **nenhuma `Area2D`**, nenhuma física da engine.
- A checagem usa o mesmo traçado supercover do Arc, para não perder colisão quando o Runner atravessa várias células num tick.
- Eventos do tick são coletados **antes** de aplicar, para resolver simultaneidade sem ambiguidade.

### Backwash (ADR-0007)
- Auto-colisão e colisão com barreira **não matam**: apagam o Arc, iniciam um novo na posição atual no mesmo tick, zeram o Surge e aplicam penalidade de velocidade via `StatBlock`.
- O reinício imediato do Arc é o que impede o Backwash de virar botão de invulnerabilidade — existe um teste dedicado a isso.
- Em `Safe`, a borda apenas desliza.

### Morte
- Lista de causas **fechada** (R5.7): corte de Arc, morte mútua, Squeeze e perigo de arena telegrafado. Nada mais mata.
- Ao morrer, o Claim vira **neutro** — não vai para o matador.
- Ordem no tick: movimento → Arc → colisões → Seals (por `runner_id`) → mortes → respawns → eventos.

### Respawn
- Escolhe célula neutra respeitando distância mínima; se não houver ideal, usa a melhor disponível — **nunca falha**.
- Invulvulnerabilidade cai ao sair do Claim.

### Feedback
- Aviso periférico de ameaça olha a distância do inimigo até o **seu Arc**, não até o seu Runner. Máximo 2 setas.
- VFX/SFX definitivos são da fase 9; aqui basta cor e texto distinguindo morte de Backwash.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/04-combat-elimination/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/04-combat-elimination/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/04-combat-elimination/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/04-combat-elimination/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/04-combat-elimination/TESTS.md` — os testes que precisam existir
- `.gsd/phases/04-combat-elimination/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/04-combat-elimination/`
- `docs/gameplay/rules.md` §5 e §6
- `docs/decisions/ADR-0007-self-collision-rule.md`
- `docs/architecture/territory-system.md` §6

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

*Phase: 04-combat-elimination*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
