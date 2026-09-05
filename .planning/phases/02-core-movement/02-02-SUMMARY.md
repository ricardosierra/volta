---
phase: 02-core-movement
plan: 02
subsystem: gameplay
tags: [fsm, state-machine, arena, gut-tests, gdscript]

# Dependency graph
requires:
  - phase: 01-foundation
    provides: GUT test framework instalado, StateMachine/State genéricos em core/fsm/
provides:
  - "game_state.gd com as 11 transições da tabela de docs/architecture/state-machines.md §2, incluindo Boot->Loading"
  - "ArenaDefinition com width_cells/height_cells/cell_size + get_pixel_size(), consumido por Arena._init sem quebrar em runtime"
  - "open_field.tres alinhado a docs/design/balance.md §1 (128x128 células de 16 unidades = 2048x2048)"
  - "cobertura de teste para StateMachine genérica, GameState e Arena/ArenaDefinition (18 testes novos)"
affects: [02-05-match-director-composition-root]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Teste de Node que depende de get_tree() (via State com _init(tree)) usa add_child_autofree() no lugar de chamar _ready() manualmente fora da árvore"
    - "assert() de transição inválida em StateMachine.request vira erro de engine capturado pelo GUT — consumido com assert_engine_error_count (contagem cumulativa por chamada, não incremental)"

key-files:
  created:
    - apps/mobile/tests/unit/test_state_machine.gd
    - apps/mobile/tests/unit/test_game_state.gd
    - apps/mobile/tests/unit/test_arena.gd
  modified:
    - apps/mobile/src/gameplay/game_state.gd
    - apps/mobile/src/arena/arena_definition.gd
    - apps/mobile/resources/arenas/open_field.tres

key-decisions:
  - "GameState._init(null) + add_child_autofree(gs) no teste, não gs._ready() direto: PausedState.new(get_tree()) precisa de árvore real, senão o engine reclama 'Parameter data.tree is null' e o GUT marca a suíte como falha"
  - "assert_engine_error_count no teste de 5 transições inválidas é chamado UMA vez após o loop inteiro, com o total (5), porque cada chamada de assert_engine_error_count soma todos os erros do tipo já vistos (não só os novos) — chamar dentro do loop a cada iteração acumula e falha a partir da segunda"

patterns-established:
  - "Dimensão de arena vem de dado (width_cells/height_cells/cell_size com defaults de balance.md), nunca hardcoded em Arena; ArenaDefinition sem esses campos usa os defaults sem quebrar"

requirements-completed: [MOV-07, MOV-02]

# Metrics
duration: 20min
completed: 2026-09-05
---

# Phase 02 Plan 02: FSM Arena Foundation Summary

**game_state.gd ganha a transição Boot->Loading que faltava (11/11 da tabela), ArenaDefinition ganha get_pixel_size() que Arena.gd já chamava sem existir (bug de runtime real), e open_field.tres foi corrigido de 100x100@32 com campo órfão para 128x128@16 (2048x2048) conforme balance.md — 18 testes novos cobrindo os dois.**

## Performance

- **Duration:** ~20 min
- **Tasks:** 2
- **Files modified:** 3 (game_state.gd, arena_definition.gd, open_field.tres)
- **Files created:** 3 (test_state_machine.gd, test_game_state.gd, test_arena.gd)

## Accomplishments
- `game_state.gd` cobre as 11 transições documentadas em `docs/architecture/state-machines.md` §2 (faltava `Boot -> Loading`, o caminho de "primeira execução, vai direto pra partida")
- `StateMachine` genérica provada por teste: transição válida muda estado e emite `state_changed`; transição inválida é rejeitada sem travar o processo (grita no console via `assert`/`push_error`, mas continua)
- `ArenaDefinition` deixou de ser uma classe que quebra em runtime: `Arena._init()` já chamava `def.get_pixel_size()`, método que não existia — agora existe, com `width_cells`/`height_cells`/`cell_size` (defaults 128/128/16.0 de `docs/design/balance.md` §1)
- `open_field.tres` corrigido para 128×128 células de 16 unidades (2048×2048), campo órfão `blocked_cells` removido, `uid://cc0q2` preservado
- As 4 arenas reais da Fase 13 (`archipelago`, `crossroads`, `halo`, `rift`) confirmadas intocadas (`git diff` vazio nos 4 caminhos) e continuam carregando corretamente com os novos defaults de dimensão

## Task Commits

Each task was committed atomically:

1. **Task 1: FSM do jogo — transição Boot->Loading + cobertura de teste completa** - `43186da` (feat)
2. **Task 2: ArenaDefinition ganha get_pixel_size(); corrige open_field.tres** - `90f2258` (feat)

**Plan metadata:** (this commit) - `docs: complete plan`

## Files Created/Modified
- `apps/mobile/src/gameplay/game_state.gd` - adiciona `fsm.add_transition(Id.BOOT, Id.LOADING)`, completando as 11 transições
- `apps/mobile/tests/unit/test_state_machine.gd` - 3 testes: transição válida com sinal, transição inválida rejeitada sem sinal, primeira transição a partir de estado não inicializado
- `apps/mobile/tests/unit/test_game_state.gd` - 4 testes: Boot->Loading, caminho normal de 7 transições via Menu, Playing->Results->Loading, 5 pares inválidos rejeitados
- `apps/mobile/src/arena/arena_definition.gd` - adiciona `width_cells`/`height_cells`/`cell_size` (default 128/128/16.0) e `get_pixel_size()`
- `apps/mobile/resources/arenas/open_field.tres` - reescrito: `width_cells=128`, `height_cells=128`, `cell_size=16.0`, campo órfão `blocked_cells` removido, `id`/`name` adicionados, `uid` preservado
- `apps/mobile/tests/unit/test_arena.gd` - 6 testes: pixel_size do open_field, validade, `Arena.limits` batendo com a definição, as 4 arenas da Fase 13 carregando com os defaults, contenção em velocidade máxima, deslize na borda sem zerar velocidade tangencial

## Decisions Made
- `GameState._init(null)` + `add_child_autofree(gs)` no lugar de chamar `gs._ready()` fora da árvore: `PausedState.new(get_tree())` precisa de uma árvore real — sem isso o engine reclama "Parameter data.tree is null" e o GUT falha a suíte. `add_child_autofree` entra o nó na árvore de teste do GUT, o que dispara `_ready()` automaticamente.
- Consumo de erro de engine (`assert_engine_error_count`) no teste de 5 transições inválidas é feito UMA vez, depois do loop inteiro, com o total (5) — `_assert_error_count` do GUT soma **todos** os erros do tipo já vistos a cada chamada (não só os novos desde a última), então chamar dentro do loop por iteração acumula e falha a partir da segunda iteração.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `gs._ready()` fora da árvore quebrava com "Parameter data.tree is null"**
- **Found during:** Task 1, primeira rodada de `./tools/ci/test-client.sh`
- **Issue:** O texto do plano instruía `var gs := GameState.new(null); gs._ready(); return gs` — mas `GameState._ready()` monta `PausedState.new(get_tree())`, e `get_tree()` num `Node` que nunca entrou na árvore de cena causa um erro de engine ("Parameter data.tree is null") que o GUT captura como "Unexpected Errors" e reprova o teste, mesmo sem crash real.
- **Fix:** `_fresh_game_state()` passou a usar `add_child_autofree(gs)` (helper do GUT que entra o nó na árvore de teste e libera no fim), deixando `_ready()` disparar automaticamente pelo ciclo de vida do `Node`, com uma árvore real disponível para `get_tree()`.
- **Files modified:** `apps/mobile/tests/unit/test_game_state.gd`
- **Commit:** `43186da` (parte do commit da Task 1, nenhum commit extra)

**2. [Rule 3 - Blocking] `assert(false, msg)` de transição inválida reprovava os próprios testes que provam a rejeição**
- **Found during:** Task 1, segunda rodada de `./tools/ci/test-client.sh`
- **Issue:** `StateMachine.request()` já existente faz `assert(false, msg)` em debug build para transição inválida (comportamento correto, não mudado). O GUT trata isso como um "erro de engine" e reprova qualquer teste que o dispare sem consumi-lo explicitamente — o que aconteceria em `test_invalid_transition_is_rejected_and_state_unchanged` e em `test_at_least_five_invalid_transitions_are_rejected`, justamente os testes que provam "rejeita sem travar".
- **Fix:** Adicionado `assert_engine_error_count(...)` para consumir o(s) erro(s) esperado(s) — 1 chamada por teste em `test_state_machine.gd`, e 1 chamada única após o loop inteiro (com o total de casos) em `test_game_state.gd`, porque a contagem do GUT é cumulativa por chamada, não incremental.
- **Files modified:** `apps/mobile/tests/unit/test_state_machine.gd`, `apps/mobile/tests/unit/test_game_state.gd`
- **Commit:** `43186da` (parte do commit da Task 1, nenhum commit extra)

---

**Total deviations:** 2 auto-fixed (ambas Rule 3 - blocking, na própria escrita dos testes exigidos pela Task 1)
**Impact on plan:** Nenhum impacto na Task 2. Ambas as correções foram necessárias só para os testes novos da Task 1 rodarem e provarem exatamente o comportamento que o plano pedia (rejeição sem travar); nenhuma mudança de comportamento em `game_state.gd`, `state_machine.gd` ou `state.gd` além da linha de transição já planejada.

## Issues Encountered
- `test_build.gd::test_version_matches_project_settings` falha (`Build.version()` retorna `"0.1.2"`, teste espera `"0.1.0"`) — pré-existente, sem relação com `game_state.gd`/`arena_definition.gd`/arenas, já registrado em `deferred-items.md` desta fase pelo Plano 02-03 (que rodou em paralelo). Não corrigido aqui por estar fora do escopo (decisão de versionamento, não bug de FSM/Arena).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `game_state.gd` e `ArenaDefinition`/`open_field.tres` prontos para o Plano 02-05 (MatchDirector/composition root), que depende deste plano.
- `./tools/ci/validate-repo.sh` verde (10/10 regras). `./tools/ci/test-client.sh`: 85/86 testes verdes — a única falha é o `test_build.gd` pré-existente e fora de escopo, já rastreado.
- Nenhum bloqueio novo introduzido por este plano.

---
*Phase: 02-core-movement*
*Completed: 2026-09-05*

## Self-Check: PASSED

All created/modified files confirmed on disk; both task commits (`43186da`, `90f2258`) confirmed in git log.
