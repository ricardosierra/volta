---
phase: 02-core-movement
plan: 04
type: execute
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/presentation/runner_view.gd
  - apps/mobile/src/presentation/runner_view_spawner.gd
  - apps/mobile/src/presentation/camera/game_camera.gd
  - apps/mobile/tests/integration/test_runner_view_interpolation.gd
  - apps/mobile/tests/unit/test_game_camera.gd
autonomous: true
requirements:
  - MOV-01
  - MOV-06
must_haves:
  truths:
    - "RunnerView acompanha a posição/rotação real da simulação a cada tick físico, interpolando visualmente entre o tick anterior e o atual — nunca fica parada no ponto de spawn"
    - "Sem textura de cosmético aplicada, RunnerView desenha um círculo provisório visível (PLACEHOLDER-ART-001), em vez de nada"
    - "GameCamera usa os valores de CameraBalance (follow_smoothing=8.0, lookahead=90.0, zoom_base=1.0), não os defaults @export antigos e divergentes (5.0/150.0) que nunca bateram com docs/design/balance.md §11"
    - "GameCamera nunca mostra além da borda da Arena, em qualquer proporção de tela"
  artifacts:
    - path: "apps/mobile/src/presentation/runner_view.gd"
      provides: "RunnerView estende InterpolatedVisual, amostra Runner.state a cada _physics_process, desenha placeholder sem cosmético"
      contains: "extends InterpolatedVisual"
    - path: "apps/mobile/src/presentation/camera/game_camera.gd"
      provides: "GameCamera.setup(balance, arena) lendo CameraBalance real"
      contains: "func setup(balance: CameraBalance"
  key_links:
    - from: "apps/mobile/src/presentation/runner_view.gd"
      to: "apps/mobile/src/runner/runner.gd"
      via: "RunnerView.runner: Runner, amostrado em _physics_process -> update_simulation_state()"
      pattern: "update_simulation_state"
    - from: "apps/mobile/src/presentation/camera/game_camera.gd"
      to: "apps/mobile/src/core/config/camera_balance.gd"
      via: "setup(balance) lendo follow_smoothing/lookahead/zoom_base"
      pattern: "balance.follow_smoothing"
---

<objective>
Duas peças de apresentação que a auditoria de 2026-09-02 encontrou com **zero referências** e,
pior, com bugs que impediriam funcionar mesmo se alguém as chamasse:

**MOVE-004 (interpolação):** `RunnerView` existe mas **não usa `InterpolatedVisual`** — ela cria
um `Sprite2D` vazio (sem textura até cosméticos serem aplicados, ou seja, hoje **invisível**) e
recebe `position` uma única vez no spawn (`runner_view_spawner.gd`), nunca mais. `InterpolatedVisual`
só é referenciado por `GameCamera` (também não instanciado). Isso viola diretamente ADR-0014
("um único componente usado por Runner, Arc e efeitos; ninguém implementa isso duas vezes") e o
próprio DoD de MOVE-004 ("nenhuma entidade visual implementa interpolação por conta própria").

**MOVE-009 (câmera):** `GameCamera` tem os cálculos certos (`_process` com lookahead + suavização
exponencial + clamp na borda), mas os `@export` de smoothing/lookahead (`5.0`/`150.0`) **nunca**
bateram com `docs/design/balance.md` §11 (`follow_smoothing=8.0`, `lookahead=90.0`) — dois números
inventados, divergentes do único lugar que deveria defini-los. Além disso, ninguém nunca
instancia `GameCamera`: `MatchDirector.setup_match()` cria um `Camera2D` cru dentro de
`gameplay/`, o que a própria auditoria já sinalizou como violação de camada.

Purpose: fazer `RunnerView` de fato seguir a simulação via `InterpolatedVisual` (o componente
único), e fazer `GameCamera` ler os números reais de `CameraBalance`. Este plano NÃO cria o
`GameCamera` no jogo real nem remove o `Camera2D` cru de `match_director.gd` — isso é
composição, feito no Plano 02-05, que depende deste (ele só precisa que `RunnerView`/`GameCamera`
já tenham o contrato certo).

Output: `RunnerView` herdando de `InterpolatedVisual`, com círculo provisório rastreado por
`PLACEHOLDER-ART-001`; `GameCamera.setup(balance, arena)` lendo `CameraBalance` real; testes
para as duas coisas.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/02-core-movement/02-CONTEXT.md
@.planning/ROADMAP.md
@docs/decisions/ADR-0014-simulation-tick-model.md
@docs/design/balance.md
</context>

<interfaces>
InterpolatedVisual (apps/mobile/src/presentation/interpolated_visual.gd) — já existe, correto,
NÃO MUDA (é o componente único que ADR-0014 exige):

    class_name InterpolatedVisual
    extends Node2D
    var prev_position: Vector2
    var curr_position: Vector2
    var prev_rotation: float
    var curr_rotation: float
    func _ready() -> void: ...           # inicializa prev==curr==global_position/rotation atuais
    func update_simulation_state(new_pos: Vector2, new_rot: float) -> void: ...  # prev=curr, curr=novo
    func _process(_delta: float) -> void: ...  # interpola por Engine.get_physics_interpolation_fraction()

Runner (apps/mobile/src/runner/runner.gd) — já existe (após o Plano 02-01, mas o construtor
extra é opcional e não afeta este plano):

    class_name Runner
    extends RefCounted
    var state: RunnerState   # state.position: Vector2, state.direction: Vector2 (use .angle())

CameraBalance (apps/mobile/src/core/config/camera_balance.gd) — já existe, NÃO MUDA:

    class_name CameraBalance
    extends Resource
    @export_range(0.5, 2.0) var zoom_base: float = 1.0
    @export_range(1.0, 20.0) var follow_smoothing: float = 8.0
    @export_range(0.0, 300.0) var lookahead: float = 90.0
    ... (demais campos não usados nesta fase — punch/shake são GSD 03/09)

Arena (apps/mobile/src/arena/arena.gd) — já existe (após o Plano 02-02), NÃO MUDA:

    class_name Arena
    extends RefCounted
    var limits: Rect2

GameCamera (apps/mobile/src/presentation/camera/game_camera.gd) — estado ATUAL (defaults
errados, sem setup()):

    class_name GameCamera
    extends Camera2D
    @export var smoothing_speed: float = 5.0       # ERRADO — balance.md §11 diz 8.0
    @export var lookahead_distance: float = 150.0  # ERRADO — balance.md §11 diz 90.0
    var target_visual: InterpolatedVisual
    var arena: Arena
    func _process(delta: float) -> void: ...  # cálculo já certo, só os números de entrada mudam

RunnerView (apps/mobile/src/presentation/runner_view.gd) — estado ATUAL (Sprite2D vazio, sem
interpolação):

    class_name RunnerView
    extends Node2D
    var loadout: Loadout
    var sprite: Sprite2D
    func _ready() -> void: ...
    func apply_cosmetics(l: Loadout, catalog: Catalog) -> void: ...

RunnerViewSpawner (apps/mobile/src/presentation/runner_view_spawner.gd) — estado ATUAL (posiciona
uma vez, nunca mais):

    class_name RunnerViewSpawner
    extends Node
    func watch(director: MatchDirector) -> void: ...
    func _on_runner_spawned(runner: Runner) -> void:
    	var view := RunnerView.new()
    	add_child(view)
    	view.position = runner.state.position
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: RunnerView estende InterpolatedVisual e acompanha a simulação a cada tick</name>
  <files>apps/mobile/src/presentation/runner_view.gd, apps/mobile/src/presentation/runner_view_spawner.gd, apps/mobile/tests/integration/test_runner_view_interpolation.gd</files>
  <read_first>
    - apps/mobile/src/presentation/runner_view.gd (estado atual completo)
    - apps/mobile/src/presentation/runner_view_spawner.gd (estado atual completo)
    - apps/mobile/src/presentation/interpolated_visual.gd (o componente único — leia inteiro, é pequeno)
    - apps/mobile/src/runner/runner_state.gd (position: Vector2, direction: Vector2)
    - .gsd/BACKLOG.md (procure "PLACEHOLDER-ART-001" — já está rastreado com destino GSD 08, você só precisa criar o comentário no código, não adicionar uma linha nova ao backlog)
    - apps/mobile/tests/integration/test_runner_presentation_wiring.gd (padrão de teste já usado para RunnerViewSpawner)
  </read_first>
  <behavior>
    - `RunnerView` É um `InterpolatedVisual` (herda, não compõe) — `RunnerView.new() is InterpolatedVisual` é verdadeiro
    - `RunnerView.runner` guarda a referência ao `Runner` que ela representa
    - A cada `_physics_process(delta)`, se `runner` não é nulo, `RunnerView` chama `update_simulation_state(runner.state.position, runner.state.direction.angle())` — a mesma chamada que qualquer `InterpolatedVisual` já sabe interpolar em `_process()`
    - Sem `apply_cosmetics()` ter sido chamado (sprite sem textura), `RunnerView._draw()` desenha um círculo branco provisório — com o comentário `PLACEHOLDER-ART-001` na mesma linha do `Replacement: GSD 08`
    - `RunnerViewSpawner._on_runner_spawned` passa `runner` para a view em vez de só copiar `position` uma vez
  </behavior>
  <action>
    Reescreva `apps/mobile/src/presentation/runner_view.gd`:

    ```gdscript
    class_name RunnerView
    extends InterpolatedVisual

    ## Representação visual de um Runner. Estende InterpolatedVisual (o componente único de
    ## interpolação de ADR-0014) em vez de reimplementar prev/curr — amostra Runner.state a
    ## cada _physics_process (mesma cadência da simulação) e deixa a interpolação para o
    ## _process() herdado.

    var runner: Runner
    var loadout: Loadout
    var sprite: Sprite2D

    func _ready() -> void:
    	super._ready()
    	sprite = Sprite2D.new()
    	add_child(sprite)

    func _physics_process(_delta: float) -> void:
    	if runner:
    		update_simulation_state(runner.state.position, runner.state.direction.angle())

    func apply_cosmetics(l: Loadout, catalog: Catalog) -> void:
    	loadout = l
    	var skin_id = loadout.get_equipped(CosmeticItem.Type.SKIN)
    	var item = catalog.get_item(skin_id)

    	if item and item.texture_path:
    		sprite.texture = load(item.texture_path)

    	var mat = ShaderMaterial.new()
    	mat.shader = load(item.shader_path if item.shader_path else "res://assets/shaders/runner.gdshader")
    	sprite.material = mat
    	queue_redraw()

    func _draw() -> void:
    	if sprite and sprite.texture:
    		return
    	# PLACEHOLDER-ART-001: círculo branco provisório enquanto não há cosmético equipado. Replacement: GSD 08
    	draw_circle(Vector2.ZERO, 16.0, Color.WHITE)
    ```

    Em `apps/mobile/src/presentation/runner_view_spawner.gd`, mude só a linha que posicionava a
    view, para em vez disso guardar a referência ao Runner (a posição passa a vir do próprio
    `_physics_process` da view, herdado de `InterpolatedVisual` via `_ready()`):

    ```gdscript
    func _on_runner_spawned(runner: Runner) -> void:
    	var view := RunnerView.new()
    	add_child(view)
    	view.runner = runner
    	view.global_position = runner.state.position

    	# If catalog/loadout are available via Autoload, we would apply cosmetics here
    ```

    (Setar `global_position` uma vez ainda no spawn evita que o Runner "salte" da origem
    `(0,0)` até a posição real no primeiro frame interpolado — `InterpolatedVisual._ready()`
    já usa `global_position` atual para inicializar `prev`/`curr`, então isso precisa acontecer
    ANTES do primeiro `_physics_process`, o que a ordem `add_child` → `view.runner = ...` →
    `view.global_position = ...` garante, já que `_ready()` roda dentro de `add_child`.)

    Crie `apps/mobile/tests/integration/test_runner_view_interpolation.gd`:

    ```gdscript
    extends GutTest

    ## RunnerView + InterpolatedVisual (MOVE-004, ADR-0014). Prova que a view segue a
    ## simulação a cada tick físico, e que o círculo provisório (PLACEHOLDER-ART-001) só
    ## aparece sem cosmético.

    func test_runner_view_is_an_interpolated_visual() -> void:
    	var view := add_child_autofree(RunnerView.new())
    	assert_true(view is InterpolatedVisual)

    func test_physics_process_updates_curr_position_from_runner_state() -> void:
    	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP, RunnerBalance.new())
    	var view := add_child_autofree(RunnerView.new())
    	view.runner = runner

    	runner.state.position = Vector2(100.0, 40.0)
    	view._physics_process(0.016)

    	assert_eq(view.curr_position, Vector2(100.0, 40.0))

    func test_physics_process_shifts_prev_to_old_curr() -> void:
    	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP, RunnerBalance.new())
    	var view := add_child_autofree(RunnerView.new())
    	view.runner = runner

    	runner.state.position = Vector2(10.0, 0.0)
    	view._physics_process(0.016)
    	runner.state.position = Vector2(20.0, 0.0)
    	view._physics_process(0.016)

    	assert_eq(view.prev_position, Vector2(10.0, 0.0))
    	assert_eq(view.curr_position, Vector2(20.0, 0.0))

    func test_view_without_runner_does_not_crash_on_physics_process() -> void:
    	var view := add_child_autofree(RunnerView.new())
    	view._physics_process(0.016) # runner é null — não deveria lançar erro
    	assert_null(view.runner)
    ```
  </action>
  <acceptance_criteria>
    - `grep -q "extends InterpolatedVisual" apps/mobile/src/presentation/runner_view.gd`
    - `grep -q "PLACEHOLDER-ART-001" apps/mobile/src/presentation/runner_view.gd`
    - `grep -q "Replacement: GSD 08" apps/mobile/src/presentation/runner_view.gd`
    - `grep -q "view.runner = runner" apps/mobile/src/presentation/runner_view_spawner.gd`
    - `test -f apps/mobile/tests/integration/test_runner_view_interpolation.gd`
    - `./tools/ci/test-client.sh` sai com código 0
    - `./tools/ci/validate-repo.sh` sai com código 0 (placeholder rastreado corretamente, regra 6)
  </acceptance_criteria>
  <verify>
    <automated>grep -q "extends InterpolatedVisual" apps/mobile/src/presentation/runner_view.gd && grep -q "PLACEHOLDER-ART-001" apps/mobile/src/presentation/runner_view.gd && grep -q "Replacement: GSD 08" apps/mobile/src/presentation/runner_view.gd && test -f apps/mobile/tests/integration/test_runner_view_interpolation.gd && ./tools/ci/test-client.sh && ./tools/ci/validate-repo.sh</automated>
  </verify>
  <done>RunnerView estende InterpolatedVisual, amostra o Runner a cada _physics_process, desenha um placeholder rastreado quando não há cosmético; RunnerViewSpawner passa a referência do Runner; os 4 testes novos passam; test-client.sh e validate-repo.sh continuam verdes.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: GameCamera lê CameraBalance real via setup() (fim dos defaults inventados)</name>
  <files>apps/mobile/src/presentation/camera/game_camera.gd, apps/mobile/tests/unit/test_game_camera.gd</files>
  <read_first>
    - apps/mobile/src/presentation/camera/game_camera.gd (estado atual completo, 21 linhas)
    - apps/mobile/src/core/config/camera_balance.gd (contrato — follow_smoothing=8.0, lookahead=90.0, zoom_base=1.0)
    - apps/mobile/src/arena/arena.gd e arena_definition.gd (limits: Rect2, após o Plano 02-02)
    - docs/design/balance.md §11 (os números reais de câmera)
    - apps/mobile/tests/integration/test_match_field_renderer.gd (padrão de `add_child_autofree` para dar viewport real a um nó que precisa de `get_viewport_rect()`)
  </read_first>
  <behavior>
    - `GameCamera.setup(balance, arena)` aplica `follow_smoothing`/`lookahead`/`zoom_base` do `CameraBalance` passado — não usa mais `5.0`/`150.0` inventados
    - Sem `setup()` chamado, os campos internos ainda têm um valor coerente com `CameraBalance.new()` (nunca ficam em branco/zero)
    - Com `target_visual` e `arena` setados, `_process(delta)` aproxima `global_position` do alvo (mais lookahead) e nunca ultrapassa `arena.limits`
    - Sem `target_visual` ou sem `arena`, `_process(delta)` não faz nada (não lança erro)
  </behavior>
  <action>
    Reescreva `apps/mobile/src/presentation/camera/game_camera.gd`:

    ```gdscript
    class_name GameCamera
    extends Camera2D

    ## Segue o Runner do jogador sobre a posição INTERPOLADA (nunca a de simulação — ADR-0014).
    ## Os números vêm de CameraBalance (docs/design/balance.md §11) via setup(), nunca de
    ## @export inventado: os defaults antigos (5.0/150.0) nunca bateram com o documento.

    var target_visual: InterpolatedVisual
    var arena: Arena

    var _follow_smoothing: float = 8.0
    var _lookahead_distance: float = 90.0

    func setup(balance: CameraBalance, game_arena: Arena) -> void:
    	_follow_smoothing = balance.follow_smoothing
    	_lookahead_distance = balance.lookahead
    	zoom = Vector2(balance.zoom_base, balance.zoom_base)
    	arena = game_arena

    func _process(delta: float) -> void:
    	if not target_visual or not arena:
    		return

    	var offset_vec := Vector2.RIGHT.rotated(target_visual.global_rotation) * _lookahead_distance
    	var desired_pos := target_visual.global_position + offset_vec

    	var half_size := get_viewport_rect().size / 2.0 / zoom
    	desired_pos.x = clamp(desired_pos.x, arena.limits.position.x + half_size.x, arena.limits.end.x - half_size.x)
    	desired_pos.y = clamp(desired_pos.y, arena.limits.position.y + half_size.y, arena.limits.end.y - half_size.y)

    	global_position = global_position.lerp(desired_pos, 1.0 - exp(-_follow_smoothing * delta))
    ```

    Note que os defaults internos (`8.0`/`90.0`) JÁ são os valores de `CameraBalance.new()` —
    não são um literal novo, são o mesmo número que `setup()` aplicaria de qualquer forma; isso
    só evita valor zerado antes de `setup()` ser chamado (defensivo, igual ao padrão de
    `StatBlock` no Plano 02-01).

    Crie `apps/mobile/tests/unit/test_game_camera.gd`:

    ```gdscript
    extends GutTest

    ## GameCamera (MOVE-009, docs/design/balance.md §11). Prova que setup() aplica os valores
    ## reais de CameraBalance, que o follow converge para o alvo, e que a câmera nunca mostra
    ## além da borda da Arena.

    func _small_arena() -> Arena:
    	var def := ArenaDefinition.new()
    	def.width_cells = 20
    	def.height_cells = 20
    	def.cell_size = 16.0 # 320x320
    	def.spawn_points = [Vector2(160, 160)]
    	return Arena.new(def)

    func test_setup_applies_camera_balance_values() -> void:
    	var camera := add_child_autofree(GameCamera.new())
    	var balance := CameraBalance.new()
    	balance.follow_smoothing = 12.0
    	balance.lookahead = 55.0
    	balance.zoom_base = 1.25

    	camera.setup(balance, _small_arena())

    	assert_eq(camera._follow_smoothing, 12.0)
    	assert_eq(camera._lookahead_distance, 55.0)
    	assert_eq(camera.zoom, Vector2(1.25, 1.25))

    func test_camera_converges_toward_target_over_several_frames() -> void:
    	var camera := add_child_autofree(GameCamera.new())
    	camera.setup(CameraBalance.new(), _small_arena())
    	camera.global_position = Vector2(160, 160)

    	var target := add_child_autofree(InterpolatedVisual.new())
    	target.global_position = Vector2(160, 160)
    	target.update_simulation_state(Vector2(200, 160), 0.0)
    	camera.target_visual = target

    	var start_distance := camera.global_position.distance_to(Vector2(200, 160))
    	for i in range(30):
    		camera._process(1.0 / 60.0)
    	var end_distance := camera.global_position.distance_to(Vector2(200, 160))

    	assert_lt(end_distance, start_distance, "câmera deveria se aproximar do alvo ao longo de vários frames")

    func test_camera_never_shows_beyond_arena_edge() -> void:
    	var camera := add_child_autofree(GameCamera.new())
    	var arena := _small_arena()
    	camera.setup(CameraBalance.new(), arena)

    	var target := add_child_autofree(InterpolatedVisual.new())
    	target.global_position = Vector2(5, 5) # canto, bem perto da borda
    	target.update_simulation_state(Vector2(5, 5), 0.0)
    	camera.target_visual = target

    	for i in range(120):
    		camera._process(1.0 / 60.0)

    	var half_size := camera.get_viewport_rect().size / 2.0 / camera.zoom
    	assert_gte(camera.global_position.x, arena.limits.position.x + half_size.x - 0.5)
    	assert_gte(camera.global_position.y, arena.limits.position.y + half_size.y - 0.5)

    func test_process_without_target_or_arena_does_not_crash() -> void:
    	var camera := add_child_autofree(GameCamera.new())
    	camera._process(0.016) # nem target_visual nem arena setados
    	assert_null(camera.target_visual)
    ```
  </action>
  <acceptance_criteria>
    - `! grep -q "smoothing_speed: float = 5.0" apps/mobile/src/presentation/camera/game_camera.gd`
    - `! grep -q "lookahead_distance: float = 150.0" apps/mobile/src/presentation/camera/game_camera.gd`
    - `grep -q "func setup(balance: CameraBalance" apps/mobile/src/presentation/camera/game_camera.gd`
    - `test -f apps/mobile/tests/unit/test_game_camera.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "func setup(balance: CameraBalance" apps/mobile/src/presentation/camera/game_camera.gd && ! grep -q "smoothing_speed: float = 5.0" apps/mobile/src/presentation/camera/game_camera.gd && test -f apps/mobile/tests/unit/test_game_camera.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>GameCamera.setup() aplica CameraBalance real; os defaults @export inventados (5.0/150.0) foram removidos; os 4 testes novos passam (setup, convergência, clamp de borda, ausência de crash sem target/arena); test-client.sh continua verde.</done>
</task>

</tasks>

<verification>
- `./tools/ci/test-client.sh` sai com código 0
- `./tools/ci/validate-repo.sh` sai com código 0
- `grep -rn "presentation/\|res://src/ui/" apps/mobile/src/runner apps/mobile/src/arena` não retorna nada (nenhum vazamento de camada introduzido)
- Os 2 arquivos de teste novos (`test_runner_view_interpolation.gd`, `test_game_camera.gd`) passam dentro da suíte GUT
</verification>

<success_criteria>
`RunnerView` segue a simulação de verdade via `InterpolatedVisual` — o componente único que
ADR-0014 exige — em vez de ficar parada no ponto de spawn. `GameCamera` lê os números reais de
`docs/design/balance.md` §11 via `CameraBalance`, não mais valores inventados. As duas classes
ficam prontas para o Plano 02-05 instanciá-las de verdade no jogo (composição em root.gd),
removendo o `Camera2D` cru que hoje vive dentro de `gameplay/`.
</success_criteria>

<output>
Após completar, crie `.planning/phases/02-core-movement/02-04-SUMMARY.md` seguindo o template
de summary.md, registrando a migração de RunnerView para InterpolatedVisual e a correção dos
números de câmera.
</output>
</content>
