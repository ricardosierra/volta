# Quality Gate — verificação da Fase 26.1

**Execução:** 2026-09-01 · **Commit:** `b6b711e` · **Branch:** `master`

Registro da saída real dos verificadores ao fim da Fase 26.1. A saída abaixo está colada
literalmente do terminal — não é paráfrase nem resumo.

## 1. validate-repo.sh — as 10 regras do CLAUDE.md §3

Código de saída: **0**

```text
== 1. Estrutura obrigatória ==
OK: estrutura completa
== 2. Fases GSD com os 7 documentos ==
OK: 26 fases com 7 documentos cada
== 3. Nomes de arquivo proibidos ==
OK: nenhum arquivo-depósito
== 4. TODO com referência de tarefa ==
OK: todo TODO tem referência de tarefa
== 5. Mocks com fase de substituição ==
OK: todo mock tem fase de substituição
== 6. Placeholders rastreados ==
OK: placeholders rastreados
== 7. Regra de camadas (simulação não conhece apresentação) ==
OK: camadas respeitadas
== 8. Tamanho de arquivo ==
OK: nenhum arquivo acima de 600 linhas
OK: nenhuma função acima de 50 linhas
== 9. Links de documentação ==
OK: links de documentação
== 10. Sincronia packages/shared/config <-> apps/mobile/resources/config ==
OK: config sincronizada

✅ validate-repo: tudo certo.
```

## 2. test-client.sh — suíte GUT

Código de saída: **0**

```text
Asserts             133
Orphans               8
Time              0.517s


[32m---- All tests passed! ----
[0m
WARNING: 28 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
ERROR: 6 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:822)
✅ test-client: todos os testes GUT passaram.
```

## 3. lint.sh — tipagem estática

Código de saída: **1** — dívida pré-existente, ver ressalva abaixo.

| Momento | Violações |
|---|---|
| Antes da Fase 26.1 (commit `38e59e7`) | 234 |
| Depois da Fase 26.1 | 171 |

As 171 restantes estão em arquivos de `input/`, `runner/states/`, `presentation/` e
`progression/` que esta fase não tocou. São dívida de tipagem herdada das fases 2 a 9.
Os dois arquivos que a fase tocou e ainda apareciam no lint (`match_director.gd` e
`root.gd`) foram tipados no commit `b6b711e`.

## O que corrigiu cada regra

| Regra | Estava | Plano | Como foi corrigida |
|---|---|---|---|
| 4 — TODO com referência | Falso positivo em `TODOS OS ADVERSÁRIOS` | 05 | Limite de palavra à direita no regex, com prova negativa |
| 6 — Placeholder rastreado | `Replacement: GSD 08` na linha seguinte | 05 | Marcador e replacement na mesma linha |
| 7 — Camadas | `match_director.gd:55` fazia `load("res://src/presentation/...")` | 01 | Inversão de dependência: sinal `runner_spawned`, `RunnerViewSpawner` escuta |
| 8 — Tamanho | `match_screen.gd` 867 linhas; 5 funções > 50 | 02, 03 | `SealSolver.solve()` decomposto em 5 funções; `MatchHudBuilder` e `MatchFieldRenderer` extraídos |
| 10 — Config em sincronia | 17 arquivos só no app | 04 | Promovidos para `packages/shared/config/`, byte a byte |

## O que este relatório NÃO afirma

O gate verde significa **apenas** conformidade com as 10 regras estruturais do
`CLAUDE.md` §3. Ele **não** significa nenhuma das coisas abaixo:

- **Não** significa que o jogo funciona. A auditoria de 2026-08-31
  (`.planning/audit/`) mostrou que `bootstrap.gd` registra 6 de 32 serviços, que o sinal
  `match_ended` não tem ouvintes e que `SealSolver` não tem chamador — a captura de
  território, mecânica central do jogo, continua desligada. Esta fase corrigiu a
  **conformidade**, não a **religação**.
- **Não** significa que as fases 2 a 25 estão concluídas. Elas foram reabertas no
  `ROADMAP.md` e continuam desmarcadas.
- **Não** houve teste em aparelho físico. O gate F01-07 segue aberto (`adb devices`
  vazio); `docs/performance/device-results.md` continua sem medição real.
- **Não** significa que o `lint.sh` passa. Passou de 234 para 171 violações; não zerou.
- A CI ainda roda `simulate.gd`, que imprime aprovação sem instanciar partida
  (`.github/workflows/godot-ci.yml:15`). Corrigir isso é trabalho de uma fase de religação.
