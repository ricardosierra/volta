# Phase 6: Complete Match Loop - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Existe um jogo completo — countdown, score com Surge e bônus, fim de partida, resultado e restart em um toque. Fecha o marco MVP

**Requisitos cobertos:** MTC-01, MTC-02, MTC-03, MTC-04, UIX-06

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Design system e telas bonitas (é 07)
- Arte final (é 08)
- VFX/SFX/háptico finais (é 09)
- XP, ranks, conquistas (é 10)
- Outros modos (é 12)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/06-match-loop/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Score
- Implementar `docs/design/scoring.md` **termo a termo**, com um teste por termo usando valor calculado à mão.
- Todas as constantes vêm de `score.tres` e `surge.tres`. Nenhum literal.
- Invariantes: score ≥ 0, determinístico, todo multiplicador com teto.

### Surge
- Sobe por Seal e por Break dentro das janelas; decai por inatividade; **zera** em morte e em Backwash.
- Emite sinais para HUD; áudio e VFX de Surge são da fase 9.

### Bônus nomeados
- Nove bônus, cada um com teste positivo **e** negativo (dispara / não dispara fora da condição).
- Popup empilha no máximo 3 e sobe a partir do ponto de fechamento, não do topo da tela.

### Fim de partida
- Três condições: tempo, meta de domínio, último vivo.
- Desempate em cascata: território → score → maior Seal → menor tempo em `DrawingTrail`.
- Abandono registra derrota mas **preserva** XP e moeda já ganhos (R7.4).

### Resultado e restart
- `PLAY AGAIN` é o maior alvo de toque e vai direto para `Loading`, sem passar pelo menu.
- A próxima partida é pré-carregada durante a animação da contagem, para o restart ficar < 0,8 s.
- Tocar durante a contagem completa na hora, não bloqueia.

### Analytics
- `AnalyticsBridge` é o **único** tradutor: nenhum sistema de gameplay chama analytics direto.
- `NoopAnalytics` é o adapter padrão nesta fase (MOCK-002, destino fase 18).

### HUD
- Exatamente 5 elementos permanentes. Números tabulares para o layout não tremer.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/06-match-loop/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/06-match-loop/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/06-match-loop/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/06-match-loop/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/06-match-loop/TESTS.md` — os testes que precisam existir
- `.gsd/phases/06-match-loop/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/06-match-loop/`
- `docs/design/scoring.md`
- `docs/design/balance.md` §4–§6
- `docs/gameplay/rules.md` §7
- `docs/ui/hud.md`
- `docs/product/analytics-plan.md`

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

*Phase: 06-match-loop*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
