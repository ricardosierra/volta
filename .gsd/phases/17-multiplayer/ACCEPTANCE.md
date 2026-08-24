# GSD 17 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A17-01 | Partida com 4+ jogadores reais roda ponta a ponta | teste manual |
| A17-02 | Servidor usa o mesmo código de simulação | inspeção + teste de seed |
| A17-03 | Território **nunca** diverge entre cliente e servidor | teste com checksum de grid |
| A17-04 | Jogável com 120 ms de RTT | teste com latência simulada |
| A17-05 | Reconexão em até 30 s restaura o estado | teste |
| A17-06 | Input inválido descartado sem afetar a partida | teste |
| A17-07 | Banda < 12 KB/s por cliente | medição |
| A17-08 | ≥ 4 partidas de 6 Runners por vCPU | teste de carga |
| A17-09 | Nenhum `Node` replicado pela rede | inspeção |
| A17-10 | Relatório de viabilidade com recomendação explícita | documento |

## Critério de sucesso da fase

O sucesso é **saber**, com números, se o multiplayer é viável nesta arquitetura — e não
"ter multiplayer". Um relatório honesto dizendo "não vale a pena assim" é um resultado válido
e valioso, desde que fundamentado.
