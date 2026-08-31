---
phase: 26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick
plan: 2
subsystem: docs/google-play
tags: [google-play-games, pgs-v2, sidekick, level-up, play-integrity, achievements, leaderboards, game-stats, play-points, play-pass, rewards, liveops, quests, discovery]
dependency-graph:
  requires: []
  provides:
    - "docs/google-play/current-requirements.md"
  affects:
    - "26-03-arquitetura-integracao (Plano 03 desta fase)"
    - "Fase 28 (PGS v2 / Autenticação)"
    - "Fase 29 (Conquistas e Progression Loop)"
    - "Fase 30 (Game Stats)"
    - "Fase 31 (XP, Quests e Rewards)"
    - "Fase 32 (Leaderboards e Social Engagement)"
    - "Fase 33 (LiveOps - Seasons e Quests Dinâmicas)"
    - "Fase 34 (Sidekick - Integração Completa)"
    - "Fase 35 (Play Integrity / Anti-cheat)"
    - "Fase 36 (QA / docs/google-play/level-up-quality.md)"
tech-stack:
  added: []
  patterns:
    - "Pesquisa ao vivo via curl+pandoc contra fontes oficiais (substituindo WebSearch/WebFetch, indisponíveis neste executor), com cada afirmação citada por URL + data de consulta"
key-files:
  created:
    - "docs/google-play/current-requirements.md"
  modified: []
decisions:
  - "Nenhuma decisão de arquitetura tomada — este plano é só pesquisa/registro, decisões ficam para o Plano 03"
metrics:
  duration: "~50min"
  completed: "2026-08-31"
---

# Phase 26 Plan 2: Requisitos Oficiais Google Play Games Summary

Pesquisa ao vivo (não de memória) das 13 superfícies do ecossistema Google Play Games
relevantes para o VOLTA, com o achado central de que Quests/LiveOps não têm SDK próprio —
são mecânicas orquestradas pelo Google sobre Achievements + Game Stats + Rewards.

## O que foi feito

Criado `docs/google-play/current-requirements.md` (316 linhas, 14 seções) cobrindo:

1. Play Games Services v2 — Sign-In
2. Recall API
3. Saved Games / Cloud Save
4. Play Integrity API
5. Achievements
6. Leaderboards
7. Game Stats
8. Play Points
9. Play Pass
10. Google Play Games Sidekick
11. Level Up (Programa de Qualidade)
12. LiveOps / Quests
13. Play Games Rewards
14. Resumo de Disponibilidade (tabela com as 13 superfícies)

Cada seção segue a subestrutura exigida pelo plano (Fontes Oficiais Consultadas /
Requisitos Vigentes / Disponibilidade e Elegibilidade / Impacto para VOLTA), com 28
citações "Consultado em: 2026-08-31" e 25 URLs de `developer.android.com` ou
`developers.google.com`, além de 3 URLs de `play.google.com/console/about/*` para os
programas comerciais (Level Up, Play Points, Play Pass) que não têm página equivalente em
`developer.android.com`.

### Método de pesquisa (nota de execução)

As ferramentas WebSearch/WebFetch não estavam disponíveis neste executor. Toda a pesquisa foi
feita com `curl` (User-Agent de navegador) + `pandoc` para converter HTML em texto legível,
contra as mesmas fontes oficiais exigidas pelo plano (`developer.android.com`,
`developers.google.com`, `play.google.com`). O efeito é idêntico ao pedido pelo hard
constraint: toda afirmação vem de uma resposta HTTP real obtida em 2026-08-31, nunca de
memória — inclusive descobri a árvore de navegação real (`href`) de `developer.android.com/games/pgs/*`
via grep no HTML bruto para encontrar as URLs corretas de Game Stats, Sidekick e Rewards
(a URL que eu teria adivinhado de memória, `/games/pgs/stats`, retornou 404 — a correta é
`/games/pgs/gamestats`).

## Achados críticos (para o Plano 03 e fases seguintes)

1. **Não existe "Quests API" nem "LiveOps API" do Google** (seção 12). Todas as URLs
   candidatas testadas (`/games/pgs/quests`, `/games/pgs/liveops`, `/games/pgs/leagues`,
   `/games/pgs/android/quests`) retornaram HTTP 404. Quests/Leagues/Social Challenges são
   mecânicas do lado do servidor do Google, construídas sobre dados que o jogo já reporta via
   Achievements API + Game Stats API + Play Games Rewards. **A Fase 33 (LiveOps) precisa
   continuar usando o backend próprio de seasons/quests do VOLTA** (já existe desde a Fase 25 —
   season service) e não deve ser desenhada em cima de um SDK de quests do Google que não existe.
2. **Game Stats: a UI pública ("You tab") só entra em produção em setembro/2026** — hoje
   (2026-08-31) está disponível apenas para testes, segundo a doc oficial atualizada há 3 dias
   (28/08/2026). API e configuração via Play Console já podem ser integradas.
3. **Play Games Rewards entra em vigor em 01/09/2026** — literalmente no dia seguinte a esta
   pesquisa. Testes end-to-end completos só são possíveis a partir dessa data.
4. **Play Points e Play Pass são invite-only/curated**, não auto-serviço: Play Points exige
   "allowlisting" pelo Google (Brasil está entre os 36 mercados ativos); Play Pass exige
   "express interest" e curadoria, com uma FAQ oficial cuja informação de disponibilidade
   regional ("initially only available in the US") parece desatualizada frente ao histórico
   conhecido do programa — registrado como inconsistência, não corrigido por presunção.
5. **PGS v1 está em desativação com cronograma fixo**: bloqueio de publicação de títulos novos
   desde set/2025, remoção de APIs v1 do SDK em jun/2026, desligamento total em mai/2027 — não
   é uma preocupação para o VOLTA (que ainda não tem integração nenhuma e vai direto para v2),
   mas confirma que v2 é a única via correta.
6. **Level Up tem um rate card comercial com rollout geográfico faseado** (30/set/2026 em
   AU/EEA/JP/UK/US; 31/dez/2026 na Coreia; 30/set/2027 no resto do mundo) e um conjunto de
   requisitos codificados (`LU-PA`, `LU-SK`, `LU-AC`, `LU-GS`, `LU-RE`, `LU-CS`, entre outros)
   com prazos próprios (ex.: Rewards precisa de 2 ofertas single-use até 30/set/2026).
7. **VOLTA publica em AAB** (`docs/mobile/android.md`), então a ativação básica do Sidekick é
   só um toggle no Play Console — não precisa da Sidekick SDK separada nem do formulário de
   registro de 1-2 semanas (isso só vale para publicação via APK legado).
8. **VOLTA já cumpre o requisito de Cloud Save do Level Up** via backend próprio (Fases 15/16) —
   a doc oficial confirma explicitamente que qualquer solução de cloud save conta, não precisa
   ser o Saved Games da PGS.
9. **O export Android do VOLTA hoje usa `gradle_build/use_gradle_build=false`** — não existe
   `build.gradle` customizado onde adicionar as dependencies Java (`play-services-games-v2`,
   Play Integrity, Recall). Isso é um pré-requisito técnico transversal a quase todas as
   superfícies (1, 2, 4, 10-via-SDK) que o Plano 03 precisa decidir como resolver.

## Superfícies cuja disponibilidade não pôde ser confirmada por completo (risco explícito)

- **Play Pass (seção 9)**: a FAQ oficial consultada em 2026-08-31 ainda afirma "Play Pass is
  initially only available in the US" — texto aparentemente desatualizado. Recomendo
  re-checagem direta com o Play Console Help antes da Fase 31/33, não assumir nem a versão
  otimista (disponível globalmente) nem a pessimista (só EUA) sem confirmação adicional.
- **Enrollment de Quests dentro de LiveOps/Quests (seção 12)**: confirmei a arquitetura
  (dado alimentado pelo jogo, mecânica orquestrada pelo Google) e o requisito técnico mínimo
  (4 achievements em 1h, Game Stats, 2 Rewards single-use), mas não encontrei, nas páginas
  acessadas, o processo formal de "como se tornar um enrolled Quest developer" — as 4 URLs
  candidatas testadas retornaram 404. Registrado como "Não confirmado" na seção 12 e na
  tabela de resumo (seção 14).

## Deviations from Plan

Nenhum desvio de escopo. Uma adaptação de ferramenta foi necessária e está documentada acima:
as ferramentas WebSearch/WebFetch citadas literalmente no plano não estavam disponíveis neste
executor; usei `curl` + `pandoc` contra as mesmas fontes oficiais, com o mesmo efeito de
pesquisa ao vivo datada exigido pelo hard constraint. Nenhum requisito foi escrito de memória.

## Verificação

- `test -f docs/google-play/current-requirements.md` → OK
- `grep -c '^## ' docs/google-play/current-requirements.md` → 14
- `grep -c 'Consultado em: 2026-'` → 28 (≥ 8 exigido)
- `grep -cE 'https://developer(s)?\.(android|google)\.com'` → 25 (≥ 8 exigido)
- `./tools/ci/lint_docs.sh` → OK: todos os docs começam com título H1
- `git status --porcelain -- apps packages services tools .github` → vazio (nenhum arquivo de produção tocado)
- Nenhum arquivo do outro executor em paralelo (`compatibility-audit.md`) foi criado, lido para escrita ou staged por este plano.

## Self-Check: PASSED

- FOUND: docs/google-play/current-requirements.md (316 linhas, 14 seções `## `)
- FOUND commit c1f68d9 (Task 1 — seções 1-4)
- FOUND commit cea4aa0 (Task 2 — seções 5-9)
- FOUND commit 7596401 (Task 3 — seções 10-14 + resumo)
