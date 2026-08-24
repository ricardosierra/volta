<div align="center">

# VOLTA

**Arcade mobile de conquista territorial.**
Saia da sua zona, desenhe o arco, feche a volta e o terreno é seu.

`Godot 4.3` · `Android / iOS` · `Laravel 11 + PostgreSQL (opcional, fase 15+)` · `working title`

![validate](https://github.com/ricardosierra/volta/actions/workflows/validate.yml/badge.svg)
![client-ci](https://github.com/ricardosierra/volta/actions/workflows/client-ci.yml/badge.svg)

</div>

---

## 1. O projeto

**VOLTA** (título de trabalho) é um jogo mobile arcade de **conquista territorial** em arena:
um loop de 60–180 segundos onde o jogador expande seu território desenhando um arco fora
da própria área e **fechando a volta** de volta nela.

O nome carrega o próprio verbo do jogo: *dar a volta*. E também a carga elétrica da direção
de arte — neon geométrico, alto contraste, resposta visual imediata.

> **Isto não é um clone.** A referência é apenas o *conceito* de loop territorial (sair,
> cercar, retornar, capturar). Regras, economia, bots, arte, UI, áudio, nomes, arquitetura e
> progressão são próprios. Nenhum código, asset, mapa, personagem ou interface de terceiros
> é copiado. Ver [`docs/product/vision.md`](docs/product/vision.md) e
> [`docs/art/art-direction.md`](docs/art/art-direction.md).

### Glossário próprio

| Termo | Significado |
|---|---|
| **Runner** | A entidade controlada pelo jogador ou por um bot |
| **Claim** | O território controlado por um Runner |
| **Arc** | A trilha luminosa desenhada fora do Claim (vulnerável) |
| **Seal** | O ato de fechar o Arc e converter a região cercada em Claim |
| **Break** | Eliminar um Runner cortando o Arc dele |
| **Surge** | Sistema de combo (Seals encadeados, Breaks encadeados, risco) |
| **Spark / Prism** | Moeda de progressão (soft) / moeda premium cosmética (hard) |
| **Field** | A arena — grid lógico + camada visual |

---

## 2. Gameplay

```text
                 ┌──────────────────────────────────────────────┐
   Safe  ───────►│  sai do Claim → começa o Arc (DrawingTrail)  │
    ▲            └──────────────────────┬───────────────────────┘
    │                                   │
    │                  volta a tocar o próprio Claim
    │                                   ▼
    │            ┌──────────────────────────────────────────────┐
    └────────────┤  Seal: flood fill fecha a região → Claim++   │
                 └──────────────────────────────────────────────┘

   Enquanto o Arc existe, ele é vulnerável: qualquer Runner que o cortar
   causa um Break. Você morre, e quem cortou leva o bônus.
```

- **Fácil de aprender em ~10 s.** Um swipe move; sair pinta; voltar captura.
- **Difícil de dominar.** Arco grande = captura grande = risco grande. O jogo inteiro é
  essa negociação, medida pelo multiplicador de risco no score.
- **Auto-colisão não mata** — ela *cancela* o Arc e devolve o Runner ao Claim mais próximo
  com penalidade de tempo. Decisão de design registrada em
  [`ADR-0007`](docs/decisions/ADR-0007-self-collision-rule.md).

Regras completas: [`docs/gameplay/rules.md`](docs/gameplay/rules.md) ·
Loop: [`docs/gameplay/core-loop.md`](docs/gameplay/core-loop.md) ·
Modos: [`docs/gameplay/game-modes.md`](docs/gameplay/game-modes.md)

---

## 3. Screenshots

> Ainda não existem. Serão adicionados em **GSD 08 — Art Direction** (primeiro conjunto) e
> substituídos por capturas de loja em **GSD 21/22**. Placeholders rastreados em
> [`.gsd/BACKLOG.md`](.gsd/BACKLOG.md) sob `PLACEHOLDER-ART-*`.

---

## 4. Arquitetura (visão de 1 minuto)

O cliente é dividido em sistemas com fronteiras explícitas. Não existe `GameManager` global.

```text
apps/mobile (Godot)
├── core/        Bootstrap, EventBus, Config, Logging, SaveSystem, ServiceLocator
├── gameplay/    MatchDirector, GameState FSM, Rules, Score, Modes
├── territory/   Grid, ClaimMap, ArcTracker, SealSolver (flood fill), TerritoryRenderer
├── runner/      Runner FSM, Movement, Collision, RunnerFactory
├── ai/          BotBrain, Behaviors, RiskModel, ThreatMap
├── arena/       ArenaDefinition, Spawner, ArenaModifiers
├── presentation/ Camera, VFX, Juice, Audio, Haptics
├── ui/          Screens, HUD, DesignSystem, Navigation
├── input/       InputRouter, SwipeDriver, JoystickDriver, RelativeDriver
├── progression/ Profile, XP, Achievements, Challenges, Cosmetics
└── platform/    Analytics, Telemetry, RemoteConfig, Store (interfaces + adapters)
```

Regras estruturais que valem para todas as fases:

1. **Simulação não conhece apresentação.** `territory/`, `runner/`, `ai/` e `gameplay/`
   nunca importam `presentation/` ou `ui/`. Comunicação de saída é por sinal/evento.
2. **Toda dependência externa entra por interface** (`*Repository`, `*Service`) com
   implementação `Local*` antes de `Remote*`.
3. **Configuração é dado**, não literal no código (`packages/shared/config` → `Resource`).
4. **Nada de arquivos-depósito** (`Utils.gd`, `Global.gd`, `Manager.gd`).

Detalhes: [`docs/architecture/overview.md`](docs/architecture/overview.md) ·
[`docs/architecture/territory-system.md`](docs/architecture/territory-system.md) ·
[`docs/decisions/`](docs/decisions/)

---

## 5. Stack

| Camada | Tecnologia | Fase |
|---|---|---|
| Engine | **Godot 4.3 stable**, GDScript tipado, renderer *Mobile* | GSD 01 |
| Territory | Grid denso `PackedByteArray` + flood fill incremental | GSD 03 |
| UI | Godot Control + Design System próprio (tokens em `Resource`) | GSD 07 |
| Testes | [GUT](https://github.com/bitwes/Gut) (unit/integration) + headless sim runner | GSD 01 |
| CI | GitHub Actions (lint, gdscript check, testes, export validation) | GSD 01 |
| Backend | **PHP 8.3 + Laravel 11**, PostgreSQL 16, Redis 7, filas, Sanctum | GSD 15 |
| Realtime | WebSocket autoritativo (avaliado em ADR-0005) | GSD 17 |
| Analytics | Interface própria + adapter (nenhum SDK acoplado ao gameplay) | GSD 18 |

---

## 6. Estrutura do repositório

```text
volta/
├── apps/mobile/         Projeto Godot (cliente) — criado em GSD 01
├── services/api/        Laravel API — criado em GSD 15
├── packages/shared/     Contratos compartilhados: schemas de save, config, protocolo
├── assets/              Fontes de arte/áudio (source) e exportados
├── tools/               Scripts de CI, dev, benchmarks e stress test
├── tests/               Suites que rodam fora do projeto Godot (harness, fixtures)
├── docs/                Documentação viva — ver docs/INDEX.md
└── .gsd/                O "cérebro operacional": plano mestre, fases, tarefas, status
```

---

## 7. Pré-requisitos

| Ferramenta | Versão | Obrigatório desde |
|---|---|---|
| Godot | 4.3 stable (mesma build do CI, ver `.godot-version`) | GSD 01 |
| Export templates Godot | 4.3 stable | GSD 01 |
| Git | ≥ 2.40 | agora |
| Android SDK + JDK 17 | API 34, build-tools 34 | GSD 21 |
| Xcode | ≥ 15 (apenas macOS) | GSD 22 |
| PHP / Composer | 8.3 / 2.x | GSD 15 |
| Docker | ≥ 24 (Postgres + Redis locais) | GSD 15 |

---

## 8. Instalação

```bash
git clone git@github.com:ricardosierra/volta.git
cd volta
cp .env.example .env
./tools/dev/doctor.sh          # valida versões, estrutura e dependências
```

## 9. Execução

```bash
# Cliente (a partir de GSD 01)
godot --path apps/mobile                       # abre no editor
godot --path apps/mobile --rendering-driver opengl3   # roda a cena principal

# Backend (a partir de GSD 15)
cd services/api && composer install && php artisan serve
```

## 10. Testes

```bash
./tools/ci/test-client.sh      # GUT: unit + integration, headless
./tools/ci/lint.sh             # gdscript style + static check + docs lint
./tools/dev/simulate.sh 500    # 500 partidas só de bots (stress/balance)
./tools/ci/validate-repo.sh    # estrutura, TODOs sem tarefa, mocks órfãos
```

Estratégia completa: [`docs/testing/testing-strategy.md`](docs/testing/testing-strategy.md)

## 11. Builds

- **Android:** [`docs/mobile/android.md`](docs/mobile/android.md) — keystore, AAB, permissões, ABI split.
- **iOS:** [`docs/mobile/ios.md`](docs/mobile/ios.md) — provisioning, entitlements, launch screen.
- **Release:** [`docs/deployment/release-process.md`](docs/deployment/release-process.md)

## 12. Backend

Não existe até **GSD 15**. Até lá tudo é local por trás de interfaces
(`LocalLeaderboardRepository`, `LocalProfileRepository`, …) — ver
[`docs/architecture/networking.md`](docs/architecture/networking.md) e
[`docs/backend/`](docs/backend/).

---

## 13. Documentação

Comece por [`docs/INDEX.md`](docs/INDEX.md). Decisões arquiteturais em
[`docs/decisions/`](docs/decisions/).

## 14. Roadmap

26 fases GSD, de *Discovery* a *Post Launch*. Marcos:
**MVP** (fim da GSD 06) → **Alpha** (fim da GSD 14) → **Beta** (fim da GSD 20) →
**Release v0.1.0** (fim da GSD 24). Ver [`docs/product/roadmap.md`](docs/product/roadmap.md)
e [`.gsd/MASTER_PLAN.md`](.gsd/MASTER_PLAN.md).

## 15. Como trabalhar neste repositório

Este projeto é executado por fases. Os comandos conceituais são:

```text
Execute GSD 01            # executa a próxima fase inteira
Execute next GSD phase
Resume current GSD phase
Audit GSD 03
Show project status
```

Ou, usando as ferramentas GSD instaladas:

```text
/gsd:autonomous          executa todas as fases restantes (discuss→plan→execute por fase)
/gsd:plan-phase 1        planeja apenas a fase 1
/gsd:execute-phase 1     executa os planos da fase 1
/gsd:progress            mostra onde o projeto está
```

Dois diretórios, um plano: [`.gsd/`](.gsd/) é a **fonte autoritativa** (26 fases × 7
documentos, ADRs, riscos, quality gates); [`.planning/`](.planning/) é a **interface** que os
comandos `/gsd:*` leem e escrevem. Em caso de divergência, `.gsd/` e `docs/` vencem.

O estado atual vive em [`.gsd/STATUS.md`](.gsd/STATUS.md) e em
[`.planning/STATE.md`](.planning/STATE.md).
Regras de contribuição em [`CONTRIBUTING.md`](CONTRIBUTING.md) e no
[`CLAUDE.md`](CLAUDE.md).

## 16. Licença

Código sob [MIT](LICENSE). **Assets de arte, áudio, marca e nome não estão cobertos pela MIT** —
ver seção "Assets" em `LICENSE` e `assets/README.md`.

## 17. Status

| | |
|---|---|
| Master Plan | ✅ READY |
| Fase atual | **GSD 01 — Repository Foundation** |
| Implementação | ⛔ NOT STARTED |
| Versão | `v0.1.0` (não lançada) |
