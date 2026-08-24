# GSD 20 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F20-01 | Aparelho específico com bug intratável | 3 | 3 | matriz ampla + nuvem de dispositivos; se necessário, elevar o mínimo suportado (decisão documentada) |
| F20-02 | Acessibilidade tratada como "desligar coisas" | 2 | 3 | requisito é continuar **divertido**; playtest com tudo reduzido |
| F20-03 | Upgrade da engine introduzir regressões | 3 | 4 | avaliação em branch separado; suíte completa + 2 000 partidas antes de decidir; não migrar é uma resposta válida |
| F20-04 | Tablet virar segunda classe | 3 | 2 | layout que reflui, testado em iPad e Android |
| F20-05 | Crash-free abaixo de 99 % no teste fechado | 3 | 4 | crash reporting já ativo desde a GSD 18; bloqueia o marco até resolver |
| F20-06 | Falta de testador com deficiência visual real | 3 | 2 | simulador + checklist; limitação registrada com honestidade no handoff |

## Riscos globais tocados
- **RISK-013** (limitação da engine) é decidido aqui.
- **RISK-004** (performance) é confirmado em campo, não em bancada.
