# GSD 16 — Requisitos

| # | Requisito | Verificação |
|---|---|---|
| R16-01 | Sem rede, o jogo é 100 % jogável, sem degradação percebida | teste em modo avião |
| R16-02 | Nenhuma chamada de rede bloqueia gameplay | inspeção + teste |
| R16-03 | Escritas entram em fila persistente e nunca duplicam | teste com app morto no meio |
| R16-04 | Retry com backoff exponencial e jitter, no máximo 2 | teste |
| R16-05 | Erro de rede nunca vira popup durante a partida | inspeção |
| R16-06 | Leaderboards nas 6 abas, com sua posição fixada | manual |
| R16-07 | Cloud save sincroniza sem perder progresso local | teste |
| R16-08 | Desafios passam a vir do servidor, com fallback local | teste |
| R16-09 | Remote config aplicado só fora de partida, com fallback embutido | teste |
| R16-10 | Vinculação de conta é opcional e reversível | manual |
| R16-11 | MOCK-001, MOCK-003 e MOCK-004 fechados | `BACKLOG.md` |
| R16-12 | Nenhum segredo real embutido no cliente | inspeção |
