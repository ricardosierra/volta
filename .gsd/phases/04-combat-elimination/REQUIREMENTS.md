# GSD 04 — Requisitos

## Funcionais

| # | Requisito | Regra | Verificação |
|---|---|---|---|
| R04-01 | Entrar numa célula de Arc inimigo causa Break naquele inimigo | R5.1 | teste de integração |
| R04-02 | Pisar no próprio Arc **não** mata: dispara Backwash | R5.2/R6.1 | teste |
| R04-03 | Colisão corpo a corpo não mata: aplica repulsão | R5.3 | teste |
| R04-04 | Morte mútua no mesmo tick elimina os dois, sem crédito | R5.4 | teste |
| R04-05 | Ao morrer, o Claim inteiro vira neutro | R5.5 | teste |
| R04-06 | O matador recebe crédito de Break (evento) | R5.6 | teste |
| R04-07 | Backwash apaga o Arc, reinicia na posição atual e aplica penalidade | R6.3 | teste |
| R04-08 | Após Backwash o Runner **continua vulnerável** | R6.4 | teste específico |
| R04-09 | Colisão com borda/obstáculo enquanto desenha dispara Backwash com deflexão | R6.2 | teste |
| R04-10 | Dentro do Claim, a borda apenas desliza | R6.5 | teste |
| R04-11 | Squeeze elimina o Runner com Claim zerado | R4.6 | teste |
| R04-12 | Respawn após atraso, em local válido, com invulnerabilidade | R2.4/E10 | teste |
| R04-13 | Invulnerabilidade cai ao sair do Claim | R2.4 | teste |
| R04-14 | Seal e morte no mesmo tick: Seal primeiro | E08 | teste |
| R04-15 | Dois Runners entram no mesmo Arc no mesmo tick: ambos matam; crédito ao menor id | E05 | teste |
| R04-16 | Aviso periférico quando um inimigo se aproxima do seu Arc | Pilar 1 | manual |
| R04-17 | Lista de causas de morte é **fechada** e verificada | R5.7 | revisão + teste |

## Não funcionais

| # | Requisito | Alvo |
|---|---|---|
| N04-01 | Colisões de 8 Runners | < 0,02 ms/tick |
| N04-02 | Nenhum uso de `Area2D`/física da engine para colisão de Arc | inspeção |
| N04-03 | Toda morte é explicável pelo jogador | teste de sensação |
| N04-04 | Zero alocação no caminho de colisão | profiler |
