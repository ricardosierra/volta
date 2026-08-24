# GSD 03 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A03-01 | Sair do Claim inicia o Arc; voltar captura a região cercada | jogar; teste de integração |
| A03-02 | Os 30 casos de mesa do `SealSolver` passam | `test_seal_solver.gd` |
| A03-03 | O Arc é 4-conectado em 10 000 trajetos aleatórios | teste de propriedade |
| A03-04 | Capturar contra a borda funciona | caso de mesa + manual |
| A03-05 | Roubo de território inimigo funciona e atualiza os dois contadores | caso de mesa |
| A03-06 | Claim desconectado, buraco e Claim côncavo (B13) tratados | 3 casos de mesa |
| A03-07 | Célula bloqueada nunca é capturada nem entra no percentual | caso de mesa |
| A03-08 | O Seal resolve no mesmo tick e **não** bloqueia o controle | teste + manual |
| A03-09 | Overload limita o Arc com aviso prévio | manual + teste |
| A03-10 | Seal típico p95 < 0,8 ms; pior caso < 4,0 ms **em dispositivo real** | B01–B04 |
| A03-11 | Zero alocação durante 1 000 Seals sequenciais | B06 |
| A03-12 | Território renderiza em 1 draw call, com custo independente da área | B14 + monitor |
| A03-13 | A animação de captura roda sem atrasar a simulação | profiler |
| A03-14 | O zoom da câmera acompanha o crescimento sem enjoar | manual, 2 min |
| A03-15 | 500 partidas headless: 0 crash, 0 invariante violada | `simulate.sh 500` |
| A03-16 | Determinismo: mesma seed → mesmo estado final, 10 execuções | teste |
| A03-17 | Serialização do grid faz round-trip exato | teste |
| A03-18 | Orçamento do módulo território < 2,0 ms em regime | overlay em dispositivo |
| A03-19 | `SealSolver` é função pura, sem sinal nem dependência de partida | revisão |
| A03-20 | Nenhum número de território hardcoded | `validate-repo.sh` |

## Critério de saída inegociável

**Zero violação de invariante em 500 partidas.** Se aparecer uma, a fase não fecha — o bug é
investigado, corrigido e vira caso de mesa permanente. Território errado na fase 03 é bug
insolúvel na fase 12.
