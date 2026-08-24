# GSD 17 — Requisitos

| # | Requisito | Verificação |
|---|---|---|
| R17-01 | Servidor roda o **mesmo** código de simulação do cliente | inspeção |
| R17-02 | Cliente envia apenas input; servidor tem autoridade total | inspeção + teste |
| R17-03 | Território nunca é predito; Seal só com confirmação | teste |
| R17-04 | Predição local do próprio Runner com reconciliação suave | teste + manual |
| R17-05 | Outros Runners interpolados com buffer de ~100 ms | manual |
| R17-06 | Jogável com 120 ms de RTT | teste com latência simulada |
| R17-07 | Aviso ao jogador acima de 250 ms | manual |
| R17-08 | Reconexão em até 30 s, com piloto automático defensivo | teste |
| R17-09 | Input implausível descartado no servidor | teste |
| R17-10 | Matchmaking por modo e faixa, com bots preenchendo após espera curta | teste |
| R17-11 | Uma instância headless por partida, encerrada ao fim | teste de carga |
| R17-12 | **Nenhum `Node` do Godot replicado pela rede** | inspeção |

## Não funcionais

| Requisito | Alvo |
|---|---|
| Banda por cliente | < 12 KB/s |
| Snapshot delta | ≤ 15 Hz |
| Input | ≤ 20 Hz |
| Instâncias simultâneas por vCPU | ≥ 4 partidas de 6 Runners |
| Divergência cliente↔servidor no território | **zero** |
