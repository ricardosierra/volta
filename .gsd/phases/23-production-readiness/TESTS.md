# GSD 23 — Testes

## Automatizado
Suíte completa + 5 000 partidas (todos os modos × todas as arenas) + benchmarks + testes da API.

## Migração de save
Fixtures de todas as versões de teste → migração encadeada → corrompido → versão futura → vazio.

## Crash e recuperação
Kill forçado em 10 momentos, verificando integridade do progresso em cada um.

## QA manual
`tests/qa/release_checklist.md` executado em Android e iOS, cobrindo:
todos os modos · todas as arenas · todas as telas · todas as settings · progressão · cosméticos ·
online · offline · interrupções do sistema · rotação bloqueada · bateria.

## Operação
Rollback nas duas lojas · desativação por remote config · backup e restauração da API.
