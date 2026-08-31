---
phase: 26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick
plan: 3
subsystem: docs/google-play
tags: [architecture, event-bus, gamification-engine, domain-events, feature-flags, offline-queue, risk-register, go-no-go, discovery]
dependency-graph:
  requires:
    - "docs/google-play/compatibility-audit.md (Plano 01)"
    - "docs/google-play/current-requirements.md (Plano 02)"
  provides:
    - "docs/google-play/architecture.md"
    - "docs/google-play/compatibility-audit.md (seções 7-8)"
  affects:
    - "Fase 27 (Gamification Foundation - Eventos de Domínio e Integração)"
    - "Fase 28 (Play Games Services v2 e Autenticação)"
    - "Fase 29 (Sistema de Conquistas e Progression Loop)"
    - "Fase 30 (Game Stats e Integração Analytics)"
    - "Fase 31 (Gamificação Avançada - XP, Quests e Rewards)"
    - "Fase 32 (Leaderboards e Social Engagement)"
    - "Fase 33 (LiveOps - Seasons e Quests Dinâmicas)"
    - "Fase 34 (Sidekick - Integração Completa)"
    - "Fase 35 (Segurança, Anti-cheat e Play Integrity)"
    - "Fase 36 (QA Gamificação e Sidekick)"
    - "Fase 37 (Performance Gamificação e Otimização)"
    - "Fase 38 (Release - Rollout Google Play Games)"
tech-stack:
  added: []
  patterns:
    - "Pipeline Gameplay -> Domain Events -> Gamification Engine -> Integração Google, com EventBus (core/event_bus.gd) como único transporte desacoplado"
    - "Gamification Engine como novo submódulo de progression/ (progression/gamification/), nunca abaixo de core/"
    - "Adaptadores Google isolados em platform/google_play/, seguindo o mesmo padrão Local/Remote já usado por leaderboard/ e analytics/"
    - "Feature flags nomeadas google_play_<superficie>, resolvidas via extensão de core/config/http_remote_config.gd com fallback seguro"
    - "Fila pending_game_events reaproveitando a primitiva de persistência de platform/api/offline_queue.gd, com drain/retry a implementar na Fase 27 (gap hoje inexistente)"
key-files:
  created:
    - "docs/google-play/architecture.md"
  modified:
    - "docs/google-play/compatibility-audit.md"
decisions:
  - "Go para prosseguir com a integração faseada (Fases 27-38), com 4 bloqueadores nomeados e 1 dependência humana (H-02) mapeados explicitamente para as fases que eles afetam"
  - "Gamification Engine vive em progression/gamification/ (novo), nunca em platform/ nem abaixo de core/ — consome EventBus, nunca é chamado diretamente por gameplay/"
  - "Nenhum SDK/adapter Google é chamado diretamente por gameplay/territory/runner/ai — mesmo sendo tecnicamente permitido pela regra de camadas (gameplay pode depender de platform/), a decisão de arquitetura é usar sempre o EventBus para manter I/O assíncrono fora do caminho de simulação"
  - "Fase 33 (LiveOps) continua sobre o SeasonService próprio do VOLTA — não existe Quests API do Google para integrar"
metrics:
  duration: "~45min"
  completed: "2026-08-31"
---

# Phase 26 Plan 3: Arquitetura de Integração Google Play Games Summary

Desenhada e validada a arquitetura Gameplay → Domain Events → Gamification Engine → Integração
Google contra o código real do VOLTA (não uma arquitetura genérica), com mapeamento completo
das 12 fases (27-38) e o parecer final: **Go** para a Fase 27, com bloqueadores nomeados.

## O que foi feito

### Task 1 — `docs/google-play/architecture.md` (novo, 268 linhas, 5 seções)

1. **Visão Geral do Pipeline** — as 4 camadas mapeadas para caminhos reais: `gameplay/` e
   `progression/*` emitem (hoje só como signals locais: `MatchDirector.match_ended`,
   `EliminationService.runner_eliminated` em `apps/mobile/src/gameplay/elimination_service.gd`,
   etc.); `core/event_bus.gd` + `core/events/` são o transporte; um novo
   `progression/gamification/` (Gamification Engine) aplica as regras de negócio; um novo
   `platform/google_play/` hospeda os adaptadores que finalmente falam com o SDK.
2. **Compatibilidade com a Arquitetura Existente** — validação explícita de que o desenho não
   viola `docs/architecture/overview.md` §1: o `EventBus` real (citados os 4 sinais primitivos
   por nome — `config_loaded`, `config_load_failed`, `save_loaded`, `save_written`) é estendido,
   não substituído; o limite de 5 emissões/seg é por sinal (não global), e os 8 eventos novos
   (fim de partida, level up, etc.) ficam muito abaixo desse teto mesmo no pior caso realista.
3. **Eventos de Domínio Necessários** — tabela com os 8 eventos exigidos (`MatchStarted`,
   `MatchEnded`, `SealCompleted`, `RunnerEliminated`, `AchievementProgressed`, `LevelUp`,
   `DailyChallengeCompleted`, `PowerUpCollected`), cada um cruzado com o arquivo real que hoje
   produz (ou deveria produzir) o fato equivalente e a fase do ROADMAP que primeiro consome.
4. **Feature Flags e Fila Offline** — convenção `google_play_<superficie>` (8 flags concretas
   com default recomendado e motivo), reaproveitando `core/config/http_remote_config.gd`; desenho
   da fila `pending_game_events` como segunda instância do padrão de
   `platform/api/offline_queue.gd`, com a lacuna real do arquivo original (nenhum
   `flush()`/`drain()` hoje) registrada explicitamente como algo que a Fase 27 precisa
   **adicionar**, não apenas copiar.
5. **Mapeamento de Fases (27-38)** — tabela com exatamente 12 linhas (uma por fase), cruzando
   superfície Google, sistema existente reaproveitado (citando arquivos reais de
   `compatibility-audit.md` §3) e novo componente necessário.

### Task 2 — Seções 7-8 anexadas a `docs/google-play/compatibility-audit.md`

- **Seção 7 (Registro de Riscos Consolidado)**: 13 riscos, cada um com origem explícita em um
  dos três documentos (`compatibility-audit.md §6` para os 6 riscos preliminares do Plano 01,
  `current-requirements.md §14` para 6 riscos de disponibilidade — Play Points, Play Pass,
  ausência de Quests API, atraso da UI de Game Stats, data de Rewards, achievements badge do
  Sidekick —, `architecture.md §2` para o risco arquitetural do limite de emissão do EventBus).
- **Seção 8 (Parecer Go/No-Go)**: **Go** para prosseguir com a Fase 27, com 4 bloqueadores
  nomeados (Gradle build customizado ausente → Fase 28; Play Points/Play Pass invite-only →
  Fase 31; ausência de Quests API → Fase 33; achievements badge de tração → Fase 34) e a
  dependência humana H-02 (`.planning/STATE.md`) mapeada para bloquear as Fases 34/38, não a 27.

## Achados e decisões relevantes

1. **O único ponto onde a arquitetura escolhe não usar a permissão de camada que teria**: pela
   regra de `docs/architecture/overview.md` §1, `gameplay/` poderia legalmente depender
   diretamente de `platform/` (camada mais funda). A arquitetura decide explicitamente **não**
   fazer isso para SDKs Google — só via `EventBus` — porque I/O de SDK é assíncrono e o projeto
   proíbe `await` no caminho de simulação (`CLAUDE.md` regra 10). Isso está registrado como
   decisão de arquitetura, não como redescoberta de uma regra que já existia.
2. `OfflineQueue` (`apps/mobile/src/platform/api/offline_queue.gd`) não tem `flush`/`drain` hoje
   — confirmado por leitura direta do arquivo nesta tarefa (já havia sido registrado como débito
   por `compatibility-audit.md` §2.5 no Plano 01). O desenho da fila `pending_game_events` na
   Seção 4 de `architecture.md` já avisa a Fase 27 que precisa suprir essa lacuna, não presumir
   que o padrão existente já resolve retry.
3. `PowerUpService` (`apps/mobile/src/gameplay/powerups/power_up_service.gd`) não emite nenhum
   sinal no momento da coleta de um power-up — `apply_effect` é chamado sem nenhum
   `signal.emit()` — então `PowerUpCollected` na tabela de eventos foi documentado como "ponto de
   extensão a criar", não como signal local já existente (diferente de `MatchEnded` e
   `RunnerEliminated`, que já existem como signal local hoje).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Bloqueio de verificação] `architecture.md` tinha 6 seções `## ` em vez de 5**
- **Encontrado durante:** verificação final do plano (checagem do bloco `<verification>`, que
  exige `grep -c '^## ' docs/google-play/architecture.md` == 5).
- **Problema:** a primeira versão do arquivo incluía uma seção extra `## Referências` no final,
  além das 5 seções exigidas pela Task 1.
- **Correção:** a lista de referências cruzadas foi rebaixada de cabeçalho H2 para um parágrafo
  em negrito no rodapé do documento, preservando as citações a `compatibility-audit.md`,
  `current-requirements.md`, `docs/architecture/overview.md` e `event_bus.gd` sem violar a
  contagem de seções exigida.
- **Arquivos modificados:** `docs/google-play/architecture.md`
- **Commit:** `a6bca1b`

### Nota sobre uma verificação do plano que não pôde ser satisfeita como escrita

O bloco `<verification>` do plano inclui `git diff --name-only origin/master...HEAD | grep -v
'^docs/' | grep -v '^\.planning/'` retornando vazio. Esta verificação **não passa** neste
ambiente — mas por um motivo que antecede e é independente deste plano: `origin/master` está
travado no commit `477fd96` (a migração de engine, o commit mais recente feito antes do início
da Fase 26), enquanto o `master` local já está várias dezenas de commits à frente
(incluindo trabalho de fases anteriores nunca enviado ao remoto, como
`03f9d63 fix(gameplay): match_director avança a FSM...` e `8b2c19d fix(integration): migrate
code to godot root...`). O hard constraint real deste plano — confirmado explicitamente na
tarefa recebida — é `git status --porcelain -- apps packages services tools .github` imprimir
vazio, o que **foi verificado e passa** em todas as etapas deste plano (nenhum arquivo de
produção foi criado, modificado ou staged por mim). A verificação contra `origin/master` do
próprio texto do plano depende de o remoto estar atualizado, o que é responsabilidade de um
`git push` humano fora do escopo de execução deste agente — registrado aqui para não ser
confundido com uma violação do plano.

## Verificação

- `test -f docs/google-play/architecture.md` → OK
- `head -1 docs/google-play/architecture.md` → `# Arquitetura de Integração — Google Play Games (VOLTA)`
- `grep -c '^## ' docs/google-play/architecture.md` → 5
- `grep -c '^## ' docs/google-play/compatibility-audit.md` → 8
- `grep -q 'event_bus.gd'` / `'pending_game_events'` / `'offline_queue.gd'` em `architecture.md` → todos OK
- `grep -c '^| '` em `architecture.md` → 31 (≥ 21 exigido: 9 da tabela de eventos + 13 da tabela de fases + 9 da tabela de feature flags)
- `grep -c '^| '` em `compatibility-audit.md` → 37 (≥ 22 exigido, cumulativo desde o Plano 01)
- `grep -qiE 'Go\b|No-Go'` em `compatibility-audit.md` → OK (seção 8 conclui "Go para a Fase 27")
- `./tools/ci/lint_docs.sh` → OK: todos os docs começam com título H1
- `git status --porcelain -- apps packages services tools .github` → vazio (nenhum arquivo de produção tocado em todo o plano)

## Self-Check: PASSED

- FOUND: docs/google-play/architecture.md (268 linhas, 5 seções `## `)
- FOUND: docs/google-play/compatibility-audit.md com seções 7 e 8 anexadas (8 seções `## ` no total)
- FOUND commit e52a4be (Task 1 — architecture.md criado)
- FOUND commit a6bca1b (fix — architecture.md ajustado para 5 seções H2)
- FOUND commit e084819 (Task 2 — seções 7-8 anexadas a compatibility-audit.md)
