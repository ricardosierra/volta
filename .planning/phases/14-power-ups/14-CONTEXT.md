# Phase 14: Power-ups - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Seis power-ups que movem a posição do risco sem decidir a partida — cada um com contra-jogo executável. Fecha o marco Alpha

**Requisitos cobertos:** MTC-07

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/14-power-ups/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Contrato de efeito
- `PowerUpEffect` nunca escreve direto no Runner: empilha modificadores num `StatBlock` resolvido em **ponto único**. Isso torna remoção e expiração triviais.
- Todo efeito é reversível e idempotente na expiração; um efeito por vez, novo substitui o ativo.
- Todo descritor declara ícone, cor, nome, duração, VFX, SFX e háptico — sem isso não passa no gate de game feel.

### Contra-jogo (cada um é testado)
- `Bulwark`: absorve 1 Break, casca visível, **não** protege contra Squeeze.
- `Overdrive`: +velocidade, **taxa de giro inalterada** — o Runner fica rápido e desengonçado; corte a rota, não persiga.
- `Arc Guard`: protege só as células antigas; a **ponta** continua vulnerável — ensina a habilidade de cortar perto de quem desenha.
- `Pulse`: revelação **simétrica** — quem é revelado vê o pulso acontecer.
- `Amplify`: multiplica **pontos**, nunca área; obriga a fechar, tornando o jogador previsível.
- `Drag Field`: afeta também quem soltou; é visível, estático e contornável.

### Spawn
- Orbe pisca antes de existir; nunca nasce a menos da distância mínima de um Runner; máximo simultâneo por config.

### Saúde
- Métricas objetivas: < 15 % de partidas decididas por power-up; winrate do primeiro orbe em 50 % ± 8 pp; < 20 % da partida com efeito ativo.
- Power-up fraco é **enfraquecido ou ajustado**, nunca vendido para compensar.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/14-power-ups/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/14-power-ups/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/14-power-ups/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/14-power-ups/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/14-power-ups/TESTS.md` — os testes que precisam existir
- `.gsd/phases/14-power-ups/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/14-power-ups/`
- `docs/gameplay/power-ups.md`
- `docs/design/balance.md` §9
- `docs/design/game-feel.md`

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

*Phase: 14-power-ups*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
