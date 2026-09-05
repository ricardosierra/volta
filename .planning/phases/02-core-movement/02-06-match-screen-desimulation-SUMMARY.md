---
phase: 02-core-movement
plan: 06
subsystem: ui
tags: [godot, gdscript, gut, screen-stack, hud, safe-area]

# Dependency graph
requires:
  - phase: 02-core-movement (Wave 2: 02-05)
    provides: "MatchDirector.configure(config, arena_definition, router) com player_runner real, step() executando input->movimento->contenção de arena a 60 Hz; root.gd como composition root completo (CanvasLayer da UI, ConfigService, InputRouter/GameCamera/MatchDirector/RunnerViewSpawner ligados)"
provides:
  - "MatchScreen sem simulação própria — lê MatchDirector.game_state/time_elapsed/runners e não trata nenhum InputEvent"
  - "PauseScreen e ResultsScreen com UI real (rótulo + botões), ResultsScreen agora extends Screen (empilhável)"
  - "SettingsControls como Screen empilhável, ligada ao InputRouter real (driver_changed -> set_driver)"
  - "MatchHudBuilder reduzido a dado real (rivais/tempo) + 3 botões de ação; overlay de resultado removido"
  - "MatchFieldRenderer reduzido à moldura estática do campo (Runners vêm de RunnerView real)"
  - "root.gd liga match_screen.set_match_director()/set_input_router() após setup_match()"
  - "Bug pré-existente corrigido: _hud_header_top()/_safe_bottom_inset() agora implementados via DisplayServer.get_display_safe_area()"
affects: [02-07-phase-closure, 03-territory-claim-seal]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Safe area de tela cheia lida em runtime via DisplayServer.get_display_safe_area()/window_get_size(), mesmo padrão de ui/components/safe_area_container.gd, com fallback 0.0 headless/editor"
    - "Navegação de partida via ScreenStack real: PAUSAR empilha PauseScreen (congela SceneTree), DESISTIR desempilha e empilha ResultsScreen, CONTROLES empilha SettingsControls ligada ao InputRouter ao vivo"

key-files:
  created:
    - apps/mobile/tests/integration/test_pause_and_results_screens.gd
    - apps/mobile/tests/integration/test_match_screen_wiring.gd
  modified:
    - apps/mobile/src/ui/screens/pause_screen.gd
    - apps/mobile/src/ui/screens/results_screen.gd
    - apps/mobile/src/ui/screens/match_hud_builder.gd
    - apps/mobile/src/ui/screens/settings_controls.gd
    - apps/mobile/src/ui/screens/match_screen.gd
    - apps/mobile/src/ui/screens/match_field_renderer.gd
    - apps/mobile/src/root.gd
    - apps/mobile/tests/unit/test_match_hud_builder.gd
    - apps/mobile/tests/integration/test_match_field_renderer.gd
    - .gsd/BACKLOG.md

key-decisions:
  - "Fase 2 não tem restart real (MTC-04 é Fase 6) — os dois botões de ResultsScreen (JOGAR NOVAMENTE e VOLTAR AO MENU) levam ao mesmo lugar (menu), registrado como BL-021"
  - "PausedState da FSM (gameplay/states/paused_state.gd) e SceneTree.paused em PauseScreen são redundantes de propósito: um cobre o jogo real, o outro cobre testes headless que chamam _physics_process sem SceneTree"
  - "test-client.sh só fica 100% verde após as 3 tasks juntas, não task a task — match_hud_builder.gd (Task 2) removeu build_result_overlay() que match_screen.gd (Task 3) ainda chamava; mesmo padrão documentado no Plano 02-05. Cada task foi commitada com seu próprio pathspec de arquivos, mas a verificação completa (test-client/validate-repo/lint) só rodou depois que as edições de Task 2 e Task 3 já estavam as duas na árvore de trabalho"

requirements-completed: [MOV-01, MOV-02, MOV-03]

# Metrics
duration: 35min
completed: 2026-09-05
---

# Phase 2 Plan 06: Match Screen De-simulation Summary

**MatchScreen parou de rodar sua própria simulação de brinquedo (588 linhas de _update_player/_update_bots/_resolve_combat/_seal_trail com PLAYER_SPEED/BOT_SPEED hardcoded) e passou a mostrar de verdade o MatchDirector/RunnerView reais, com PAUSAR/CONTROLES/DESISTIR navegando por telas empilháveis reais.**

## Performance

- **Duration:** ~35 min
- **Tasks:** 3
- **Files modified:** 10 (7 produção, 3 teste atualizados/novos), 2 arquivos de teste novos

## Accomplishments

- `MatchScreen` caiu de 588 para 198 linhas: removidos `PLAYER_SPEED`/`BOT_SPEED`/`PLAYER_RADIUS`/`BOT_RADIUS`/`WIN_TERRITORY_PERCENT`, `_update_player`, `_update_bots`, `_resolve_combat`, `_seal_trail`, `_eliminate_bot`, `_check_win`, `_finish_match`, `_read_direction`, `_input(event)`, `_set_gesture_direction`, `_direction_for_key`, `_polyline_hits_circle`, `_distance_to_segment` e todo o estado de bots/trilha/claim que a tela mantinha por conta própria. Nenhum `InputEvent` chega mais perto de um Runner pela tela.
- `set_match_director(director)`/`set_input_router(router)` guardam as referências reais; `_process(delta)` lê `director.game_state.current_state()` para o countdown e `director.time_elapsed`/`director.runners.size()` para o HUD — o que aparece na tela é exatamente o que `MatchDirector` simula.
- Bug pré-existente corrigido: `_hud_header_top()`/`_safe_bottom_inset()` eram chamados por `MatchScreen` sem nunca terem sido definidos em lugar nenhum (achado da Fase 26.1, registrado como fora de escopo até este plano) — GDScript só falha nisso em runtime, nunca no parse. Agora implementados com `DisplayServer.get_display_safe_area()`, mesmo padrão de `ui/components/safe_area_container.gd`, com fallback `0.0` headless/editor.
- `PauseScreen` e `ResultsScreen` (stubs vazios da Fase 7, com sinais nunca emitidos) ganharam rótulo + botões reais. `ResultsScreen` passou a `extends Screen` (era `Control`) — sem isso `ScreenStack.push()` recusaria o tipo estaticamente. `PauseScreen` roda com `PROCESS_MODE_ALWAYS` para que os próprios botões da pausa continuem clicáveis com a árvore congelada.
- `SettingsControls` passou de `Control` solto (nunca empilhado por ninguém) para `Screen` empilhável, com botão "Fechar" emitindo o `exit_requested` já herdado — ligada ao `InputRouter` real via `driver_changed -> router.set_driver`, tornando a troca de esquema um test drive ao vivo sobre a partida em andamento.
- `MatchHudBuilder` perdeu `territory_label`/`kills_label`/`territory_bar` (não há território/combate nesta fase) e as 4 funções do overlay de resultado (`build_result_overlay`, `_build_result_shell`, `_build_result_content`, `make_result_label`) — o fim de partida agora é `ResultsScreen`. `_build_actions()` ganhou os 3 botões reais (PAUSAR/CONTROLES/VOLTAR AO MENU).
- `MatchFieldRenderer` caiu de desenhar campo+bots+claim+trilha+jogador para só desenhar a moldura estática (fundo, campo, cantos, rodapé) — os Runners reais já são desenhados pelas `RunnerView`s (Plano 02-04/02-05) sob a `GameCamera` real.
- `root.gd` liga `match_screen.set_match_director(_match_director)`/`set_input_router(_input_router)` logo após `setup_match()`, fechando o composition root da fase.
- 3 linhas novas em `.gsd/BACKLOG.md` (BL-019/020/021) registrando o que a tela perdeu temporariamente: trilha/captura visual (Fase 3), feedback de eliminação/combate (Fase 4), placar real e restart sem menu (Fase 6).

## Task Commits

1. **Task 1: PauseScreen e ResultsScreen ganham UI real e emitem os sinais que já declaravam** - `0c8e5cf` (feat)
2. **Task 2: MatchHudBuilder perde território/kills/overlay de resultado; SettingsControls vira Screen empilhável** - `ed71555` (feat)
3. **Task 3: MatchScreen para de simular; MatchFieldRenderer reduzido; root.gd liga tudo; BACKLOG.md atualizado** - `95588e4` (feat)

_Nenhuma task teve fase RED/GREEN/REFACTOR separada — o próprio plano especificava o código final diretamente por task._

## Files Created/Modified

- `apps/mobile/src/ui/screens/pause_screen.gd` - rótulo "PAUSADO" + botões CONTINUAR/DESISTIR reais, `PROCESS_MODE_ALWAYS`
- `apps/mobile/src/ui/screens/results_screen.gd` - `extends Screen`, rótulo "PARTIDA ENCERRADA" + detalhe + botões JOGAR NOVAMENTE/VOLTAR AO MENU, sinal `menu_requested` novo
- `apps/mobile/src/ui/screens/match_hud_builder.gd` - `_build_top_bar` só com rivais/tempo, `_build_status_row` sem barra de território, `_build_actions` com 3 botões; `build_result_overlay`/`_build_result_shell`/`_build_result_content`/`make_result_label` removidas
- `apps/mobile/src/ui/screens/settings_controls.gd` - `extends Screen`, `on_pushed`/`handle_back_button`, botão "Fechar" emitindo `exit_requested`
- `apps/mobile/src/ui/screens/match_screen.gd` - reescrito por inteiro (588 -> 198 linhas): sem simulação própria, `_hud_header_top`/`_safe_bottom_inset` implementados, navegação real Pause/Settings/Results
- `apps/mobile/src/ui/screens/match_field_renderer.gd` - `draw()` só chama `_draw_background`/`_draw_field`/`_draw_footer`; funções de bots/claim/trilha/runners removidas
- `apps/mobile/src/root.gd` - `match_screen.set_match_director(_match_director)`/`set_input_router(_input_router)` após `setup_match()`
- `apps/mobile/tests/integration/test_pause_and_results_screens.gd` - 5 testes novos (pausa/retoma, 2 sinais de PauseScreen, back_button, os 2 sinais de ResultsScreen)
- `apps/mobile/tests/integration/test_match_screen_wiring.gd` - 3 testes novos (ausência do loop de brinquedo por inspeção de source, `on_pushed()` não crasha, rótulo de rivais reflete `MatchDirector` real)
- `apps/mobile/tests/unit/test_match_hud_builder.gd` - atualizado para o novo conjunto de elementos (sem território/kills/overlay)
- `apps/mobile/tests/integration/test_match_field_renderer.gd` - atualizado: `state` só carrega `size`/`field`
- `.gsd/BACKLOG.md` - BL-019 (trilha/captura visual, destino Fase 3), BL-020 (feedback de eliminação/combate, destino Fase 4), BL-021 (placar real + restart sem menu, destino Fase 6)

## Decisions Made

- Os dois botões de `ResultsScreen` (JOGAR NOVAMENTE e VOLTAR AO MENU) levam ao mesmo lugar nesta fase — Fase 2 não implementa restart real (MTC-04 é Fase 6), registrado como BL-021 em vez de fingir um restart que reseta apenas visualmente.
- `PauseScreen.on_pushed()` continua chamando `get_tree().paused = true` (redundante com `GameState.PausedState` da FSM) de propósito: uma camada cobre o jogo real rodando com `SceneTree`, a outra cobre testes headless que chamam `_physics_process` diretamente sem árvore.
- `MatchFieldRenderer` não ganhou nenhuma lógica nova de desenho de Runner — a decisão de "Runners vêm de RunnerView real" já estava fechada pelo Plano 02-04/02-05; este plano só removeu o desenho paralelo que a tela fazia por cima.

## Deviations from Plan

**1. [Rule 3 - Blocking] `test_pause_and_results_screens.gd` não compilava com `:=` em `add_child_autofree(...)`**
- **Found during:** Task 1, primeira rodada de `./tools/ci/test-client.sh`
- **Issue:** `var pause := add_child_autofree(PauseScreen.new())` falha com "Cannot infer the type of 'pause' variable because the value doesn't have a set type" — `add_child_autofree()` do GUT devolve um tipo que a inferência `:=` não resolve. O texto do plano usava `:=` nesses 5 lugares.
- **Fix:** trocado para tipagem explícita (`var pause: PauseScreen = add_child_autofree(...)`, `var results: ResultsScreen = add_child_autofree(...)`), mesmo padrão já usado em `test_pause_freeze.gd`/`test_match_lifecycle.gd`/`test_headless_movement.gd` (todos com `var director: MatchDirector = add_child_autofree(...)`).
- **Files modified:** apps/mobile/tests/integration/test_pause_and_results_screens.gd
- **Verification:** `./tools/ci/test-client.sh` — 117/117 após o ajuste (era 112 antes, +5 novos).
- **Committed in:** `0c8e5cf` (Task 1 commit)

**2. [Ordem de execução entre tasks, não um bug] Task 2 quebra temporariamente a compilação de `match_screen.gd`**
- **Found during:** transição Task 2 -> Task 3
- **Issue:** `match_hud_builder.gd` (Task 2) remove `build_result_overlay()`, mas `match_screen.gd` (só reescrito na Task 3) ainda chamava essa função em `_build_result_overlay()` — se rodado isoladamente entre as duas tasks, `./tools/ci/test-client.sh` falharia por erro de compilação em cascata (toda a suíte, não só os testes de MatchScreen).
- **Ação:** implementei as edições de Task 2 e Task 3 na árvore de trabalho antes de rodar a suíte completa uma única vez (119/119 verde), depois separei os commits pelo pathspec de arquivos de cada task — mesmo padrão já registrado no Plano 02-05 ("test-client.sh só fica 100% verde após as 3 tasks, não task a task"). Nenhum arquivo de outro plano foi tocado; cada commit contém exatamente o `files_modified` da sua task.
- **Files modified:** nenhum além do que o plano já listava para Task 2/3.
- **Verification:** `./tools/ci/test-client.sh` (119/119), `./tools/ci/validate-repo.sh` (10/10) e `./tools/ci/lint.sh` (limpo nos arquivos tocados) rodados após ambas as tasks estarem na árvore, antes de qualquer commit ser criado.
- **Committed in:** `ed71555` (Task 2), `95588e4` (Task 3)

---

**Total deviations:** 2 (1 auto-fix de bloqueio em teste, 1 ajuste de ordem de commit sem mudança de conteúdo)
**Impact on plan:** Nenhum desvio de escopo — os dois ajustes são de execução (tipagem de teste e ordem de verificação/commit), não mudam nenhuma decisão do plano.

## Issues Encountered

- `./tools/ci/lint.sh` continua com o mesmo débito de tipagem estática pré-existente já registrado em `.planning/phases/02-core-movement/deferred-items.md` pelos Planos 02-03/02-05 (`input_buffer.gd`, `runner/states/*_state.gd`, `presentation/**` fora deste plano etc.) — confirmado que nenhum arquivo tocado por este plano aparece na lista de violações; não corrigido por Scope Boundary.

## User Setup Required

None - nenhuma configuração de serviço externo necessária.

## Next Phase Readiness

- O jogo real (via `root.gd` -> `MatchDirector`) agora mostra Runners reais se movendo, com HUD provisório honesto (rivais/tempo) e navegação completa Countdown -> Playing -> Paused -> Playing -> Results -> Menu alcançável por um humano tocando na tela, não só provada por teste headless.
- Falta o Plano 02-07 (fechamento da Fase 2) — inclui o checkpoint humano de verificação visual num aparelho/editor real (PLAY mostra Runners reais, PAUSAR congela, DESISTIR chega a um resultado, CONTROLES troca de esquema ao vivo).
- `./tools/ci/test-client.sh` (119/119) e `./tools/ci/validate-repo.sh` (10/10) verdes ao final; `./tools/ci/lint.sh` continua com débito pré-existente fora do escopo deste plano, já registrado em deferred-items.md por planos anteriores.

---
*Phase: 02-core-movement*
*Completed: 2026-09-05*

## Self-Check: PASSED

All 12 created/modified source and test files confirmed present on disk; all 3 task commits
(`0c8e5cf`, `ed71555`, `95588e4`) confirmed in `git log`.
