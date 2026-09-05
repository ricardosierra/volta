extends GutTest

## MatchScreen de-simulada (Plano 02-06): prova que a tela deixou de rodar sua própria
## simulação e que ela reflete o MatchDirector real sem crashar.

func test_match_screen_has_no_leftover_toy_simulation() -> void:
	var script: GDScript = load("res://src/ui/screens/match_screen.gd")
	var source: String = script.source_code
	assert_false(source.contains("PLAYER_SPEED"), "PLAYER_SPEED deveria ter saído junto com o loop de brinquedo")
	assert_false(source.contains("BOT_SPEED"), "BOT_SPEED deveria ter saído junto com o loop de brinquedo")
	assert_false(source.contains("_update_player"), "_update_player (simulação própria da tela) deveria ter sido removido")
	assert_false(source.contains("func _input(event: InputEvent)"), "MatchScreen não deveria mais ler InputEvent diretamente")

func test_on_pushed_builds_hud_without_crashing() -> void:
	var screen: MatchScreen = add_child_autofree(MatchScreen.new())
	screen.size = Vector2(1080, 1920)

	screen.on_pushed()

	assert_true(is_instance_valid(screen))

func test_opponents_label_reflects_real_match_director_runner_count() -> void:
	var screen: MatchScreen = add_child_autofree(MatchScreen.new())
	screen.size = Vector2(1080, 1920)
	screen.on_pushed()

	var director: MatchDirector = add_child_autofree(MatchDirector.new())
	var config := Resource.new()
	config.set_meta("bot_count", 3)
	director.setup_match(config)

	screen.set_match_director(director)
	screen._process(0.016)

	assert_eq(screen._opponents_label.text, "RIVAIS 3")
