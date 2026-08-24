---
gsd_state_version: 1.0
milestone: v0.1.0
milestone_name: v0.1.0
status: ready
stopped_at: Planejamento completo — pronto para executar a Phase 1
last_updated: "2026-08-24T00:00:00.000Z"
last_activity: 2026-08-24 — Master plan criado (25 fases, 245 tarefas, 14 ADRs, 63 documentos)
progress:
  total_phases: 25
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-24)

**Core value:** Arcade mobile de conquista territorial em partidas de 90–180 s — sair da zona segura, desenhar o arco, fechar a volta e capturar — com controle que responde, bots com intenção legível e monetização que nunca vende vantagem.
**Current focus:** Phase 1 — Repository Foundation

## Current Position

Phase: 1 of 25 (Repository Foundation)
Plan: 0 of TBD in current phase
Status: Ready to plan
Last activity: 2026-08-24 — Master plan criado

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Velocity:**
- Total plans completed: 0
- Average duration: —
- Total execution time: —

**By Phase:**

| Phase | Plans | Status |
|-------|-------|--------|
| — | — | — |

## Accumulated Context

### Decisions

Decisões arquiteturais completas em `docs/decisions/ADR-0001..0014` e resumidas em
`.gsd/DECISIONS.md`. As que mais afetam a execução:

- **A simulação não conhece a apresentação.** `territory/`, `runner/`, `ai/` e `gameplay/` nunca importam `presentation/` ou `ui/` — é isso que permite rodar 500 partidas headless por noite.
- **Território é grid denso** (`PackedByteArray`) com flood fill **do exterior**, restrito à bounding box do Arc. O Arc precisa ser 4-conectado (traçado supercover) ou o fill vaza e captura o mapa inteiro.
- **Simulação a 60 Hz fixo**, render livre, interpolação visual manual. Nada de `await` no caminho de simulação — quebra o determinismo.
- **Auto-colisão dá Backwash, não morte.** O Arc reinicia na hora, para não virar rota de fuga. A lista de causas de morte é fechada (R5.7).
- **Nenhum número de gameplay no código.** Tudo em `.tres` sob `packages/shared/config/`, com os valores de `docs/design/balance.md`.
- **Dificuldade de bot por comportamento**, nunca por velocidade. `enemySpeed *= 2` é proibido.
- **Nada comprável altera a simulação.**

### Pending Todos

- Backlog completo em `.gsd/BACKLOG.md` (18 itens adiados, 7 placeholders e 5 mocks rastreados, todos com fase de destino).

### Blockers/Concerns

- [Phase 1] Export templates do Godot 4.3 precisam estar instalados para a tarefa REPO-012 (APK de debug). Se faltarem, as demais tarefas seguem e a pendência fica explícita aqui.
- [Phase 2] É necessário um aparelho Android intermediário real para medir latência de input (< 50 ms) — sem ele, a Phase 2 não fecha.
- [Phase 15] Hospedagem da API e domínio dependem de decisão humana (H-03). Desenvolvimento roda em Docker local, então não bloqueia.
- [Phase 21] Busca de anterioridade da marca "VOLTA" é decisão humana (H-01) com prazo **antes** desta fase.
- [Phase 21/22] Contas Google Play e Apple Developer são decisão humana (H-02).

## Session Continuity

Last session: 2026-08-24
Stopped at: Planejamento completo
Resume file: .planning/ROADMAP.md
