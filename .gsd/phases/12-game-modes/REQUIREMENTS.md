# GSD 12 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R12-01 | Os 5 modos existem e são jogáveis do início ao fim | manual + stress |
| R12-02 | Modo é definido por `MatchRulesResource`, sem ramo espalhado | inspeção + `grep` no gate |
| R12-03 | Time Attack: Seal adiciona tempo, com teto por captura | teste |
| R12-04 | Survival: ondas escalam por **composição de bots**, nunca por velocidade | teste + inspeção |
| R12-05 | Domination: primeiro a atingir a meta vence; HUD mostra todos | teste + manual |
| R12-06 | Endless: *Reset Pulse* telegrafado a cada intervalo | teste |
| R12-07 | Os 3 arquétipos novos funcionam e são distinguíveis | teste de legibilidade |
| R12-08 | `Nemesis` marca quem o matou e prioriza esse alvo | teste |
| R12-09 | Cada modo tem leaderboard e critério de recorde próprios | teste |
| R12-10 | Tela de seleção de modo com recorde pessoal e tempo típico | manual |
| R12-11 | Nenhum modo introduz causa de morte nova (R5.7) | revisão |
| R12-12 | Nenhum modo pode gerar partida infinita | stress test |

## Não funcionais

| Requisito | Alvo |
|---|---|
| Trocar de modo não exige recarregar o app | manual |
| Cada modo dentro da janela de duração projetada | 500 partidas |
| 60 FPS em todos os modos, inclusive Survival com 8 Runners | dispositivo |
