---
phase: 02-core-movement
plan: 01
subsystem: gameplay
tags: [gdscript, godot, config, runner, stat-block, bootstrap, service-registry]

# Dependency graph
requires:
  - phase: 01-repository-foundation
    provides: ConfigService/ConfigValidator/RunnerBalance already implemented and tested (test_config_service.gd), Bootstrap/ServiceRegistry pattern
provides:
  - StatBlock e Runner sem nenhum literal de gameplay (base_speed/base_turn_rate vem sempre de RunnerBalance)
  - Bootstrap._default_steps() registra "config" (ConfigService ja carregado) como primeiro passo de boot
  - ConfigService alcancavel via Bootstrap.registry.resolve("config") no jogo real
affects: [02-05-match-director-composition-root]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Factory de boot com mais de uma instrucao vira metodo privado nomeado (_make_config_service), nunca lambda multilinha inline dentro de dict aninhado em array literal — GDScript 4.7 nao faz o parse disso"

key-files:
  created:
    - apps/mobile/tests/unit/test_stat_block.gd
    - apps/mobile/tests/unit/test_runner_movement.gd
  modified:
    - apps/mobile/src/runner/stat_block.gd
    - apps/mobile/src/runner/runner.gd
    - apps/mobile/src/core/bootstrap.gd
    - apps/mobile/tests/integration/test_bootstrap.gd

key-decisions:
  - "StatBlock._init(balance: RunnerBalance = null) usa RunnerBalance.new() como fallback em vez de duplicar 220.0/540.0 numa segunda constante"
  - "Runner._init ganha balance: RunnerBalance = null com default null de proposito — o unico chamador real (match_director.gd:50) so sera atualizado no Plano 02-05"
  - "Passo 'config' entra como PRIMEIRO item de _default_steps(), antes de 'log', por nao depender de nada e outros passos poderem precisar dele no futuro"
  - "Fabrica multi-instrucao do passo 'config' extraida para _make_config_service() em vez de lambda multilinha inline: lambda com mais de uma instrucao dentro de dict aninhado em array literal quebra o parser do GDScript 4.7 (Unindent doesn't match the previous indentation level), confirmado com --check-only"

patterns-established:
  - "Boot step factories: uma linha via lambda quando trivial, metodo privado nomeado quando precisa de mais de uma instrucao"

requirements-completed: [MOV-02]

# Metrics
duration: ~15min
completed: 2026-09-05
---

# Phase 02 Plan 01: Runner Stat Block Config Summary

**StatBlock/Runner leem velocidade e taxa de giro de RunnerBalance (220.0/540.0) em vez de literais 300.0/180.0, e Bootstrap agora registra um ConfigService carregado como serviço "config".**

## Performance

- **Duration:** ~15min
- **Completed:** 2026-09-05T18:58:00Z
- **Tasks:** 2/2 completed
- **Files modified:** 4 (2 created, 4 modified — stat_block.gd, runner.gd, bootstrap.gd, test_bootstrap.gd; +2 novos arquivos de teste)

## Accomplishments

- `StatBlock` não tem mais nenhum literal de gameplay: `base_speed`/`base_turn_rate` vêm sempre de um `RunnerBalance` (customizado ou `RunnerBalance.new()`), fechando a lacuna MOVE-003 apontada pela auditoria de 2026-09-02.
- `Runner.new(id, pos, dir, balance)` propaga o `RunnerBalance` para `StatBlock`, mantendo compatibilidade retroativa (`balance` default `null`) com o único chamador real hoje (`match_director.gd:50`), que será atualizado no Plano 02-05.
- `Bootstrap._default_steps()` ganhou o passo `"config"` (primeiro da lista), registrando um `ConfigService` já com `load_all()` executado — agora resolvível via `Bootstrap.registry.resolve("config")` a partir do jogo real, não só em teste isolado.

## Task Commits

Each task was committed atomically:

1. **Task 1: StatBlock e Runner passam a ler RunnerBalance (fim do literal 300.0/180.0)** - `6075141` (feat)
2. **Task 2: Bootstrap registra o serviço "config" (ConfigService carregado)** - `e67ea2e` (feat)

**Plan metadata:** (this commit) `docs(02-01): complete runner-stat-block-config plan`

## Files Created/Modified

- `apps/mobile/src/runner/stat_block.gd` - `_init(balance: RunnerBalance = null)` lê `base_speed`/`turn_rate` do balance; removidos os literais 300.0/180.0
- `apps/mobile/src/runner/runner.gd` - `_init` ganha parâmetro `balance: RunnerBalance = null`, propagado para `StatBlock.new(balance)`
- `apps/mobile/tests/unit/test_stat_block.gd` (novo) - 5 testes: defaults vêm do balance, override customizado, modificadores de velocidade/giro empilham e removem sem resíduo, piso em zero
- `apps/mobile/tests/unit/test_runner_movement.gd` (novo) - 4 testes: velocidade/giro vêm do balance, movimento em linha reta na velocidade base, virada de 180° leva exatamente `180/turn_rate` segundos (20 ticks a 60 Hz, nem 19 nem 21), Runner eliminado não se move
- `apps/mobile/src/core/bootstrap.gd` - passo `"config"` adicionado como primeiro de `_default_steps()`; fábrica extraída para `_make_config_service()` (nomeada, não lambda multilinha)
- `apps/mobile/tests/integration/test_bootstrap.gd` - novo teste `test_default_steps_register_a_loaded_config_service`, provando `registry.has("config")` e `runner().base_speed == 220.0`

## Decisions Made

- `StatBlock` usa `RunnerBalance.new()` como fallback em vez de reintroduzir um segundo literal — a fonte única de verdade continua sendo `RunnerBalance` (`core/config/runner_balance.gd`).
- `Runner._init` mantém `balance` com default `null` de propósito: o chamador real (`match_director.gd:50`) não foi tocado neste plano (fora de escopo — pertence ao Plano 02-05, que ainda não rodou nesta wave).
- Passo `"config"` entra como **primeiro** item de `_default_steps()`, antes de `"log"`, por não depender de nenhum outro serviço.
- Fábrica do passo `"config"` extraída para um método privado nomeado (`_make_config_service()`) em vez de lambda multilinha inline dentro do dicionário do array de steps — ver Deviations abaixo.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Lambda multilinha do plano quebra o parser do GDScript 4.7**

- **Found during:** Task 2 (Bootstrap registra "config")
- **Issue:** O texto literal do plano especificava a fábrica do passo `"config"` como uma lambda de 3 instruções (`var svc := ...`, `svc.load_all()`, `return svc`) escrita inline dentro do dicionário `{"name": "config", "factory": func() -> Object: ... }`, por sua vez dentro do array literal retornado por `_default_steps()`. Ao rodar `godot --check-only` nesse arquivo, o parser reportou `Parse Error: Unindent doesn't match the previous indentation level` na linha de fechamento do dicionário — uma lambda com bloco de mais de uma instrução aninhada dessa forma (dict dentro de array) não é suportada pelo parser de indentação do GDScript 4.7, mesmo com tabs consistentes.
- **Fix:** Extraído o corpo da lambda para um método privado nomeado `_make_config_service() -> Object`, chamado por uma lambda de uma linha (`func() -> Object: return _make_config_service()`), mantendo o mesmo padrão de uma linha por passo usado por todos os outros 7 factories de `_default_steps()`. Comportamento idêntico ao pretendido pelo plano: `ConfigService.new()` seguido de `load_all()`, nunca retorna `null`.
- **Files modified:** `apps/mobile/src/core/bootstrap.gd`
- **Verification:** `godot --check-only --script res://src/core/bootstrap.gd` deixou de reportar erro de parse (o único erro remanescente, "Identifier not found: Log", é esperado — autoloads não carregam em modo `--script` isolado); `./tools/ci/test-client.sh` e a suíte completa de `test_bootstrap.gd` (4/4) passam com o serviço `"config"` resolvendo para um `ConfigService` com `runner().base_speed == 220.0`.
- **Committed in:** `e67ea2e` (Task 2 commit)

**2. [Rule 1 - Bug] Sinal do ângulo de virada de 180° na asserção "ainda não completa"**

- **Found during:** Task 1 (StatBlock/Runner leem RunnerBalance) — teste novo `test_runner_movement.gd`
- **Issue:** O texto literal do plano para `test_180_degree_turn_takes_exactly_180_over_turn_rate_seconds` usava `assert_gt(runner.state.direction.angle_to(Vector2.DOWN), deg_to_rad(1.0), ...)` um tick antes da virada completar. UP→DOWN é uma virada de exatamente 180°, um caso-limite ambíguo: `Math::rotate_toward` do Godot resolve a ambiguidade de sinal sempre girando no sentido negativo (`wrapf(PI, -PI, PI) == -PI`), então o ângulo restante um tick antes de completar é **negativo** (-9°), não positivo — a asserção original comparava um valor negativo contra um limiar positivo e falhava (`-0.157 > 0.017` é falso).
- **Fix:** Trocado para `assert_gt(absf(runner.state.direction.angle_to(Vector2.DOWN)), deg_to_rad(1.0), ...)`, provando a **magnitude** do ângulo restante (o que a asserção realmente pretende verificar — "a virada ainda não terminou"), não o sinal, que é um detalhe de implementação de `rotate_toward` para o caso-limite de 180°. A asserção final (`assert_almost_eq(..., 0.0, 0.001)`, provando que a virada completou exatamente no tick previsto) não foi afetada e já passava.
- **Files modified:** `apps/mobile/tests/unit/test_runner_movement.gd`
- **Verification:** `test_180_degree_turn_takes_exactly_180_over_turn_rate_seconds` passa; os outros 3 testes do mesmo arquivo (velocidade/giro vêm do balance, movimento reto, runner eliminado não se move) continuam passando.
- **Committed in:** `6075141` (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking — Rule 3, 1 bug de teste — Rule 1)
**Impact on plan:** Ambos os ajustes foram necessários para o plano compilar/passar exatamente como especificado em comportamento; nenhuma mudança de escopo, nenhum comportamento de `StatBlock`/`Runner`/`Bootstrap` alterado além do que o plano pedia.

## Issues Encountered

- `./tools/ci/test-client.sh` roda a suíte GUT inteira do repositório, incluindo arquivos de outros 4 planos executando em paralelo na mesma árvore de trabalho (mesmo índice git, working tree compartilhada). Durante a execução, `test_state_machine.gd` falhou transitoriamente por causa de trabalho não commitado de um plano irmão (`game_state.gd`/`input_router.gd`/`swipe_driver.gd` modificados, mas não meus) — confirmado por `git status --short` mostrando esses arquivos como `M`/`??` fora do escopo deste plano. Não foi tocado; ao rodar a suíte de novo mais tarde (depois que o plano irmão avançou), essa falha já não aparecia.
- `test_build.gd::test_version_matches_project_settings` continua falhando (`project.godot` tem `config/version="0.1.2"`, o teste espera `"0.1.0"`) — falha pré-existente e sem nenhuma relação com `apps/mobile/src/runner/` ou `apps/mobile/src/core/bootstrap.gd`. Já estava registrada em `.planning/phases/02-core-movement/deferred-items.md` pelo Plano 02-03 antes deste plano rodar; não duplicada, não corrigida aqui (fora de escopo — decisão de versionamento, não bug de Runner/Bootstrap).
- Excluindo essa única falha pré-existente e fora de escopo, `./tools/ci/test-client.sh` sai verde (85/86 testes passando, a única falha sendo a de versão) e `./tools/ci/validate-repo.sh` sai 100% verde (as 10 regras).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `ConfigService` está alcançável via `Bootstrap.registry.resolve("config")` no boot real do jogo, desbloqueando o Plano 02-05 (MatchDirector/composition root), que precisa buscar `RunnerBalance`/`CameraBalance` sem inventar um segundo mecanismo de acesso a config.
- `Runner.new(id, pos, dir, balance)` já aceita o `RunnerBalance` real; o Plano 02-05 só precisa trocar a chamada em `match_director.gd:50` para passar o balance resolvido do `ConfigService`, sem qualquer mudança adicional em `runner.gd`/`stat_block.gd`.
- Nenhum bloqueio identificado para os planos seguintes desta fase (02-02 a 02-07).

## Self-Check: PASSED

All files created/modified verified present on disk (stat_block.gd, runner.gd, test_stat_block.gd,
test_runner_movement.gd, bootstrap.gd, test_bootstrap.gd, this SUMMARY.md). Both task commits
(`6075141`, `e67ea2e`) verified present in `git log --oneline --all`.

---
*Phase: 02-core-movement*
*Completed: 2026-09-05*
