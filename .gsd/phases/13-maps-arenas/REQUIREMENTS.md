# GSD 13 — Requisitos

| # | Requisito | Verificação |
|---|---|---|
| R13-01 | Arena é `ArenaDefinition` (dado), sem código por arena | inspeção |
| R13-02 | Células bloqueadas nunca são capturadas nem entram no percentual (B10) | teste |
| R13-03 | Cercar contra obstáculo interno funciona como contra a borda | teste de mesa |
| R13-04 | `Rift`: o perigo é letal, **telegrafado** e é a única exceção de R5.7 | teste + revisão |
| R13-05 | Spawns por arena respeitam distância e espaço | teste, 1 000 spawns |
| R13-06 | Bots navegam obstáculos sem travar | stress test |
| R13-07 | Nenhuma arena permite estratégia degenerada (canto inexpugnável) | stress + playtest |
| R13-08 | Cada arena tem identidade visual dentro do tema ativo | manual |
| R13-09 | Seleção de arena disponível (ou pool por modo) | manual |
| R13-10 | Percentual de território correto com células bloqueadas | teste |

## Não funcionais
Benchmark de Seal por arena dentro do orçamento · 60 FPS em todas · carregamento < 1 s.
