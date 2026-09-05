---
phase: 02-core-movement
plan: 03
subsystem: input
tags: [godot, gdscript, input, gut, tdd]

# Dependency graph
requires:
  - phase: 02-core-movement (Plano 01)
    provides: RunnerBalance/StatBlock e Bootstrap com passo "config" (não usados diretamente aqui, mas confirmam o padrão de configuração sem literal)
provides:
  - InputRouter com InputBuffer interno no caminho de poll_direction() — única porta de saída de direção, conforme ADR-0014
  - SwipeDriver.mm_to_px() estático e testável sem DisplayServer real
  - Cobertura de teste completa para os 3 esquemas de controle (Swipe, Joystick, Relativo) e para InputBuffer
affects: [02-05-match-director-composition-root]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "InputRouter monta driver+buffer em _init() (não em _ready()), permitindo instanciar e testar fora da SceneTree, mesmo padrão de test_bootstrap.gd"
    - "Conversão física (mm->px) extraída como static func pura, testável sem depender de singletons de engine (DisplayServer)"
    - "Buffer só recebe um comando quando a direção resultante do driver muda de fato em relação à última enfileirada — evita comando fantasma de eventos que não alteram direção (toque inicial, toque solto)"

key-files:
  created:
    - apps/mobile/tests/unit/test_input_router.gd
    - apps/mobile/tests/unit/test_swipe_driver.gd
    - apps/mobile/tests/unit/test_input_buffer.gd
    - apps/mobile/tests/unit/test_joystick_driver.gd
    - apps/mobile/tests/unit/test_relative_driver.gd
  modified:
    - apps/mobile/src/input/input_router.gd
    - apps/mobile/src/input/drivers/swipe_driver.gd

key-decisions:
  - "InputRouter rastreia _last_pushed_direction e só chama buffer.push_command() quando a nova direção difere da última enfileirada (dot <= buffer.similarity_threshold) — sem isso, o toque inicial (diff=0) e o toque solto empurravam a direção 'parada' como se fosse um comando real, that entrava na fila NA FRENTE do comando real do arraste seguinte"
  - "swipe_driver.gd: 'var diff = ...' sem tipo (pré-existente, preservado verbatim pelo texto do plano) tipado para 'var diff: Vector2 = ...' para respeitar a regra 1 de CLAUDE.md (tipagem estática sem exceção), sem mudar nenhum valor/comportamento"
  - "test_swipe_driver.gd::test_direction_updates_continuously_while_dragging corrigido: o segundo ponto de arraste do texto do plano (100,150) assumia diff relativo ao toque original, mas poll() já reancora start_pos após cruzar a zona morta (comportamento de 'joystick contínuo', pré-existente, não mudado) — o segundo ponto foi ajustado para (130,160), consistente com o start_pos já reancorado pelo primeiro poll()"

requirements-completed: [MOV-03, MOV-04]

# Metrics
duration: 30min
completed: 2026-09-05
---

# Phase 02 Plan 03: Input Buffer Router Summary

**InputRouter agora enfileira direção via InputBuffer antes de expô-la a poll_direction(), com SwipeDriver.mm_to_px() extraído como função pura e os 3 esquemas de controle (Swipe/Joystick/Relativo) cobertos por 19 testes GUT novos.**

## Performance

- **Duration:** ~30 min
- **Completed:** 2026-09-05T19:03:13Z
- **Tasks:** 3/3 completed
- **Files modified:** 12 (2 modificados, 10 novos incluindo `.uid`)

## Accomplishments

- `InputRouter` deixou de ser um repasse puro de `driver.poll(delta)`: agora tem um `InputBuffer` interno no caminho, satisfazendo o contrato de ADR-0014 ("input é coletado por evento e consumido no tick, com buffer") — nenhum `InputEvent` chega à simulação além dele.
- `InputRouter` é instanciável e testável fora da `SceneTree` (`_init()` monta `driver`/`buffer`, não depende de `_ready()`), mesmo padrão de `test_bootstrap.gd`.
- `SwipeDriver.mm_to_px(mm, dpi)` extraído como `static func` pura — prova, com teste, que a mesma distância física (3mm) produz pixels diferentes em 160 e 480 DPI, sem depender de `DisplayServer.screen_get_dpi()` real (que pode devolver 0 em headless).
- 19 testes GUT novos em 5 arquivos provam: enfileiramento/ordem/dedup/idade do `InputBuffer` (MOVE-006); paridade de qualidade entre os 3 esquemas de controle — mantém direção ao soltar, ignora abaixo da zona morta, direção contínua durante o arraste (MOVE-007); e o comportamento do `InputRouter` com o buffer no caminho, incluindo troca de driver sem vazamento de estado.

## Task Commits

Each task was committed atomically:

1. **Task 1: InputRouter ganha InputBuffer interno; testável fora da árvore; SwipeDriver com mm→px extraído** - `932ffe7` (feat)
2. **Task 2: Cobertura de InputBuffer (MOVE-006)** - `c25e747` (test)
3. **Task 3: Cobertura de JoystickDriver e RelativeDriver (MOVE-007)** - `e493433` (test)

**Plan metadata:** (este commit, docs: complete plan)

## Files Created/Modified

- `apps/mobile/src/input/input_router.gd` - `_init()` monta driver+buffer; `poll_direction()` envelhece o buffer e consome um comando por chamada antes do driver contínuo; `_unhandled_input()` só enfileira quando a direção muda de fato; `set_driver()` reseta o buffer.
- `apps/mobile/src/input/drivers/swipe_driver.gd` - `mm_to_px()` extraído como `static func`; `_init()` passa a chamá-lo; `process_event`/`poll` mantidos idênticos (só a var `diff` ganhou tipo explícito).
- `apps/mobile/tests/unit/test_input_router.gd` - 4 testes: usabilidade imediata após `.new()`, `_unhandled_input` fora da árvore não quebra, dois comandos distintos consumidos em ordem entre dois `poll_direction()`, `set_driver()` reseta o buffer.
- `apps/mobile/tests/unit/test_swipe_driver.gd` - 4 testes: `mm_to_px` escala com DPI, direção contínua durante o arraste, direção mantida ao soltar, movimento abaixo da zona morta não muda direção.
- `apps/mobile/tests/unit/test_input_buffer.gd` - 6 testes: ordem FIFO, dedup por similaridade (dot > 0.95), descarte por idade (`tick`), sobrevivência dentro da idade, fila vazia sem erro, direção quase nula ignorada.
- `apps/mobile/tests/unit/test_joystick_driver.gd` - 4 testes: aparece no toque e segue arraste, zona morta mantém direção anterior, arraste além do raio ainda produz direção correta, soltar mantém última direção.
- `apps/mobile/tests/unit/test_relative_driver.gd` - 4 testes: começa apontando para cima, arraste horizontal gira sentido horário, sensibilidade escala a rotação, soltar mantém ângulo e ignora arraste subsequente.

## Decisions Made

- `_last_pushed_direction` em `InputRouter` (ver key-decisions acima) — necessário porque `InputBuffer.push_command()` só deduplica contra o último item **na fila**, não contra a última direção efetivamente consumida; sem esse rastreio externo, o primeiro evento de qualquer gesto (toque inicial, sem deslocamento ainda) virava um comando "fantasma" que atrasava a resposta real do arraste em um tick — exatamente o tipo de latência de input que a Fase 2 existe para eliminar.
- Tipagem de `diff` em `swipe_driver.gd` corrigida por ser regra de CLAUDE.md "sem exceção", mesmo estando dentro do trecho que o plano pediu para manter "idêntico" — a correção é puramente de tipo, zero mudança de comportamento.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] InputRouter enfileirava comando fantasma em eventos sem mudança de direção**
- **Found during:** Task 1, ao rodar `test_input_router.gd::test_unhandled_input_outside_tree_does_not_crash`
- **Issue:** o código do plano empurrava `driver.poll(0.0)` no buffer a cada `process_event()`, inclusive no toque inicial (antes de qualquer deslocamento) e no toque solto — nesses casos o driver devolve a direção **inalterada**, mas como o buffer estava vazio, `InputBuffer.push_command()` não tinha nada para deduplicar contra e enfileirava esse valor como se fosse um comando real. O comando fantasma entrava na fila ANTES do comando real do arraste seguinte, fazendo `poll_direction()` devolver a direção velha por um tick.
- **Fix:** `InputRouter` passou a rastrear `_last_pushed_direction` (inicializado com `driver.poll(0.0)` em `_init()`/`set_driver()`) e só chama `buffer.push_command()` quando a nova direção difere o bastante da última enfileirada (reaproveita `buffer.similarity_threshold`, sem número novo no código).
- **Files modified:** `apps/mobile/src/input/input_router.gd`
- **Verification:** `test_input_router.gd` 4/4 passando (antes: 3/4, com `test_unhandled_input_outside_tree_does_not_crash` falhando).
- **Committed in:** `932ffe7` (Task 1)

**2. [Rule 1 - Bug de teste] Segunda asserção de test_swipe_driver.gd usava ponto de arraste incompatível com o reset de start_pos já existente em SwipeDriver.poll()**
- **Found during:** Task 1, ao rodar `test_swipe_driver.gd::test_direction_updates_continuously_while_dragging`
- **Issue:** o texto do plano testava um segundo arraste até `(100, 150)`, assumindo diff relativo ao toque original `(100,100)` — mas `SwipeDriver.poll()` (código pré-existente, não alterado) reancora `start_pos` para `current_pos - current_dir*deadzone_px` toda vez que a zona morta é cruzada, comportamento de "joystick contínuo" documentado no próprio `<behavior>` do plano. Com o `start_pos` já em `(130,100)` após o primeiro `poll()`, arrastar até `(100,150)` produzia uma direção diagonal (`y≈0.858`), não vertical pura.
- **Fix:** segundo ponto de arraste ajustado para `(130, 160)`, consistente com o `start_pos` reancorado — mesma intenção do teste (arraste contínuo, sem soltar o dedo, muda de direção), sem tocar em `SwipeDriver`.
- **Files modified:** `apps/mobile/tests/unit/test_swipe_driver.gd`
- **Verification:** `test_swipe_driver.gd` 4/4 passando.
- **Committed in:** `932ffe7` (Task 1)

**3. [Rule 1 - Lint] `var diff` sem tipo em swipe_driver.gd**
- **Found during:** Task 1, `./tools/ci/lint.sh`
- **Issue:** `var diff = current_pos - start_pos` (pré-existente, preservado verbatim pelo texto do plano) viola a Regra 1 de CLAUDE.md ("GDScript com TIPAGEM ESTÁTICA... sem exceção"), pega pelo `lint.sh`.
- **Fix:** `var diff: Vector2 = current_pos - start_pos`. Zero mudança de comportamento.
- **Files modified:** `apps/mobile/src/input/drivers/swipe_driver.gd`
- **Verification:** `./tools/ci/lint.sh` não aponta mais nenhuma linha de `swipe_driver.gd`.
- **Committed in:** `932ffe7` (Task 1)

---

**Total deviations:** 3 auto-fixed (2 bugs de comportamento/teste, 1 lint)
**Impact on plan:** Todas as correções necessárias para os próprios critérios de aceite do plano (os testes que o plano pediu não passavam sem elas). Nenhum scope creep — `InputBuffer`, `JoystickDriver` e `RelativeDriver` não foram tocados, como o plano exigiu.

## Issues Encountered

- `./tools/ci/test-client.sh` roda a suíte GUT inteira, compartilhada com os outros 4 planos executando em paralelo na mesma árvore. Durante a execução, resultados de `test_game_state.gd`, `test_state_machine.gd`, `test_runner_movement.gd` e `test_game_camera.gd` oscilaram entre passar e falhar conforme os planos 02-02/02-04 escreviam seus próprios arquivos no meio da minha rodada — nenhuma dessas falhas está relacionada a `apps/mobile/src/input/`, confirmado por `git status` (arquivos daqueles planos, não deste). Não foram tocadas.
- `test_build.gd::test_version_matches_project_settings` falha de forma estável e pré-existente (`project.godot` tem `config/version="0.1.2"`, do release F-Droid — commit `480eef0`, anterior a este plano — mas o teste ainda espera `"0.1.0"`). Fora do escopo de `apps/mobile/src/input/`; registrado em `deferred-items.md` desta fase, não corrigido.
- Resultado final de `./tools/ci/test-client.sh` isolando só os 5 arquivos de teste deste plano: **19/19 passando**. Resultado da suíte inteira no momento da verificação final: 103/104 (única falha é a de `test_build.gd` acima, não relacionada a este plano).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `InputRouter.poll_direction()` está pronto para ser consumido diretamente por `MatchDirector.step()` no Plano 02-05 — a única porta de saída de direção, com buffer no caminho, sem literal de gameplay novo.
- `SwipeDriver`, `JoystickDriver` e `RelativeDriver` têm paridade de qualidade provada por teste (não só leitura de código), desbloqueando a tela de `Settings > Controls` (Plano 02-06) para trocar de esquema com confiança.
- Pendência de fora deste plano, sem bloquear o 02-05: `test_build.gd` desalinhado com `config/version` do `project.godot` (ver deferred-items.md) — decisão de versionamento, não de input.

## Self-Check: PASSED

Todos os 7 arquivos citados (`input_router.gd`, `swipe_driver.gd`, e os 5 arquivos de teste novos)
confirmados presentes em disco. Os 3 hashes de commit (`932ffe7`, `c25e747`, `e493433`) confirmados
em `git log --oneline --all`.
