---
phase: 02-core-movement
plan: 02
type: execute
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/gameplay/game_state.gd
  - apps/mobile/src/arena/arena_definition.gd
  - apps/mobile/resources/arenas/open_field.tres
  - apps/mobile/tests/unit/test_state_machine.gd
  - apps/mobile/tests/unit/test_game_state.gd
  - apps/mobile/tests/unit/test_arena.gd
autonomous: true
requirements:
  - MOV-07
  - MOV-02
must_haves:
  truths:
    - "Todas as 11 transições da tabela de docs/architecture/state-machines.md §2 (FSM do jogo) existem e funcionam, incluindo Boot->Loading (primeira execução), hoje ausente"
    - "Pelo menos 5 transições inválidas são rejeitadas pela StateMachine genérica, sem travar o processo"
    - "open_field.tres carrega como uma ArenaDefinition coerente com docs/design/balance.md §1 (128x128 células de 16 unidades), sem campo órfão que o script não declara"
    - "Arena.limits é computável a partir de qualquer uma das 5 ArenaDefinition já existentes (open_field + as 4 arenas da Fase 13) sem crashar"
  artifacts:
    - path: "apps/mobile/src/gameplay/game_state.gd"
      provides: "tabela de transições completa da FSM do jogo, incluindo Boot->Loading"
      contains: "fsm.add_transition(Id.BOOT, Id.LOADING)"
    - path: "apps/mobile/src/arena/arena_definition.gd"
      provides: "dimensões em células + cell_size + get_pixel_size(), com defaults de docs/design/balance.md §1"
      contains: "func get_pixel_size() -> Vector2"
    - path: "apps/mobile/resources/arenas/open_field.tres"
      provides: "arena retangular padrão, 128x128 células de 16 unidades, sem campo órfão"
      contains: "width_cells = 128"
  key_links:
    - from: "apps/mobile/src/arena/arena.gd"
      to: "apps/mobile/src/arena/arena_definition.gd"
      via: "Arena._init faz limits = Rect2(Vector2.ZERO, def.get_pixel_size())"
      pattern: "get_pixel_size"
    - from: "apps/mobile/tests/unit/test_game_state.gd"
      to: "docs/architecture/state-machines.md"
      via: "cobertura das 11 transições declaradas na tabela §2"
      pattern: "add_transition"
---

<objective>
Duas lacunas pequenas e independentes, agrupadas neste plano porque nenhuma sozinha justifica
um plano inteiro e nenhuma toca nos arquivos da outra.

**MOVE-001 (FSM):** `game_state.gd` já implementa 10 das 11 transições da tabela de
`docs/architecture/state-machines.md` §2 — falta `Boot -> Loading` ("primeira execução, vai
direto pra partida"). Além disso, **nenhum teste** cobre a tabela de transições, a rejeição de
transição inválida, nem a `StateMachine` genérica.

**MOVE-008 (Arena):** `ArenaDefinition` não tem `get_pixel_size()`, mas `Arena._init()` já
chama esse método — ou seja, **hoje isso quebra em runtime** assim que alguém tentar
`Arena.new(qualquer_definicao)`. **Descoberta importante ao investigar:** `apps/mobile/resources/arenas/`
NÃO está vazia — já existem 5 arquivos: `open_field.tres` (o alvo deste plano) e mais
`archipelago.tres`, `crossroads.tres`, `halo.tres`, `rift.tres` (artefatos reais da Fase 13,
que a auditoria classificou como "em boa parte real"). Os 4 arquivos da Fase 13 usam
exatamente os campos que `arena_definition.gd` já declara hoje (`id`, `name`, `spawn_points`,
`blocked_rects`, `hazard_rects`) — **não mexa neles, não mude esses nomes de campo**. Só
`open_field.tres` está fora de sincronia: ele tem `width_cells=100`, `height_cells=100`,
`cell_size=32.0` (3200×3200, não bate com `docs/design/balance.md` §1) e um campo
`blocked_cells = Array[Vector2i]([])` que **não existe** em `arena_definition.gd` — resíduo de
uma versão anterior e revertida da classe. Ele é vazio, então não perde dado nenhum ao ser
corrigido.

Purpose: fechar as duas lacunas com o mínimo de código, sem tocar nas 4 arenas da Fase 13, e
deixando FSM e Arena prontas para o Plano 02-05 (MatchDirector/composition root), que depende
deste plano.

Output: `game_state.gd` com a tabela completa; `ArenaDefinition` com `width_cells`/
`height_cells`/`cell_size`/`get_pixel_size()` (defaults de balance.md, que também servem de
fallback são para as 4 arenas da Fase 13, que não setam esses campos); `open_field.tres`
corrigido para 128×128@16 (2048×2048, o Field padrão de balance.md §1); testes para as duas
coisas.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/02-core-movement/02-CONTEXT.md
@.planning/ROADMAP.md
@docs/architecture/state-machines.md
@docs/design/balance.md
</context>

<interfaces>
StateMachine (apps/mobile/src/core/fsm/state_machine.gd) — já existe, NÃO MUDA:

    class_name StateMachine
    extends RefCounted
    signal state_changed(from_state: int, to_state: int)
    func add_state(id: int, state: State) -> void: ...
    func add_transition(from_id: int, to_id: int) -> void: ...
    func request(to_id: int) -> void: ...  # inválida: assert em debug, push_error em release; ignora
    func tick(delta: float) -> void: ...
    func get_current_state() -> int: ...

GameState (apps/mobile/src/gameplay/game_state.gd) — estado ATUAL, veja a única linha que falta
(Id.BOOT -> Id.LOADING não existe na lista de `add_transition`):

    enum Id { BOOT, MENU, LOADING, COUNTDOWN, PLAYING, PAUSED, RESULTS }
    fsm.add_transition(Id.BOOT, Id.MENU)
    fsm.add_transition(Id.MENU, Id.LOADING)
    fsm.add_transition(Id.LOADING, Id.COUNTDOWN)
    fsm.add_transition(Id.COUNTDOWN, Id.PLAYING)
    fsm.add_transition(Id.PLAYING, Id.PAUSED)
    fsm.add_transition(Id.PAUSED, Id.PLAYING)
    fsm.add_transition(Id.PLAYING, Id.RESULTS)
    fsm.add_transition(Id.RESULTS, Id.MENU)
    fsm.add_transition(Id.RESULTS, Id.LOADING)
    fsm.add_transition(Id.PAUSED, Id.RESULTS)

Tabela completa esperada (docs/architecture/state-machines.md §2, 11 linhas — a que falta é a
segunda): Boot->Menu, **Boot->Loading**, Menu->Loading, Loading->Countdown, Countdown->Playing,
Playing->Paused, Paused->Playing, Paused->Results, Playing->Results, Results->Loading,
Results->Menu.

ArenaDefinition (apps/mobile/src/arena/arena_definition.gd) — estado ATUAL, sem dimensão:

    class_name ArenaDefinition
    extends Resource
    @export var id: String = "standard"
    @export var name: String = "Standard Arena"
    @export var spawn_points: Array[Vector2] = []
    @export var blocked_rects: Array[Rect2] = []
    @export var hazard_rects: Array[Rect2] = []
    func is_blocked(pos: Vector2) -> bool: ...
    func is_hazard(pos: Vector2) -> bool: ...
    func is_valid() -> bool: ...  # false se spawn_points vazio

Arena (apps/mobile/src/arena/arena.gd) — já existe, NÃO MUDA (é o chamador que hoje quebraria):

    class_name Arena
    extends RefCounted
    var definition: ArenaDefinition
    var limits: Rect2
    func _init(def: ArenaDefinition) -> void:
    	definition = def
    	limits = Rect2(Vector2.ZERO, def.get_pixel_size())
    func resolve_boundaries(runner_state: RunnerState) -> void: ...

As 4 arenas já reais da Fase 13 (NÃO TOQUE nestes 4 arquivos) — confirme que usam só os campos
que já existem hoje em `arena_definition.gd`:

    apps/mobile/resources/arenas/archipelago.tres  — id, name, spawn_points, blocked_rects, hazard_rects
    apps/mobile/resources/arenas/crossroads.tres   — idem
    apps/mobile/resources/arenas/halo.tres         — idem
    apps/mobile/resources/arenas/rift.tres         — idem (usa hazard_rects, não blocked_rects)

Nenhum dos 4 seta `width_cells`/`height_cells`/`cell_size` — por isso os defaults que você vai
adicionar em `arena_definition.gd` (128/128/16.0, de docs/design/balance.md §1) precisam ser
grandes o bastante para conter os retângulos deles: o maior ponto usado é
`Rect2(340, 760, 400, 400)` (halo) e spawns até `Vector2(900, 1800)` (crossroads) — tudo cabe
com folga dentro de 2048×2048.
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: FSM do jogo — transição Boot-&gt;Loading + cobertura de teste completa</name>
  <files>apps/mobile/src/gameplay/game_state.gd, apps/mobile/tests/unit/test_state_machine.gd, apps/mobile/tests/unit/test_game_state.gd</files>
  <read_first>
    - apps/mobile/src/gameplay/game_state.gd (as 10 transições atuais)
    - apps/mobile/src/core/fsm/state_machine.gd (add_transition, request, _is_valid_transition)
    - apps/mobile/src/core/fsm/state.gd (State base: enter/exit/update)
    - docs/architecture/state-machines.md §2 (tabela completa das 11 transições + regra "primeira execução pula Menu")
    - .gsd/phases/02-core-movement/TASKS.md, seção MOVE-001 (Testes: "todas as transições da tabela do documento; ≥ 5 transições inválidas rejeitadas")
  </read_first>
  <behavior>
    - `StateMachine` genérica: transição declarada muda o estado atual e emite `state_changed(from, to)` com os valores corretos
    - `StateMachine` genérica: transição NÃO declarada é rejeitada — `get_current_state()` continua no estado anterior, nenhum `state_changed` é emitido, e o processo não trava
    - `GameState`: as 11 transições da tabela de state-machines.md §2 funcionam, incluindo a nova `Boot -> Loading`
    - `GameState`: pelo menos 5 pares fora da tabela são rejeitados (ex.: Boot->Playing, Menu->Results, Countdown->Menu, Playing->Loading, Results->Paused)
  </behavior>
  <action>
    Em `apps/mobile/src/gameplay/game_state.gd`, adicione UMA linha, logo depois de
    `fsm.add_transition(Id.BOOT, Id.MENU)`:

    ```gdscript
    	fsm.add_transition(Id.BOOT, Id.MENU)
    	fsm.add_transition(Id.BOOT, Id.LOADING)
    	fsm.add_transition(Id.MENU, Id.LOADING)
    ```

    Não toque em mais nada nesse arquivo — as outras 9 transições e a ordem de `add_state` já
    estão corretas.

    Crie `apps/mobile/tests/unit/test_state_machine.gd`:

    ```gdscript
    extends GutTest

    ## StateMachine genérica (docs/architecture/state-machines.md §3, core/fsm/). Prova
    ## transição válida com sinal, e rejeição de transição inválida sem travar o processo
    ## (MOVE-001, TESTS.md test_state_machine.gd).

    const STATE_A := 0
    const STATE_B := 1
    const STATE_C := 2

    func _machine_with_a_to_b() -> StateMachine:
    	var machine := StateMachine.new()
    	machine.add_state(STATE_A, State.new())
    	machine.add_state(STATE_B, State.new())
    	machine.add_state(STATE_C, State.new())
    	machine.add_transition(STATE_A, STATE_B)
    	machine.request(STATE_A)
    	return machine

    func test_valid_transition_changes_state_and_emits_signal() -> void:
    	var machine := _machine_with_a_to_b()
    	watch_signals(machine)

    	machine.request(STATE_B)

    	assert_eq(machine.get_current_state(), STATE_B)
    	assert_signal_emitted_with_parameters(machine, "state_changed", [STATE_A, STATE_B])

    func test_invalid_transition_is_rejected_and_state_unchanged() -> void:
    	var machine := _machine_with_a_to_b()
    	watch_signals(machine)

    	machine.request(STATE_C) # A -> C não foi declarada

    	assert_eq(machine.get_current_state(), STATE_A, "estado não deveria mudar numa transição inválida")
    	assert_signal_not_emitted(machine, "state_changed")

    func test_first_request_from_uninitialized_state_always_succeeds() -> void:
    	var machine := StateMachine.new()
    	machine.add_state(STATE_A, State.new())

    	machine.request(STATE_A)

    	assert_eq(machine.get_current_state(), STATE_A)
    ```

    Crie `apps/mobile/tests/unit/test_game_state.gd`:

    ```gdscript
    extends GutTest

    ## GameState — FSM do jogo (docs/architecture/state-machines.md §2). Cobre as 11 transições
    ## da tabela e a rejeição de pelo menos 5 pares inválidos (MOVE-001, ACCEPTANCE A02-08).
    ## GameState._init(director) só guarda a referência; _ready() monta a fsm — testável fora
    ## da árvore chamando _ready() diretamente, mesmo padrão de test_bootstrap.gd.

    func _fresh_game_state() -> GameState:
    	var gs := GameState.new(null)
    	gs._ready()
    	return gs

    func test_boot_to_loading_first_run_path_works() -> void:
    	var gs := _fresh_game_state()
    	assert_eq(gs.current_state(), GameState.Id.BOOT)
    	gs.request_transition(GameState.Id.LOADING)
    	assert_eq(gs.current_state(), GameState.Id.LOADING, "Boot -> Loading (primeira execução) deveria funcionar")

    func test_normal_menu_path_covers_seven_transitions() -> void:
    	var gs := _fresh_game_state()
    	gs.request_transition(GameState.Id.MENU)
    	assert_eq(gs.current_state(), GameState.Id.MENU)
    	gs.request_transition(GameState.Id.LOADING)
    	assert_eq(gs.current_state(), GameState.Id.LOADING)
    	gs.request_transition(GameState.Id.COUNTDOWN)
    	assert_eq(gs.current_state(), GameState.Id.COUNTDOWN)
    	gs.request_transition(GameState.Id.PLAYING)
    	assert_eq(gs.current_state(), GameState.Id.PLAYING)
    	gs.request_transition(GameState.Id.PAUSED)
    	assert_eq(gs.current_state(), GameState.Id.PAUSED)
    	gs.request_transition(GameState.Id.PLAYING)
    	assert_eq(gs.current_state(), GameState.Id.PLAYING)
    	gs.request_transition(GameState.Id.RESULTS)
    	assert_eq(gs.current_state(), GameState.Id.RESULTS)
    	gs.request_transition(GameState.Id.MENU)
    	assert_eq(gs.current_state(), GameState.Id.MENU)

    func test_playing_to_results_to_loading_path_works() -> void:
    	var gs := _fresh_game_state()
    	gs.request_transition(GameState.Id.LOADING)
    	gs.request_transition(GameState.Id.COUNTDOWN)
    	gs.request_transition(GameState.Id.PLAYING)
    	gs.request_transition(GameState.Id.RESULTS)
    	assert_eq(gs.current_state(), GameState.Id.RESULTS, "Playing -> Results direto (fim de partida) deveria funcionar")
    	gs.request_transition(GameState.Id.LOADING)
    	assert_eq(gs.current_state(), GameState.Id.LOADING, "Results -> Loading (jogar de novo) deveria funcionar")

    func test_at_least_five_invalid_transitions_are_rejected() -> void:
    	var cases := [
    		[GameState.Id.BOOT, GameState.Id.PLAYING],
    		[GameState.Id.MENU, GameState.Id.RESULTS],
    		[GameState.Id.COUNTDOWN, GameState.Id.MENU],
    		[GameState.Id.PLAYING, GameState.Id.LOADING],
    		[GameState.Id.RESULTS, GameState.Id.PAUSED],
    	]
    	for pair in cases:
    		var gs := _fresh_game_state()
    		_walk_to(gs, pair[0])
    		gs.request_transition(pair[1])
    		assert_eq(gs.current_state(), pair[0], "transição %s -> %s deveria ter sido rejeitada" % [pair[0], pair[1]])

    func _walk_to(gs: GameState, target: GameState.Id) -> void:
    	var path_from_boot := {
    		GameState.Id.BOOT: [],
    		GameState.Id.MENU: [GameState.Id.MENU],
    		GameState.Id.LOADING: [GameState.Id.LOADING],
    		GameState.Id.COUNTDOWN: [GameState.Id.LOADING, GameState.Id.COUNTDOWN],
    		GameState.Id.PLAYING: [GameState.Id.LOADING, GameState.Id.COUNTDOWN, GameState.Id.PLAYING],
    		GameState.Id.RESULTS: [GameState.Id.LOADING, GameState.Id.COUNTDOWN, GameState.Id.PLAYING, GameState.Id.RESULTS],
    	}
    	for step in path_from_boot[target]:
    		gs.request_transition(step)
    ```

    `GameState._init(director)` aceita `null` sem problema — `director` só é usado dentro de
    `CountdownState`, que não é exercitado por estes testes de transição pura.
  </action>
  <acceptance_criteria>
    - `grep -q "fsm.add_transition(Id.BOOT, Id.LOADING)" apps/mobile/src/gameplay/game_state.gd`
    - `test -f apps/mobile/tests/unit/test_state_machine.gd`
    - `test -f apps/mobile/tests/unit/test_game_state.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "fsm.add_transition(Id.BOOT, Id.LOADING)" apps/mobile/src/gameplay/game_state.gd && test -f apps/mobile/tests/unit/test_state_machine.gd && test -f apps/mobile/tests/unit/test_game_state.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>game_state.gd tem as 11 transições da tabela; test_state_machine.gd prova transição válida (com sinal) e inválida (rejeitada, sem sinal); test_game_state.gd cobre os 11 pares válidos e pelo menos 5 inválidos; test-client.sh continua verde.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: ArenaDefinition ganha get_pixel_size(); corrige open_field.tres (sem tocar nas 4 arenas da Fase 13)</name>
  <files>apps/mobile/src/arena/arena_definition.gd, apps/mobile/resources/arenas/open_field.tres, apps/mobile/tests/unit/test_arena.gd</files>
  <read_first>
    - apps/mobile/src/arena/arena_definition.gd (estado atual, sem dimensão nem get_pixel_size)
    - apps/mobile/src/arena/arena.gd (chama def.get_pixel_size() — hoje quebraria)
    - apps/mobile/resources/arenas/open_field.tres (estado atual: width_cells=100/height_cells=100/cell_size=32.0/blocked_cells — campos fora de sincronia, blocked_cells não existe no script)
    - apps/mobile/resources/arenas/archipelago.tres, crossroads.tres, halo.tres, rift.tres (NÃO TOCAR — confirme que só usam id/name/spawn_points/blocked_rects/hazard_rects, os campos que já existem)
    - apps/mobile/src/runner/runner_state.gd (RunnerState.position/velocity, para o teste de contenção)
    - docs/design/balance.md §1 (Field: cell_size=16, grid_default=128x128 → 2048x2048 unidades)
    - .gsd/phases/02-core-movement/TASKS.md, seção MOVE-008 (passos e DoD: "nenhuma dimensão hardcoded")
  </read_first>
  <behavior>
    - `ArenaDefinition` tem `width_cells`, `height_cells`, `cell_size` como campos de dado, com defaults 128/128/16.0 (docs/design/balance.md §1) — as 4 arenas da Fase 13 não setam esses campos e devem continuar carregando e funcionando com esses defaults
    - `get_pixel_size()` devolve `Vector2(width_cells * cell_size, height_cells * cell_size)`
    - `open_field.tres` corrigido tem `get_pixel_size() == Vector2(2048.0, 2048.0)` (128 células × 16 unidades) e não tem mais o campo órfão `blocked_cells`
    - `Arena.new(open_field.tres)` e `Arena.new(qualquer uma das 4 arenas da Fase 13)` não quebram, e `limits` bate com `get_pixel_size()` em todos os 5 casos
    - Um Runner na velocidade máxima em qualquer direção não sai de `arena.limits`, e `resolve_boundaries` desliza (não trava nem inverte a posição) na borda
    - `is_valid()` continua falso com `spawn_points` vazio, verdadeiro com pelo menos um spawn
  </behavior>
  <action>
    Em `apps/mobile/src/arena/arena_definition.gd`, adicione os três campos de dimensão e o
    método que `arena.gd` já espera. Não renomeie `blocked_rects`/`hazard_rects` — as 4 arenas
    da Fase 13 dependem exatamente desses nomes:

    ```gdscript
    class_name ArenaDefinition
    extends Resource

    @export var id: String = "standard"
    @export var name: String = "Standard Arena"
    @export var width_cells: int = 128
    @export var height_cells: int = 128
    @export var cell_size: float = 16.0
    @export var spawn_points: Array[Vector2] = []
    @export var blocked_rects: Array[Rect2] = []
    @export var hazard_rects: Array[Rect2] = []

    func get_pixel_size() -> Vector2:
    	return Vector2(float(width_cells) * cell_size, float(height_cells) * cell_size)

    func is_blocked(pos: Vector2) -> bool:
    	for r in blocked_rects:
    		if r.has_point(pos):
    			return true
    	return false

    func is_hazard(pos: Vector2) -> bool:
    	for r in hazard_rects:
    		if r.has_point(pos):
    			return true
    	return false

    func is_valid() -> bool:
    	if spawn_points.is_empty():
    		return false
    	return true
    ```

    Os defaults (128, 128, 16.0) são os valores de `docs/design/balance.md` §1
    (`grid_default` 128×128, `cell_size` 16) — os mesmos que `TerritoryBalance` usa para o
    Field. Como as 4 arenas da Fase 13 não setam `width_cells`/`height_cells`/`cell_size`, elas
    passam a usar esses defaults, e todo o conteúdo delas (spawns até `Vector2(900,1800)`,
    retângulo de bloqueio até `x=740,y=1160`) continua bem dentro de um campo de 2048×2048 —
    nada nelas precisa mudar.

    Corrija `apps/mobile/resources/arenas/open_field.tres` (substitua o conteúdo inteiro —
    remove o campo órfão `blocked_cells`, alinha a dimensão a balance.md, adiciona `id`/`name`
    como as outras 4 arenas já têm):

    ```
    [gd_resource type="Resource" script_class="ArenaDefinition" load_steps=2 format=3 uid="uid://cc0q2"]

    [ext_resource type="Script" path="res://src/arena/arena_definition.gd" id="1_arena"]

    [resource]
    script = ExtResource("1_arena")
    id = "open_field"
    name = "Open Field"
    width_cells = 128
    height_cells = 128
    cell_size = 16.0
    spawn_points = Array[Vector2]([Vector2(1024, 1024)])
    blocked_rects = Array[Rect2]([])
    hazard_rects = Array[Rect2]([])
    ```

    Mantenha a mesma linha `uid="uid://cc0q2"` do arquivo original (não gere um uid novo — o
    Godot já indexou este recurso por esse identificador).

    Crie `apps/mobile/tests/unit/test_arena.gd`:

    ```gdscript
    extends GutTest

    ## Arena + ArenaDefinition (MOVE-008, docs/design/balance.md §1). Prova que a dimensão vem
    ## de dado (não hardcoded), que get_pixel_size() bate com o open_field.tres corrigido, que
    ## as 4 arenas da Fase 13 continuam carregando com os defaults, e que a contenção nos
    ## limites desliza em vez de travar.

    func _open_field() -> ArenaDefinition:
    	return load("res://resources/arenas/open_field.tres") as ArenaDefinition

    func test_open_field_resource_has_2048x2048_pixel_size() -> void:
    	var def := _open_field()
    	assert_eq(def.get_pixel_size(), Vector2(2048.0, 2048.0))

    func test_open_field_is_valid_with_a_spawn_point() -> void:
    	assert_true(_open_field().is_valid())

    func test_definition_without_spawn_points_is_invalid() -> void:
    	var def := ArenaDefinition.new()
    	def.spawn_points = []
    	assert_false(def.is_valid())

    func test_arena_limits_match_definition_pixel_size() -> void:
    	var arena := Arena.new(_open_field())
    	assert_eq(arena.limits, Rect2(Vector2.ZERO, Vector2(2048.0, 2048.0)))

    func test_phase_13_arenas_still_load_and_produce_valid_arena_limits() -> void:
    	for path in [
    		"res://resources/arenas/archipelago.tres",
    		"res://resources/arenas/crossroads.tres",
    		"res://resources/arenas/halo.tres",
    		"res://resources/arenas/rift.tres",
    	]:
    		var def := load(path) as ArenaDefinition
    		assert_not_null(def, "%s deveria carregar" % path)
    		var arena := Arena.new(def)
    		assert_eq(arena.limits.size, Vector2(2048.0, 2048.0), "%s deveria usar os defaults 128x128@16 (nenhum campo de dimensão seta valor próprio)" % path)

    func test_runner_at_max_speed_never_leaves_the_arena() -> void:
    	var arena := Arena.new(_open_field())
    	var state := RunnerState.new()
    	state.position = Vector2(2040.0, 2040.0)
    	state.velocity = Vector2(999999.0, 999999.0) # empurra bem além da borda antes de conter

    	arena.resolve_boundaries(state)

    	assert_lte(state.position.x, arena.limits.end.x)
    	assert_lte(state.position.y, arena.limits.end.y)

    func test_runner_sliding_at_boundary_does_not_zero_the_tangential_velocity() -> void:
    	var arena := Arena.new(_open_field())
    	var state := RunnerState.new()
    	state.position = Vector2(-5.0, 1000.0) # já passou da borda esquerda
    	state.velocity = Vector2(-50.0, 80.0)

    	arena.resolve_boundaries(state)

    	assert_eq(state.position.x, arena.limits.position.x, "eixo perpendicular à borda deveria ser preso na borda")
    	assert_eq(state.velocity.y, 80.0, "eixo tangente à borda não deveria ser afetado — é o deslize, não a trava")
    ```
  </action>
  <acceptance_criteria>
    - `grep -q "func get_pixel_size() -> Vector2" apps/mobile/src/arena/arena_definition.gd`
    - `grep -q "width_cells: int = 128" apps/mobile/src/arena/arena_definition.gd`
    - `! grep -q "blocked_cells" apps/mobile/resources/arenas/open_field.tres`
    - `grep -q "width_cells = 128" apps/mobile/resources/arenas/open_field.tres`
    - `grep -q 'uid="uid://cc0q2"' apps/mobile/resources/arenas/open_field.tres`
    - `test -f apps/mobile/tests/unit/test_arena.gd`
    - `git diff --name-only -- apps/mobile/resources/arenas/archipelago.tres apps/mobile/resources/arenas/crossroads.tres apps/mobile/resources/arenas/halo.tres apps/mobile/resources/arenas/rift.tres` não imprime nada (nenhuma das 4 arenas da Fase 13 foi tocada)
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "func get_pixel_size() -> Vector2" apps/mobile/src/arena/arena_definition.gd && ! grep -q "blocked_cells" apps/mobile/resources/arenas/open_field.tres && test -f apps/mobile/tests/unit/test_arena.gd && [ -z "$(git diff --name-only -- apps/mobile/resources/arenas/archipelago.tres apps/mobile/resources/arenas/crossroads.tres apps/mobile/resources/arenas/halo.tres apps/mobile/resources/arenas/rift.tres)" ] && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>ArenaDefinition tem width_cells/height_cells/cell_size (default 128/128/16.0) + get_pixel_size(); open_field.tres corrigido para 2048x2048 sem campo órfão; as 4 arenas da Fase 13 continuam intocadas e carregando corretamente com os defaults; test_arena.gd prova dimensão, validade, as 5 arenas carregando, e deslize na borda; test-client.sh continua verde.</done>
</task>

</tasks>

<verification>
- `./tools/ci/test-client.sh` sai com código 0
- `./tools/ci/validate-repo.sh` sai com código 0
- `grep -c "add_transition" apps/mobile/src/gameplay/game_state.gd` retorna 11
- `Arena.new(load("res://resources/arenas/open_field.tres"))` e o mesmo para as 4 arenas da Fase 13 não lançam erro (provado por test_arena.gd)
- Nenhuma das 4 arenas da Fase 13 foi modificada (`git diff` vazio nesses 4 caminhos)
</verification>

<success_criteria>
A FSM do jogo cobre as 11 transições documentadas (critério de sucesso #6 do ROADMAP da Fase
2), com teste de rejeição de inválidas. `ArenaDefinition` deixou de ser uma classe que quebra em
runtime — tem dimensão real vinda de dado, `open_field.tres` está alinhado a
`docs/design/balance.md`, e as 4 arenas já reais da Fase 13 continuam funcionando sem alteração,
prontas para o Plano 02-05 usar.
</success_criteria>

<output>
Após completar, crie `.planning/phases/02-core-movement/02-02-SUMMARY.md` seguindo o template
de summary.md, registrando a transição adicionada, a correção de open_field.tres, e a
confirmação de que as 4 arenas da Fase 13 não foram tocadas.
</output>
</content>
