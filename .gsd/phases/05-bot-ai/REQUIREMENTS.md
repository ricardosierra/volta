# GSD 05 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R05-01 | Bots usam a mesma simulação e a mesma velocidade base do jogador (R8.1) | inspeção + teste |
| R05-02 | Bots só enxergam dentro do raio de percepção do perfil (R8.2) | teste |
| R05-03 | Decisão por utilidade: 8 ações pontuadas, a maior vence | teste unitário |
| R05-04 | Perfil de bot é `Resource`, sem lógica em código | inspeção |
| R05-05 | 4 arquétipos com comportamento distinguível | teste de legibilidade |
| R05-06 | 3 níveis de dificuldade por percepção, reação e erro | teste + stress |
| R05-07 | Atraso de reação e taxa de erro aplicados | teste unitário |
| R05-08 | Bot nunca fica travado por mais de 3 s | invariante no stress test |
| R05-09 | Bot avalia rota de retorno antes de arriscar (anti-suicídio) | teste |
| R05-10 | Máximo de 2 decisões de bot por tick, escalonadas | profiler + teste |
| R05-11 | Overlay de debug mostra ação escolhida, score e segunda colocada | manual |
| R05-12 | Se todos os bots ficarem passivos, a pressão de expansão aumenta | teste |
| R05-13 | Bots respeitam Backwash, Overload e todas as regras do jogador | stress test |
| R05-14 | Decisões são determinísticas dada a seed | teste, 10 execuções |

## Não funcionais

| # | Requisito | Alvo |
|---|---|---|
| N05-01 | IA de 8 bots | < 1,2 ms/tick |
| N05-02 | Nenhuma busca de caminho global por frame | inspeção |
| N05-03 | Zero alocação por decisão | profiler |
| N05-04 | Distribuição de vitórias por arquétipo entre 8 % e 45 % | 500 partidas |
| N05-05 | Duração média de partida dentro da janela do modo | 500 partidas |
| N05-06 | ≥ 70 % dos jogadores identificam corretamente a intenção de um `Hunter` | playtest |
