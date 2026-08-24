# GSD 24 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F24-01 | Bug crítico só aparecer em escala | 3 | 5 | rollout gradual com 24 h por degrau; rollback ensaiado; remote config para desligar feature sem build |
| F24-02 | Rejeição de última hora na revisão | 2 | 3 | checklists cumpridas; teste interno e TestFlight já validados |
| F24-03 | Servidor não aguentar o pico | 2 | 4 | rollout gradual dá tempo de escalar; monitoramento e alertas ativos |
| F24-04 | Avaliações negativas por bug pontual | 3 | 3 | resposta rápida a avaliações; hotfix `patch` pronto para sair |
| F24-05 | Métrica ruim de retenção | 3 | 3 | não é bloqueador de lançamento; alimenta a GSD 25 com dados reais |
| F24-06 | Pressa em ir a 100 % | 3 | 4 | regra de 24 h por degrau é rígida; degrau só avança com métrica saudável |
