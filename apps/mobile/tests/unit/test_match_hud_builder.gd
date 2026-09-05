extends GutTest

## Regressão da extração de MatchHudBuilder (Regra 8 do CLAUDE.md). Testa a fábrica direto,
## sem instanciar MatchScreen inteira. Desde o Plano 02-06 (Fase 2): território/kills
## saíram da HUD (Fases 3/4 religam), e o overlay de resultado virou a tela dedicada
## ResultsScreen — build_result_overlay() não existe mais.

func test_build_hud_creates_all_expected_elements() -> void:
	var parent := Control.new()

	var elements := MatchHudBuilder.build_hud(parent, 40.0)

	var expected_keys := ["top_bar", "opponents_label", "time_label", "status_label",
		"countdown_label", "hint_label", "actions", "pause_button", "settings_button", "exit_button"]
	for key in expected_keys:
		assert_true(elements.has(key), "elements deveria conter '%s'" % key)
		assert_true(is_instance_valid(elements[key]), "'%s' deveria ser um nó válido" % key)

	assert_eq((elements["opponents_label"] as Label).text, "RIVAIS 0")
	assert_eq((elements["time_label"] as Label).text, "00:00")

	parent.queue_free()


func test_make_button_enforces_minimum_touch_target_height() -> void:
	var button := MatchHudBuilder.make_button("VOLTAR AO MENU", Vector2(440.0, 40.0), 40)

	assert_eq(button.custom_minimum_size.y, MatchScreen.MIN_TOUCH_TARGET_HEIGHT, "botão nunca pode ficar abaixo do alvo de toque mínimo")

	button.queue_free()
