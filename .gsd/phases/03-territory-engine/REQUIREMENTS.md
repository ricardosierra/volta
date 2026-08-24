# GSD 03 — Requisitos

## Funcionais

| # | Requisito | Regra | Verificação |
|---|---|---|---|
| R03-01 | Consulta de dono de célula em O(1) | T1 | benchmark B07 |
| R03-02 | Marcação e limpeza de Arc em O(1) | T2 | benchmark B07 |
| R03-03 | O Arc é sempre 4-conectado | — | teste de propriedade com trajetos aleatórios |
| R03-04 | Sair do Claim inicia o Arc | R2.1 | teste de integração |
| R03-05 | Tocar o próprio Claim com Arc ≥ 2 dispara o Seal | R2.2 | teste de integração |
| R03-06 | O Seal captura exatamente a região cercada | R4.2 | 30 casos de mesa |
| R03-07 | O Seal é resolvido no mesmo tick, sem bloquear o controle | R2.3 | teste + verificação manual |
| R03-08 | Células de inimigos dentro da região são roubadas | R4.3 | teste de mesa |
| R03-09 | O Arc vira Claim ao selar e é limpo | R4.4 | teste |
| R03-10 | Seal sem área interna é válido e não pontua área | R4.8 | teste |
| R03-11 | Claim desconectado é permitido e conta | B03 | teste |
| R03-12 | Buraco neutro dentro do Claim é capturado quando incluído na busca | B04 | teste |
| R03-13 | Cercar contra a borda funciona (borda é barreira) | B01/E03 | teste |
| R03-14 | Claim côncavo maior que a bbox do Arc é tratado | B13 | teste específico |
| R03-15 | Célula bloqueada não é capturada nem entra no percentual | B10 | teste |
| R03-16 | Overload: acima do comprimento máximo a cauda decai, com aviso | E07 | teste + manual |
| R03-17 | O custo do Seal é proporcional à região, não ao mapa | T3 | benchmarks B01–B04 |
| R03-18 | Nenhuma alocação durante um Seal | T6 | benchmark B06 |
| R03-19 | O render atualiza só o `dirty_rect`, em 1 draw call | T7 | inspeção + benchmark B14 |
| R03-20 | O estado do grid é serializável e restaurável | T9 | teste de round-trip |
| R03-21 | Percentual de território é exato e incremental | — | teste + invariante de soma |
| R03-22 | Zoom da câmera acompanha o crescimento do território | — | manual |

## Não funcionais

| # | Requisito | Alvo |
|---|---|---|
| N03-01 | Seal típico (~3 % do mapa) | p95 < 0,8 ms |
| N03-02 | Seal de pior caso (mapa inteiro) | máx < 4,0 ms |
| N03-03 | Marcação de Arc + colisões, 8 Runners | < 0,15 ms/tick |
| N03-04 | Atualização de textura | p95 < 0,5 ms |
| N03-05 | Módulo território, em regime | < 2,0 ms/tick |
| N03-06 | Memória do grid (128×128) | ≤ 32 KB + 128 KB de buffers |
| N03-07 | `SealSolver` é função pura, sem sinal e sem dependência de partida | inspeção |
| N03-08 | Determinismo entre execuções e entre plataformas | teste com seed |
