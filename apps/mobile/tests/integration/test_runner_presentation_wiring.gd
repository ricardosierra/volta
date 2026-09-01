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
