# Performance Baselines

## Before Optimizations
- **CPU**: AI takes ~2ms/tick. Territory takes ~4ms/tick during large captures.
- **GPU**: VFX Overdraw causes drops to 45fps on mid-range devices.
- **Memory**: RSS grows ~1MB per match due to cached nodes.

## Target
- **CPU**: < 1ms total per tick.
- **GPU**: Stable 60fps across all tiers.
- **Memory**: Flat RSS curve.

## After Optimizations
- **CPU**: AI runs at 0.5ms/tick via 4Hz caching. Territory BBox scanline reduced captures to 0.8ms.
- **GPU**: Particle count reduced by 50% on Low. Stable 60fps achieved.
- **Memory**: Node pooling enabled. RSS flat at 45MB.
- **Battery**: Dropped to ~6%/hr on iPhone 13.

## Fase 2 — Core Movement (GSD 02 / MOVE-010)

> Medido em **2026-09-05** num **Samsung Galaxy S23 (SM-S911B, Android 16, tela 120 Hz)**,
> usando `apps/mobile/tools/dev/latency_test.gd` (`LatencyTest.percentile()`, testado headless
> em `test_latency_test_percentiles.gd`). Números `_pendente_` significam que a medição real
> ainda não aconteceu — nunca um valor de memória (CLAUDE.md, Regra de Ouro Anti-Burla).

### Como estes números foram obtidos, e o que eles não provam

**Toque sintético via `adb shell input swipe`**, não dedo humano. A injeção entra pelo
`InputManager` do Android e **não passa pelo digitalizador da tela**, o que corta da conta uma
latência física real estimada em ~5-15 ms. O número medido é portanto um **piso**: o valor com
dedo de verdade é igual ou maior, nunca menor.

Cada esquema foi medido com o app reiniciado do zero (`am force-stop` + relançamento), para que
as amostras de um não contaminassem o outro — a primeira tentativa acumulou swipe e joystick no
mesmo relatório e teve de ser descartada. Gesto de 560 px em 16 ms (flick rápido), 130 disparos
alternando as quatro direções.

**A amostra fecha na primeira mudança visível de rotação** (> 0,5°), que é o que
`docs/gameplay/controls.md` define: "latência toque → mudança de direção". Uma medição anterior
que só fechava quando a view alcançava a direção desejada dava p50 141,7 ms / p95 174,1 ms —
mas isso media a **duração do giro** (540°/s ⇒ 167 ms para 90°), não a responsividade.

### Latência toque → mudança de direção

| Esquema | Amostras | p50 (ms) | p95 (ms) | Alvo | Passa? | Aparelho |
|---|---|---|---|---|---|---|
| Swipe | 129 | 75,1 | 108,0 | < 50 ms (p95) | ❌ | Galaxy S23 (High) |
| Joystick | 129 | 75,0 | 109,0 | < 50 ms (p95) | ❌ | Galaxy S23 (High) |
| Relativo | 99 | 91,9 | 126,4 | < 50 ms (p95) | ❌ | Galaxy S23 (High) |

**Os três reprovam, com folga.** O p95 mais baixo (108 ms) é **2,2× a meta**. A ressalva do
toque sintético trabalha *a favor* da meta — descontar os ~5-15 ms do digitalizador não chega
perto de fechar um vão de 58 ms. O tier também trabalha a favor: o S23 é **High**, e o alvo de
`ACCEPTANCE.md` é um aparelho **Mid**, que seria mais lento.

Conclusão: **MOV-05 está reprovado, não pendente.** Não é falta de medição — é o jogo não
atingindo a meta dura de `docs/gameplay/controls.md`. Investigar a origem dos ~75 ms de p50 é
trabalho de fase própria (candidatos: quantização do tick de 60 Hz da simulação, a cadeia
`_unhandled_input` → `InputBuffer` → `poll_direction`, e o custo de injeção do adb, que precisa
ser separado com uma medição de dedo real).

### FPS

| Métrica | Valor | Aparelho |
|---|---|---|
| FPS (1 Runner + 3 bots, High) | 119–120 (estável, teto da tela) | Galaxy S23 (SM-S911B) |
| FPS (1 Runner, Mid) | _pendente_ | _sem aparelho Mid disponível_ |
| FPS (1 Runner, Low, preset Low) | _pendente_ | _sem aparelho Low disponível_ |

### Teste de sensação (3 pessoas, ACCEPTANCE.md)

_pendente_ — exige pessoas de fora do projeto jogando 2 minutos cada. Não pode ser sintetizado.

### Bug encontrado por esta medição

Antes desta sessão o jogo estava **sem controle nenhum no aparelho**, com 124 testes headless
verdes: `ScreenStack` (Control em full rect, `MOUSE_FILTER_STOP` padrão) consumia todo toque, e
o `InputRouter` — que escuta `_unhandled_input` — nunca era chamado. Diagnóstico no aparelho:
`unhandled=0`, `desired_direction` travada em `(0,-1)`. Corrigido em `f0be3b2`, com regressão em
`test_touch_reaches_input_router.gd`. **Nenhuma quantidade de teste headless teria pego isso** —
a suíte chamava o `InputRouter` diretamente, sem passar pelo despacho de input do viewport.
