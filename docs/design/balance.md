# Balanceamento — todos os números

> **Este é o único lugar do projeto onde números de gameplay vivem em prosa.** No código eles
> vivem em `Resource` sob `packages/shared/config/`. Nenhum valor abaixo pode aparecer como
> literal dentro de um `.gd` de sistema — isso é checado em code review e o CI reclama de
> literais numéricos em arquivos de gameplay (heurística, ver `tools/ci/validate-repo.sh`).
>
> Valores marcados 🎯 são **alvos iniciais de design**, não verdades: existem para serem
> ajustados com dados do stress test (GSD 05/19) e do playtest (Alpha).

---

## 1. Field (arena)

| Parâmetro | Valor 🎯 | Notas |
|---|---|---|
| `cell_size` | 16 unidades | 1 célula = 16 px no zoom 1.0 |
| `grid_default` | 128 × 128 | 16 384 células · arena de 2048 × 2048 unidades |
| `grid_small` | 96 × 96 | arenas de 4 Runners |
| `grid_large` | 160 × 160 | Endless / 8 Runners |
| `spawn_claim` | 5 × 5 células | ≈ 0,15 % do mapa |
| `spawn_min_distance` | 28 células | distância mínima entre Runners no spawn |
| `border_thickness` | 1 célula | sólida, atua como barreira de Seal (E03) |

## 2. Runner

| Parâmetro | Valor 🎯 | Notas |
|---|---|---|
| `base_speed` | 220 u/s | 13,75 células/s — igual para todos (R3.2) |
| `turn_rate` | 540 °/s | alto de propósito: responsividade > realismo |
| `collision_radius` | 10 u | |
| `arc_visual_width` | 6 u | leitura clara sem cobrir o Field |
| `spawn_invuln` | 2,0 s | cai ao sair do Claim (R2.4) |
| `respawn_delay` | 1,5 s | Classic/Domination/Endless |
| `respawn_delay_time_attack` | 3,0 s | morrer custa tempo |
| `arc_max_cells` | 1 200 | acima disso: Overload (E07) |
| `overload_decay` | 8 células/s | cauda se desfaz; aviso 2 s antes |

## 3. Backwash (auto-colisão / borda)

| Parâmetro | Valor 🎯 |
|---|---|
| `speed_penalty` | −40 % |
| `penalty_duration` | 1,2 s |
| `surge_loss` | zera |
| `deflection` | desliza tangente à barreira |

## 4. Score

| Constante | Valor 🎯 |
|---|---|
| `CELL_VALUE` | 4 |
| `STOLEN_CELL_MULT` | 1,6× |
| `RISK_DIVISOR` | 150 células |
| `RISK_CAP` | 1,5 → multiplicador 1,0–2,5 |
| `BREAK_BASE` | 600 |
| `BREAK_STREAK_STEP` | 300 |
| `BREAK_STREAK_CAP` | 5 |
| `SURVIVAL_PER_SECOND` | 5 |
| `TERRITORY_WEIGHT` | 8 000 |
| `LARGEST_SEAL_WEIGHT` | 4 000 |
| `PLACEMENT_BONUS` | 1º 2 500 · 2º 1 200 · 3º 600 · demais 0 |
| `VICTORY_MULT` | 1,25 |
| `PUSH_MULT` | 1,25 (últimos 30 s) |

## 5. Surge

| Constante | Valor 🎯 |
|---|---|
| `SURGE_STEP` | 0,15 |
| `SURGE_MAX_LEVEL` | 6 → multiplicador máx. 1,90 |
| `SEAL_CHAIN_WINDOW` | 8,0 s |
| `BREAK_CHAIN_WINDOW` | 10,0 s |
| `SURGE_DECAY_INTERVAL` | 8,0 s por nível |

## 6. Bônus nomeados

| Bônus | Condição 🎯 | Pontos 🎯 |
|---|---|---|
| Double Seal | 2 Seals na janela | 400 |
| Triple Seal | 3 Seals na janela | 1 000 |
| Claim Streak | 5 Seals sem morrer | 1 500 |
| Break Streak | 2+ Breaks encadeados | 500 por Break extra |
| Risk Bonus | `risk_multiplier ≥ 2,0` | 600 |
| Close Call | inimigo a ≤ 3 células do Arc no último 1,0 s antes do Seal | 400 |
| Mega Seal | Seal ≥ 8 % do mapa | 2 000 |
| Cut | Seal engoliu Arc inimigo | 800 |
| Squeeze | zerou o Claim de um inimigo | 2 000 |

## 7. Modos

| Modo | Duração | Runners | Respawn | Meta | Power-ups |
|---|---|---|---|---|---|
| Classic | 180 s | 6 | ✅ 1,5 s | 60 % encerra | ✅ |
| Time Attack | 90 s + bônus | 4 | ✅ 3,0 s | — | ✅ |
| Survival | ∞ | 3 → 8 | ❌ | — | ✅ |
| Domination | teto 300 s | 4 | ✅ 1,5 s | 50 % | ❌ |
| Endless | ∞ | 6 | ✅ 1,5 s | — | ✅ |

- Time Attack: cada Seal adiciona `2 s + 0,4 s por 1 % capturado` 🎯 (teto de 8 s por Seal).
- Endless: *Reset Pulse* a cada 120 s devolve ao neutro as células mais antigas de quem passar
  de 45 % 🎯, com 5 s de aviso.

## 8. Bots

| Nível | `enemy_awareness` | `reaction_delay_ms` | `error_rate` | `risk_tolerance` | `aggression` |
|---|---|---|---|---|---|
| Rookie | 0,30 (≈ 18 células) | 320 | 0,22 | 0,30 | 0,15 |
| Skilled | 0,55 (≈ 30 células) | 190 | 0,10 | 0,55 | 0,45 |
| Elite | 0,85 (≈ 46 células) | 90 | 0,03 | 0,80 | 0,75 |

Arquétipos aplicam deltas sobre o nível: `Hunter` `aggression +0,25`; `Grazer` `risk −0,20`;
`Warden` `escape_threshold +0,25`; `Baron` `expansion=deep, risk +0,15`. 🎯

Orçamento: no máximo **2 decisões de bot por tick**; ciclo de decisão de 150 ms por bot 🎯.

## 9. Power-ups

| Power-up | Duração 🎯 | Efeito 🎯 |
|---|---|---|
| Bulwark | até absorver, teto 10 s | absorve 1 Break |
| Overdrive | 3,0 s | +45 % velocidade, taxa de giro inalterada |
| Arc Guard | 4,0 s | células do Arc com idade > 1,5 s ficam incortáveis |
| Pulse | 5,0 s | revela Runners e Arcs na borda da tela |
| Amplify | próximo Seal, teto 12 s | +75 % pontos do Seal |
| Drag Field | 6,0 s | raio de 6 células, −35 % velocidade dentro |

Spawn: 1 orbe a cada 18 s 🎯, máximo 3 simultâneos, nunca a menos de 10 células de um Runner.

## 10. Progressão e economia

| Constante | Valor 🎯 |
|---|---|
| `XP = floor(score/30) + 25×breaks + 100 se vitória` | |
| `xp_for_level(n) = round(100 × n^1,35)` | nível 10 ≈ 2 239 XP acumulados |
| `Sparks = clamp(floor(score/60), 0, 500)` | |
| Custo médio de skin | 2 500 Sparks (≈ 8–12 partidas) |
| Desafios diários | 3/dia, 1 reroll, 150–400 Sparks cada |

## 11. Câmera

| Parâmetro | Valor 🎯 |
|---|---|
| `zoom_base` | 1,0 (mostra ≈ 42 × 24 células em 19,5:9) |
| `zoom_range` | 0,75 – 1,35, interpolado pelo % de Claim |
| `follow_smoothing` | 8,0 (lerp exponencial) |
| `lookahead` | 90 u na direção do movimento |
| `punch_seal` | 0,03 · 0,12 s |
| `punch_break` | 0,06 · 0,18 s |
| `shake_max` | 4 u, sempre escalado por `Settings > Reduce shake` |

---

## Como ajustar

1. Mude o `.tres`, não o código.
2. Rode `./tools/dev/simulate.sh 500` e compare com o baseline em
   [`../performance/territory-benchmarks.md`](../performance/territory-benchmarks.md) e com as
   métricas de saúde de bots.
3. Registre o antes/depois numa linha da tabela de histórico no fim deste documento.
4. Se o ajuste alterar uma **regra** (não um número), atualize [`../gameplay/rules.md`](../gameplay/rules.md) primeiro.

### Histórico de balanceamento

| Data | Fase | Mudança | Motivo | Efeito medido |
|---|---|---|---|---|
| 2026-08-24 | GSD 00 | valores iniciais 🎯 | baseline de design | — |
