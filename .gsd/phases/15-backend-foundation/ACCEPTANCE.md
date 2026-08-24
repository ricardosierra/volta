# GSD 15 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A15-01 | Ambiente sobe com um comando | `api_up.sh` |
| A15-02 | Todas as rotas de `api-design.md` implementadas e testadas | Pest |
| A15-03 | Score sempre recalculado no servidor | teste |
| A15-04 | 8 validações de plausibilidade cobertas | testes de limite |
| A15-05 | Submissão duplicada é idempotente | teste |
| A15-06 | Leaderboards corretos nas 4 janelas, com virada de período | teste |
| A15-07 | Cloud save nunca perde progresso | teste de conflito |
| A15-08 | Desafios diários iguais para todos e resgatáveis uma vez | teste |
| A15-09 | Remote config não aceita chave nova nem valor fora de faixa | teste |
| A15-10 | Rate limit por rota e por jogador | teste |
| A15-11 | Apelido sanitizado, inclusive homóglifos | teste |
| A15-12 | Pint e PHPStan nível 6+ limpos | CI |
| A15-13 | Cobertura ≥ 85 % nas rotas críticas | relatório |
| A15-14 | Migrações reversíveis | teste |
| A15-15 | Backup restaurado com sucesso em ambiente limpo | procedimento |
| A15-16 | Nenhum segredo no repositório | CI |
| A15-17 | p95 < 200 ms; leaderboard < 50 ms | medição |
