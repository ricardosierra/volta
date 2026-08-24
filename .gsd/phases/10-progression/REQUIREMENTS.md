# GSD 10 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R10-01 | XP calculado conforme `balance.md` §10 | teste unitário |
| R10-02 | **Toda** partida dá XP, inclusive derrota | teste |
| R10-03 | Curva de rank sem nível máximo; primeiro nível sobe na 1ª partida | teste |
| R10-04 | Recompensa a cada nível; cosmético a cada 5; título a cada 10 | teste |
| R10-05 | 15+ estatísticas rastreadas e persistidas | teste |
| R10-06 | Conquistas nas 3 famílias, com progresso parcial visível | teste |
| R10-07 | 3 desafios diários + 3 semanais, com 1 reroll gratuito | teste |
| R10-08 | Desafios gerados por seed diária determinística (mesmos para o jogador o dia todo) | teste |
| R10-09 | Nenhum desafio exige comportamento antidivertido | revisão do pool |
| R10-10 | Todo desafio é cumprível em ≤ 4 partidas por jogador mediano | simulação |
| R10-11 | Sparks conforme a fórmula, com teto por partida | teste |
| R10-12 | Progresso sobrevive a fechar o app a qualquer momento | teste |
| R10-13 | Nada de progressão altera a simulação | revisão + teste |
| R10-14 | Eventos de analytics de progressão emitidos | teste |

## Não funcionais

| # | Requisito | Alvo |
|---|---|---|
| N10-01 | Cálculo de fim de partida | < 5 ms |
| N10-02 | Tela de perfil carrega | < 200 ms |
| N10-03 | Save cresce de forma controlada | < 100 KB com tudo desbloqueado |
| N10-04 | Todas as fontes de dado atrás de `*Repository` | inspeção |
