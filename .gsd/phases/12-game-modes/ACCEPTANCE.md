# GSD 12 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A12-01 | Os 5 modos jogáveis do início ao fim | manual |
| A12-02 | Nenhum `if mode ==` no código | `grep` no gate |
| A12-03 | Time Attack: bônus de tempo com teto, relógio correto | teste |
| A12-04 | Survival: ondas por composição, velocidade constante | teste + inspeção |
| A12-05 | Domination: vitória na meta, HUD com todos | teste + manual |
| A12-06 | Endless: Reset Pulse telegrafado, sem Squeeze acidental | teste |
| A12-07 | Endless: 30 min sem queda de FPS nem vazamento | dispositivo |
| A12-08 | 7 arquétipos distinguíveis | teste de legibilidade |
| A12-09 | `Nemesis` persegue quem o matou | teste |
| A12-10 | Leaderboard e recorde por modo | teste |
| A12-11 | Nenhuma causa de morte nova | revisão |
| A12-12 | 2 500 partidas: 0 crash, 0 invariante, 0 partida infinita | relatório |
| A12-13 | Duração de cada modo dentro da janela projetada | relatório |
| A12-14 | 60 FPS em todos os modos, inclusive Survival com 8 Runners | dispositivo |
