# GSD 00 — Testes

Fase de planejamento: os "testes" são verificações de consistência do próprio plano.

## Verificações executadas

| # | Verificação | Resultado |
|---|---|---|
| V00-01 | Toda fase tem `README`, `REQUIREMENTS`, `TASKS`, `ACCEPTANCE`, `TESTS`, `RISKS`, `HANDOFF` | ✅ 26/26 |
| V00-02 | Todo link interno de documento aponta para arquivo existente | ✅ `tools/ci/check_links.sh` |
| V00-03 | Toda tarefa tem os 8 campos obrigatórios | ✅ |
| V00-04 | Toda dependência declarada existe como fase | ✅ |
| V00-05 | Todo placeholder e mock tem fase de destino | ✅ `.gsd/BACKLOG.md` |
| V00-06 | Nenhum número de gameplay aparece fora de `balance.md` (nos docs) | ✅ |
| V00-07 | Todo ADR tem as 5 seções obrigatórias | ✅ 14/14 |
| V00-08 | Nenhuma decisão listada como "pendente" bloqueia as fases 01–14 | ✅ |
| V00-09 | Estrutura do repositório bate com a documentada no README | ✅ `tools/ci/validate-repo.sh` |
| V00-10 | CHANGELOG segue o formato Release Notes do projeto | ✅ |

## O que NÃO foi testado (por não existir ainda)

Qualquer coisa que exija código: performance, gameplay, build, dispositivo. Tudo isso começa
a ser testado na GSD 01 e passa a ser exigência de gate a partir da GSD 02.
