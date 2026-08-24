# ADR-0014 — Tick de simulação e taxa de atualização

## Context

Aparelhos-alvo têm painéis de 60, 90 e 120 Hz — e taxa variável (LTPO). Precisamos ao mesmo
tempo de: **determinismo** (requisito de testes, replay e servidor autoritativo — regra R8.5),
**fluidez** em 120 Hz e **latência de input < 50 ms**. Godot 4.3 não tem interpolação física 2D
nativa.

## Decision

**Simulação a 60 Hz fixo, render livre, interpolação visual manual.**

```text
_physics_process(1/60)   input → IA → movimento → grid → seals → regras → eventos
_process(delta)          interpola visuais entre o estado anterior e o atual, VFX, HUD, câmera
```

- `Engine.physics_ticks_per_second = 60`, `Engine.max_physics_steps_per_frame = 4`.
- `Engine.max_fps` acompanha a taxa do painel (`DisplayServer.screen_get_refresh_rate()`).
- Cada entidade visual guarda `prev_transform` e `curr_transform` e interpola por
  `Engine.get_physics_interpolation_fraction()`.
- Input é **coletado** por evento (sem perda) e **consumido** no tick — com buffer, para que
  nenhum toque entre dois ticks seja descartado.
- Nada de `await` nem de dependência de `delta` variável dentro da simulação.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Simulação em `_process` com delta variável** | Mata o determinismo; a mesma sequência de input daria resultados diferentes em 60 e 120 Hz, inviabilizando testes e servidor autoritativo |
| **Simulação a 120 Hz** | Dobra o custo de CPU sem ganho perceptível para este gênero; pior no aparelho Low |
| **Simulação a 30 Hz** | Latência de input inaceitável (33 ms só de espera) e Arc com degraus grosseiros |
| **Interpolação nativa da engine** | Não disponível para 2D em 4.3; reavaliado no upgrade (ADR-0001) |
| **Sem interpolação** | Em 120 Hz o movimento mostraria "escadinha" de 60 Hz, desperdiçando o painel |

## Consequences

**Positivas:** determinismo garantido; a mesma simulação roda headless a velocidade máxima nos
testes; custo de CPU previsível; fluidez em qualquer painel.

**Negativas / mitigações:**
- Interpolação manual é código extra em toda entidade visual → um componente único
  (`InterpolatedVisual`) usado por Runner, Arc e efeitos; ninguém implementa isso duas vezes.
- Um tick longo pode acumular passos → teto de 4 passos por frame evita espiral da morte; um
  hitch degrada visual, nunca corrompe simulação.
- 60 Hz limita a precisão da rasterização em velocidades altas → resolvido pelo traçado
  supercover (ADR-0002), que cobre saltos de várias células.

## Status

**Accepted** — 2026-08-24.
