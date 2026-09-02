---
phase: 02-core-movement
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/core/bootstrap.gd
  - apps/mobile/src/runner/stat_block.gd
  - apps/mobile/src/runner/runner.gd
  - apps/mobile/tests/integration/test_bootstrap.gd
  - apps/mobile/tests/unit/test_stat_block.gd
  - apps/mobile/tests/unit/test_runner_movement.gd
autonomous: true
requirements:
  - MOV-02
must_haves:
  truths:
    - "O Runner gira e acelera usando os números de docs/design/balance.md §2 (base_speed=220, turn_rate=540), nunca um literal escondido em stat_block.gd ou runner.gd"
    - "Inverter a direção desejada em 180° leva exatamente 180/turn_rate segundos, medido tick a tick"
    - "ConfigService está registrado no Bootstrap e resolvível por 'config' antes de qualquer Runner ser criado no jogo real"
  artifacts:
    - path: "apps/mobile/src/runner/stat_block.gd"
      provides: "StatBlock construído a partir de RunnerBalance, sem literal de gameplay"
      contains: "func _init(balance: RunnerBalance"
    - path: "apps/mobile/src/runner/runner.gd"
      provides: "Runner aceita RunnerBalance no construtor e propaga para StatBlock"
      contains: "balance: RunnerBalance"
    - path: "apps/mobile/src/core/bootstrap.gd"
      provides: "passo 'config' nos _default_steps(), registrando um ConfigService carregado"
      contains: "\"config\""
  key_links:
    - from: "apps/mobile/src/core/bootstrap.gd"
      to: "apps/mobile/src/core/config/config_service.gd"
      via: "factory do passo 'config' -> ConfigService.new() + load_all()"
      pattern: "ConfigService.new"
    - from: "apps/mobile/src/runner/runner.gd"
      to: "apps/mobile/src/core/config/runner_balance.gd"
      via: "StatBlock.new(balance) lendo base_speed/turn_rate"
      pattern: "StatBlock.new\\(balance\\)"
---

<objective>
Fechar a lacuna encontrada pela auditoria de 2026-09-02 em MOVE-003: `StatBlock` hoje tem
`base_speed: float = 300.0` e `base_turn_rate: float = 180.0` **hardcoded**, violando a regra
"nenhum número de gameplay no código" (CLAUDE.md regra 4) e ignorando por completo
`RunnerBalance`/`packages/shared/config/balance/runner.tres` (220.0 / 540.0, per
`docs/design/balance.md` §2). Além disso, `ConfigService` — que já existe e já sabe carregar e
validar os 6 balances — **nunca é instanciado** em lugar nenhum do jogo real: `Bootstrap`
registra hoje 7 serviços (log, quality, haptics, vfx, wallet, catalog, profile_repo) e "config"
não está entre eles.

Purpose: fazer o Runner (jogador e bots) usar os números reais de balanceamento, e deixar
`ConfigService` alcançável via `Bootstrap.registry.resolve("config")` para que o Plano 02-05
(MatchDirector/composition root) possa buscar `RunnerBalance`/`CameraBalance` sem inventar um
segundo mecanismo de acesso a config.

Output: `StatBlock`/`Runner` sem literais de gameplay; `Bootstrap` com o passo `config`
registrado; testes que prendem os dois comportamentos no lugar.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/02-core-movement/02-CONTEXT.md
@.planning/ROADMAP.md
@docs/design/balance.md
@docs/decisions/ADR-0006-movement-model.md
</context>

<interfaces>
RunnerBalance (apps/mobile/src/core/config/runner_balance.gd) — contrato tipado, já existe,
NÃO MUDA neste plano:

    class_name RunnerBalance
    extends Resource
    @export_range(50.0, 600.0) var base_speed: float = 220.0
    @export_range(90.0, 1080.0) var turn_rate: float = 540.0
    @export_range(4.0, 32.0) var collision_radius: float = 10.0
    ... (demais campos inalterados)

ConfigService (apps/mobile/src/core/config/config_service.gd) — já existe, NÃO MUDA:

    class_name ConfigService
    extends RefCounted
    func load_all() -> bool: ...
    func runner() -> RunnerBalance: ...
    func camera() -> CameraBalance: ...
    func get_load_error() -> String: ...

Movement (apps/mobile/src/runner/movement.gd) — consumidor de StatBlock, NÃO MUDA (já lê
`stats.get_speed()`/`stats.get_turn_rate()`, nunca um literal):

    static func step(state: RunnerState, stats: StatBlock, delta: float) -> void: ...

ServiceRegistry (apps/mobile/src/core/service_registry.gd) — já existe, NÃO MUDA:

    func register(service_name: String, instance: Object) -> bool: ...
    func resolve(service_name: String) -> Object: ...

Bootstrap (apps/mobile/src/core/bootstrap.gd) — estado atual dos passos padrão, para você ver
exatamente onde entra o novo passo `config` (logo depois de `"log"`):

    func _default_steps() -> Array[Dictionary]:
    	return [
    		{"name": "log", "factory": func(): return Log},
    		{"name": "quality", "factory": func(): return QualityService.new()},
    		{"name": "haptics", "factory": func(): return HapticService.new()},
    		{"name": "vfx", "factory": func(): return VfxService.new()},
    		{"name": "wallet", "factory": func(): return Wallet.new()},
    		{"name": "catalog", "factory": func(): return Catalog.new()},
    		{"name": "profile_repo", "factory": func(): return LocalProfileRepository.new()}
    	]
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: StatBlock e Runner passam a ler RunnerBalance (fim do literal 300.0/180.0)</name>
  <files>apps/mobile/src/runner/stat_block.gd, apps/mobile/src/runner/runner.gd, apps/mobile/tests/unit/test_stat_block.gd, apps/mobile/tests/unit/test_runner_movement.gd</files>
  <read_first>
    - apps/mobile/src/runner/stat_block.gd (estado atual: base_speed=300.0, base_turn_rate=180.0, literais a remover)
    - apps/mobile/src/runner/runner.gd (estado atual: `_init` sem parâmetro de balance)
    - apps/mobile/src/runner/movement.gd (não muda; confirma o contrato get_speed()/get_turn_rate())
    - apps/mobile/src/core/config/runner_balance.gd (defaults 220.0/540.0 — a fonte, não duplicar)
    - docs/design/balance.md §2 (Runner: base_speed 220 u/s, turn_rate 540 °/s)
    - .planning/phases/02-core-movement/02-CONTEXT.md bloco `<reexecution>`, linha MOVE-003
    - apps/mobile/tests/unit/test_config_service.gd (padrão de teste GUT já usado para os balances)
  </read_first>
  <behavior>
    - `StatBlock.new()` (sem argumento) usa os defaults do próprio `RunnerBalance` (220.0 / 540.0) — nunca um segundo literal duplicado dentro de stat_block.gd
    - `StatBlock.new(balance)` com um `RunnerBalance` customizado usa exatamente os valores desse balance
    - Empilhar e remover modificadores de velocidade/giro continua sem resíduo (comportamento já existente, apenas re-provado)
    - `get_speed()` nunca fica negativo mesmo com modificador extremo negativo
    - `Runner.new(id, pos, dir, balance)` propaga `balance` para `StatBlock`; sem `balance`, cai no mesmo default de `RunnerBalance.new()`
    - Girar 180° com `turn_rate=540°/s` (o default real) leva exatamente `180/540 = 0.3333...s` = 20 ticks de `1/60s` — nem 19, nem 21
    - Um Runner em `RunnerState.State.ELIMINATED` não se move, mesmo chamando `tick()`
  </behavior>
  <action>
    Reescreva `apps/mobile/src/runner/stat_block.gd` para:

    ```gdscript
    class_name StatBlock
    extends RefCounted

    ## Estatísticas resolvidas de um Runner. base_speed/base_turn_rate vêm SEMPRE de um
    ## RunnerBalance (docs/design/balance.md §2, packages/shared/config/balance/runner.tres) —
    ## nunca de um literal aqui (CLAUDE.md regra 4). Sem balance explícito, usa
    ## RunnerBalance.new(), cujos defaults tipados JÁ são os valores de balance.md
    ## (core/config/runner_balance.gd) — não duplicamos o número numa segunda classe.

    var base_speed: float
    var base_turn_rate: float
    var speed_multiplier: float = 1.0

    var _speed_modifiers: Array[float] = []
    var _turn_rate_modifiers: Array[float] = []

    func _init(balance: RunnerBalance = null) -> void:
    	var b: RunnerBalance = balance if balance else RunnerBalance.new()
    	base_speed = b.base_speed
    	base_turn_rate = b.turn_rate

    func add_speed_modifier(value: float) -> void:
    	_speed_modifiers.append(value)

    func remove_speed_modifier(value: float) -> void:
    	var idx = _speed_modifiers.find(value)
    	if idx != -1:
    		_speed_modifiers.remove_at(idx)

    func add_turn_rate_modifier(value: float) -> void:
    	_turn_rate_modifiers.append(value)

    func remove_turn_rate_modifier(value: float) -> void:
    	var idx = _turn_rate_modifiers.find(value)
    	if idx != -1:
    		_turn_rate_modifiers.remove_at(idx)

    func get_speed() -> float:
    	var s = base_speed
    	for m in _speed_modifiers:
    		s += m
    	return maxf(0.0, s)

    func get_turn_rate() -> float:
    	var tr = base_turn_rate
    	for m in _turn_rate_modifiers:
    		tr += m
    	return maxf(0.0, tr)
    ```

    Em `apps/mobile/src/runner/runner.gd`, mude apenas a assinatura de `_init` e a construção
    de `stats`, mantendo todo o resto idêntico:

    ```gdscript
    class_name Runner
    extends RefCounted

    var state: RunnerState
    var stats: StatBlock

    func _init(runner_id: int, start_pos: Vector2, start_dir: Vector2, balance: RunnerBalance = null) -> void:
    	state = RunnerState.new()
    	state.id = runner_id
    	state.position = start_pos
    	state.direction = start_dir
    	state.desired_direction = start_dir
    	stats = StatBlock.new(balance)

    func set_desired_direction(dir: Vector2) -> void:
    	if dir.length_squared() > 0.01:
    		state.desired_direction = dir.normalized()

    func tick(delta: float) -> void:
    	Movement.step(state, stats, delta)
    ```

    `balance` tem default `null` de propósito: o único chamador de `Runner.new()` hoje
    (`match_director.gd:50`) será atualizado no Plano 02-05, que roda depois (wave 2) — até lá
    o comportamento sem argumento continua idêntico ao de antes (fallback para os defaults do
    `RunnerBalance`, que são os mesmos valores de balance.md).

    Crie `apps/mobile/tests/unit/test_stat_block.gd`:

    ```gdscript
    extends GutTest

    ## StatBlock (docs/design/balance.md §2). Garante que base_speed/base_turn_rate vêm de
    ## RunnerBalance — nunca de um literal duplicado em stat_block.gd — e que os modificadores
    ## empilham e removem sem resíduo (MOVE-003, TESTS.md test_stat_block.gd).

    func test_defaults_come_from_runner_balance() -> void:
    	var stats := StatBlock.new()
    	assert_eq(stats.get_speed(), 220.0)
    	assert_eq(stats.get_turn_rate(), 540.0)

    func test_custom_balance_overrides_defaults() -> void:
    	var balance := RunnerBalance.new()
    	balance.base_speed = 300.0
    	balance.turn_rate = 720.0
    	var stats := StatBlock.new(balance)
    	assert_eq(stats.get_speed(), 300.0)
    	assert_eq(stats.get_turn_rate(), 720.0)

    func test_speed_modifiers_stack_and_remove_without_residue() -> void:
    	var stats := StatBlock.new()
    	var base := stats.get_speed()
    	stats.add_speed_modifier(50.0)
    	stats.add_speed_modifier(-20.0)
    	assert_eq(stats.get_speed(), base + 30.0)
    	stats.remove_speed_modifier(50.0)
    	stats.remove_speed_modifier(-20.0)
    	assert_eq(stats.get_speed(), base, "remover todos os modificadores deveria voltar ao valor base")

    func test_turn_rate_modifiers_stack_and_remove_without_residue() -> void:
    	var stats := StatBlock.new()
    	var base := stats.get_turn_rate()
    	stats.add_turn_rate_modifier(100.0)
    	assert_eq(stats.get_turn_rate(), base + 100.0)
    	stats.remove_turn_rate_modifier(100.0)
    	assert_eq(stats.get_turn_rate(), base)

    func test_speed_never_goes_negative() -> void:
    	var stats := StatBlock.new()
    	stats.add_speed_modifier(-99999.0)
    	assert_eq(stats.get_speed(), 0.0)
    ```

    Crie `apps/mobile/tests/unit/test_runner_movement.gd`:

    ```gdscript
    extends GutTest

    ## Runner + Movement (docs/design/balance.md §2, ADR-0006). Prova que velocidade/giro vêm
    ## de RunnerBalance e que inverter 180° leva exatamente 180/turn_rate segundos — critério
    ## de sucesso #2 do ROADMAP da Fase 2.

    const PHYSICS_DT: float = 1.0 / 60.0

    func test_speed_and_turn_rate_come_from_balance() -> void:
    	var balance := RunnerBalance.new()
    	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP, balance)
    	assert_eq(runner.stats.get_speed(), balance.base_speed)
    	assert_eq(runner.stats.get_turn_rate(), balance.turn_rate)

    func test_constant_direction_moves_in_straight_line_at_base_speed() -> void:
    	var balance := RunnerBalance.new()
    	var runner := Runner.new(1, Vector2.ZERO, Vector2.RIGHT, balance)
    	runner.set_desired_direction(Vector2.RIGHT)
    	runner.tick(PHYSICS_DT)
    	assert_almost_eq(runner.state.position.x, balance.base_speed * PHYSICS_DT, 0.001)
    	assert_almost_eq(runner.state.position.y, 0.0, 0.001)

    func test_180_degree_turn_takes_exactly_180_over_turn_rate_seconds() -> void:
    	var balance := RunnerBalance.new()
    	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP, balance)
    	runner.set_desired_direction(Vector2.DOWN)

    	var expected_seconds: float = 180.0 / balance.turn_rate
    	var ticks_needed: int = int(round(expected_seconds / PHYSICS_DT))

    	for i in range(ticks_needed - 1):
    		runner.tick(PHYSICS_DT)
    	assert_gt(runner.state.direction.angle_to(Vector2.DOWN), deg_to_rad(1.0), "um tick antes do previsto a virada de 180° ainda não deveria estar completa")

    	runner.tick(PHYSICS_DT)
    	assert_almost_eq(runner.state.direction.angle_to(Vector2.DOWN), 0.0, 0.001, "após ticks_needed ticks a virada de 180° deveria estar completa")

    func test_eliminated_runner_does_not_move() -> void:
    	var runner := Runner.new(1, Vector2.ZERO, Vector2.UP, RunnerBalance.new())
    	runner.state.fsm_state = RunnerState.State.ELIMINATED
    	var start_pos := runner.state.position
    	runner.tick(PHYSICS_DT)
    	assert_eq(runner.state.position, start_pos)
    	assert_eq(runner.state.velocity, Vector2.ZERO)
    ```
  </action>
  <acceptance_criteria>
    - `grep -q "func _init(balance: RunnerBalance" apps/mobile/src/runner/stat_block.gd`
    - `! grep -q "300.0" apps/mobile/src/runner/stat_block.gd`
    - `! grep -qE "base_turn_rate: float = [0-9]" apps/mobile/src/runner/stat_block.gd`
    - `grep -q "balance: RunnerBalance = null" apps/mobile/src/runner/runner.gd`
    - `test -f apps/mobile/tests/unit/test_stat_block.gd`
    - `test -f apps/mobile/tests/unit/test_runner_movement.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "func _init(balance: RunnerBalance" apps/mobile/src/runner/stat_block.gd && ! grep -q "300.0" apps/mobile/src/runner/stat_block.gd && grep -q "balance: RunnerBalance = null" apps/mobile/src/runner/runner.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>stat_block.gd não contém mais 300.0/180.0; base_speed/base_turn_rate vêm de RunnerBalance; runner.gd aceita balance no construtor; os dois arquivos de teste novos passam; test-client.sh continua verde.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Bootstrap registra o serviço "config" (ConfigService carregado)</name>
  <files>apps/mobile/src/core/bootstrap.gd, apps/mobile/tests/integration/test_bootstrap.gd</files>
  <read_first>
    - apps/mobile/src/core/bootstrap.gd (função `_default_steps()`, 7 passos atuais)
    - apps/mobile/tests/integration/test_bootstrap.gd (padrão do repo: `BootstrapScript.new()` fora da árvore, sem depender de `_ready()`)
    - apps/mobile/src/core/config/config_service.gd (contrato: `load_all()`, `runner()`, `camera()`)
    - apps/mobile/src/core/service_registry.gd (`register`/`resolve`/`has`)
  </read_first>
  <behavior>
    - Depois de `boot()` com os passos padrão, `bootstrap.registry.has("config")` é verdadeiro
    - O objeto registrado em "config" é um `ConfigService` com `runner().base_speed == 220.0` (prova que `load_all()` rodou e leu o `.tres` real, não só o fallback embutido por acaso coincidir)
    - O passo "config" não quebra a ordem determinística de boot já provada por `test_boot_order_is_deterministic`
  </behavior>
  <action>
    Em `apps/mobile/src/core/bootstrap.gd`, adicione o passo `config` como o PRIMEIRO item da
    lista devolvida por `_default_steps()` (antes de `"log"`, já que outros passos podem no
    futuro precisar de config, e config não depende de nada):

    ```gdscript
    func _default_steps() -> Array[Dictionary]:
    	return [
    		{"name": "config", "factory": func() -> Object:
    			var svc := ConfigService.new()
    			svc.load_all()
    			return svc
    		},
    		{"name": "log", "factory": func(): return Log},
    		{"name": "quality", "factory": func(): return QualityService.new()},
    		{"name": "haptics", "factory": func(): return HapticService.new()},
    		{"name": "vfx", "factory": func(): return VfxService.new()},
    		{"name": "wallet", "factory": func(): return Wallet.new()},
    		{"name": "catalog", "factory": func(): return Catalog.new()},
    		{"name": "profile_repo", "factory": func(): return LocalProfileRepository.new()}
    	]
    ```

    Note que a factory sempre devolve um `ConfigService` válido (nunca `null`), mesmo se
    `load_all()` retornar `false` — `ConfigService._load_and_validate()` já cai nos defaults
    embutidos por arquivo (comportamento existente, não mude `config_service.gd` neste plano).
    Por isso não é preciso `essential: false`; o passo nunca falha o boot.

    Adicione a `apps/mobile/tests/integration/test_bootstrap.gd` (ao final do arquivo, mesmo
    padrão dos testes existentes: `BootstrapScript.new()`, `configure_steps()`, `boot()`):

    ```gdscript
    func test_default_steps_register_a_loaded_config_service() -> void:
    	var bootstrap := BootstrapScript.new()
    	bootstrap.configure_steps(bootstrap._default_steps())

    	bootstrap.boot()

    	assert_true(bootstrap.registry.has("config"), "Bootstrap deveria registrar um serviço 'config'")
    	var config := bootstrap.registry.resolve("config")
    	assert_true(config is ConfigService)
    	assert_eq((config as ConfigService).runner().base_speed, 220.0, "ConfigService deveria ter carregado runner.tres, não só o fallback por coincidência")
    ```
  </action>
  <acceptance_criteria>
    - `grep -q '"name": "config"' apps/mobile/src/core/bootstrap.gd`
    - `grep -q "ConfigService.new()" apps/mobile/src/core/bootstrap.gd`
    - `grep -q "svc.load_all()" apps/mobile/src/core/bootstrap.gd`
    - `grep -q "test_default_steps_register_a_loaded_config_service" apps/mobile/tests/integration/test_bootstrap.gd`
    - `./tools/ci/test-client.sh` sai com código 0
    - `./tools/ci/validate-repo.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q '"name": "config"' apps/mobile/src/core/bootstrap.gd && grep -q "svc.load_all()" apps/mobile/src/core/bootstrap.gd && ./tools/ci/test-client.sh && ./tools/ci/validate-repo.sh</automated>
  </verify>
  <done>Bootstrap._default_steps() registra "config" como um ConfigService já carregado; test_bootstrap.gd prova que ele é resolvível e que runner().base_speed é 220.0; test-client.sh e validate-repo.sh continuam verdes.</done>
</task>

</tasks>

<verification>
- `./tools/ci/test-client.sh` sai com código 0, incluindo os 3 arquivos de teste novos/alterados deste plano
- `./tools/ci/validate-repo.sh` sai com código 0 (nenhuma regressão nas 10 regras)
- `grep -c "300.0\|180.0" apps/mobile/src/runner/stat_block.gd` retorna 0
- `Bootstrap.registry.resolve("config")` (via teste) devolve um `ConfigService` com `runner().base_speed == 220.0`
</verification>

<success_criteria>
`StatBlock`/`Runner` não têm mais nenhum literal de velocidade ou taxa de giro — os dois vêm de
`RunnerBalance`, carregado por um `ConfigService` agora alcançável via
`Bootstrap.registry.resolve("config")`. Isso desbloqueia o Plano 02-05 (MatchDirector), que
precisa desse serviço para criar Runners com os números reais de `docs/design/balance.md`.
</success_criteria>

<output>
Após completar, crie `.planning/phases/02-core-movement/02-01-SUMMARY.md` seguindo o template
de summary.md, registrando os literais removidos, o novo passo de Bootstrap e os testes que
provam os dois.
</output>
</content>
