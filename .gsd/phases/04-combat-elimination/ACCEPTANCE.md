# GSD 04 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A04-01 | Cortar o Arc de um inimigo o elimina | teste + manual |
| A04-02 | O território do eliminado vira neutro (não vai para o matador) | teste |
| A04-03 | Pisar no próprio Arc dá Backwash, nunca morte | teste |
| A04-04 | Após Backwash o Runner continua vulnerável | teste dedicado |
| A04-05 | Bater na borda enquanto desenha dá Backwash com deflexão | teste + manual |
| A04-06 | Dentro do Claim, a borda só desliza | teste |
| A04-07 | Morte mútua elimina os dois sem crédito | teste |
| A04-08 | Squeeze funciona e credita quem selou | teste |
| A04-09 | Respawn acontece em local válido, com invulnerabilidade | teste + 1 000 respawns |
| A04-10 | Invulnerabilidade cai ao sair do Claim | teste |
| A04-11 | Seal e morte no mesmo tick: Seal resolve primeiro | teste |
| A04-12 | Nenhuma causa de morte fora da lista fechada (R5.7) | revisão de código + grep |
| A04-13 | Aviso periférico de ameaça funciona | manual |
| A04-14 | Colisões de 8 Runners < 0,02 ms/tick | benchmark B08 |
| A04-15 | 500 partidas: 0 crash, 0 invariante violada | `simulate.sh 500` |
| A04-16 | Nenhuma `Area2D` usada para colisão de Arc | inspeção |

## Teste de sensação (obrigatório)

Três pessoas jogam contra Runners de script agressivos por 3 minutos. Para cada morte,
perguntar: *"você sabe por que morreu?"*. **Menos de 90 % de respostas corretas reprova a
fase** — é o Pilar 1 sendo medido, não opinado.
