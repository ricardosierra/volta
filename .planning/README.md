# .planning/ — interface do GSD

Este diretório é o que as **ferramentas** `/gsd:*` leem e escrevem. Ele é gerado a partir do
plano mestre em [`../.gsd/`](../.gsd/), que continua sendo a **fonte autoritativa**.

```text
.gsd/          o plano (escrito por humano/planejamento) — POR QUE e O QUE
   │           26 fases × 7 documentos, ADRs, riscos, quality gates, backlog
   ▼
.planning/     a interface do GSD (lida por máquina) — ROADMAP, STATE, CONTEXT, PLAN, SUMMARY
```

| Arquivo | Papel | Quem escreve |
|---|---|---|
| `PROJECT.md` | identidade, stack, restrições, decisões | humano; espelha `docs/` |
| `REQUIREMENTS.md` | requisitos com ID, usados no ROADMAP | humano |
| `ROADMAP.md` | 25 fases com Goal, Depends on, Success Criteria | humano; **lido pelo GSD** |
| `STATE.md` | posição atual, progresso, bloqueadores | GSD, a cada fase |
| `config.json` | modo, granularidade, perfil de modelo, gates | humano |
| `phases/NN-slug/NN-CONTEXT.md` | decisões fechadas da fase | **pré-gravado** aqui |
| `phases/NN-slug/*-PLAN.md` | plano executável | `gsd-planner` |
| `phases/NN-slug/*-SUMMARY.md` | o que foi feito | `gsd-executor` |

## Por que os CONTEXT.md já estão preenchidos

O fluxo normal do GSD é `discuss → plan → execute`, e o `discuss` faz perguntas ao humano.
Aqui essas perguntas **já foram respondidas** no planejamento mestre: cada
`NN-CONTEXT.md` traz as decisões fechadas da fase e aponta para os documentos canônicos.

Efeito prático: `roadmap analyze` reporta cada fase como `discussed`, o `/gsd:autonomous`
pula a etapa de discussão e vai direto para o planejamento — que é exatamente o que se quer
ao rodar com um modelo mais fraco, que não deveria estar tomando decisões de arquitetura.

## Regra de precedência

Se `.planning/` e `.gsd/`/`docs/` discordarem, **`docs/` e `.gsd/` vencem**. `.planning/` é
projeção; corrija a projeção, não a fonte.
