# Benchmarks do sistema de território

> O território é o subsistema com maior risco de virar gargalo. Ele é medido desde a primeira
> linha, não depois que "ficou lento". Executados por `tools/benchmarks/territory_bench.gd`,
> em dispositivo real e em CI (desktop, com baseline próprio).

## Suíte

| # | Benchmark | O que mede | Orçamento 🎯 |
|---|---|---|---|
| B01 | `seal_small` | 100 Seals de ~1 % em 128×128 | p95 < 0,4 ms |
| B02 | `seal_medium` | 100 Seals de ~5 % | p95 < 0,8 ms |
| B03 | `seal_large` | 100 Seals de ~20 % | p95 < 2,0 ms |
| B04 | `seal_worst_case` | Arc atravessando o mapa inteiro | máx < 4,0 ms |
| B05 | `seal_concave` | Claim côncavo abraçando área fora da bbox do Arc | p95 < 1,5 ms |
| B06 | `seal_1000` | 1 000 Seals sequenciais | 0 alocação, tempo estável (sem tendência de alta) |
| B07 | `arc_marking` | 100 000 marcações de célula | < 0,4 µs por célula |
| B08 | `collision_queries` | 8 Runners × 10 000 ticks | < 0,02 ms por tick |
| B09 | `bots_10` | partida completa com 10 bots | tick p95 < 3,0 ms |
| B10 | `bots_20` | 20 bots (acima do máximo de produção) | tick p95 < 6,0 ms — teste de escala |
| B11 | `arena_large` | grid 256×256 | Seal p95 < 3,0 ms |
| B12 | `rapid_updates` | 60 Seals por segundo por 10 s | sem hitch > 8 ms |
| B13 | `max_arc` | Arc no comprimento máximo + Seal | máx < 4,0 ms |
| B14 | `texture_update` | atualização da textura de Claim por `dirty_rect` | p95 < 0,5 ms |
| B15 | `memory_stability` | 500 partidas headless | crescimento de RSS ≈ 0 |

## Formato do resultado

```json
{
  "device": "Pixel 6a", "os": "Android 14", "build": "0.3.0-dev", "commit": "abc1234",
  "godot": "4.3.stable", "date": "2026-09-01",
  "results": {
    "seal_medium": {"p50_us": 210, "p95_us": 640, "max_us": 1120, "allocs": 0},
    "seal_worst_case": {"max_us": 3180, "allocs": 0}
  }
}
```

Resultados aceitos viram baseline em `tests/baselines/territory/<device>.json`.
**Regressão > 10 % reprova o CI.**

## Registro de execuções

| Data | Fase | Dispositivo | Destaque | Ação |
|---|---|---|---|---|
| — | — | — | *(primeira execução em GSD 03)* | — |

## Estratégias já previstas se algum orçamento estourar

Em ordem de preferência (aplicar a mais simples que resolver):

1. **Reduzir a região de busca** — bbox mais justa, aproveitando o histórico do Arc.
2. **Flood fill por scanline** em vez de célula a célula (menos empilhamento, mais cache-friendly).
3. **Cache de "alcança a borda"** por região, invalidado por `dirty_rect`.
4. **Amortizar o Seal** em dois ticks para capturas gigantes, com a animação cobrindo o atraso
   (a simulação continua consistente porque o Arc permanece como barreira até o fim).
5. **Chunks** (64×64) com contagem por chunk — só se algum dia existir arena > 512².
6. **GDExtension em C++** apenas para o `SealSolver` — último recurso, com o custo de build
   multiplataforma que isso traz. Registrado como ADR futuro, não como plano.

Nenhuma dessas é implementada preventivamente. Otimização sem medição é dívida disfarçada
de zelo.
