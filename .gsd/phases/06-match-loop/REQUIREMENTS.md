# GSD 06 — Requisitos

## Funcionais

| # | Requisito | Regra | Verificação |
|---|---|---|---|
| R06-01 | Countdown de 3 s antes de `Playing`, com input já lido | — | teste + manual |
| R06-02 | Score segue exatamente a fórmula documentada | `scoring.md` | testes por termo |
| R06-03 | Multiplicador de risco calculado no momento do Seal | §1.2 | teste |
| R06-04 | Surge sobe, decai e zera conforme as regras | §2 | teste |
| R06-05 | Os 9 bônus nomeados disparam nas condições certas | §3 | 9 testes |
| R06-06 | Final Push aplica o multiplicador nos últimos 30 s | R7.3 | teste |
| R06-07 | Partida termina por tempo, meta, ou último vivo | R7.1 | 3 testes |
| R06-08 | Ranking por território, com desempate em cascata | R7.2 | teste |
| R06-09 | Tela de resultado mostra colocação, território, score, bônus | — | manual |
| R06-10 | PLAY AGAIN reinicia em um toque, sem passar pelo menu | — | manual |
| R06-11 | Recorde pessoal por modo é persistido | — | teste |
| R06-12 | Eventos de analytics emitidos (`game_started`, `game_finished`, `territory_captured`, `player_eliminated`, `enemy_eliminated`) | `analytics-plan.md` | teste com adapter falso |
| R06-13 | HUD mostra território, posição, tempo, risco e pause — nada mais | `hud.md` | inspeção |
| R06-14 | Abandonar a partida registra derrota mas preserva o ganho | R7.4 | teste |
| R06-15 | Score é determinístico para a mesma sequência de eventos | §5 | teste |
| R06-16 | Score nunca é negativo e todo multiplicador tem teto | §5 | teste de propriedade |

## Não funcionais

| # | Requisito | Alvo |
|---|---|---|
| N06-01 | Results → nova partida | < 0,8 s |
| N06-02 | Cálculo de score por evento | desprezível (< 0,05 ms) |
| N06-03 | 60 FPS estáveis com 6 Runners no Mid | dispositivo |
| N06-04 | Nenhum popup interrompe o controle durante `Playing` | inspeção |
| N06-05 | O ciclo completo funciona headless (para o stress test) | teste |
