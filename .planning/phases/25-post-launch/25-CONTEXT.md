# Phase 25: Post Launch - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Transformar o jogo publicado em produto vivo — balanceamento por dados reais, monetização ética, temporadas e conteúdo, sem ferir os pilares

**Requisitos cobertos:** QLT-06

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/25-post-launch/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Ordem de decisão (North Star)
```
Fun > Responsiveness > Clarity > Game Feel > Performance > Visual Quality > Retention > Monetization
```
Se uma mudança melhora receita e piora qualquer item acima de "Monetization", **ela não entra**.

### Balanceamento
- Só por dado: distribuição de território final, vitórias por arquétipo, mortes por causa, frequência de Backwash, uso de power-ups, duração por modo.
- Todo ajuste com antes/depois medido e registrado no histórico de `docs/design/balance.md`. Nunca "parece melhor".
- Publicar por remote config quando possível, evitando build nova.

### Monetização
- Rewarded ads **opt-in** apenas em dois pontos (resultado e desafios), com limites diários. Nunca no meio da partida, nunca no boot, nunca antes da primeira partida de um jogador novo.
- IAP validado no servidor: recibo único, reembolso revoga o item, restauração funciona.
- Season pass **só cosmético**, com trilha gratuita que entrega itens reais — não migalhas. Item permanente, mesmo após a temporada.
- Nenhum item novo pode alterar a simulação. Revisar item a item.

### Conteúdo
- Arena, modo ou cosmético novo passa pelos **mesmos gates** da fase de origem (13, 12, 11) e pelo stress test.
- Temporada precisa começar e terminar sem publicar versão.

### Operação
- Post-mortem de incidente em `docs/backend/incidents/`. Revisão trimestral de dependências e segurança. Auditoria de débito ao fim de cada ciclo.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/25-post-launch/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/25-post-launch/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/25-post-launch/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/25-post-launch/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/25-post-launch/TESTS.md` — os testes que precisam existir
- `.gsd/phases/25-post-launch/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/25-post-launch/`
- `docs/product/monetization.md`
- `docs/design/economy.md`
- `docs/design/balance.md`

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

*Phase: 25-post-launch*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
