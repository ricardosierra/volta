---
phase: 02-core-movement
plan: 05
subsystem: gameplay
tags: [godot, gdscript, gut, composition-root, fsm, determinism, camera]

# Dependency graph
requires:
  - phase: 02-core-movement (Wave 1: 02-01..02-04)
    provides: "Runner._init com RunnerBalance opcional, ConfigService.runner()/camera() resolvível via Bootstrap, ArenaDefinition.get_pixel_size()+Arena.resolve_boundaries(), InputRouter.poll_direction() com InputBuffer interno, RunnerView extends InterpolatedVisual, GameCamera.setup(balance, arena)"
provides:
  - "MatchDirector.configure(config, arena_definition, router) — injeção de dependência do composition root"
  - "MatchDirector.setup_match() sempre cria um Runner de jogador (id 0, sem BotBrain) antes dos bots"
  - "MatchDirector.step() executa input->movimento->contenção de arena de verdade, sem literal de gameplay"
  - "root.gd como composition root completo da Fase 2: CanvasLayer isolando a UI, ConfigService resolvido do Bootstrap, InputRouter/GameCamera/MatchDirector/RunnerViewSpawner ligados na ordem certa"
  - "Testes de alcançabilidade/determinismo (test_headless_movement.gd), ciclo de FSM real (test_match_lifecycle.gd) e congelamento em Paused (test_pause_freeze.gd)"
affects: [02-06-match-screen-real-simulation, 03-territory-claim-seal]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Composition root único (root.gd) conhece gameplay/ e presentation/ ao mesmo tempo — o resto da árvore nunca importa os dois lados"
    - "CanvasLayer para toda a UI empilhada por ScreenStack, para isolá-la da transformação de uma Camera2D real que agora existe no canvas base"

key-files:
  created:
    - apps/mobile/tests/gameplay/test_headless_movement.gd
    - apps/mobile/tests/integration/test_match_lifecycle.gd
    - apps/mobile/tests/integration/test_pause_freeze.gd
  modified:
    - apps/mobile/src/gameplay/match_director.gd
    - apps/mobile/src/root.gd
    - apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd
    - apps/mobile/tests/integration/test_runner_presentation_wiring.gd

key-decisions:
  - "Player Runner sempre nasce primeiro (id 0), antes dos bots, para runners[0]/player_runner serem sempre o mesmo objeto e para a contagem de runner_spawned virar bot_count+1 de forma previsível"
  - "configure() é opcional e idempotente com defaults seguros (RunnerBalance.new(), Vector2(540,960)) para não quebrar os testes existentes que só chamam setup_match() sem configure()"
  - "UI entra num CanvasLayer próprio; GameCamera, RunnerViewSpawner e MatchDirector ficam fora dele, no canvas base, onde a Camera2D de verdade deve atuar"

requirements-completed: [MOV-01, MOV-02, MOV-07]

# Metrics
duration: 25min
completed: 2026-09-05
---

# Phase 2 Plan 05: Match Director Composition Root Summary

**MatchDirector agora move um Runner de jogador de verdade a 60 Hz via InputRouter/Arena/RunnerBalance, e root.gd virou o composition root completo da fase, com a UI isolada num CanvasLayer da câmera real.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 3
- **Files modified:** 7 (2 arquivos de produção reescritos, 2 testes existentes atualizados, 3 testes novos)

## Accomplishments

- `MatchDirector.step()` deixou de ser só `clock.advance()`: agora aplica `input_router.poll_direction(delta)` no jogador, avança `tick(delta)` em todos os Runners e contém cada um pela `Arena`, na ordem fixa documentada (CMBT-007).
- `setup_match()` cria sempre um Runner de jogador (id 0, sem `BotBrain`), centrado na `Arena` quando configurada — o "loop de brinquedo" de `MatchScreen` (Plano 02-06) agora tem um Runner real de simulação para observar.
- `gameplay/match_director.gd` não instancia mais nenhum `Camera2D` cru — violação de camada eliminada.
- `root.gd` resolve `ConfigService` uma única vez de `Bootstrap.registry`, cria `InputRouter`/`MatchDirector`/`RunnerViewSpawner`/`GameCamera` na ordem que respeita as dependências de cada um, e conecta a `RunnerView` do jogador como alvo da câmera.
- Risco novo descoberto e corrigido: a UI (`ScreenStack`) não tinha `CanvasLayer` próprio — com uma `Camera2D` de verdade agora existindo, ela afetaria a UI inteira. Corrigido movendo `ScreenStack` para dentro de um `CanvasLayer`, que ignora a transformação da câmera do canvas base.
- Três testes novos provam, sem nenhum nó visual: (a) o jogador se move via `InputRouter.poll_direction()`, nunca via `InputEvent`; (b) 600 ticks com a mesma config produzem o mesmo estado final em 10 execuções; (c) a simulação não cria nenhum `Node2D`.
- Dois testes novos de integração provam o ciclo completo da FSM (`Boot→Countdown→Playing→Paused→Playing→Results→Loading`) através do `MatchDirector` real, e que `Paused` congela posição/tick/tempo mesmo chamando `_physics_process` repetidamente.

## Task Commits

1. **Task 1: MatchDirector — Runner do jogador real, step() completo, sem Camera2D cru** - `76e0a8f` (feat)
2. **Task 2: root.gd — composition root completo (config, input, câmera, CanvasLayer)** - `32edf36` (feat)
3. **Task 3: FSM do jogo através do MatchDirector real + Paused congela tudo** - `4d0bca7` (test)

_Nenhuma task teve fase RED/GREEN/REFACTOR separada — os testes novos e as mudanças de produção fecharam juntos por task, conforme o plano especificava o código final diretamente._

## Files Created/Modified

- `apps/mobile/src/gameplay/match_director.gd` - `configure()`, `player_runner`, `arena`, `input_router`; `step()` aplica input→movimento→contenção; `setup_match()` sempre cria o jogador antes dos bots; Camera2D cru removido
- `apps/mobile/src/root.gd` - CanvasLayer para a UI; resolve `ConfigService` do Bootstrap; cria/liga `InputRouter`/`GameCamera`/`MatchDirector`/`RunnerViewSpawner`; libera os quatro ao voltar ao menu
- `apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd` - contagens atualizadas para bot_count+1; assert de que `runners[0] == player_runner`
- `apps/mobile/tests/gameplay/test_headless_movement.gd` - alcançabilidade/determinismo/ausência de nó visual (3 testes)
- `apps/mobile/tests/integration/test_match_lifecycle.gd` - ciclo completo da FSM através do `MatchDirector` real (2 testes)
- `apps/mobile/tests/integration/test_pause_freeze.gd` - congelamento em `Paused` e retomada (2 testes)
- `apps/mobile/tests/integration/test_runner_presentation_wiring.gd` - contagem de `RunnerView`s atualizada para bot_count+1

## Decisions Made

- Player Runner sempre é o primeiro `Runner` criado (id 0), garantindo que `director.runners[0] == director.player_runner` em qualquer configuração de `bot_count`, incluindo zero bots.
- `configure()` tem defaults seguros e é opcional — testes que só chamam `setup_match()` direto (sem `configure()`) continuam funcionando exatamente como antes deste plano, sem duplicar setup de teste.
- `_game_camera`, `_input_router`, `_match_director` e `_runner_view_spawner` ficam fora do `CanvasLayer` da UI, no canvas base de `root` — é isso que garante que a câmera afeta o jogo (Runners/Arena) mas nunca a UI empilhada por `ScreenStack`.

## Deviations from Plan

None - plan executado exatamente como escrito. O próprio plano já previa e descrevia a descoberta do risco do `CanvasLayer` na seção `<objective>`; a Task 2 apenas implementou a correção que o plano já havia especificado por completo.

## Issues Encountered

- `./tools/ci/lint.sh` falha com débito de tipagem estática pré-existente (dezenas de `var` sem tipo e 6 `_init()` sem `-> void`) em arquivos totalmente fora do escopo deste plano (`gameplay/score/*`, `progression/**`, `presentation/**` fora dos tocados aqui, `arena/arena.gd`, `input/input_buffer.gd`, `runner/states/*_state.gd`). Confirmado idêntico em `HEAD` antes deste plano via `git stash` + `lint.sh`. Registrado em `.planning/phases/02-core-movement/deferred-items.md`, não corrigido (Scope Boundary). Os 7 arquivos tocados por este plano passam limpos no lint isoladamente.
- Ordem de execução de tarefas: a Task 1 quebra temporariamente `test_runner_presentation_wiring.gd` (contagem antiga de 3 vs a nova realidade de 4) — esperado e documentado no próprio plano, corrigido pela Task 3. `test-client.sh` só fica 100% verde após as 3 tasks, não task a task; confirmado 112/112 verde ao final.

## User Setup Required

None - nenhuma configuração de serviço externo necessária.

## Next Phase Readiness

- O Plano 02-06 (MatchScreen) pode agora remover o loop de brinquedo (`_update_player`/`_update_bots`/`_resolve_combat`/`_seal_trail`/`_read_direction`/`_input(event)` com `PLAYER_SPEED`/`BOT_SPEED` literais) e mostrar apenas o que `MatchDirector`/`RunnerView`/`GameCamera` já entregam de verdade.
- `check_end_conditions`/`_end_match`/`match_ended` continuam sem chamador — dependem de `TerritoryGrid`/`ScoreService` reais (Fases 3/6), fora de escopo aqui, como o plano determinou.
- `./tools/ci/test-client.sh` (112/112) e `./tools/ci/validate-repo.sh` (10/10) verdes ao final; `./tools/ci/lint.sh` continua com débito pré-existente fora do escopo deste plano, registrado em deferred-items.md.

---
*Phase: 02-core-movement*
*Completed: 2026-09-05*

## Self-Check: PASSED

All 7 modified/created source and test files confirmed present on disk; all 3 task commits
(`76e0a8f`, `32edf36`, `4d0bca7`) confirmed in `git log`.
