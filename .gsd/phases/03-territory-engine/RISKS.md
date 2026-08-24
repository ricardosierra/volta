# GSD 03 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F03-01 | **Arc não 4-conectado → flood fill vaza → captura o mapa** (RISK-002) | 3 | 5 | `TERR-003` vem **antes** do solver, com teste de propriedade de 10 000 casos; invariante verificada em todo tick do stress test |
| F03-02 | **Seal lento e o jogo trava em capturas grandes** (RISK-001) | 3 | 5 | benchmarks desde a `TERR-006`; medição em dispositivo real, não em desktop; 6 estratégias de otimização já mapeadas em `territory-benchmarks.md` |
| F03-03 | Caso de borda topológico não previsto (espiral, anel com ilha) | 3 | 4 | 30 casos de mesa incluem os patológicos conhecidos; toda falha do stress test vira caso permanente |
| F03-04 | Bbox insuficiente em Claim côncavo (B13) | 3 | 4 | tratado explicitamente na `TERR-006`; caso de mesa dedicado; benchmark B05 mede o custo |
| F03-05 | Alocação escondida por frame (arrays temporários) | 3 | 3 | B06 verifica 1 000 Seals sem alocação; buffers pré-alocados + epoch |
| F03-06 | Divergência entre o grid e o que é renderizado | 2 | 3 | teste de sincronia grid × textura; `dirty_rect` como único caminho de atualização |
| F03-07 | Fase estourar o prazo por ser grande | 3 | 2 | é a fase com folga deliberada; melhor demorar aqui que pagar em 22 fases |
| F03-08 | Integração antes do solver estar provado | 2 | 4 | ordem das tarefas é normativa: TERR-008 só depois de TERR-006 e TERR-007 verdes |
| F03-09 | Determinismo quebrar em ordem de Seals simultâneos | 2 | 4 | R4.7 fixa a ordem por `runner_id`; teste dedicado |

## Riscos globais tocados

- **RISK-001** e **RISK-002** (score 15) são mitigados aqui — esta é a fase onde eles morrem
  ou contaminam o projeto.
- **RISK-004** (60 FPS): o primeiro subsistema pesado entra no orçamento.
- **RISK-014** (determinismo): reforçado com ordem de resolução e teste de seed.

## Sinal de alerta

Se ao fim da `TERR-006` os 30 casos de mesa não estiverem verdes, **não avance para a
TERR-007**. Investigue. Integrar um solver errado é como construir em cima de fundação torta:
o custo de descobrir depois cresce a cada fase.
