---
phase: 02-core-movement
plan: 04
subsystem: presentation
tags: [godot, gdscript, camera, interpolation, gut]

# Dependency graph
requires:
  - phase: 02-core-movement (02-01, 02-02, parallel wave 1)
    provides: "Runner._init com balance opcional; ArenaDefinition com width_cells/height_cells/cell_size/get_pixel_size()"
provides:
  - "RunnerView herdando InterpolatedVisual, sincronizada com Runner.state a cada _physics_process"
  - "GameCamera.setup(balance, arena) lendo CameraBalance real, com clamp de borda defensivo para arena menor que a viewport"
affects: [02-05-match-director-composition-root, 02-06-match-screen-desimulation]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Visual de simulação estende InterpolatedVisual em vez de compor/reimplementar prev/curr (ADR-0014, componente único)"
    - "Câmera/entidade de apresentação recebe config via setup(balance, ...) explícito, nunca @export com literal de gameplay"

key-files:
  created:
    - apps/mobile/tests/integration/test_runner_view_interpolation.gd
    - apps/mobile/tests/unit/test_game_camera.gd
  modified:
    - apps/mobile/src/presentation/runner_view.gd
    - apps/mobile/src/presentation/runner_view_spawner.gd
    - apps/mobile/src/presentation/camera/game_camera.gd

key-decisions:
  - "Teste de RunnerView usa Runner.new() com 3 argumentos (sem o 4º RunnerBalance opcional que o Plano 02-01 adiciona em paralelo), porque com default null o construtor aceita as duas formas e o teste não fica refém da ordem de conclusão entre planos da mesma wave"
  - "GameCamera._process() ganhou _clamp_to_arena_axis(): quando a metade da viewport é maior que a metade da Arena num eixo, centraliza nesse eixo em vez de aplicar um clamp(min>max) que colava a câmera num canto arbitrário — bug real, exposto pelo próprio teste de borda com a viewport real do runner headless (1920x1920)"
  - "Teste de convergência da câmera compara a distância até a posição real para a qual o algoritmo converge (alvo + lookahead), não até a posição crua do alvo — o texto original do plano comparava contra o alvo sem lookahead, o que fazia a câmera ficar matematicamente mais longe do ponto de referência ao convergir corretamente para alvo+lookahead"

requirements-completed: [MOV-01, MOV-06]

# Metrics
duration: 50min
completed: 2026-09-05
---

# Phase 02 Plan 04: Presentation Sync (RunnerView + GameCamera) Summary

**RunnerView agora estende InterpolatedVisual e segue Runner.state tick a tick (em vez de ficar presa no ponto de spawn); GameCamera.setup() lê follow_smoothing/lookahead/zoom_base de CameraBalance real e corrige um clamp de borda que invertia min/max em arenas pequenas.**

## Performance

- **Duration:** ~50 min
- **Started:** 2026-09-05T18:15:00Z (aprox.)
- **Completed:** 2026-09-05T19:03:44Z
- **Tasks:** 2 completed
- **Files modified:** 5 (3 código, 2 teste; mais 2 `.uid` gerados)

## Accomplishments
- `RunnerView` deixou de ser um `Sprite2D` vazio parado no spawn: agora herda `InterpolatedVisual` (o componente único de ADR-0014), amostra `Runner.state.position/direction` a cada `_physics_process` e desenha um círculo placeholder (`PLACEHOLDER-ART-001`, `Replacement: GSD 08`) enquanto não há cosmético equipado.
- `RunnerViewSpawner` passa a guardar a referência do `Runner` na view, não só copiar a posição de spawn uma vez.
- `GameCamera.setup(balance, arena)` aplica `follow_smoothing`/`lookahead`/`zoom_base` reais de `CameraBalance` (`8.0`/`90.0`/`1.0`), eliminando os `@export` inventados (`5.0`/`150.0`) que nunca bateram com `docs/design/balance.md` §11.
- Bug real corrigido em `GameCamera._process()`: o clamp de borda (`clamp(value, min, max)`) invertia `min > max` sempre que a metade da viewport era maior que a metade da Arena num eixo — resultado era a câmera colar num canto arbitrário. Extraído `_clamp_to_arena_axis()`, que centraliza nesse eixo quando o clamp seria inválido.

## Task Commits

Each task was committed atomically:

1. **Task 1: RunnerView estende InterpolatedVisual e acompanha a simulação a cada tick** - `f68d0f5` (feat)
2. **Task 2: GameCamera lê CameraBalance real via setup()** - `c444f72` (feat)

_Nenhuma etapa RED/GREEN separada — TDD aplicado escrevendo teste+implementação juntos por arquivo e confirmando 4/4 verde antes de cada commit, dado que o plano já trazia teste e implementação emparelhados por task._

## Files Created/Modified
- `apps/mobile/src/presentation/runner_view.gd` - agora `extends InterpolatedVisual`; `_physics_process` chama `update_simulation_state`; `_draw()` desenha placeholder rastreado
- `apps/mobile/src/presentation/runner_view_spawner.gd` - `_on_runner_spawned` guarda `view.runner = runner` além de `global_position` inicial
- `apps/mobile/src/presentation/camera/game_camera.gd` - `setup(balance, arena)`; `_clamp_to_arena_axis()` substitui o `clamp()` direto nas duas linhas de borda
- `apps/mobile/tests/integration/test_runner_view_interpolation.gd` - 4 testes (herança, sync de posição, shift prev/curr, ausência de crash sem runner)
- `apps/mobile/tests/unit/test_game_camera.gd` - 4 testes (setup, convergência com lookahead, clamp de borda, ausência de crash sem target/arena)

## Decisions Made
- Testes de `RunnerView` usam `Runner.new(id, pos, dir)` com 3 argumentos, não 4 — o Plano 02-01 (paralelo, mesma wave) adiciona um `balance: RunnerBalance = null` opcional ao construtor; usar a forma de 3 argumentos funciona antes e depois dessa mudança aterrissar, sem depender da ordem de execução entre planos concorrentes.
- Arena de teste da câmera precisou ser bem maior (4000×4000, `_big_arena()`) que a usada no `setup()`-only test (320×320, `_small_arena()`), porque a viewport real medida no runner GUT headless é 1920×1920 — uma arena menor que isso faz a "metade da viewport" exceder a "metade da arena" em qualquer eixo, tornando o clamp de borda matematicamente impossível de satisfazer sem centralizar (daí o novo `_clamp_to_arena_axis`).
- Teste de convergência da câmera comparado contra a posição real de convergência (`alvo + lookahead`), não contra o alvo cru: com `lookahead=90` e um deslocamento de alvo de só `40` unidades, comparar contra o alvo cru fazia a câmera "se afastar" ao convergir corretamente — matemática do teste original do plano, corrigida mantendo a mesma intenção (provar convergência monotônica ao longo dos frames).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Runner.new() do teste ajustado para 3 argumentos**
- **Found during:** Task 1 (leitura de `runner.gd` antes de escrever o teste)
- **Issue:** O texto do plano usa `Runner.new(1, Vector2.ZERO, Vector2.UP, RunnerBalance.new())` (4 args), mas `Runner._init` só aceita 3 parâmetros até o Plano 02-01 (paralelo, mesma wave, `depends_on: []`) adicionar o 4º opcional. Rodar o teste antes de 02-01 terminar quebraria por "too many arguments".
- **Fix:** Teste escrito com `Runner.new(1, Vector2.ZERO, Vector2.UP)` (3 args) — válido antes e depois de 02-01, já que o 4º parâmetro que ele adiciona tem default `null`.
- **Files modified:** `apps/mobile/tests/integration/test_runner_view_interpolation.gd`
- **Verification:** `./tools/ci/test-client.sh` — 4/4 testes do arquivo passando (confirmado inclusive depois de 02-01 ter aterrissado sua mudança, ainda com 3 args).
- **Committed in:** `f68d0f5`

**2. [Rule 3 - Blocking] `add_child_autofree(...)` não pode ser atribuído com `:=`**
- **Found during:** Task 1, primeira rodada de `test-client.sh`
- **Issue:** `GutTest.add_child_autofree(node, legible_unique_name = false)` não declara tipo de retorno; `var view := add_child_autofree(RunnerView.new())` falhava com "Cannot infer the type" (erro de parse, os 4 testes do arquivo não carregavam).
- **Fix:** Padrão trocado para `var view := RunnerView.new(); add_child_autofree(view)` (mesmo padrão já usado em outros testes do repositório, ex. `test_match_field_renderer.gd`).
- **Files modified:** `apps/mobile/tests/integration/test_runner_view_interpolation.gd`
- **Verification:** `./tools/ci/test-client.sh` — parse ok, 4/4 passando.
- **Committed in:** `f68d0f5`

**3. [Rule 6 - regra 8 do CLAUDE.md] Comentário de teste citava `PLACEHOLDER-ART-001` sem `Replacement:` na mesma linha**
- **Found during:** Task 1, `./tools/ci/validate-repo.sh`
- **Issue:** O docstring do teste mencionava o ID do placeholder por extenso, disparando a regra 6 (todo `PLACEHOLDER-ART-NNN` precisa de `Replacement: GSD XX` na mesma linha) mesmo sendo só um comentário sobre o comportamento, não uma nova ocorrência a rastrear.
- **Fix:** Reescrito para descrever o comportamento sem repetir o literal `PLACEHOLDER-ART-001` (que já está corretamente rastreado em `runner_view.gd`).
- **Files modified:** `apps/mobile/tests/integration/test_runner_view_interpolation.gd`
- **Verification:** `./tools/ci/validate-repo.sh` sai com código 0.
- **Committed in:** `f68d0f5`

**4. [Rule 1 - Bug] Clamp de borda da câmera invertia min/max quando a Arena é menor que a viewport**
- **Found during:** Task 2, teste `test_camera_never_shows_beyond_arena_edge` com a viewport real do runner GUT headless (1920×1920, medida via probe)
- **Issue:** `clamp(value, arena.limits.position.x + half_size.x, arena.limits.end.x - half_size.x)` produz `min > max` sempre que `half_size` (metade da viewport) excede a metade da Arena nesse eixo — o `clamp` do Godot nesse caso devolve o `min` (um canto arbitrário e potencialmente fora da Arena), não uma posição sensata.
- **Fix:** Extraído `_clamp_to_arena_axis(value, min_limit, max_limit, half_extent)`: se `low > high`, centraliza no meio da Arena nesse eixo; senão, clamp normal (comportamento inalterado para arenas maiores que a viewport, que é o caso real de produção — `open_field.tres` corrigido pelo Plano 02-02 para 2048×2048).
- **Files modified:** `apps/mobile/src/presentation/camera/game_camera.gd`
- **Verification:** `./tools/ci/test-client.sh` — os 4 testes de `test_game_camera.gd` passam, incluindo o de borda com arena grande (4000×4000) e o teste original só de `setup()` com a arena pequena (320×320, onde o novo fallback de centralização é quem evita o clamp inválido).
- **Committed in:** `c444f72`

**5. [Rule 1 - Bug] Matemática do teste de convergência da câmera não batia com o próprio algoritmo**
- **Found during:** Task 2, `./tools/ci/test-client.sh` (teste falhando com distância final ~1139 vs esperado <40)
- **Issue:** O teste do plano comparava a distância da câmera até o alvo cru (`Vector2(200,160)`), mas o algoritmo converge para `alvo + lookahead` (`lookahead=90` por padrão). Com o alvo só `40` unidades à frente da câmera, convergir corretamente para `alvo+90` deixa a câmera **mais longe** do alvo cru do que estava no início — o teste, como escrito, não podia passar mesmo com a implementação correta.
- **Fix:** Reescrito para comparar contra a posição real de convergência (`target.global_position + Vector2.RIGHT * balance.lookahead`), com câmera/alvo posicionados no centro de uma arena grande o bastante para o clamp de borda não interferir.
- **Files modified:** `apps/mobile/tests/unit/test_game_camera.gd`
- **Verification:** `./tools/ci/test-client.sh` — teste passando, convergência monotônica confirmada ao longo de 30 frames.
- **Committed in:** `c444f72`

---

**Total deviations:** 5 auto-fixed (3 Rule 3 - bloqueio, 2 Rule 1 - bug)
**Impact on plan:** Todos os ajustes foram necessários para o código e os testes compilarem/passarem corretamente; nenhum é mudança de escopo ou arquitetura. O bug de clamp (item 4) é uma correção real de comportamento visual (câmera não deve colar em cantos arbitrários), consistente com o objetivo do próprio plano ("GameCamera nunca mostra além da borda da Arena, em qualquer proporção de tela").

## Issues Encountered
- Execução em paralelo com os Planos 02-01 (Runner/StatBlock/RunnerBalance) e 02-02 (FSM/ArenaDefinition) na mesma árvore de trabalho: confirmado via leitura dos respectivos PLAN.md que ambos alteram construtores/campos dos quais os testes deste plano dependem (`Runner._init`, `ArenaDefinition.width_cells/height_cells/cell_size/get_pixel_size()`). Resolvido escrevendo os testes de forma compatível com o estado anterior E posterior a essas mudanças (ver Decisions Made), sem esperar bloqueado pela ordem de conclusão de outro plano.
- `./tools/ci/lint.sh` não foi rodado como gate de bloqueio: o baseline do repositório já falha em dezenas de arquivos pré-existentes fora do escopo deste plano (várias `var` sem `:=`/tipo em `gameplay/score/`, `progression/`, etc., e `func _init` sem `-> void` em `runner/states/*`). Os 3 arquivos deste plano (`runner_view.gd`, `runner_view_spawner.gd`, `game_camera.gd`) foram escritos com tipagem estática completa (toda `var`/parâmetro/retorno tipado), verificado manualmente contra a heurística de `tools/ci/lint_gdscript.sh`.
- `test_build.gd::test_version_matches_project_settings` continua falhando (pré-existente, documentado por outro plano da mesma wave em `.planning/phases/02-core-movement/deferred-items.md` sob `[02-03]`) — confirmado sem relação com `presentation/`, não corrigido aqui.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `RunnerView` e `GameCamera` têm o contrato certo (`runner`/`setup(balance, arena)`) para o Plano 02-05 (MatchDirector/composition root) instanciá-los de verdade em `root.gd` e remover o `Camera2D` cru hoje dentro de `gameplay/match_director.setup_match()`.
- Nenhum bloqueio conhecido para 02-05 originado por este plano.

---
*Phase: 02-core-movement*
*Completed: 2026-09-05*

## Self-Check: PASSED

Todos os 6 arquivos declarados (3 código, 2 teste, este SUMMARY) confirmados em disco; os 2
commits de task (`f68d0f5`, `c444f72`) confirmados em `git log --oneline --all`.
