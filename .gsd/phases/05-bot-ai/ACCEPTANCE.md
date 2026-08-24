# GSD 05 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A05-01 | Partida completa contra 5 bots, do início ao fim | manual |
| A05-02 | Os 4 arquétipos são distinguíveis por quem assiste | teste de legibilidade com 5 pessoas |
| A05-03 | ≥ 70 % identificam corretamente a intenção do `Hunter` | teste de legibilidade |
| A05-04 | Dificuldade muda comportamento, **não** velocidade | inspeção + teste |
| A05-05 | Bots respeitam todas as regras do jogador (Backwash, Overload, morte) | stress test |
| A05-06 | Nenhum bot travado por mais de 3 s | invariante, 500 partidas |
| A05-07 | Nenhuma partida infinita | 500 partidas |
| A05-08 | Distribuição de vitórias entre 8 % e 45 % por arquétipo | relatório |
| A05-09 | IA de 8 bots < 1,2 ms/tick | benchmark B09 |
| A05-10 | 20 bots (teste de escala) dentro do orçamento estendido | benchmark B10 |
| A05-11 | Decisões determinísticas dada a seed | teste, 10 execuções |
| A05-12 | Overlay de intenção funciona em debug e não existe em release | manual + export |
| A05-13 | Perfis são dados; criar arquétipo não exige código | inspeção |
| A05-14 | 500 partidas: 0 crash, 0 invariante violada | `simulate.sh 500` |
| A05-15 | 60 FPS mantidos com 6 Runners no aparelho Mid | dispositivo |

## Teste de diversão (obrigatório)

Três pessoas jogam 3 partidas cada. Perguntas: *"os adversários pareciam inteligentes?"*,
*"você quis jogar de novo?"*. Se a maioria disser que os bots parecem aleatórios, **a fase não
fecha** — é RISK-003 se materializando, e o custo de consertar depois é muito maior.
