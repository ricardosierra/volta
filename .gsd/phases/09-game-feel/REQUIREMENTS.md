# GSD 09 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R09-01 | Toda ação da tabela de `game-feel.md` responde nos 7 canais | checklist por ação |
| R09-02 | Intensidade proporcional ao tamanho do evento (contínua, não discreta) | manual + inspeção |
| R09-03 | Nenhum efeito bloqueia o controle, nem por 1 frame | teste de input durante efeitos |
| R09-04 | Screen shake só em Break e Mega Seal, escalado por configuração | inspeção |
| R09-05 | Música adaptativa entra e sai por crossfade sincronizado ao compasso | manual |
| R09-06 | Háptico segue a tabela e respeita Off/Light/Full | manual em Android e iOS |
| R09-07 | SFX com 3–4 variações e limite de vozes simultâneas | inspeção + manual |
| R09-08 | Áudio pausa e retoma sem estalo | teste |
| R09-09 | `Reduce shake`, `Reduce flashes` e `Haptics off` funcionam de verdade | teste de acessibilidade |
| R09-10 | Com todas as reduções ativas, o jogo continua legível e divertido | playtest |
| R09-11 | Tudo instanciado em partida vem de pool | inspeção + profiler |
| R09-12 | Transições e curvas conforme a tabela de tempos | inspeção |

## Não funcionais

| # | Requisito | Alvo |
|---|---|---|
| N09-01 | VFX (CPU) | < 0,7 ms/frame |
| N09-02 | VFX (GPU) | < 2,0 ms/frame |
| N09-03 | Áudio | < 0,5 ms/frame, ≤ 16 vozes |
| N09-04 | Latência evento → som | < 60 ms |
| N09-05 | Memória de áudio | ≤ 12 MB |
| N09-06 | Zero alocação durante efeitos (pool) | profiler |
