# Índice da documentação — VOLTA

> Toda documentação é **viva**: se uma fase GSD muda uma decisão, o documento correspondente
> muda no mesmo PR. Documento desatualizado bloqueia o quality gate da fase.

## Como ler, dependendo do que você quer fazer

| Quero… | Leia nesta ordem |
|---|---|
| Entender o produto | `product/vision.md` → `product/game-pillars.md` → `gameplay/core-loop.md` |
| Implementar gameplay | `gameplay/rules.md` → `architecture/state-machines.md` → `architecture/territory-system.md` |
| Mexer no território | `architecture/territory-system.md` → `decisions/ADR-0002` → `performance/performance-budget.md` |
| Fazer bots | `gameplay/bots.md` → `decisions/ADR-0008` → `design/balance.md` |
| Fazer UI | `ui/design-system.md` → `ui/screens.md` → `ui/hud.md` |
| Fazer arte/VFX | `art/art-direction.md` → `art/vfx.md` → `design/game-feel.md` |
| Fazer áudio | `audio/audio-direction.md` → `design/game-feel.md` |
| Mexer no backend | `architecture/networking.md` → `backend/api-design.md` → `backend/security.md` |
| Publicar | `mobile/android.md` / `mobile/ios.md` → `deployment/release-process.md` |
| Executar uma fase | `.gsd/MASTER_PLAN.md` → `.gsd/STATUS.md` → `.gsd/phases/XX-*/README.md` |

## Produto

- [`product/vision.md`](product/vision.md) — visão, público, diferencial, título e posicionamento
- [`product/game-pillars.md`](product/game-pillars.md) — os 5 pilares e como usá-los para decidir
- [`product/roadmap.md`](product/roadmap.md) — marcos MVP → Alpha → Beta → Release
- [`product/monetization.md`](product/monetization.md) — monetização ética, o que é e o que não é permitido
- [`product/analytics-plan.md`](product/analytics-plan.md) — o que medimos e por quê

## Design

- [`design/game-design-document.md`](design/game-design-document.md) — GDD consolidado
- [`design/game-feel.md`](design/game-feel.md) — juice: o contrato de resposta de cada ação
- [`design/scoring.md`](design/scoring.md) — fórmula de score, Surge e multiplicador de risco
- [`design/progression.md`](design/progression.md) — XP, ranks, conquistas, desafios
- [`design/economy.md`](design/economy.md) — Sparks, Prisms, fontes, drenos, inflação
- [`design/balance.md`](design/balance.md) — todos os números ajustáveis e como ajustá-los
- [`design/onboarding.md`](design/onboarding.md) — primeira sessão, ensino dentro do jogo

## Gameplay

- [`gameplay/core-loop.md`](gameplay/core-loop.md) — o loop de 10 segundos, 3 minutos e 3 semanas
- [`gameplay/rules.md`](gameplay/rules.md) — regras formais, estados, edge cases
- [`gameplay/game-modes.md`](gameplay/game-modes.md) — Classic, Time Attack, Survival, Domination, Endless
- [`gameplay/bots.md`](gameplay/bots.md) — arquétipos, utilidade, percepção, dificuldade
- [`gameplay/power-ups.md`](gameplay/power-ups.md) — os 6 power-ups e seus contra-jogos
- [`gameplay/controls.md`](gameplay/controls.md) — swipe, joystick, relativo, acessibilidade de input

## Arquitetura

- [`architecture/overview.md`](architecture/overview.md) — camadas, módulos, dependências, convenções
- [`architecture/territory-system.md`](architecture/territory-system.md) — **o sistema mais crítico do projeto**
- [`architecture/state-machines.md`](architecture/state-machines.md) — FSM do Runner e do jogo
- [`architecture/save-system.md`](architecture/save-system.md) — persistência, schema, migrações
- [`architecture/networking.md`](architecture/networking.md) — repositórios locais → remotos, multiplayer
- [`architecture/configuration.md`](architecture/configuration.md) — configuração orientada a dados
- [`architecture/logging.md`](architecture/logging.md) — logging estruturado por categoria
- [`architecture/debug-tools.md`](architecture/debug-tools.md) — menu de debug e como ele fica fora do release

## Mobile / UI / Arte / Áudio

- [`mobile/android.md`](mobile/android.md) · [`mobile/ios.md`](mobile/ios.md) · [`mobile/device-matrix.md`](mobile/device-matrix.md)
- [`ui/design-system.md`](ui/design-system.md) · [`ui/screens.md`](ui/screens.md) · [`ui/hud.md`](ui/hud.md) · [`ui/accessibility.md`](ui/accessibility.md)
- [`art/art-direction.md`](art/art-direction.md) · [`art/vfx.md`](art/vfx.md) · [`art/themes.md`](art/themes.md)
- [`audio/audio-direction.md`](audio/audio-direction.md)

## Qualidade / operação

- [`testing/testing-strategy.md`](testing/testing-strategy.md) · [`testing/stress-testing.md`](testing/stress-testing.md)
- [`performance/performance-budget.md`](performance/performance-budget.md) · [`performance/territory-benchmarks.md`](performance/territory-benchmarks.md)
- [`deployment/release-process.md`](deployment/release-process.md) · [`deployment/ci-cd.md`](deployment/ci-cd.md)
- [`backend/api-design.md`](backend/api-design.md) · [`backend/security.md`](backend/security.md) · [`backend/anti-cheat.md`](backend/anti-cheat.md)

## Decisões

Todas em [`decisions/`](decisions/) — formato Context / Decision / Alternatives / Consequences / Status.

| ADR | Assunto |
|---|---|
| [0001](decisions/ADR-0001-engine.md) | Engine e versão |
| [0002](decisions/ADR-0002-territory-representation.md) | Representação do território |
| [0003](decisions/ADR-0003-save-system.md) | Save e migrações |
| [0004](decisions/ADR-0004-backend.md) | Stack de backend |
| [0005](decisions/ADR-0005-networking.md) | Multiplayer autoritativo |
| [0006](decisions/ADR-0006-movement-model.md) | Modelo de movimento |
| [0007](decisions/ADR-0007-self-collision-rule.md) | Regra de auto-colisão |
| [0008](decisions/ADR-0008-bot-ai-architecture.md) | Arquitetura da IA |
| [0009](decisions/ADR-0009-ui-framework.md) | Framework e escala de UI |
| [0010](decisions/ADR-0010-analytics-abstraction.md) | Abstração de analytics |
| [0011](decisions/ADR-0011-theming-and-cosmetics.md) | Temas e cosméticos |
| [0012](decisions/ADR-0012-branching-and-release-flow.md) | Branching e releases |
| [0013](decisions/ADR-0013-testing-stack.md) | Stack de testes |
| [0014](decisions/ADR-0014-simulation-tick-model.md) | Tick de simulação e refresh rate |

## Diagramas

[`diagrams/`](diagrams/) — fontes Mermaid (`.mmd`) versionadas; exportações vivem em `assets/exported/`.
