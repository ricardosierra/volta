---
phase: 26.1-correcao-quality-gate
plan: 2
type: execute
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/territory/seal_solver.gd
  - apps/mobile/tests/unit/test_seal_solver.gd
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "SealSolver.solve() continua determinístico e produz exatamente os mesmos captured_cells, stolen_from_owners, swallowed_arcs e bounding_box de antes da refatoração, para os mesmos grid e arc_tracker de entrada"
    - "Nenhuma função de territory/seal_solver.gd passa de 50 linhas"
  artifacts:
    - path: "apps/mobile/src/territory/seal_solver.gd"
      provides: "solve() decomposto em _compute_bounding_box, _flood_fill_exterior e _collect_captured_cells, todas com tipagem estática completa nas variáveis locais"
      contains: "_compute_bounding_box"
    - path: "apps/mobile/tests/unit/test_seal_solver.gd"
      provides: "4 casos de caracterização (captura retangular, roubo de claim, engolir arc inimigo, arc vazio) que travam o comportamento antes e depois da refatoração"
      min_lines: 30
  key_links:
    - from: "apps/mobile/src/territory/seal_solver.gd"
      to: "apps/mobile/tests/unit/test_seal_solver.gd"
      via: "os 4 testes chamam SealSolver.solve() diretamente e travam os valores de retorno"
      pattern: "SealSolver.solve"
---

<objective>
`apps/mobile/src/territory/seal_solver.gd:5` tem uma função `solve()` de 102 linhas — acima do
teto de 50 linhas por função (Regra 8 do quality gate). `SealSolver` é código de **simulação**
pura (determinística, sem `await`, chamada até 1000x sem alocar por benchmark) — é o algoritmo
mais sensível do projeto: quebrá-lo quebra a captura de território em todo o jogo.

Purpose: decompor `solve()` em três funções nomeadas por responsabilidade (bounding box, flood
fill exterior, coleta de células capturadas) SEM mudar uma linha de lógica, com testes de
caracterização escritos e comprovados ANTES da refatoração — para que qualquer desvio de
comportamento apareça como teste vermelho, não como bug em produção.

Output: `seal_solver.gd` com `solve()` como orquestrador fino e três funções auxiliares, mais
`test_seal_solver.gd` com 4 casos que travam entrada→saída.
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
Contratos que os testes usam, já existentes e inalterados por este plano:

    # apps/mobile/src/territory/territory_grid.gd
    class_name TerritoryGrid
    extends RefCounted
    var width: int
    var height: int
    func setup(w: int, h: int, blocked: Array[Vector2i] = []) -> void: ...
    func seed_claim(runner_id: int, center_x: int, center_y: int, size: int) -> void: ...
    func set_owner(x: int, y: int, runner_id: int) -> void: ...
    func cell_index(x: int, y: int) -> int: ...
    func is_blocked(x: int, y: int) -> bool: ...

    # apps/mobile/src/territory/arc_tracker.gd
    class_name ArcTracker
    extends RefCounted
    func _init(id: int, target_grid: TerritoryGrid) -> void: ...
    func mark(from_cell: Vector2i, to_cell: Vector2i) -> void: ...
    func length() -> int: ...

    # apps/mobile/src/territory/seal_result.gd
    class_name SealResult
    extends RefCounted
    var runner_id: int
    var captured_cells: PackedInt32Array
    var stolen_from_owners: Dictionary
    var swallowed_arcs: Array[int]
    var bounding_box: Rect2i
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Testes de caracterização de SealSolver.solve() (RED contra a implementação atual — devem passar já, travando o comportamento hoje)</name>
  <files>apps/mobile/tests/unit/test_seal_solver.gd</files>
  <read_first>
    - apps/mobile/src/territory/seal_solver.gd (implementação atual, inteira — 121 linhas)
    - apps/mobile/src/territory/territory_grid.gd
    - apps/mobile/src/territory/arc_tracker.gd
    - apps/mobile/src/territory/arc_rasterizer.gd (supercover_line — confirma que mark(p,p) marca só a célula p)
    - apps/mobile/src/territory/seal_result.gd
    - apps/mobile/tests/unit/test_service_registry.gd (padrão de teste GUT do repo)
  </read_first>
  <behavior>
    - um anel de Arc fechado ao redor de uma célula vazia captura a célula interior + as 7 células do anel (8 no total), com bounding_box = Rect2i(0,0,5,5)
    - se a célula interior já era claim de outro runner, ela some de stolen_from_owners com contagem 1
    - se a célula interior tinha um arc de 1 célula de outro runner, esse runner aparece em swallowed_arcs
    - arc_tracker vazio (length() == 0) retorna um SealResult sem células capturadas e bounding_box padrão (Rect2i())
  </behavior>
  <action>
    Crie `apps/mobile/tests/unit/test_seal_solver.gd`:

    ```gdscript
    extends GutTest

    ## Caracterização de SealSolver.solve() antes/depois da extração das funções internas
    ## (Regra 8 do CLAUDE.md — territory/seal_solver.gd:5 tinha 102 linhas). SealSolver é
    ## simulação pura (docs/architecture/overview.md §1): estes testes travam o comportamento
    ## exato para provar que a refatoração da Task 2 deste plano não mudou resultado nenhum.

    var grid: TerritoryGrid


    func before_each() -> void:
    	grid = TerritoryGrid.new()
    	grid.setup(10, 10, [])


    func _ring_tracker(runner_id: int) -> ArcTracker:
    	var tracker := ArcTracker.new(runner_id, grid)
    	tracker.mark(Vector2i(1, 2), Vector2i(1, 3))
    	tracker.mark(Vector2i(1, 3), Vector2i(3, 3))
    	tracker.mark(Vector2i(3, 3), Vector2i(3, 1))
    	tracker.mark(Vector2i(3, 1), Vector2i(2, 1))
    	return tracker


    func test_rectangle_capture_seals_interior_and_arc_cells() -> void:
    	grid.seed_claim(0, 1, 1, 1) # claim em (1,1), fecha o canto do anel
    	var tracker := _ring_tracker(0)

    	var result := SealSolver.solve(0, grid, tracker)

    	assert_eq(result.captured_cells.size(), 8, "7 células de arc + a célula interior (2,2)")
    	assert_eq(result.bounding_box, Rect2i(0, 0, 5, 5))
    	assert_true(result.stolen_from_owners.is_empty())
    	assert_true(result.swallowed_arcs.is_empty())


    func test_seal_steals_enemy_claim_inside_capture() -> void:
    	grid.seed_claim(0, 1, 1, 1)
    	grid.set_owner(2, 2, 1) # (2,2) é claim do runner 1 antes do Seal do runner 0
    	var tracker := _ring_tracker(0)

    	var result := SealSolver.solve(0, grid, tracker)

    	assert_eq(result.captured_cells.size(), 8)
    	assert_eq(result.stolen_from_owners.get(1, 0), 1, "capturar (2,2) deveria roubar 1 célula do runner 1")


    func test_seal_records_swallowed_enemy_arc() -> void:
    	grid.seed_claim(0, 1, 1, 1)
    	var tracker := _ring_tracker(0)
    	var enemy_tracker := ArcTracker.new(2, grid)
    	enemy_tracker.mark(Vector2i(2, 2), Vector2i(2, 2)) # arc de 1 célula do runner 2 dentro do anel

    	var result := SealSolver.solve(0, grid, tracker)

    	assert_eq(result.captured_cells.size(), 8)
    	assert_true(result.swallowed_arcs.has(2), "o arc do runner 2 em (2,2) deveria ser engolido")


    func test_seal_with_empty_arc_returns_empty_result() -> void:
    	var empty_tracker := ArcTracker.new(0, grid)

    	var result := SealSolver.solve(0, grid, empty_tracker)

    	assert_true(result.captured_cells.is_empty())
    	assert_eq(result.bounding_box, Rect2i())
    ```

    Rode `./tools/ci/test-client.sh` e confirme que os 4 testes passam CONTRA A IMPLEMENTAÇÃO
    ATUAL (ainda não refatorada) — isso prova que os testes caracterizam corretamente o
    comportamento real, não um comportamento desejado que talvez nunca tenha existido.
  </action>
  <acceptance_criteria>
    - `test -f apps/mobile/tests/unit/test_seal_solver.gd`
    - `grep -c '^func test_' apps/mobile/tests/unit/test_seal_solver.gd` retorna 4
    - `./tools/ci/test-client.sh` sai com código 0 (os 4 testes novos passam contra o solve() ainda não refatorado)
  </acceptance_criteria>
  <verify>
    <automated>[ "$(grep -c '^func test_' apps/mobile/tests/unit/test_seal_solver.gd)" -eq 4 ] && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>4 testes de caracterização existem e passam contra a implementação atual de SealSolver.solve(), sem nenhuma mudança em seal_solver.gd ainda.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Decompor solve() em três funções nomeadas, tipando todas as variáveis locais</name>
  <files>apps/mobile/src/territory/seal_solver.gd</files>
  <read_first>
    - apps/mobile/src/territory/seal_solver.gd (implementação atual)
    - apps/mobile/tests/unit/test_seal_solver.gd (criado na Task 1 deste plano — não altere)
    - CLAUDE.md §3 regra 1 (tipagem estática obrigatória em parâmetro, retorno e membro)
  </read_first>
  <behavior>
    - os mesmos 4 testes de test_seal_solver.gd continuam passando byte a byte igual, sem alterar nenhuma asserção
  </behavior>
  <action>
    Substitua TODO o conteúdo de `apps/mobile/src/territory/seal_solver.gd` por:

    ```gdscript
    class_name SealSolver
    extends RefCounted

    ## Pure function to solve the seal logic via exterior flood-fill.
    static func solve(runner_id: int, grid: TerritoryGrid, arc_tracker: ArcTracker) -> SealResult:
    	var result := SealResult.new()
    	result.runner_id = runner_id

    	if arc_tracker.length() == 0:
    		return result

    	var bbox := _compute_bounding_box(arc_tracker, grid)
    	result.bounding_box = bbox

    	var visited := _flood_fill_exterior(bbox, grid, runner_id)
    	_collect_captured_cells(bbox, grid, runner_id, visited, result)

    	for idx in arc_tracker._cells:
    		result.captured_cells.append(idx)

    	return result


    ## Bounding box do Arc, expandido em 1 célula para dar espaço ao flood fill exterior.
    static func _compute_bounding_box(arc_tracker: ArcTracker, grid: TerritoryGrid) -> Rect2i:
    	var min_x: int = grid.width
    	var max_x: int = 0
    	var min_y: int = grid.height
    	var max_y: int = 0

    	for idx in arc_tracker._cells:
    		var x: int = idx % grid.width
    		var y: int = idx / grid.width
    		if x < min_x: min_x = x
    		if x > max_x: max_x = x
    		if y < min_y: min_y = y
    		if y > max_y: max_y = y

    	min_x = maxi(0, min_x - 1)
    	max_x = mini(grid.width - 1, max_x + 1)
    	min_y = maxi(0, min_y - 1)
    	max_y = mini(grid.height - 1, max_y + 1)

    	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


    ## Flood fill a partir da borda da bounding box, marcando como "visitado" (exterior) tudo
    ## que não é claim nem arc do runner_id. O que sobra não-visitado é a região fechada.
    static func _flood_fill_exterior(bbox: Rect2i, grid: TerritoryGrid, runner_id: int) -> PackedByteArray:
    	var min_x: int = bbox.position.x
    	var min_y: int = bbox.position.y
    	var max_x: int = bbox.position.x + bbox.size.x - 1
    	var max_y: int = bbox.position.y + bbox.size.y - 1
    	var bbox_w: int = bbox.size.x

    	var visited := PackedByteArray()
    	visited.resize(bbox.size.x * bbox.size.y)
    	visited.fill(0)

    	var queue := PackedInt32Array()

    	for x in range(min_x, max_x + 1):
    		_enqueue_if_exterior(x, min_y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
    		_enqueue_if_exterior(x, max_y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)

    	for y in range(min_y + 1, max_y):
    		_enqueue_if_exterior(min_x, y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)
    		_enqueue_if_exterior(max_x, y, min_x, min_y, bbox_w, grid, runner_id, queue, visited)

    	var dx: Array[int] = [1, -1, 0, 0]
    	var dy: Array[int] = [0, 0, 1, -1]

    	var q_idx: int = 0
    	while q_idx < queue.size():
    		var pt_idx: int = queue[q_idx]
    		q_idx += 1

    		var lx: int = pt_idx % bbox_w
    		var ly: int = pt_idx / bbox_w
    		var gx: int = min_x + lx
    		var gy: int = min_y + ly

    		for i in range(4):
    			var nx: int = gx + dx[i]
    			var ny: int = gy + dy[i]

    			if nx >= min_x and nx <= max_x and ny >= min_y and ny <= max_y:
    				_enqueue_if_exterior(nx, ny, min_x, min_y, bbox_w, grid, runner_id, queue, visited)

    	return visited


    ## As células não visitadas pelo flood fill exterior (e que não são barreira) foram
    ## fechadas pelo Seal: entram em captured_cells, e quem era dono/arco alheio entra em
    ## stolen_from_owners/swallowed_arcs.
    static func _collect_captured_cells(bbox: Rect2i, grid: TerritoryGrid, runner_id: int, visited: PackedByteArray, result: SealResult) -> void:
    	var min_x: int = bbox.position.x
    	var min_y: int = bbox.position.y
    	var max_x: int = bbox.position.x + bbox.size.x - 1
    	var max_y: int = bbox.position.y + bbox.size.y - 1
    	var bbox_w: int = bbox.size.x

    	for y in range(min_y, max_y + 1):
    		for x in range(min_x, max_x + 1):
    			var lx: int = x - min_x
    			var ly: int = y - min_y
    			var local_idx: int = ly * bbox_w + lx

    			if visited[local_idx] == 0:
    				var global_idx: int = grid.cell_index(x, y)
    				var is_our_claim: bool = grid._owner[global_idx] == runner_id
    				var is_our_arc: bool = grid._arc[global_idx] == runner_id
    				var is_blocked: bool = grid.is_blocked(x, y)

    				if not is_our_claim and not is_our_arc and not is_blocked:
    					result.captured_cells.append(global_idx)

    					var owner: int = grid._owner[global_idx]
    					if owner != 254 and owner != 255:
    						if not result.stolen_from_owners.has(owner):
    							result.stolen_from_owners[owner] = 0
    						result.stolen_from_owners[owner] += 1

    					var arc_owner: int = grid._arc[global_idx]
    					if arc_owner != 255 and arc_owner != runner_id:
    						if not result.swallowed_arcs.has(arc_owner):
    							result.swallowed_arcs.append(arc_owner)


    static func _enqueue_if_exterior(gx: int, gy: int, min_x: int, min_y: int, bbox_w: int, grid: TerritoryGrid, runner_id: int, queue: PackedInt32Array, visited: PackedByteArray) -> void:
    	var lx: int = gx - min_x
    	var ly: int = gy - min_y
    	var local_idx: int = ly * bbox_w + lx

    	if visited[local_idx] == 1:
    		return

    	var global_idx: int = grid.cell_index(gx, gy)
    	var is_our_claim: bool = grid._owner[global_idx] == runner_id
    	var is_our_arc: bool = grid._arc[global_idx] == runner_id

    	if not is_our_claim and not is_our_arc:
    		visited[local_idx] = 1
    		queue.append(local_idx)
    ```

    Isto é uma decomposição byte-a-byte da lógica original em quatro funções — nenhuma
    condição, ordem de operação ou valor numérico muda. A única diferença real é tipagem
    estática explícita em toda variável local (corrige de brinde a dívida de lint pré-existente
    deste arquivo, sem tocar em nenhum outro arquivo com o mesmo tipo de dívida — isso é
    trabalho de outra fase).
  </action>
  <acceptance_criteria>
    - `./tools/ci/validate-repo.sh 2>&1 | grep -A2 '== 8\.'` não menciona `seal_solver.gd`
    - `awk '/^func |^static func /{if(s){print NR-s} s=NR} END{if(s){print NR-s+1}}' apps/mobile/src/territory/seal_solver.gd | sort -rn | head -1` é menor que 50
    - `./tools/ci/lint_gdscript.sh` não menciona `seal_solver.gd`
    - `grep -c '^func test_' apps/mobile/tests/unit/test_seal_solver.gd` continua 4 (arquivo de teste intocado)
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>! ./tools/ci/validate-repo.sh 2>&1 | grep -A5 '== 8\.' | grep -q seal_solver.gd && ! ./tools/ci/lint_gdscript.sh 2>&1 | grep -q seal_solver.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>seal_solver.gd decomposto em solve()/_compute_bounding_box()/_flood_fill_exterior()/_collect_captured_cells()/_enqueue_if_exterior(), todas abaixo de 50 linhas, totalmente tipado; os 4 testes de caracterização da Task 1 continuam verdes sem alteração; test-client.sh continua verde.</done>
</task>

</tasks>

<verification>
- `./tools/ci/validate-repo.sh` seção 8 não lista mais `seal_solver.gd` entre as funções acima de 50 linhas
- `./tools/ci/lint_gdscript.sh` não lista `seal_solver.gd` (tipagem completa)
- Os 4 testes de `test_seal_solver.gd` passam antes E depois da Task 2, sem alteração de asserção
- `./tools/ci/test-client.sh` sai com código 0
</verification>

<success_criteria>
`SealSolver.solve()` continua uma função pura e determinística, agora com nenhuma função acima
de 50 linhas e tipagem estática completa. O comportamento de captura de território é
byte-a-byte idêntico ao anterior, provado pelos 4 testes de caracterização escritos antes da
refatoração.
</success_criteria>

<output>
Após completar, crie `.planning/phases/26.1-correcao-quality-gate/26.1-02-SUMMARY.md` seguindo
o template de summary.md, registrando os 4 casos de caracterização e confirmando que passaram
antes e depois da decomposição.
</output>
