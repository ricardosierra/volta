extends GutTest

## Alcançabilidade e determinismo do núcleo de simulação (MOVE-002/003/005, ADR-0014,
## ROADMAP Fase 2 critérios de sucesso #1 e #5). Sobe um MatchDirector exatamente como
## root.gd faz (configure + setup_match), sem nenhum nó visual (nem RunnerView, nem
## GameCamera), e prova: (a) o Runner do jogador se move em resposta a
## InputRouter.poll_direction(), nunca a um InputEvent; (b) 600 ticks com a mesma
## configuração produzem exatamente o mesmo estado final em 10 execuções.

func _new_configured_director(bot_count: int) -> MatchDirector:
	var director: MatchDirector = add_child_autofree(MatchDirector.new())
	var arena_def := load("res://resources/arenas/open_field.tres") as ArenaDefinition
	var router := InputRouter.new()
	director.configure(ConfigService.new(), arena_def, router)
	var config := Resource.new()
	config.set_meta("bot_count", bot_count)
	director.setup_match(config)
	return director

func test_player_runner_moves_via_input_router_not_input_event() -> void:
	var director := _new_configured_director(0)
	var start_pos := director.player_runner.state.position

	director.input_router.buffer.push_command(Vector2.RIGHT)
	for i in range(10):
		director.step(1.0 / 60.0)

	assert_gt(director.player_runner.state.position.x, start_pos.x, "o jogador deveria ter se movido para a direita, vindo do InputRouter, sem nenhum InputEvent disparado")

func test_600_ticks_are_deterministic_across_ten_runs() -> void:
	var final_positions: Array[Vector2] = []

	for run in range(10):
		var director := _new_configured_director(2)
		for tick in range(600):
			director.step(1.0 / 60.0)

		var snapshot := Vector2.ZERO
		for r in director.runners:
			snapshot += r.state.position
		final_positions.append(snapshot)

	for i in range(1, final_positions.size()):
		assert_eq(final_positions[i], final_positions[0], "execução %d divergiu da execução 0 após 600 ticks com a mesma configuração" % i)

func test_headless_simulation_creates_no_visual_node() -> void:
	var director := _new_configured_director(1)
	for tick in range(60):
		director.step(1.0 / 60.0)
	for child in director.get_children():
		assert_false(child is Node2D, "a simulação não deveria instanciar nenhum nó visual (Node2D)")
