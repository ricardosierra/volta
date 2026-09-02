---
phase: 02-core-movement
plan: 03
type: execute
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/input/input_router.gd
  - apps/mobile/src/input/drivers/swipe_driver.gd
  - apps/mobile/tests/unit/test_input_router.gd
  - apps/mobile/tests/unit/test_swipe_driver.gd
  - apps/mobile/tests/unit/test_input_buffer.gd
  - apps/mobile/tests/unit/test_joystick_driver.gd
  - apps/mobile/tests/unit/test_relative_driver.gd
autonomous: true
requirements:
  - MOV-03
  - MOV-04
must_haves:
  truths:
    - "InputRouter produz um único Vector2 de direção por chamada de poll_direction() — nenhum InputEvent chega além dele"
    - "Um comando de direção que chega enquanto o Runner ainda está girando fica na fila e é aplicado no tick seguinte, em vez de ser descartado ou de substituir o comando atual na hora"
    - "A zona morta do swipe é a mesma distância física (mm) em duas densidades de tela diferentes, não a mesma contagem de pixels"
    - "Os três esquemas de controle (swipe, joystick, relativo) produzem um Vector2 coerente a partir dos mesmos tipos de evento sintético, com paridade de qualidade (mantém direção ao soltar, ignora abaixo da zona morta)"
    - "InputRouter e seus componentes são instanciáveis e testáveis fora da SceneTree (mesmo padrão de test_bootstrap.gd), sem exigir viewport real"
  artifacts:
    - path: "apps/mobile/src/input/input_router.gd"
      provides: "InputRouter com InputBuffer interno no caminho de poll_direction()"
      contains: "buffer.tick(delta)"
    - path: "apps/mobile/src/input/drivers/swipe_driver.gd"
      provides: "conversão mm->px extraída como função estática testável"
      contains: "static func mm_to_px"
  key_links:
    - from: "apps/mobile/src/input/input_router.gd"
      to: "apps/mobile/src/input/input_buffer.gd"
      via: "buffer interno, populado a cada InputEvent processado, consumido uma vez por poll_direction(delta)"
      pattern: "InputBuffer.new"
    - from: "apps/mobile/src/input/input_router.gd"
      to: "apps/mobile/src/input/drivers/swipe_driver.gd"
      via: "driver ativo, trocável em runtime via set_driver()"
      pattern: "driver.poll"
---

<objective>
A auditoria de 2026-09-02 encontrou `InputRouter` com **zero referências** em todo o projeto —
ninguém o instancia nem chama `poll_direction()`. Ele existe, compila, e já tem a peça certa
(`_unhandled_input` para não competir com toque em UI), mas `InputBuffer` (MOVE-006) não está
ligado a ele — hoje `InputRouter.poll_direction()` simplesmente repassa `driver.poll(delta)`
puro, sem fila nenhuma. O contrato de `ADR-0014` ("Input é coletado por evento e consumido no
tick, com buffer") exige que o buffer fique entre o evento bruto e o valor lido pela simulação.

`JoystickDriver` e `RelativeDriver` (MOVE-007) já existem e, pela leitura do código, já
implementam o contrato certo (mantêm direção ao soltar, zona morta no joystick, sensibilidade no
relativo) — mas a auditoria não encontrou nenhum teste para eles, só uso na tela de settings
(`settings_controls.gd`, fora do alcance de qualquer navegação até o Plano 02-06). Este plano
prova que os dois já funcionam, sem mudar o código deles.

Purpose: fazer `InputRouter` ser a ÚNICA porta de saída de direção para a simulação, com
`InputBuffer` no caminho, e deixar `SwipeDriver` testável sem depender de `DisplayServer` real
(headless não tem tela, `screen_get_dpi()` pode devolver 0). Este plano NÃO conecta o
`InputRouter` ao `MatchDirector` ainda — isso é wiring de composição, feito no Plano 02-05, que
depende deste.

Output: `InputRouter` com buffer interno; `SwipeDriver` com a conversão mm→px extraída e
testável; os 5 arquivos de teste de MOVE-005/006/007 que a auditoria encontrou ausentes.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/02-core-movement/02-CONTEXT.md
@.planning/ROADMAP.md
@docs/gameplay/controls.md
@docs/decisions/ADR-0014-simulation-tick-model.md
</context>

<interfaces>
InputDriver (apps/mobile/src/input/input_driver.gd) — já existe, NÃO MUDA:

    class_name InputDriver
    extends RefCounted
    func poll(delta: float) -> Vector2:
    	return Vector2.ZERO

InputBuffer (apps/mobile/src/input/input_buffer.gd) — já existe, correto, NÃO MUDA neste
plano (só ganha teste):

    class_name InputBuffer
    extends RefCounted
    func push_command(dir: Vector2) -> void: ...   # ignora comando quase idêntico ao último (dot > 0.95)
    func tick(delta: float) -> void: ...            # envelhece e descarta comandos > max_age (0.5s)
    func has_commands() -> bool: ...
    func pop_command() -> Vector2: ...
    func peek_command() -> Vector2: ...

InputRouter (apps/mobile/src/input/input_router.gd) — estado ATUAL (sem buffer, `driver` só
existe depois de `_ready()`, o que impede testar sem árvore):

    class_name InputRouter
    extends Node
    var driver: InputDriver
    func _ready() -> void:
    	driver = SwipeDriver.new()
    	set_process_unhandled_input(true)
    func _unhandled_input(event: InputEvent) -> void:
    	if driver and driver.has_method("process_event"):
    		driver.process_event(event)
    	if event is InputEventScreenTouch or event is InputEventScreenDrag:
    		get_viewport().set_input_as_handled()
    func poll_direction(delta: float) -> Vector2:
    	if driver:
    		return driver.poll(delta)
    	return Vector2.ZERO
    func set_driver(new_driver: InputDriver) -> void:
    	driver = new_driver

SwipeDriver (apps/mobile/src/input/drivers/swipe_driver.gd) — estado ATUAL (conversão mm→px
inline no `_init`, não testável sem `DisplayServer` real):

    class_name SwipeDriver
    extends InputDriver
    var deadzone_mm: float = 3.0
    var deadzone_px: float = 20.0
    func _init() -> void:
    	var dpi = DisplayServer.screen_get_dpi()
    	if dpi > 0:
    		deadzone_px = (deadzone_mm / 25.4) * dpi
    func process_event(event: InputEvent) -> void: ...   # NÃO MUDA
    func poll(_delta: float) -> Vector2: ...              # NÃO MUDA

JoystickDriver (apps/mobile/src/input/drivers/joystick_driver.gd) — já existe, correto, NÃO
MUDA neste plano (só ganha teste):

    class_name JoystickDriver
    extends InputDriver
    var radius: float = 100.0
    var deadzone: float = 20.0
    var current_dir: Vector2 = Vector2.UP
    func process_event(event: InputEvent) -> void: ...  # aparece no toque, clampa ao raio
    func poll(_delta: float) -> Vector2: ...             # mantém direção ao soltar

RelativeDriver (apps/mobile/src/input/drivers/relative_driver.gd) — já existe, correto, NÃO
MUDA neste plano (só ganha teste):

    class_name RelativeDriver
    extends InputDriver
    var current_angle: float = 0.0  # inicia em -PI/2 (UP)
    var sensitivity: float = 0.01
    func process_event(event: InputEvent) -> void: ...  # arraste horizontal gira proporcional
    func poll(_delta: float) -> Vector2: ...             # Vector2.RIGHT.rotated(current_angle)
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: InputRouter ganha InputBuffer interno; testável fora da árvore; SwipeDriver com mm→px extraído</name>
  <files>apps/mobile/src/input/input_router.gd, apps/mobile/src/input/drivers/swipe_driver.gd, apps/mobile/tests/unit/test_input_router.gd, apps/mobile/tests/unit/test_swipe_driver.gd</files>
  <read_first>
    - apps/mobile/src/input/input_router.gd (estado atual completo, 26 linhas)
    - apps/mobile/src/input/drivers/swipe_driver.gd (estado atual completo, 38 linhas)
    - apps/mobile/src/input/input_buffer.gd (contrato completo — não muda)
    - docs/gameplay/controls.md (regra 1-6, especialmente "amostrado no tick de simulação", "toque sobre UI não vira movimento")
    - docs/decisions/ADR-0014-simulation-tick-model.md ("Input é coletado por evento... e consumido no tick — com buffer")
    - apps/mobile/tests/integration/test_bootstrap.gd (padrão de teste: instanciar `.new()` fora da árvore, sem `_ready()`)
    - .gsd/phases/02-core-movement/TASKS.md, seções MOVE-005 e MOVE-006
  </read_first>
  <behavior>
    - `InputRouter.new()` (sem `_ready()`, fora da árvore) já tem `driver` e `buffer` prontos — inicialização move de `_ready()` para `_init()`
    - Cada evento processado por `driver.process_event()` empurra a direção resultante no `buffer` (se ela for diferente o bastante da última — a própria dedup de `InputBuffer.push_command` cuida disso)
    - `poll_direction(delta)` primeiro envelhece o buffer (`buffer.tick(delta)`); se há comando na fila, consome UM por chamada (`pop_command()`); senão cai no valor contínuo do driver (`driver.poll(delta)`) — isso é o que garante "nunca para sozinho" ao soltar o dedo
    - Dois comandos empurrados entre duas chamadas de `poll_direction()` são consumidos em duas chamadas seguidas, na ordem em que entraram (prova de MOVE-006)
    - `set_driver()` troca o driver ativo E zera o buffer (comando antigo de um esquema não vaza para o novo esquema)
    - Chamar `_unhandled_input` fora da árvore (sem viewport) não lança erro — `get_viewport()` pode ser `null` nesse contexto de teste, e o código já lida com isso
    - `SwipeDriver.mm_to_px(mm, dpi)` é uma função estática pura: `(mm / 25.4) * dpi`; a mesma distância em mm produz pixels diferentes em DPIs diferentes (160 vs 480), provando que a zona morta é física, não em pixels fixos
  </behavior>
  <action>
    Reescreva `apps/mobile/src/input/input_router.gd`:

    ```gdscript
    class_name InputRouter
    extends Node

    ## Única porta de saída de direção para a simulação (docs/gameplay/controls.md,
    ## ADR-0014). Nenhum InputEvent chega ao Runner: eventos são coletados por
    ## _unhandled_input() (para não competir com toque em UI), traduzidos pelo driver ativo em
    ## um Vector2, e enfileirados num InputBuffer — a simulação só lê poll_direction() uma vez
    ## por tick de 60 Hz.

    var driver: InputDriver
    var buffer: InputBuffer

    func _init() -> void:
    	driver = SwipeDriver.new()
    	buffer = InputBuffer.new()

    func _ready() -> void:
    	set_process_unhandled_input(true)

    func _unhandled_input(event: InputEvent) -> void:
    	if driver and driver.has_method("process_event"):
    		driver.process_event(event)
    		buffer.push_command(driver.poll(0.0))

    	if event is InputEventScreenTouch or event is InputEventScreenDrag:
    		var vp := get_viewport()
    		if vp:
    			vp.set_input_as_handled()

    func poll_direction(delta: float) -> Vector2:
    	buffer.tick(delta)
    	if buffer.has_commands():
    		return buffer.pop_command()
    	if driver:
    		return driver.poll(delta)
    	return Vector2.ZERO

    func set_driver(new_driver: InputDriver) -> void:
    	driver = new_driver
    	buffer = InputBuffer.new()
    ```

    Em `apps/mobile/src/input/drivers/swipe_driver.gd`, extraia a conversão mm→px para uma
    função estática, mantendo `process_event`/`poll` idênticos:

    ```gdscript
    class_name SwipeDriver
    extends InputDriver

    var is_touching: bool = false
    var start_pos: Vector2 = Vector2.ZERO
    var current_pos: Vector2 = Vector2.ZERO
    var current_dir: Vector2 = Vector2.UP

    # Zona morta física: aprox. 3mm, convertida para pixels pelo DPI real da tela.
    var deadzone_mm: float = 3.0
    var deadzone_px: float = 20.0

    func _init() -> void:
    	var dpi := DisplayServer.screen_get_dpi()
    	if dpi > 0:
    		deadzone_px = mm_to_px(deadzone_mm, dpi)

    static func mm_to_px(mm: float, dpi: float) -> float:
    	return (mm / 25.4) * dpi

    func process_event(event: InputEvent) -> void:
    	if event is InputEventScreenTouch:
    		if event.pressed:
    			is_touching = true
    			start_pos = event.position
    			current_pos = event.position
    		else:
    			is_touching = false

    	elif event is InputEventScreenDrag and is_touching:
    		current_pos = event.position

    func poll(_delta: float) -> Vector2:
    	if is_touching:
    		var diff = current_pos - start_pos
    		if diff.length() > deadzone_px:
    			current_dir = diff.normalized()
    			start_pos = current_pos - (current_dir * deadzone_px)

    	return current_dir
    ```

    Crie `apps/mobile/tests/unit/test_input_router.gd`:

    ```gdscript
    extends GutTest

    ## InputRouter (MOVE-005/MOVE-006, docs/gameplay/controls.md, ADR-0014). Prova que o
    ## buffer fica no caminho de poll_direction() e que trocar de driver não vaza estado.

    func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
    	var e := InputEventScreenTouch.new()
    	e.position = pos
    	e.pressed = pressed
    	return e

    func _drag(pos: Vector2) -> InputEventScreenDrag:
    	var e := InputEventScreenDrag.new()
    	e.position = pos
    	return e

    func test_router_is_usable_immediately_after_new_without_ready() -> void:
    	var router := InputRouter.new()
    	assert_not_null(router.driver)
    	assert_not_null(router.buffer)
    	assert_eq(router.poll_direction(0.016), Vector2.UP, "sem nenhum toque, o SwipeDriver default aponta para cima")

    func test_unhandled_input_outside_tree_does_not_crash() -> void:
    	var router := InputRouter.new()
    	router._unhandled_input(_touch(Vector2(100, 100), true))
    	router._unhandled_input(_drag(Vector2(200, 100)))
    	assert_gt(router.poll_direction(0.016).x, 0.0, "arrastar para a direita deveria produzir direção com x positivo")

    func test_two_distinct_commands_between_polls_are_consumed_in_order() -> void:
    	var router := InputRouter.new()
    	router.buffer.push_command(Vector2.RIGHT)
    	router.buffer.push_command(Vector2.DOWN)

    	var first := router.poll_direction(0.01)
    	var second := router.poll_direction(0.01)

    	assert_eq(first, Vector2.RIGHT)
    	assert_eq(second, Vector2.DOWN)

    func test_set_driver_resets_the_buffer() -> void:
    	var router := InputRouter.new()
    	router.buffer.push_command(Vector2.LEFT)
    	assert_true(router.buffer.has_commands())

    	router.set_driver(SwipeDriver.new())

    	assert_false(router.buffer.has_commands(), "trocar de esquema não deveria carregar comando do esquema anterior")
    ```

    Crie `apps/mobile/tests/unit/test_swipe_driver.gd`:

    ```gdscript
    extends GutTest

    ## SwipeDriver (MOVE-005, docs/gameplay/controls.md — zona morta em mm físicos). Prova
    ## conversão mm->px pura (sem depender de DisplayServer real, headless não tem tela),
    ## direção contínua durante o arraste, e manutenção da direção ao soltar.

    func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
    	var e := InputEventScreenTouch.new()
    	e.position = pos
    	e.pressed = pressed
    	return e

    func _drag(pos: Vector2) -> InputEventScreenDrag:
    	var e := InputEventScreenDrag.new()
    	e.position = pos
    	return e

    func test_mm_to_px_scales_with_dpi() -> void:
    	var px_low_density := SwipeDriver.mm_to_px(3.0, 160.0)
    	var px_high_density := SwipeDriver.mm_to_px(3.0, 480.0)
    	assert_almost_eq(px_low_density, 18.897, 0.01)
    	assert_almost_eq(px_high_density, 56.69, 0.01)
    	assert_true(px_high_density > px_low_density, "mesma distância física deveria virar mais pixels numa tela mais densa")

    func test_direction_updates_continuously_while_dragging() -> void:
    	var driver := SwipeDriver.new()
    	driver.deadzone_px = 20.0
    	driver.process_event(_touch(Vector2(100, 100), true))
    	driver.process_event(_drag(Vector2(150, 100)))
    	assert_almost_eq(driver.poll(0.016).x, 1.0, 0.01)

    	driver.process_event(_drag(Vector2(100, 150)))
    	assert_almost_eq(driver.poll(0.016).y, 1.0, 0.01)

    func test_direction_is_kept_after_release() -> void:
    	var driver := SwipeDriver.new()
    	driver.deadzone_px = 20.0
    	driver.process_event(_touch(Vector2(100, 100), true))
    	driver.process_event(_drag(Vector2(150, 100)))
    	var direction_while_touching := driver.poll(0.016)

    	driver.process_event(_touch(Vector2(150, 100), false))

    	assert_eq(driver.poll(0.016), direction_while_touching, "soltar o dedo não deveria zerar a direção — o Runner mantém o rumo")

    func test_movement_below_deadzone_does_not_change_direction() -> void:
    	var driver := SwipeDriver.new()
    	driver.deadzone_px = 50.0
    	driver.current_dir = Vector2.UP
    	driver.process_event(_touch(Vector2(100, 100), true))
    	driver.process_event(_drag(Vector2(110, 100))) # 10px < deadzone de 50px
    	assert_eq(driver.poll(0.016), Vector2.UP, "arraste menor que a zona morta não deveria mudar a direção")
    ```
  </action>
  <acceptance_criteria>
    - `grep -q "func _init() -> void:" apps/mobile/src/input/input_router.gd`
    - `grep -q "buffer.tick(delta)" apps/mobile/src/input/input_router.gd`
    - `grep -q "static func mm_to_px" apps/mobile/src/input/drivers/swipe_driver.gd`
    - `test -f apps/mobile/tests/unit/test_input_router.gd`
    - `test -f apps/mobile/tests/unit/test_swipe_driver.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "buffer.tick(delta)" apps/mobile/src/input/input_router.gd && grep -q "static func mm_to_px" apps/mobile/src/input/drivers/swipe_driver.gd && test -f apps/mobile/tests/unit/test_input_router.gd && test -f apps/mobile/tests/unit/test_swipe_driver.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>InputRouter tem buffer interno no caminho de poll_direction(), testável fora da árvore; SwipeDriver tem mm_to_px() estático e testável sem DisplayServer real; os dois arquivos de teste novos passam; test-client.sh continua verde.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Cobertura de InputBuffer (MOVE-006) — enfileiramento, ordem, idade, redundância</name>
  <files>apps/mobile/tests/unit/test_input_buffer.gd</files>
  <read_first>
    - apps/mobile/src/input/input_buffer.gd (contrato completo — este teste não muda o arquivo, só prova o que já existe)
    - .gsd/phases/02-core-movement/TASKS.md, seção MOVE-006 (Testes: "dois comandos no mesmo tick → ambos são executados na ordem; comando muito antigo é descartado; comando redundante não enfileira")
  </read_first>
  <behavior>
    - Empurrar duas direções bem diferentes enfileira as duas, na ordem
    - Empurrar uma direção quase idêntica à última da fila (produto escalar > 0,95) NÃO enfileira de novo
    - `tick(delta)` soma idade a cada comando; um comando que passa de `max_age` (0.5s) é descartado antes de ser consumido
    - `pop_command()` remove e devolve o primeiro da fila (FIFO); `peek_command()` olha sem remover
    - Fila vazia: `has_commands()` falso, `pop_command()`/`peek_command()` devolvem `Vector2.ZERO` sem erro
  </behavior>
  <action>
    Crie `apps/mobile/tests/unit/test_input_buffer.gd`:

    ```gdscript
    extends GutTest

    ## InputBuffer (MOVE-006, docs/gameplay/controls.md — "nenhum toque é descartado").
    ## Comportamento já implementado; este teste prova o contrato antes de InputRouter passar
    ## a depender dele (ver test_input_router.gd no mesmo plano).

    func test_two_distinct_commands_are_queued_in_order() -> void:
    	var buffer := InputBuffer.new()
    	buffer.push_command(Vector2.RIGHT)
    	buffer.push_command(Vector2.UP)

    	assert_eq(buffer.pop_command(), Vector2.RIGHT)
    	assert_eq(buffer.pop_command(), Vector2.UP)

    func test_near_identical_command_is_not_queued_again() -> void:
    	var buffer := InputBuffer.new()
    	buffer.push_command(Vector2.RIGHT)
    	buffer.push_command(Vector2(1.0, 0.02).normalized()) # quase idêntico, dot > 0.95

    	assert_eq(buffer.pop_command(), Vector2.RIGHT)
    	assert_false(buffer.has_commands(), "comando quase idêntico ao último não deveria ter sido enfileirado de novo")

    func test_old_command_is_discarded_by_age() -> void:
    	var buffer := InputBuffer.new()
    	buffer.max_age = 0.5
    	buffer.push_command(Vector2.RIGHT)

    	buffer.tick(0.6) # passou da idade máxima

    	assert_false(buffer.has_commands(), "comando mais velho que max_age deveria ter sido descartado")

    func test_command_within_age_survives_tick() -> void:
    	var buffer := InputBuffer.new()
    	buffer.max_age = 0.5
    	buffer.push_command(Vector2.RIGHT)

    	buffer.tick(0.3) # ainda dentro da idade máxima

    	assert_true(buffer.has_commands())
    	assert_eq(buffer.peek_command(), Vector2.RIGHT)

    func test_empty_buffer_returns_zero_vector_without_error() -> void:
    	var buffer := InputBuffer.new()
    	assert_false(buffer.has_commands())
    	assert_eq(buffer.pop_command(), Vector2.ZERO)
    	assert_eq(buffer.peek_command(), Vector2.ZERO)

    func test_ignores_near_zero_direction() -> void:
    	var buffer := InputBuffer.new()
    	buffer.push_command(Vector2(0.01, 0.01))
    	assert_false(buffer.has_commands(), "direção quase nula não deveria virar comando")
    ```
  </action>
  <acceptance_criteria>
    - `test -f apps/mobile/tests/unit/test_input_buffer.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>test -f apps/mobile/tests/unit/test_input_buffer.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>test_input_buffer.gd prova enfileiramento, ordem, dedup por similaridade, descarte por idade e caso vazio; test-client.sh continua verde.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Cobertura de JoystickDriver e RelativeDriver (MOVE-007) — paridade de qualidade entre os 3 esquemas</name>
  <files>apps/mobile/tests/unit/test_joystick_driver.gd, apps/mobile/tests/unit/test_relative_driver.gd</files>
  <read_first>
    - apps/mobile/src/input/drivers/joystick_driver.gd (contrato completo, 30 linhas — este teste não muda o arquivo)
    - apps/mobile/src/input/drivers/relative_driver.gd (contrato completo, 24 linhas — este teste não muda o arquivo)
    - docs/gameplay/controls.md, "Esquema 2 — Joystick virtual" e "Esquema 3 — Relativo (steering)"
    - .gsd/phases/02-core-movement/TASKS.md, seção MOVE-007 (Testes: "troca de driver em runtime sem reiniciar; cada driver produz direção coerente com eventos sintéticos")
  </read_first>
  <behavior>
    - `JoystickDriver`: tocar e arrastar além da zona morta produz a direção do arraste; abaixo da zona morta mantém a direção anterior; arrastar além do raio ainda produz a direção correta (só a posição visual seria clampada); soltar o dedo mantém a última direção
    - `RelativeDriver`: começa apontando para cima; arrastar para a direita gira no sentido horário (ganha componente x positiva); sensibilidade maior gira mais para o mesmo arraste; soltar o dedo mantém o ângulo atual, e arrastar depois de solto não conta
  </behavior>
  <action>
    Crie `apps/mobile/tests/unit/test_joystick_driver.gd`:

    ```gdscript
    extends GutTest

    ## JoystickDriver (MOVE-007, docs/gameplay/controls.md — esquema 2). Já implementado
    ## corretamente; este teste prova o contrato com eventos sintéticos, sem tocar no código.

    func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
    	var e := InputEventScreenTouch.new()
    	e.position = pos
    	e.pressed = pressed
    	return e

    func _drag(pos: Vector2) -> InputEventScreenDrag:
    	var e := InputEventScreenDrag.new()
    	e.position = pos
    	return e

    func test_joystick_appears_at_touch_point_and_follows_drag() -> void:
    	var driver := JoystickDriver.new()
    	driver.process_event(_touch(Vector2(300, 300), true))
    	driver.process_event(_drag(Vector2(350, 300)))
    	assert_almost_eq(driver.poll(0.016).x, 1.0, 0.01)

    func test_direction_below_deadzone_keeps_previous_direction() -> void:
    	var driver := JoystickDriver.new()
    	driver.current_dir = Vector2.UP
    	driver.deadzone = 20.0
    	driver.process_event(_touch(Vector2(300, 300), true))
    	driver.process_event(_drag(Vector2(305, 300))) # 5px < deadzone de 20px
    	assert_eq(driver.poll(0.016), Vector2.UP)

    func test_drag_beyond_radius_is_clamped_but_direction_still_follows() -> void:
    	var driver := JoystickDriver.new()
    	driver.radius = 100.0
    	driver.process_event(_touch(Vector2(300, 300), true))
    	driver.process_event(_drag(Vector2(300, 600))) # bem além do raio, reto para baixo
    	assert_almost_eq(driver.poll(0.016).y, 1.0, 0.01)

    func test_releasing_touch_keeps_last_direction() -> void:
    	var driver := JoystickDriver.new()
    	driver.process_event(_touch(Vector2(300, 300), true))
    	driver.process_event(_drag(Vector2(350, 300)))
    	var direction_while_touching := driver.poll(0.016)

    	driver.process_event(_touch(Vector2(350, 300), false))

    	assert_eq(driver.poll(0.016), direction_while_touching)
    ```

    Crie `apps/mobile/tests/unit/test_relative_driver.gd`:

    ```gdscript
    extends GutTest

    ## RelativeDriver (MOVE-007, docs/gameplay/controls.md — esquema 3, "steering"). Já
    ## implementado corretamente; este teste prova o contrato com eventos sintéticos.

    func _touch(pos: Vector2, pressed: bool) -> InputEventScreenTouch:
    	var e := InputEventScreenTouch.new()
    	e.position = pos
    	e.pressed = pressed
    	return e

    func _drag(pos: Vector2) -> InputEventScreenDrag:
    	var e := InputEventScreenDrag.new()
    	e.position = pos
    	return e

    func test_starts_pointing_up() -> void:
    	var driver := RelativeDriver.new()
    	assert_almost_eq(driver.poll(0.016).angle_to(Vector2.UP), 0.0, 0.001)

    func test_dragging_right_rotates_clockwise() -> void:
    	var driver := RelativeDriver.new()
    	driver.sensitivity = 0.01
    	driver.process_event(_touch(Vector2(300, 300), true))
    	driver.process_event(_drag(Vector2(400, 300))) # arrastou 100px para a direita

    	var direction := driver.poll(0.016)
    	assert_gt(direction.x, 0.0, "arrastar para a direita deveria girar no sentido horário, ganhando componente x positiva")

    func test_sensitivity_scales_the_rotation() -> void:
    	var low_sensitivity := RelativeDriver.new()
    	low_sensitivity.sensitivity = 0.002
    	low_sensitivity.process_event(_touch(Vector2(300, 300), true))
    	low_sensitivity.process_event(_drag(Vector2(400, 300)))

    	var high_sensitivity := RelativeDriver.new()
    	high_sensitivity.sensitivity = 0.01
    	high_sensitivity.process_event(_touch(Vector2(300, 300), true))
    	high_sensitivity.process_event(_drag(Vector2(400, 300)))

    	assert_gt(
    		absf(high_sensitivity.poll(0.016).angle_to(Vector2.UP)),
    		absf(low_sensitivity.poll(0.016).angle_to(Vector2.UP)),
    		"sensibilidade maior deveria girar mais para o mesmo arraste"
    	)

    func test_releasing_touch_keeps_current_angle() -> void:
    	var driver := RelativeDriver.new()
    	driver.process_event(_touch(Vector2(300, 300), true))
    	driver.process_event(_drag(Vector2(400, 300)))
    	var direction_while_touching := driver.poll(0.016)

    	driver.process_event(_touch(Vector2(400, 300), false))
    	driver.process_event(_drag(Vector2(500, 300))) # arraste depois de soltar não deveria contar

    	assert_eq(driver.poll(0.016), direction_while_touching)
    ```
  </action>
  <acceptance_criteria>
    - `test -f apps/mobile/tests/unit/test_joystick_driver.gd`
    - `test -f apps/mobile/tests/unit/test_relative_driver.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>test -f apps/mobile/tests/unit/test_joystick_driver.gd && test -f apps/mobile/tests/unit/test_relative_driver.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>test_joystick_driver.gd e test_relative_driver.gd provam que os dois esquemas produzem direção coerente com eventos sintéticos e mantêm a direção ao soltar, com paridade de qualidade em relação ao SwipeDriver; test-client.sh continua verde.</done>
</task>

</tasks>

<verification>
- `./tools/ci/test-client.sh` sai com código 0
- `./tools/ci/validate-repo.sh` sai com código 0
- `grep -rn "presentation/\|res://src/ui/" apps/mobile/src/input` não retorna nada (input/ continua camada de simulação, não conhece apresentação nem UI)
- Os 5 arquivos de teste novos (`test_input_router.gd`, `test_swipe_driver.gd`, `test_input_buffer.gd`, `test_joystick_driver.gd`, `test_relative_driver.gd`) passam dentro da suíte GUT
</verification>

<success_criteria>
`InputRouter` é agora a única porta de saída de direção, com `InputBuffer` no caminho —
satisfazendo ADR-0014 e MOV-04. Os três esquemas de controle (`SwipeDriver`, `JoystickDriver`,
`RelativeDriver`) têm paridade de qualidade provada por teste, não só por leitura de código —
satisfazendo MOV-03. Nenhum `InputEvent` chega além do `InputRouter`. O Plano 02-05 pode agora
consumir `InputRouter.poll_direction()` diretamente no `MatchDirector.step()`.
</success_criteria>

<output>
Após completar, crie `.planning/phases/02-core-movement/02-03-SUMMARY.md` seguindo o template
de summary.md, registrando a integração do buffer, a extração testável de mm_to_px, e a
cobertura de teste dos três esquemas de controle.
</output>
</content>
