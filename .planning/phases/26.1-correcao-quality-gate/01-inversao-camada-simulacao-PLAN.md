---
phase: 26.1-correcao-quality-gate
plan: 1
type: execute
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/gameplay/match_director.gd
  - apps/mobile/src/presentation/runner_view_spawner.gd
  - apps/mobile/src/root.gd
  - apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd
  - apps/mobile/tests/integration/test_runner_presentation_wiring.gd
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "apps/mobile/src/gameplay/match_director.gd não referencia presentation/ nem ui/, nem por load() de string — a criação da RunnerView só acontece quando a camada de apresentação escuta o sinal emitido pela simulação"
    - "Uma partida com N bots continua criando N Runners simulados e N RunnerViews visuais, exatamente como antes da inversão — só o caminho de criação mudou, não o resultado"
  artifacts:
    - path: "apps/mobile/src/gameplay/match_director.gd"
      provides: "signal runner_spawned(runner: Runner), emitido para cada Runner criado em setup_match(), sem load() nem ClassDB.class_exists de presentation/"
      contains: "signal runner_spawned"
    - path: "apps/mobile/src/presentation/runner_view_spawner.gd"
      provides: "RunnerViewSpawner — ouve MatchDirector.runner_spawned e cria a RunnerView correspondente"
      min_lines: 10
  key_links:
    - from: "apps/mobile/src/gameplay/match_director.gd"
      to: "apps/mobile/src/presentation/runner_view_spawner.gd"
      via: "sinal runner_spawned, conectado em root.gd (composição), nunca importado diretamente por gameplay/"
      pattern: "runner_spawned"
    - from: "apps/mobile/src/root.gd"
      to: "apps/mobile/src/presentation/runner_view_spawner.gd"
      via: "RunnerViewSpawner.new() + watch(_match_director) dentro de _start_match()"
      pattern: "RunnerViewSpawner"
---

<objective>
Corrigir a violação mais grave do quality gate (Regra 7 de `tools/ci/validate-repo.sh` —
"simulação não conhece apresentação"): `apps/mobile/src/gameplay/match_director.gd:55` faz
`load("res://src/presentation/runner_view.gd").new()`, guardado por
`ClassDB.class_exists("RunnerView")`. Isso quebra o invariante central do projeto (rodar 500
partidas headless sem nenhum nó visual) e é citado em `CLAUDE.md` §4 como a coisa que "quebra o
projeto".

Purpose: inverter a dependência — `MatchDirector` (simulação) emite um sinal quando um Runner
passa a existir; uma classe nova de `presentation/` escuta e cria a `RunnerView`. `gameplay/`
deixa de conhecer `presentation/` por completo, restaurando o invariante antes que as Fases
27-38 comecem a escrever código de gamificação sobre esta base.

Output: `MatchDirector.runner_spawned` (sinal novo), `RunnerViewSpawner` (classe nova em
`presentation/`), `root.gd` como ponto de composição que liga os dois, e dois testes GUT que
provam a emissão do lado da simulação e a criação de view do lado da apresentação.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/26.1-correcao-quality-gate/26.1-CONTEXT.md
@.planning/ROADMAP.md
@docs/architecture/overview.md
</context>

<interfaces>
Runner (apps/mobile/src/runner/runner.gd) — o que o sinal carrega:

    class_name Runner
    extends RefCounted
    var state: RunnerState
    var stats: StatBlock
    func _init(runner_id: int, start_pos: Vector2, start_dir: Vector2) -> void: ...

RunnerView (apps/mobile/src/presentation/runner_view.gd) — o que RunnerViewSpawner cria,
inalterado por este plano:

    class_name RunnerView
    extends Node2D
    var loadout: Loadout
    var sprite: Sprite2D
    func _ready() -> void: ...
    func apply_cosmetics(l: Loadout, catalog: Catalog) -> void: ...

MatchDirector (apps/mobile/src/gameplay/match_director.gd) — estado relevante já existente,
inalterado:

    class_name MatchDirector
    extends Node
    var ai_scheduler: AIScheduler
    var runners: Array[Runner] = []
    func setup_match(mode_config: Resource) -> void: ...

root.gd (apps/mobile/src/root.gd) — único ponto do projeto que hoje instancia MatchDirector E
tem permissão de conhecer presentation/ (é o composition root, fora das quatro pastas de
simulação vigiadas pela Regra 7: territory/, runner/, ai/, gameplay/):

    extends Control
    var screen_stack: ScreenStack
    var _match_director: MatchDirector
    func _start_match() -> void: ...
    func _return_to_menu() -> void: ...
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: MatchDirector emite runner_spawned em vez de instanciar RunnerView</name>
  <files>apps/mobile/src/gameplay/match_director.gd, apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd</files>
  <read_first>
    - apps/mobile/src/gameplay/match_director.gd (função setup_match, linhas 32-70)
    - apps/mobile/src/runner/runner.gd
    - apps/mobile/tests/integration/test_bootstrap.gd (padrão do repo: instanciar direto com .new(), sem depender de _ready(), sem adicionar à SceneTree)
    - apps/mobile/tests/unit/test_service_registry.gd (padrão de watch_signals/assert em GUT)
    - docs/architecture/overview.md §1 e §3 (regra de camadas e uso de Signal)
  </read_first>
  <behavior>
    - setup_match() com bot_count=2 emite runner_spawned exatamente 2 vezes, uma por Runner criado
    - setup_match() com bot_count=0 não emite runner_spawned nenhuma vez
    - cada emissão carrega a instância real de Runner que foi adicionada a `runners`
  </behavior>
  <action>
    Em `apps/mobile/src/gameplay/match_director.gd`:

    1. Adicione, imediatamente ANTES de `func setup_match(mode_config: Resource) -> void:`, o
       sinal novo (com o comentário de rastreio da inversão):

       ```gdscript
       ## Emitido quando um novo Runner passa a existir na partida. gameplay/ não conhece
       ## presentation/ (CLAUDE.md §5, docs/architecture/overview.md §1) — quem cria a
       ## RunnerView é RunnerViewSpawner, ouvindo este sinal (ver
       ## apps/mobile/src/presentation/runner_view_spawner.gd).
       signal runner_spawned(runner: Runner)
       ```

    2. Dentro do laço `for i in range(bot_count):`, substitua o bloco:

       ```gdscript
       		# Visualization
       		if ClassDB.class_exists("RunnerView"):
       			var view = load("res://src/presentation/runner_view.gd").new()
       			add_child(view)
       			view.position = r.state.position
       			
       			# If catalog/loadout are available via Autoload, we would apply cosmetics here
       ```

       por uma única linha:

       ```gdscript
       		runner_spawned.emit(r)
       ```

       Não toque em mais nada nesta função — a ordem de criação do Runner, do profile e do
       brain continua idêntica, só a parte de visualização sai.

    Crie `apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd`:

    ```gdscript
    extends GutTest

    ## Prova a inversão de dependência da Regra 7 (CLAUDE.md §3 / docs/architecture/overview.md
    ## §1): MatchDirector não conhece mais presentation/ — emite runner_spawned para cada
    ## Runner criado, em vez de instanciar RunnerView via load() de string.

    func test_setup_match_emits_runner_spawned_for_each_bot() -> void:
    	var director := MatchDirector.new()
    	watch_signals(director)

    	var config := Resource.new()
    	config.set_meta("bot_count", 2)
    	director.setup_match(config)

    	assert_eq(get_signal_emit_count(director, "runner_spawned"), 2)
    	assert_eq(director.runners.size(), 2)
    	assert_true(director.runners[0] is Runner)

    	director.queue_free()


    func test_setup_match_with_zero_bots_emits_nothing() -> void:
    	var director := MatchDirector.new()
    	watch_signals(director)

    	var config := Resource.new()
    	config.set_meta("bot_count", 0)
    	director.setup_match(config)

    	assert_eq(get_signal_emit_count(director, "runner_spawned"), 0)

    	director.queue_free()
    ```

    Note que `director` nunca é adicionado a uma SceneTree (mesmo padrão de
    test_bootstrap.gd): `_ready()` não roda, `game_state` fica null, e o bloco
    `if game_state and game_state.fsm:` no fim de `setup_match()` é pulado sem erro — isso já
    acontecia antes deste plano e não muda.
  </action>
  <acceptance_criteria>
    - `grep -c 'res://src/presentation\|ClassDB.class_exists' apps/mobile/src/gameplay/match_director.gd` retorna 0
    - `grep -q 'signal runner_spawned(runner: Runner)' apps/mobile/src/gameplay/match_director.gd`
    - `grep -q 'runner_spawned.emit(r)' apps/mobile/src/gameplay/match_director.gd`
    - `test -f apps/mobile/tests/gameplay/test_match_director_runner_spawned.gd`
    - `grep -rn 'presentation/\|res://src/ui/' apps/mobile/src/territory apps/mobile/src/runner apps/mobile/src/ai apps/mobile/src/gameplay` não retorna nada
  </acceptance_criteria>
  <verify>
    <automated>[ "$(grep -c 'res://src/presentation\|ClassDB.class_exists' apps/mobile/src/gameplay/match_director.gd)" -eq 0 ] && grep -q 'signal runner_spawned(runner: Runner)' apps/mobile/src/gameplay/match_director.gd && ! grep -rn 'presentation/\|res://src/ui/' apps/mobile/src/territory apps/mobile/src/runner apps/mobile/src/ai apps/mobile/src/gameplay && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>match_director.gd não contém mais load() de presentation/ nem o guard de ClassDB; emite runner_spawned(runner) para cada Runner criado; o teste novo prova a contagem de emissões para bot_count=2 e bot_count=0; test-client.sh continua verde.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: RunnerViewSpawner escuta o sinal e cria a RunnerView; wiring em root.gd</name>
  <files>apps/mobile/src/presentation/runner_view_spawner.gd, apps/mobile/src/root.gd, apps/mobile/tests/integration/test_runner_presentation_wiring.gd</files>
  <read_first>
    - apps/mobile/src/presentation/runner_view.gd
    - apps/mobile/src/root.gd (inteiro — é pequeno, 45 linhas)
    - apps/mobile/src/gameplay/match_director.gd (já com runner_spawned da Task 1 deste plano)
    - docs/architecture/overview.md §1, §2 e §8 (onde presentation/ vive e o que é responsável por quê)
  </read_first>
  <behavior>
    - RunnerViewSpawner.watch(director) conecta ao sinal runner_spawned do director passado
    - ao rodar setup_match() num director observado, o spawner ganha exatamente um filho RunnerView por bot criado
    - cada RunnerView criada é posicionada em runner.state.position
  </behavior>
  <action>
    Crie `apps/mobile/src/presentation/runner_view_spawner.gd`:

    ```gdscript
    class_name RunnerViewSpawner
    extends Node

    ## Cria a RunnerView correspondente sempre que MatchDirector (camada de simulação) sinaliza
    ## que um novo Runner passou a existir. Mantém gameplay/ sem conhecer presentation/
    ## (docs/architecture/overview.md §1, CLAUDE.md §5) — a inversão de dependência mora aqui:
    ## quem ESCUTA é apresentação, quem EMITE é simulação.

    func watch(director: MatchDirector) -> void:
    	director.runner_spawned.connect(_on_runner_spawned)


    func _on_runner_spawned(runner: Runner) -> void:
    	var view := RunnerView.new()
    	add_child(view)
    	view.position = runner.state.position

    	# If catalog/loadout are available via Autoload, we would apply cosmetics here
    ```

    Em `apps/mobile/src/root.gd`:

    1. Adicione o campo `var _runner_view_spawner: RunnerViewSpawner` logo abaixo de
       `var _match_director: MatchDirector`.
    2. Em `_start_match()`, logo após `add_child(_match_director)` e ANTES de
       `_match_director.setup_match(config)` (a ordem importa: o spawner precisa estar
       observando antes dos Runners serem criados), adicione:

       ```gdscript
       	_runner_view_spawner = RunnerViewSpawner.new()
       	add_child(_runner_view_spawner)
       	_runner_view_spawner.watch(_match_director)
       ```

    3. Em `_return_to_menu()`, logo após o bloco que libera `_match_director`, adicione:

       ```gdscript
       	if is_instance_valid(_runner_view_spawner):
       		_runner_view_spawner.queue_free()
       		_runner_view_spawner = null
       ```

    Crie `apps/mobile/tests/integration/test_runner_presentation_wiring.gd`:

    ```gdscript
    extends GutTest

    ## Prova a ponta de apresentação da inversão de dependência: RunnerViewSpawner, ao observar
    ## um MatchDirector via watch(), cria uma RunnerView por Runner sem que gameplay/ conheça
    ## presentation/ (ver test_match_director_runner_spawned.gd para o lado da simulação).

    func test_spawner_creates_a_runner_view_per_bot() -> void:
    	var director := MatchDirector.new()
    	var spawner := RunnerViewSpawner.new()
    	spawner.watch(director)

    	var config := Resource.new()
    	config.set_meta("bot_count", 3)
    	director.setup_match(config)

    	assert_eq(spawner.get_child_count(), 3)
    	for child in spawner.get_children():
    		assert_true(child is RunnerView, "cada filho deveria ser uma RunnerView")

    	spawner.queue_free()
    	director.queue_free()
    ```
  </action>
  <acceptance_criteria>
    - `test -f apps/mobile/src/presentation/runner_view_spawner.gd`
    - `grep -q 'class_name RunnerViewSpawner' apps/mobile/src/presentation/runner_view_spawner.gd`
    - `grep -q 'RunnerView.new()' apps/mobile/src/presentation/runner_view_spawner.gd`
    - `grep -q '_runner_view_spawner' apps/mobile/src/root.gd`
    - `grep -q '_runner_view_spawner.watch(_match_director)' apps/mobile/src/root.gd`
    - `test -f apps/mobile/tests/integration/test_runner_presentation_wiring.gd`
    - `./tools/ci/validate-repo.sh` imprime `OK: camadas respeitadas`
  </acceptance_criteria>
  <verify>
    <automated>grep -q 'class_name RunnerViewSpawner' apps/mobile/src/presentation/runner_view_spawner.gd && grep -q '_runner_view_spawner.watch(_match_director)' apps/mobile/src/root.gd && ./tools/ci/validate-repo.sh 2>&1 | grep -q 'OK: camadas respeitadas' && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>RunnerViewSpawner existe em presentation/, observa MatchDirector via watch(), cria uma RunnerView por Runner emitido; root.gd instancia e conecta o spawner antes de setup_match() e o libera em _return_to_menu(); validate-repo.sh Regra 7 imprime OK; test-client.sh continua verde.</done>
</task>

</tasks>

<verification>
- `./tools/ci/validate-repo.sh` seção 7 imprime `OK: camadas respeitadas` (era `FALHA` antes deste plano)
- `grep -rn 'presentation/\|res://src/ui/' apps/mobile/src/territory apps/mobile/src/runner apps/mobile/src/ai apps/mobile/src/gameplay` não retorna nada
- `./tools/ci/test-client.sh` sai com código 0
- Os dois testes novos (`test_match_director_runner_spawned.gd`, `test_runner_presentation_wiring.gd`) passam dentro da suíte GUT
</verification>

<success_criteria>
`apps/mobile/src/gameplay/match_director.gd` não referencia `presentation/` nem `ui/` de
nenhuma forma — a Regra 7 do quality gate está verde. A criação de `RunnerView` continua
acontecendo, um por Runner, só que a partir da apresentação escutando um sinal, não da
simulação instanciando um `load()`. `test-client.sh` permanece verde, provando que o
comportamento observável (quantos Runners e quantas Views existem por partida) não mudou.
</success_criteria>

<output>
Após completar, crie `.planning/phases/26.1-correcao-quality-gate/26.1-01-SUMMARY.md` seguindo
o template de summary.md, registrando a inversão de dependência aplicada e confirmando que
nenhum outro ponto do projeto ainda referencia `presentation/` a partir de `gameplay/`,
`territory/`, `runner/` ou `ai/`.
</output>
