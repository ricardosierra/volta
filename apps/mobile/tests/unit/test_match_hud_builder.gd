extends GutTest

## Regressão da extração de MatchHudBuilder (Regra 8 do CLAUDE.md). Testa a fábrica direto,
## sem instanciar MatchScreen inteira — evita depender de _hud_header_top() (achado
## pré-existente fora de escopo, ver objective do plano 03).

func test_build_hud_creates_all_expected_elements() -> void:
	var parent := Control.new()

	var elements := MatchHudBuilder.build_hud(parent, 40.0)

	var expected_keys := ["top_bar", "territory_label", "kills_label", "opponents_label",
		"time_label", "status_label", "territory_bar", "countdown_label", "hint_label",
		"actions", "exit_button"]
	for key in expected_keys:
		assert_true(elements.has(key), "elements deveria conter '%s'" % key)
		assert_true(is_instance_valid(elements[key]), "'%s' deveria ser um nó válido" % key)

	assert_eq((elements["territory_label"] as Label).text, "ÁREA 00%")
	assert_eq((elements["time_label"] as Label).text, "00:00")

	parent.queue_free()


func test_build_result_overlay_creates_all_expected_elements() -> void:
	var parent := Control.new()
	var elements: Dictionary = {}

	MatchHudBuilder.build_result_overlay(parent, elements)

	var expected_keys := ["result_overlay", "result_title", "result_detail", "restart_button", "menu_button"]
	for key in expected_keys:
		assert_true(elements.has(key), "elements deveria conter '%s'" % key)
		assert_true(is_instance_valid(elements[key]), "'%s' deveria ser um nó válido" % key)

	assert_false((elements["result_overlay"] as Control).visible, "overlay de resultado começa escondido")

	parent.queue_free()


func test_make_button_enforces_minimum_touch_target_height() -> void:
	var button := MatchHudBuilder.make_button("VOLTAR AO MENU", Vector2(440.0, 40.0), 40)

	assert_eq(button.custom_minimum_size.y, MatchScreen.MIN_TOUCH_TARGET_HEIGHT, "botão nunca pode ficar abaixo do alvo de toque mínimo")

	button.queue_free()
