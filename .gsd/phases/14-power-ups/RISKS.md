# GSD 14 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F14-01 | Power-up decidir partidas e ferir o Pilar 5 | 3 | 4 | métricas de saúde objetivas (< 15 %); duração curta; contra-jogo obrigatório por design |
| F14-02 | `Bulwark` virar passe livre para arco suicida | 3 | 3 | duração curta, não protege contra Squeeze, e o escudo é visível para o adversário |
| F14-03 | Efeito deixar resíduo no `StatBlock` | 2 | 4 | teste de 1 000 ciclos; resolução em ponto único |
| F14-04 | IA ignorar power-ups e virar desvantagem sistemática | 3 | 3 | ação `collect_powerup` + reação a efeitos inimigos; distribuição de vitórias monitorada |
| F14-05 | Poluição visual com muitos efeitos ativos | 2 | 3 | um efeito por Runner por vez; auras discretas; auditoria de legibilidade |
| F14-06 | Gate da Alpha ser "quase" e passar assim mesmo | 3 | 4 | checklist binária; item não marcado impede o fechamento do marco |
