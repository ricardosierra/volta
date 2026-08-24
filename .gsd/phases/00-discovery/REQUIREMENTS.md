# GSD 00 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R00-01 | Visão de produto escrita, com público, diferencial e métrica-norte | `docs/product/vision.md` |
| R00-02 | Pilares de design com critério de decisão aplicável | `docs/product/game-pillars.md` |
| R00-03 | Regras do jogo formalizadas, incluindo estados e casos de borda | `docs/gameplay/rules.md` |
| R00-04 | Todos os números de balanceamento em um único documento | `docs/design/balance.md` |
| R00-05 | Fórmula de score documentada e testável | `docs/design/scoring.md` |
| R00-06 | Sistema de território especificado com algoritmo e orçamento | `docs/architecture/territory-system.md` |
| R00-07 | Arquitetura do cliente com camadas e regra de dependência | `docs/architecture/overview.md` |
| R00-08 | Decisões importantes registradas como ADR | `docs/decisions/` (14 ADRs) |
| R00-09 | Estratégia de testes definida, incluindo stress test | `docs/testing/` |
| R00-10 | Orçamento de performance com alvo por subsistema | `docs/performance/` |
| R00-11 | 26 fases planejadas, com tarefas, aceite, testes e riscos | `.gsd/phases/` |
| R00-12 | Dependências entre fases mapeadas | `.gsd/DEPENDENCIES.md` |
| R00-13 | Quality gates definidos | `.gsd/QUALITY_GATES.md` |
| R00-14 | Riscos com probabilidade, impacto, mitigação e dono | `.gsd/RISKS.md` |
| R00-15 | Backlog com placeholders e mocks já rastreados | `.gsd/BACKLOG.md` |

## Não funcionais

| # | Requisito |
|---|---|
| N00-01 | Um desenvolvedor externo entende o projeto sem falar com o autor |
| N00-02 | Nenhuma fase depende de decisão fundamental não tomada |
| N00-03 | Toda decisão tem alternativas consideradas e consequências registradas |
| N00-04 | Nada no plano copia código, arte, UI ou nomes de terceiros |
| N00-05 | O plano cabe em execução incremental por agente, sem reinterpretação |
