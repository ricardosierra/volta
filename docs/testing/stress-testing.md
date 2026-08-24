# Stress testing

> Bots jogando milhares de partidas encontram, em uma noite, o que uma pessoa levaria meses
> para achar. É a ferramenta de QA mais barata que este projeto tem.

## O runner

```bash
./tools/dev/simulate.sh <partidas> [opções]
  --mode      classic|time_attack|survival|domination|endless|all
  --arena     open_field|archipelago|rift|crossroads|halo|all
  --bots      3..8
  --difficulty rookie|skilled|elite|mixed
  --seed      inteiro (padrão: sequencial e reproduzível)
  --speed     multiplicador de tick (headless roda o mais rápido possível)
  --report    caminho do JSON
  --on-fail   stop|continue|dump
```

Roda em Godot headless (`--headless --script`), sem render, sem áudio, com a mesma simulação
do jogo. Paralelizável por processo, um por núcleo.

## O que coletamos

| Métrica | Uso |
|---|---|
| crashes / erros | qualquer um > 0 é bloqueador |
| violações de invariante | qualquer uma > 0 é bloqueador |
| territórios inválidos (soma quebrada) | bloqueador |
| loops infinitos / partidas que não terminam | bloqueador |
| falhas de Seal (fechou e não capturou) | bloqueador |
| duração média e p95 da partida | balanceamento de modo |
| território final médio e distribuição | balanceamento |
| distribuição de vitórias por arquétipo | balanceamento de IA |
| Breaks por partida, mortes por causa | balanceamento de combate |
| Surge máximo alcançado | verifica se o teto é atingível |
| tempo de tick p50/p95/p99 | performance |
| tempo do Seal p95/máximo | performance de território |
| memória ao longo de 100 partidas | vazamento |
| bots travados > 3 s | qualidade de IA |

## Relatório

```json
{
  "runs": 500, "seed_base": 1000, "mode": "classic",
  "crashes": 0, "invariant_violations": 0, "unfinished": 0,
  "match_duration_s": {"p50": 172.4, "p95": 180.0},
  "final_claim_pct": {"p50": 0.28, "p95": 0.52, "max": 0.71},
  "wins_by_archetype": {"grazer": 0.14, "raider": 0.23, "hunter": 0.19, "warden": 0.12, "human_seat": 0.32},
  "tick_us": {"p50": 410, "p95": 980, "p99": 1600},
  "seal_us": {"p50": 210, "p95": 780, "max": 3400},
  "stuck_bots": 0
}
```

Relatórios ficam em `.reports/` (ignorado pelo git); o baseline aceito é versionado em
`tests/baselines/`.

## Gates

| Gate | Critério |
|---|---|
| PR | 20 partidas, 0 crash, 0 invariante violada |
| Merge em `develop` | 200 partidas, idem, + regressão de performance < 10 % |
| Fim de fase | 500 partidas no modo afetado |
| Alpha | 2 000 partidas, todos os modos |
| Beta / Release | 5 000 partidas, todos os modos e arenas, 0 bloqueador |

## Reprodução

Toda falha grava:

```text
.reports/failures/<timestamp>-<seed>/
├── seed.txt              semente e configuração exata
├── grid_state.bin        estado serializado do território no momento da falha
├── events.jsonl          eventos da partida inteira
└── repro.sh              comando pronto para reproduzir
```

Reproduzir é `./repro.sh` — se não for, o relatório de falha está incompleto e isso é um bug
da ferramenta.
