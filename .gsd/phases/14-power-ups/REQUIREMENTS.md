# GSD 14 — Requisitos

| # | Requisito | Verificação |
|---|---|---|
| R14-01 | Efeito nunca escreve direto no Runner: só empilha em `StatBlock` | inspeção |
| R14-02 | Todo efeito é reversível e idempotente na expiração | teste |
| R14-03 | Um efeito por vez; novo substitui o ativo | teste |
| R14-04 | Nenhum power-up mata por si só | revisão + teste |
| R14-05 | Todo efeito tem visual inequívoco, visível também pelo adversário | manual |
| R14-06 | Orbe pisca antes de existir e nunca nasce perto de um Runner | teste |
| R14-07 | `Overdrive` aumenta velocidade, **não** taxa de giro | teste |
| R14-08 | `Arc Guard` protege só as células antigas; a ponta continua vulnerável | teste |
| R14-09 | `Amplify` aumenta pontos, nunca área | teste |
| R14-10 | `Drag Field` afeta também quem soltou | teste |
| R14-11 | `Bulwark` não protege contra Squeeze | teste |
| R14-12 | Bots coletam e reagem a power-ups | stress |
| R14-13 | Métricas de saúde dentro do alvo (< 15 % de partidas decididas por power-up) | stress |
| R14-14 | Todos os valores em `.tres` | inspeção |
