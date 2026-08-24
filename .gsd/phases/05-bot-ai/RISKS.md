# GSD 05 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F05-01 | **Bots parecem burros e a experiência offline desaba** (RISK-003) | 3 | 5 | overlay de intenção para diagnosticar; teste de legibilidade com pessoas reais; 500 partidas com métricas objetivas; ajuste é de peso em `.tres`, barato de iterar |
| F05-02 | Ajuste de pesos vira tentativa e erro infinita | 3 | 3 | critério objetivo (distribuição de vitórias 8–45 %) em vez de opinião; simulação de 500 partidas roda em minutos |
| F05-03 | IA estourar o orçamento de CPU | 3 | 4 | escalonamento (máx. 2/tick) desde a `BOTS-007`; sem pathfinding global; benchmarks B09/B10 |
| F05-04 | Bots oscilando entre duas decisões (comportamento errático) | 3 | 3 | histerese + tempo mínimo de compromisso, testados |
| F05-05 | Bots travando em quina ou obstáculo | 3 | 3 | anti-travamento com escalada de resposta; invariante no stress test |
| F05-06 | Aleatoriedade quebrar o determinismo | 2 | 4 | todo RNG derivado da seed da partida; teste de 10 execuções |
| F05-07 | Elite virar frustrante em vez de desafiador | 2 | 4 | `error_rate` nunca zero; teste de diversão; ajuste por dado |
| F05-08 | Bot ter vantagem escondida (ler estado privado) | 2 | 5 | percepção é a única fonte de informação; revisão de código específica na tarefa; R8.1/R8.2 |

## Riscos globais tocados

- **RISK-003** (score 15) morre ou se confirma nesta fase.
- **RISK-005** (não ser divertido): o teste de diversão aqui é o primeiro sinal confiável.
- **RISK-004** (60 FPS): a IA é o segundo maior consumidor de CPU depois do território.
