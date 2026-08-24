# tests/

Suítes e fixtures que vivem **fora** do projeto Godot.

| Pasta | Conteúdo | Fase |
|---|---|---|
| `unit/`, `integration/`, `gameplay/` | harness e casos que não moram em `apps/mobile/tests` | GSD 01+ |
| `performance/` | baselines de benchmark por dispositivo | GSD 03 |
| `fixtures/saves/` | saves reais de cada versão, para testar migração | a cada bump de schema |
| `qa/` | checklists manuais de release | GSD 23 |

Os testes do cliente ficam em `apps/mobile/tests/` (GUT). Estratégia completa em
[`../docs/testing/testing-strategy.md`](../docs/testing/testing-strategy.md).
