extends GutTest

## Prova a ponta de apresentação da inversão de dependência: RunnerViewSpawner cria uma
## RunnerView por Runner emitido por MatchDirector, incluindo o jogador — desde o Plano
## 02-05, setup_match() sempre cria +1 Runner (o jogador) além dos bots.

func test_spawner_creates_a_runner_view_per_runner_including_the_player() -> void:
	var director := MatchDirector.new()
	var spawner := RunnerViewSpawner.new()
	spawner.watch(director)

	var config := Resource.new()
	config.set_meta("bot_count", 3)
	director.setup_match(config)

	assert_eq(spawner.get_child_count(), 4, "1 jogador + 3 bots")
	for child in spawner.get_children():
		assert_true(child is RunnerView, "cada filho deveria ser uma RunnerView")

	spawner.queue_free()
	director.queue_free()
