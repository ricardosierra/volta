# Plano de analytics

> **Regra de ouro:** o gameplay nunca chama um SDK. Ele emite eventos numa interface própria
> (`AnalyticsService`), e um adapter decide o destino. Ver [`ADR-0010`](../decisions/ADR-0010-analytics-abstraction.md).

## O que queremos responder

1. O jogador entende o jogo sozinho? → tempo até o primeiro Seal, taxa de conclusão do onboarding.
2. O loop prende? → partidas por sessão, taxa de restart imediato.
3. Onde as pessoas param? → funil de sessão, ponto de abandono.
4. O balanceamento está certo? → distribuição de território final, vitórias por arquétipo de bot.
5. A performance é aceitável no mundo real? → FPS p50/p10 por modelo, tempo de boot.
6. Alguém está frustrado? → mortes por causa, mortes nos primeiros 15 s.

## Eventos (v1)

| Evento | Propriedades | Fase |
|---|---|---|
| `app_started` | cold_start_ms, device_tier, os, refresh_rate | 18 |
| `game_started` | mode, arena, bot_count, difficulty, control_scheme | 06 |
| `game_finished` | mode, duration_s, claim_pct, breaks, deaths, score, placement, end_reason | 06 |
| `territory_captured` | seal_cells, seal_pct, arc_len, risk_mult, surge | 03 |
| `player_eliminated` | cause (`arc_cut`\|`wall`\|`timeout`), killer_type, alive_s, claim_pct | 04 |
| `enemy_eliminated` | victim_archetype, surge_after | 04 |
| `tutorial_step` | step_id, elapsed_s, completed | 07 |
| `tutorial_completed` | total_s, retries | 07 |
| `skin_selected` | item_id, item_type, source | 11 |
| `challenge_completed` | challenge_id, reward | 10 |
| `store_viewed` / `purchase_started` / `purchase_completed` | sku, price_local, currency | 25 |
| `settings_changed` | key, value | 07 |
| `perf_sample` | fps_p50, fps_p10, mem_mb, quality_preset, mode | 18/19 |

## Convenções

- `snake_case` para nomes de evento e de propriedade. Sem espaço, sem acento.
- Todo evento carrega automaticamente: `session_id`, `app_version`, `schema_version`,
  `device_tier`, `locale`. O gameplay não passa nada disso à mão.
- Nomes são **imutáveis** depois de publicados. Mudou o significado? Novo nome + versão.
- Nenhum evento por frame. Amostragem de performance a cada 15 s, agregada.

## Privacidade

- Zero PII. Sem e-mail, sem contatos, sem localização precisa, sem ID de publicidade no v1.
- ID de jogador é um UUID gerado localmente, rotacionável pelo próprio jogador em
  `Settings > Privacy > Reset analytics ID`.
- Opt-out real em `Settings > Privacy`, que **desliga o envio**, não só esconde o botão.
- Coleta declarada no Data Safety (Play) e Privacy Nutrition Label (App Store) — GSD 21/22.

## Implementação por fase

| Fase | Entrega |
|---|---|
| GSD 06 | `AnalyticsService` (interface) + `NoopAnalytics` + eventos de partida emitidos |
| GSD 10 | eventos de progressão |
| GSD 18 | `LocalFileAnalytics` (debug), `RemoteAnalytics` (API própria), crash reporting, dashboards |
| GSD 19 | `perf_sample` alimentando o orçamento de performance |
