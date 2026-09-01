---
phase: 26.1-correcao-quality-gate
plan: 3
type: execute
wave: 1
depends_on: []
files_modified:
  - apps/mobile/src/ui/screens/match_screen.gd
  - apps/mobile/src/ui/screens/match_hud_builder.gd
  - apps/mobile/src/ui/screens/match_field_renderer.gd
  - apps/mobile/src/ui/screens/main_menu_screen.gd
  - apps/mobile/tests/unit/test_match_hud_builder.gd
  - apps/mobile/tests/integration/test_match_field_renderer.gd
  - apps/mobile/tests/unit/test_main_menu_screen.gd
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "match_screen.gd tem menos de 600 linhas e nenhuma função (nele ou nos dois arquivos extraídos) passa de 50 linhas"
    - "main_menu_screen.gd não tem mais nenhuma função acima de 50 linhas"
    - "A HUD, o overlay de resultado e o desenho do campo de MatchScreen continuam produzindo exatamente os mesmos nós e o mesmo desenho de antes da divisão"
  artifacts:
    - path: "apps/mobile/src/ui/screens/match_hud_builder.gd"
      provides: "MatchHudBuilder — fábrica estática dos nós de HUD e do overlay de resultado, extraída de _build_hud()/_build_result_overlay()"
      contains: "class_name MatchHudBuilder"
      min_lines: 80
    - path: "apps/mobile/src/ui/screens/match_field_renderer.gd"
      provides: "MatchFieldRenderer — desenho do campo/bots/claim/trail/jogador, extraído de _draw()"
      contains: "class_name MatchFieldRenderer"
      min_lines: 60
    - path: "apps/mobile/src/ui/screens/match_screen.gd"
      provides: "Orquestração de partida (fase, input, física simplificada), delegando construção de nó e desenho para os dois arquivos extraídos"
    - path: "apps/mobile/src/ui/screens/main_menu_screen.gd"
      provides: "on_pushed() dividido em _build_title_block()/_build_play_controls()"
  key_links:
    - from: "apps/mobile/src/ui/screens/match_screen.gd"
      to: "apps/mobile/src/ui/screens/match_hud_builder.gd"
      via: "_build_hud()/_build_result_overlay() chamam MatchHudBuilder.build_hud()/build_result_overlay()"
      pattern: "MatchHudBuilder\\."
    - from: "apps/mobile/src/ui/screens/match_screen.gd"
      to: "apps/mobile/src/ui/screens/match_field_renderer.gd"
      via: "_draw() chama MatchFieldRenderer.draw(self, {...})"
      pattern: "MatchFieldRenderer\\.draw"
---

<objective>
Três violações de tamanho do quality gate (Regra 8) moram na camada de UI:
`apps/mobile/src/ui/screens/match_screen.gd` tem 867 linhas com três funções acima de 50
(`_build_hud` 87, `_build_result_overlay` 54, `_draw` 93), e
`apps/mobile/src/ui/screens/main_menu_screen.gd` tem uma função de 55 linhas (`on_pushed`).

Purpose: decompor por responsabilidade coesa — construção de nó de HUD numa fábrica nova
(`MatchHudBuilder`), desenho do campo noutra (`MatchFieldRenderer`) — sem mudar UM pixel do
que é desenhado nem UMA propriedade do que é construído. `main_menu_screen.gd` só precisa de
dois métodos privados novos, sem arquivo novo (o arquivo inteiro tem 63 linhas).

Output: `match_hud_builder.gd` e `match_field_renderer.gd` (novos), `match_screen.gd` e
`main_menu_screen.gd` reduzidos, e três suítes de teste que travam o comportamento das partes
extraídas.

ACHADO FORA DE ESCOPO (não corrigir neste plano): `match_screen.gd` chama
`_hud_header_top()` e `_safe_bottom_inset()` (em `_build_hud()`/`_layout_hud()`), mas nenhum
arquivo do projeto define essas duas funções — é bug pré-existente, não listado nos defeitos
desta fase. Preserve as duas chamadas exatamente onde estão hoje (dentro de `MatchScreen`,
nunca movidas para os arquivos novos) para não mudar esse comportamento (bom ou ruim) nem para
melhor nem para pior. Se ao rodar `./tools/ci/test-client.sh` isso já causar falha ANTES do seu
refactor, registre em SUMMARY.md como bloqueio pré-existente fora do escopo de QLT-06 e
prossiga — seu trabalho é não piorar nem mascarar esse achado, não corrigi-lo.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/26.1-correcao-quality-gate/26.1-CONTEXT.md
@.planning/ROADMAP.md
</context>

<interfaces>
Constantes de MatchScreen que os dois arquivos novos referenciam por nome de classe
(`MatchScreen.CONST`), sem duplicar valor — ficam declaradas em match_screen.gd, inalteradas:

    const FIELD_MARGIN: float = 72.0
    const FIELD_BOTTOM: float = 1470.0
    const PANEL_MARGIN: float = 48.0
    const PLAYER_RADIUS: float = 28.0
    const BOT_RADIUS: float = 26.0
    const MIN_TOUCH_TARGET_HEIGHT: float = 136.0

Screen (apps/mobile/src/ui/navigation/screen.gd) — base de MatchScreen e MainMenuScreen,
inalterada:

    class_name Screen
    extends Control
    signal back_requested
    signal exit_requested
    func on_pushed(args: Dictionary = {}) -> void: pass
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Extrair MatchHudBuilder de match_screen.gd (_build_hud, _build_result_overlay e os 4 factories de nó)</name>
  <files>apps/mobile/src/ui/screens/match_hud_builder.gd, apps/mobile/src/ui/screens/match_screen.gd, apps/mobile/tests/unit/test_match_hud_builder.gd</files>
  <read_first>
    - apps/mobile/src/ui/screens/match_screen.gd (linhas 1-19 para as consts, 431-641 para tudo que sai)
    - apps/mobile/src/ui/navigation/screen.gd
    - docs/architecture/overview.md §5 (ordem de arquivo, um tipo por arquivo, `_prefixo` é privado)
  </read_first>
  <behavior>
    - MatchHudBuilder.build_hud(parent, header_top) devolve um Dictionary com as chaves top_bar, territory_label, kills_label, opponents_label, time_label, status_label, territory_bar, countdown_label, hint_label, actions, exit_button — todos nós válidos e filhos de parent
    - MatchHudBuilder.build_result_overlay(parent, elements) preenche elements com result_overlay, result_title, result_detail, restart_button, menu_button — result_overlay começa oculto (hide())
    - make_button() nunca deixa custom_minimum_size.y abaixo de MatchScreen.MIN_TOUCH_TARGET_HEIGHT
  </behavior>
  <action>
    Crie `apps/mobile/src/ui/screens/match_hud_builder.gd` com EXATAMENTE este conteúdo (é a
    lógica de `_build_hud`/`_build_result_overlay`/`_make_hud_label`/`_make_result_label`/
    `_make_button`/`_style_box` de match_screen.gd, reorganizada em funções menores; nenhum
    valor, cor, offset ou ordem de `add_child` muda — só `add_child(x)` virou `parent.add_child(x)`
    e os campos que antes eram `_prefixados` de MatchScreen agora são devolvidos num Dictionary):

    ```gdscript
    class_name MatchHudBuilder
    extends RefCounted

    ## Fábrica dos nós de HUD de MatchScreen. Extraída por tamanho de função (Regra 8 do
    ## CLAUDE.md — _build_hud tinha 87 linhas, _build_result_overlay tinha 54). Só cria e
    ## devolve nós; MatchScreen decide o que guardar e a que sinal conectar.

    static func build_hud(parent: Control, header_top: float) -> Dictionary:
    	var elements: Dictionary = {}
    	_build_top_bar(parent, header_top, elements)
    	_build_status_row(parent, header_top, elements)
    	_build_countdown_label(parent, elements)
    	_build_hint_label(parent, elements)
    	_build_actions(parent, elements)
    	return elements


    static func build_result_overlay(parent: Control, elements: Dictionary) -> void:
    	_build_result_shell(parent, elements)
    	_build_result_content(elements)


    static func _build_top_bar(parent: Control, header_top: float, elements: Dictionary) -> void:
    	var top_bar := HBoxContainer.new()
    	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
    	top_bar.offset_left = MatchScreen.PANEL_MARGIN
    	top_bar.offset_top = header_top + 14.0
    	top_bar.offset_right = -MatchScreen.PANEL_MARGIN
    	top_bar.offset_bottom = header_top + 112.0
    	top_bar.add_theme_constant_override("separation", 12)
    	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	parent.add_child(top_bar)

    	var territory_label := make_hud_label("ÁREA 00%", HORIZONTAL_ALIGNMENT_LEFT, 38)
    	territory_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    	top_bar.add_child(territory_label)

    	var kills_label := make_hud_label("KOs 0", HORIZONTAL_ALIGNMENT_CENTER, 38)
    	kills_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    	top_bar.add_child(kills_label)

    	var opponents_label := make_hud_label("RIVAIS 0", HORIZONTAL_ALIGNMENT_CENTER, 38)
    	opponents_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    	top_bar.add_child(opponents_label)

    	var time_label := make_hud_label("00:00", HORIZONTAL_ALIGNMENT_RIGHT, 38)
    	time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    	top_bar.add_child(time_label)

    	elements["top_bar"] = top_bar
    	elements["territory_label"] = territory_label
    	elements["kills_label"] = kills_label
    	elements["opponents_label"] = opponents_label
    	elements["time_label"] = time_label


    static func _build_status_row(parent: Control, header_top: float, elements: Dictionary) -> void:
    	var status_label := make_hud_label("PARTIDA  •  CORTE OS RASTROS", HORIZONTAL_ALIGNMENT_CENTER, 36)
    	status_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
    	status_label.offset_left = MatchScreen.FIELD_MARGIN
    	status_label.offset_top = header_top + 130.0
    	status_label.offset_right = -MatchScreen.FIELD_MARGIN
    	status_label.offset_bottom = header_top + 176.0
    	parent.add_child(status_label)

    	var territory_bar := ProgressBar.new()
    	territory_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
    	territory_bar.offset_left = MatchScreen.FIELD_MARGIN
    	territory_bar.offset_top = header_top + 186.0
    	territory_bar.offset_right = -MatchScreen.FIELD_MARGIN
    	territory_bar.offset_bottom = header_top + 216.0
    	territory_bar.max_value = 100.0
    	territory_bar.show_percentage = false
    	territory_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	territory_bar.add_theme_stylebox_override("background", style_box(Color("102235"), Color("1d3d56"), 1, 12))
    	territory_bar.add_theme_stylebox_override("fill", style_box(Color("2dd4bf"), Color("6fffe9"), 1, 12))
    	parent.add_child(territory_bar)

    	elements["status_label"] = status_label
    	elements["territory_bar"] = territory_bar


    static func _build_countdown_label(parent: Control, elements: Dictionary) -> void:
    	var countdown_label := Label.new()
    	countdown_label.set_anchors_preset(Control.PRESET_CENTER)
    	countdown_label.offset_left = -180.0
    	countdown_label.offset_top = -125.0
    	countdown_label.offset_right = 180.0
    	countdown_label.offset_bottom = 40.0
    	countdown_label.add_theme_font_size_override("font_size", 108)
    	countdown_label.add_theme_color_override("font_color", Color("f8fbff"))
    	countdown_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
    	countdown_label.add_theme_constant_override("shadow_offset_x", 4)
    	countdown_label.add_theme_constant_override("shadow_offset_y", 6)
    	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    	countdown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	parent.add_child(countdown_label)

    	elements["countdown_label"] = countdown_label


    static func _build_hint_label(parent: Control, elements: Dictionary) -> void:
    	var hint_label := make_hud_label("DESLIZE OU USE AS SETAS PARA VIRAR", HORIZONTAL_ALIGNMENT_CENTER, 34)
    	hint_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
    	hint_label.offset_left = MatchScreen.FIELD_MARGIN
    	hint_label.offset_top = MatchScreen.FIELD_BOTTOM + 88.0
    	hint_label.offset_right = -MatchScreen.FIELD_MARGIN
    	hint_label.offset_bottom = MatchScreen.FIELD_BOTTOM + 148.0
    	parent.add_child(hint_label)

    	elements["hint_label"] = hint_label


    static func _build_actions(parent: Control, elements: Dictionary) -> void:
    	var actions := CenterContainer.new()
    	actions.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    	actions.offset_top = -236.0
    	actions.offset_bottom = -92.0
    	actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	parent.add_child(actions)

    	var exit_button := make_button("VOLTAR AO MENU", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 40)
    	actions.add_child(exit_button)

    	elements["actions"] = actions
    	elements["exit_button"] = exit_button


    static func _build_result_shell(parent: Control, elements: Dictionary) -> void:
    	var result_overlay := Control.new()
    	result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    	parent.add_child(result_overlay)

    	var dimmer := ColorRect.new()
    	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	dimmer.color = Color(0.02, 0.04, 0.08, 0.88)
    	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
    	result_overlay.add_child(dimmer)

    	var center := CenterContainer.new()
    	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	result_overlay.add_child(center)

    	var panel := PanelContainer.new()
    	panel.custom_minimum_size = Vector2(760.0, 800.0)
    	panel.add_theme_stylebox_override("panel", style_box(Color("0c1a2a"), Color("2dd4bf"), 2, 24))
    	center.add_child(panel)

    	var box := VBoxContainer.new()
    	box.add_theme_constant_override("separation", 28)
    	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	box.add_theme_constant_override("margin_left", 48)
    	box.add_theme_constant_override("margin_right", 48)
    	box.add_theme_constant_override("margin_top", 48)
    	box.add_theme_constant_override("margin_bottom", 48)
    	panel.add_child(box)

    	result_overlay.hide()

    	elements["result_overlay"] = result_overlay
    	elements["result_box"] = box


    static func _build_result_content(elements: Dictionary) -> void:
    	var box: VBoxContainer = elements["result_box"]

    	var kicker := make_result_label("RESULTADO DA RODADA", 30, Color("6fffe9"))
    	box.add_child(kicker)

    	var result_title := make_result_label("VITÓRIA", 80, Color("f8fbff"))
    	box.add_child(result_title)

    	var result_detail := make_result_label("", 38, Color("b9cce0"))
    	result_detail.custom_minimum_size = Vector2(0.0, 250.0)
    	box.add_child(result_detail)

    	var restart_button := make_button("JOGAR NOVAMENTE", Vector2(0.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 40)
    	restart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    	box.add_child(restart_button)

    	var menu_button := make_button("VOLTAR AO MENU", Vector2(0.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 38)
    	menu_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    	box.add_child(menu_button)

    	elements["result_title"] = result_title
    	elements["result_detail"] = result_detail
    	elements["restart_button"] = restart_button
    	elements["menu_button"] = menu_button


    static func make_hud_label(text: String, alignment: HorizontalAlignment, font_size: int) -> Label:
    	var label := Label.new()
    	label.text = text
    	label.add_theme_font_size_override("font_size", font_size)
    	label.add_theme_color_override("font_color", Color("e5f1ff"))
    	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
    	label.add_theme_constant_override("shadow_offset_x", 2)
    	label.add_theme_constant_override("shadow_offset_y", 2)
    	label.horizontal_alignment = alignment
    	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	return label


    static func make_result_label(text: String, font_size: int, color: Color) -> Label:
    	var label := make_hud_label(text, HORIZONTAL_ALIGNMENT_CENTER, font_size)
    	label.add_theme_color_override("font_color", color)
    	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    	return label


    static func make_button(text: String, minimum_size: Vector2, font_size: int) -> Button:
    	var button := Button.new()
    	button.text = text
    	var touch_size := minimum_size
    	touch_size.y = maxf(touch_size.y, MatchScreen.MIN_TOUCH_TARGET_HEIGHT)
    	button.custom_minimum_size = touch_size
    	button.add_theme_font_size_override("font_size", font_size)
    	button.add_theme_color_override("font_color", Color("f7fbff"))
    	button.add_theme_color_override("font_hover_color", Color("ffffff"))
    	button.add_theme_stylebox_override("normal", style_box(Color("13283a"), Color("28506a"), 1, 12))
    	button.add_theme_stylebox_override("hover", style_box(Color("1a3d4f"), Color("6fffe9"), 2, 12))
    	button.add_theme_stylebox_override("pressed", style_box(Color("0d1e2e"), Color("f9c74f"), 2, 12))
    	return button


    static func style_box(background: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
    	var box := StyleBoxFlat.new()
    	box.bg_color = background
    	box.border_color = border
    	box.set_border_width_all(border_width)
    	box.set_corner_radius_all(radius)
    	box.content_margin_left = 20.0
    	box.content_margin_right = 20.0
    	box.content_margin_top = 12.0
    	box.content_margin_bottom = 12.0
    	return box
    ```

    Em `apps/mobile/src/ui/screens/match_screen.gd`, substitua `_build_hud()`,
    `_build_result_overlay()`, `_make_hud_label()`, `_make_result_label()`, `_make_button()` e
    `_style_box()` por:

    ```gdscript
    func _build_hud() -> void:
    	var header_top := _hud_header_top()
    	var elements := MatchHudBuilder.build_hud(self, header_top)
    	_top_bar = elements["top_bar"]
    	_territory_label = elements["territory_label"]
    	_kills_label = elements["kills_label"]
    	_opponents_label = elements["opponents_label"]
    	_time_label = elements["time_label"]
    	_status_label = elements["status_label"]
    	_territory_bar = elements["territory_bar"]
    	_countdown_label = elements["countdown_label"]
    	_hint_label = elements["hint_label"]
    	_actions = elements["actions"]
    	(elements["exit_button"] as Button).pressed.connect(_on_exit_pressed)

    	_build_result_overlay()


    func _build_result_overlay() -> void:
    	var elements: Dictionary = {}
    	MatchHudBuilder.build_result_overlay(self, elements)
    	_result_overlay = elements["result_overlay"]
    	_result_title = elements["result_title"]
    	_result_detail = elements["result_detail"]
    	(elements["restart_button"] as Button).pressed.connect(_on_restart_pressed)
    	(elements["menu_button"] as Button).pressed.connect(_on_exit_pressed)
    ```

    Note que `_hud_header_top()` continua chamada de dentro de `MatchScreen` (não mova para
    `MatchHudBuilder`) — ver aviso no `<objective>` deste plano sobre essa função não existir em
    lugar nenhum.

    Crie `apps/mobile/tests/unit/test_match_hud_builder.gd`:

    ```gdscript
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
    ```
  </action>
  <acceptance_criteria>
    - `test -f apps/mobile/src/ui/screens/match_hud_builder.gd`
    - `grep -q 'class_name MatchHudBuilder' apps/mobile/src/ui/screens/match_hud_builder.gd`
    - `grep -c 'MatchHudBuilder\.' apps/mobile/src/ui/screens/match_screen.gd` é >= 2
    - `awk '/^func |^static func /{if(s){print NR-s} s=NR} END{if(s){print NR-s+1}}' apps/mobile/src/ui/screens/match_hud_builder.gd | sort -rn | head -1` é menor que 50
    - `test -f apps/mobile/tests/unit/test_match_hud_builder.gd`
    - `./tools/ci/lint_gdscript.sh` não menciona `match_hud_builder.gd`
  </acceptance_criteria>
  <verify>
    <automated>grep -q 'class_name MatchHudBuilder' apps/mobile/src/ui/screens/match_hud_builder.gd && [ "$(grep -c 'MatchHudBuilder\.' apps/mobile/src/ui/screens/match_screen.gd)" -ge 2 ] && ! ./tools/ci/lint_gdscript.sh 2>&1 | grep -q match_hud_builder.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>MatchHudBuilder existe com build_hud()/build_result_overlay()/make_hud_label()/make_result_label()/make_button()/style_box(), todas abaixo de 50 linhas; match_screen.gd delega a construção da HUD e do overlay de resultado para ele, conectando os sinais dos botões; os 3 testes novos passam; test-client.sh continua verde.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Extrair MatchFieldRenderer de match_screen.gd (_draw e os 3 sub-desenhos)</name>
  <files>apps/mobile/src/ui/screens/match_field_renderer.gd, apps/mobile/src/ui/screens/match_screen.gd, apps/mobile/tests/integration/test_match_field_renderer.gd</files>
  <read_first>
    - apps/mobile/src/ui/screens/match_screen.gd (função _draw, linhas 643-778, após a Task 1 deste plano já ter rodado)
    - apps/mobile/addons/gut/test.gd (add_child_autofree, linha ~2780)
  </read_first>
  <behavior>
    - MatchFieldRenderer.draw(canvas, state) com size.x/size.y <= 0 retorna sem desenhar nada
    - MatchFieldRenderer.draw(canvas, state) com um estado típico de partida (1 bot vivo, claim ativo, trail em progresso) completa sem lançar erro dentro do ciclo real de _draw() do motor
  </behavior>
  <action>
    Crie `apps/mobile/src/ui/screens/match_field_renderer.gd` com EXATAMENTE este conteúdo (é
    `_draw`/`_draw_field_brackets`/`_draw_bot`/`_draw_eliminated_bot` de match_screen.gd,
    reorganizados; toda chamada `draw_*` vira `canvas.draw_*`, e os campos `_prefixados` de
    MatchScreen viram chaves de um Dictionary `state` passado de fora):

    ```gdscript
    class_name MatchFieldRenderer
    extends RefCounted

    ## Desenha o campo, os bots, o claim, o trail e o jogador de MatchScreen. Extraído por
    ## tamanho de função (Regra 8 do CLAUDE.md — _draw() tinha 93 linhas). Pura leitura de
    ## estado via CanvasItem.draw_*, chamado de dentro do _draw() real de MatchScreen (Godot só
    ## permite draw_* durante o callback _draw() do próprio nó).

    static func draw(canvas: CanvasItem, state: Dictionary) -> void:
    	var size: Vector2 = state["size"]
    	if size.x <= 0.0 or size.y <= 0.0:
    		return

    	_draw_background(canvas, state)
    	_draw_field(canvas, state)
    	_draw_bot_homes_and_trails(canvas, state)
    	_draw_claim_and_trail(canvas, state)
    	_draw_runners(canvas, state)
    	_draw_footer(canvas, state)


    static func _draw_background(canvas: CanvasItem, state: Dictionary) -> void:
    	var size: Vector2 = state["size"]
    	var viewport_rect := Rect2(Vector2.ZERO, size)
    	canvas.draw_rect(viewport_rect, Color("050b15"))

    	for diagonal in range(-8, 18):
    		var start := Vector2(float(diagonal) * 160.0, 0.0)
    		canvas.draw_line(start, start + Vector2(-size.y * 0.42, size.y), Color(0.08, 0.20, 0.30, 0.18), 2.0)

    	var header := Rect2(MatchScreen.PANEL_MARGIN, 28.0, size.x - MatchScreen.PANEL_MARGIN * 2.0, 190.0)
    	canvas.draw_rect(header, Color("0a1726"))
    	canvas.draw_rect(Rect2(header.position, Vector2(6.0, header.size.y)), Color("2dd4bf"))
    	canvas.draw_line(
    		Vector2(header.position.x + 28.0, header.end.y - 2.0),
    		Vector2(header.end.x - 28.0, header.end.y - 2.0),
    		Color("1d3d56"),
    		2.0
    	)


    static func _draw_field(canvas: CanvasItem, state: Dictionary) -> void:
    	var field: Rect2 = state["field"]
    	canvas.draw_rect(field.grow(24.0), Color(0.0, 0.0, 0.0, 0.26))
    	canvas.draw_rect(field.grow(12.0), Color("0a1a29"))
    	canvas.draw_rect(field, Color("091f2d"))
    	canvas.draw_rect(field, Color("2dd4bf"), false, 3.0)

    	for column in range(1, 12):
    		var x := field.position.x + field.size.x * float(column) / 12.0
    		canvas.draw_line(Vector2(x, field.position.y), Vector2(x, field.end.y), Color(0.15, 0.52, 0.58, 0.16), 1.0)
    	for row in range(1, 13):
    		var y := field.position.y + field.size.y * float(row) / 13.0
    		canvas.draw_line(Vector2(field.position.x, y), Vector2(field.end.x, y), Color(0.15, 0.52, 0.58, 0.16), 1.0)

    	_draw_field_brackets(canvas, field)


    static func _draw_field_brackets(canvas: CanvasItem, field: Rect2) -> void:
    	var length := 34.0
    	var color := Color("65f4df")
    	var left := field.position.x
    	var right := field.end.x
    	var top := field.position.y
    	var bottom := field.end.y

    	canvas.draw_line(Vector2(left, top + length), Vector2(left, top), color, 5.0)
    	canvas.draw_line(Vector2(left, top), Vector2(left + length, top), color, 5.0)
    	canvas.draw_line(Vector2(right - length, top), Vector2(right, top), color, 5.0)
    	canvas.draw_line(Vector2(right, top), Vector2(right, top + length), color, 5.0)
    	canvas.draw_line(Vector2(left, bottom - length), Vector2(left, bottom), color, 5.0)
    	canvas.draw_line(Vector2(left, bottom), Vector2(left + length, bottom), color, 5.0)
    	canvas.draw_line(Vector2(right - length, bottom), Vector2(right, bottom), color, 5.0)
    	canvas.draw_line(Vector2(right, bottom - length), Vector2(right, bottom), color, 5.0)


    static func _draw_bot_homes_and_trails(canvas: CanvasItem, state: Dictionary) -> void:
    	var bot_positions: Array = state["bot_positions"]
    	var bot_alive: Array = state["bot_alive"]
    	var bot_home_rects: Array = state["bot_home_rects"]
    	var bot_trails: Array = state["bot_trails"]
    	var bot_colors: Array = state["bot_colors"]

    	for index in range(bot_positions.size()):
    		if not bot_alive[index]:
    			continue
    		var home: Rect2 = bot_home_rects[index]
    		var bot_color: Color = bot_colors[index % bot_colors.size()]
    		canvas.draw_rect(home, Color(bot_color, 0.035))
    		canvas.draw_rect(home, Color(bot_color, 0.28), false, 2.0)
    		var bot_trail: Array = bot_trails[index]
    		if bot_trail.size() > 1:
    			canvas.draw_polyline(PackedVector2Array(bot_trail), Color(0.0, 0.0, 0.0, 0.35), 18.0, true)
    			canvas.draw_polyline(PackedVector2Array(bot_trail), Color(bot_color, 0.82), 8.0, true)
    			canvas.draw_polyline(PackedVector2Array(bot_trail), Color(bot_color, 0.20), 22.0, true)


    static func _draw_claim_and_trail(canvas: CanvasItem, state: Dictionary) -> void:
    	if state["round_initialized"]:
    		var claim_rect: Rect2 = state["claim_rect"]
    		canvas.draw_rect(claim_rect.grow(8.0), Color("0b766f"), false, 8.0)
    		canvas.draw_rect(claim_rect, Color(0.12, 0.68, 0.60, 0.20))
    		canvas.draw_rect(claim_rect, Color("57e6d0"), false, 3.0)
    		for stripe in range(-2, 8):
    			var stripe_start := Vector2(claim_rect.position.x + float(stripe) * 90.0, claim_rect.end.y)
    			var stripe_end := stripe_start + Vector2(220.0, -220.0)
    			canvas.draw_line(stripe_start, stripe_end, Color(0.34, 0.95, 0.84, 0.12), 3.0)

    	var trail: Array = state["trail"]
    	if trail.size() > 1:
    		canvas.draw_polyline(PackedVector2Array(trail), Color(0.0, 0.0, 0.0, 0.42), 22.0, true)
    		canvas.draw_polyline(PackedVector2Array(trail), Color("f9c74f"), 11.0, true)
    		canvas.draw_polyline(PackedVector2Array(trail), Color("fff3b0"), 3.0, true)


    static func _draw_runners(canvas: CanvasItem, state: Dictionary) -> void:
    	var bot_positions: Array = state["bot_positions"]
    	var bot_alive: Array = state["bot_alive"]
    	var bot_flash: Array = state["bot_flash"]
    	var bot_colors: Array = state["bot_colors"]
    	var bot_directions: Array = state["bot_directions"]

    	for index in range(bot_positions.size()):
    		var bot_color: Color = bot_colors[index % bot_colors.size()]
    		if bot_alive[index]:
    			_draw_bot(canvas, bot_positions[index], bot_color, MatchScreen.BOT_RADIUS, bot_directions[index])
    		elif bot_flash[index] > 0.0:
    			_draw_eliminated_bot(canvas, bot_positions[index], bot_color, bot_flash[index])

    	if state["round_initialized"]:
    		var player_position: Vector2 = state["player_position"]
    		var player_direction: Vector2 = state["player_direction"]
    		var elapsed: float = state["elapsed"]
    		var pulse := 4.0 + sin(elapsed * 7.0) * 3.0
    		canvas.draw_circle(player_position, MatchScreen.PLAYER_RADIUS + 16.0 + pulse, Color(0.98, 0.78, 0.31, 0.10))
    		canvas.draw_circle(player_position, MatchScreen.PLAYER_RADIUS + 7.0, Color("f9c74f"), false, 3.0)
    		canvas.draw_circle(player_position, MatchScreen.PLAYER_RADIUS, Color("f9c74f"))
    		canvas.draw_line(
    			player_position,
    			player_position + player_direction * 42.0,
    			Color("fff3b0"),
    			5.0,
    			true
    		)


    static func _draw_bot(canvas: CanvasItem, position: Vector2, color: Color, radius: float, direction: Vector2) -> void:
    	canvas.draw_circle(position, radius + 16.0, Color(color, 0.10))
    	canvas.draw_circle(position, radius + 7.0, Color(color, 0.24), false, 3.0)
    	canvas.draw_circle(position, radius, color)
    	canvas.draw_line(position, position + direction * 32.0, Color("f4fbff"), 4.0, true)


    static func _draw_eliminated_bot(canvas: CanvasItem, position: Vector2, color: Color, strength: float) -> void:
    	var radius := MatchScreen.BOT_RADIUS + (1.0 - strength) * 24.0
    	canvas.draw_circle(position, radius, Color(color, strength * 0.16), false, 4.0)
    	canvas.draw_line(
    		position - Vector2(radius, radius),
    		position + Vector2(radius, radius),
    		Color("ff6b6b", strength),
    		5.0,
    		true
    	)
    	canvas.draw_line(
    		position + Vector2(-radius, radius),
    		position + Vector2(radius, -radius),
    		Color("ff6b6b", strength),
    		5.0,
    		true
    	)


    static func _draw_footer(canvas: CanvasItem, state: Dictionary) -> void:
    	var size: Vector2 = state["size"]
    	var footer := Rect2(MatchScreen.PANEL_MARGIN, MatchScreen.FIELD_BOTTOM + 58.0, size.x - MatchScreen.PANEL_MARGIN * 2.0, 160.0)
    	canvas.draw_rect(footer, Color("081521"))
    	canvas.draw_line(
    		Vector2(footer.position.x + 24.0, footer.position.y),
    		Vector2(footer.end.x - 24.0, footer.position.y),
    		Color("1d3d56"),
    		2.0
    	)
    ```

    Em `apps/mobile/src/ui/screens/match_screen.gd`, substitua `_draw()`,
    `_draw_field_brackets()`, `_draw_bot()` e `_draw_eliminated_bot()` por:

    ```gdscript
    func _draw() -> void:
    	MatchFieldRenderer.draw(self, {
    		"size": size,
    		"field": _field_rect(),
    		"bot_positions": _bot_positions,
    		"bot_directions": _bot_directions,
    		"bot_trails": _bot_trails,
    		"bot_home_rects": _bot_home_rects,
    		"bot_alive": _bot_alive,
    		"bot_flash": _bot_flash,
    		"bot_colors": _bot_colors,
    		"round_initialized": _round_initialized,
    		"claim_rect": _claim_rect,
    		"trail": _trail,
    		"player_position": _player_position,
    		"player_direction": _player_direction,
    		"elapsed": _elapsed,
    	})
    ```

    Não toque em `_polyline_hits_circle()` nem `_distance_to_segment()` — continuam em
    MatchScreen porque `_resolve_combat()` (gameplay, não desenho) as usa.

    CONTINGÊNCIA DE TAMANHO: depois das duas extrações (Task 1 e esta), rode
    `awk '/^func |^static func /{...}' ` (ver acceptance_criteria) contra `match_screen.gd`. Se
    o arquivo AINDA estiver acima de 600 linhas, mova também `_polyline_hits_circle()` e
    `_distance_to_segment()` para `match_field_renderer.gd` como funções públicas estáticas
    (`polyline_hits_circle`/`distance_to_segment`, mesma assinatura, sem `canvas` porque não
    desenham nada) e ajuste as duas chamadas em `_resolve_combat()` para
    `MatchFieldRenderer.polyline_hits_circle(...)`.

    Crie `apps/mobile/tests/integration/test_match_field_renderer.gd`:

    ```gdscript
    extends GutTest

    ## Regressão da extração de MatchFieldRenderer (Regra 8 do CLAUDE.md — _draw() tinha 93
    ## linhas): uma Control mínima delega para MatchFieldRenderer.draw() dentro do ciclo real
    ## de _draw() do motor e não pode lançar erro para um estado típico de partida.

    class _FakeFieldCanvas extends Control:
    	var state: Dictionary = {}

    	func _draw() -> void:
    		MatchFieldRenderer.draw(self, state)


    func test_draw_runs_without_error_for_a_typical_match_state() -> void:
    	var canvas := _FakeFieldCanvas.new()
    	canvas.size = Vector2(1080, 1920)
    	canvas.state = {
    		"size": canvas.size,
    		"field": Rect2(72.0, 260.0, 936.0, 1210.0),
    		"bot_positions": [Vector2(300, 400)],
    		"bot_directions": [Vector2.LEFT],
    		"bot_trails": [[Vector2(300, 400), Vector2(320, 400)]],
    		"bot_home_rects": [Rect2(100, 100, 220, 184)],
    		"bot_alive": [true],
    		"bot_flash": [0.0],
    		"bot_colors": [Color("4cc9f0")],
    		"round_initialized": true,
    		"claim_rect": Rect2(240.0, 340.0, 240.0, 220.0),
    		"trail": [Vector2(400, 500), Vector2(420, 500)],
    		"player_position": Vector2(400, 500),
    		"player_direction": Vector2.RIGHT,
    		"elapsed": 12.0,
    	}

    	add_child_autofree(canvas)
    	canvas.queue_redraw()
    	await get_tree().process_frame

    	assert_true(true, "MatchFieldRenderer.draw() completou sem lançar erro dentro de _draw()")


    func test_draw_with_zero_size_returns_early() -> void:
    	var canvas := _FakeFieldCanvas.new()
    	canvas.size = Vector2.ZERO
    	canvas.state = {"size": Vector2.ZERO}

    	add_child_autofree(canvas)
    	canvas.queue_redraw()
    	await get_tree().process_frame

    	assert_true(true, "size zero não tenta ler as outras chaves do state (early return)")
    ```
  </action>
  <acceptance_criteria>
    - `test -f apps/mobile/src/ui/screens/match_field_renderer.gd`
    - `grep -q 'class_name MatchFieldRenderer' apps/mobile/src/ui/screens/match_field_renderer.gd`
    - `grep -q 'MatchFieldRenderer.draw(self' apps/mobile/src/ui/screens/match_screen.gd`
    - `awk '/^func |^static func /{if(s){print NR-s} s=NR} END{if(s){print NR-s+1}}' apps/mobile/src/ui/screens/match_field_renderer.gd | sort -rn | head -1` é menor que 50
    - `wc -l < apps/mobile/src/ui/screens/match_screen.gd` é menor que 600
    - `./tools/ci/validate-repo.sh` seção 8 não lista mais `match_screen.gd` nem `match_hud_builder.gd` nem `match_field_renderer.gd`
    - `test -f apps/mobile/tests/integration/test_match_field_renderer.gd`
  </acceptance_criteria>
  <verify>
    <automated>grep -q 'class_name MatchFieldRenderer' apps/mobile/src/ui/screens/match_field_renderer.gd && [ "$(wc -l < apps/mobile/src/ui/screens/match_screen.gd)" -lt 600 ] && ! ./tools/ci/validate-repo.sh 2>&1 | grep -A20 '== 8\.' | grep -qE 'match_screen.gd|match_hud_builder.gd|match_field_renderer.gd' && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>MatchFieldRenderer existe com draw() e os sub-desenhos, todos abaixo de 50 linhas; match_screen.gd tem menos de 600 linhas e delega o desenho do campo para o renderer; os 2 testes novos passam; validate-repo.sh Regra 8 não lista mais nenhum dos três arquivos de UI; test-client.sh continua verde.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Dividir on_pushed() de main_menu_screen.gd</name>
  <files>apps/mobile/src/ui/screens/main_menu_screen.gd, apps/mobile/tests/unit/test_main_menu_screen.gd</files>
  <read_first>
    - apps/mobile/src/ui/screens/main_menu_screen.gd (arquivo inteiro, 63 linhas)
  </read_first>
  <behavior>
    - on_pushed() continua criando um botão chamado "PlayButton" com texto "PLAY"
    - pressionar o botão continua emitindo play_requested
  </behavior>
  <action>
    Substitua TODO o conteúdo de `apps/mobile/src/ui/screens/main_menu_screen.gd` por:

    ```gdscript
    class_name MainMenuScreen
    extends Screen

    signal play_requested
    signal settings_requested

    func on_pushed(args: Dictionary = {}) -> void:
    	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    	var background := ColorRect.new()
    	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	background.color = Color("07111e")
    	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	add_child(background)

    	var center := CenterContainer.new()
    	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	add_child(center)

    	var vbox := VBoxContainer.new()
    	vbox.custom_minimum_size = Vector2(640.0, 0.0)
    	vbox.add_theme_constant_override("separation", 24)
    	center.add_child(vbox)

    	_build_title_block(vbox)
    	_build_play_controls(vbox)

    func _build_title_block(vbox: VBoxContainer) -> void:
    	var eyebrow := Label.new()
    	eyebrow.text = "TERRITORY RUNNER"
    	eyebrow.add_theme_font_size_override("font_size", 22)
    	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	vbox.add_child(eyebrow)

    	var title := Label.new()
    	title.text = "VOLTA"
    	title.add_theme_font_size_override("font_size", 96)
    	title.custom_minimum_size = Vector2(640.0, 140.0)
    	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    	vbox.add_child(title)

    	var subtitle := Label.new()
    	subtitle.text = "Trace seu arco. Conquiste o campo."
    	subtitle.add_theme_font_size_override("font_size", 28)
    	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	vbox.add_child(subtitle)

    func _build_play_controls(vbox: VBoxContainer) -> void:
    	var play_btn := Button.new()
    	play_btn.name = "PlayButton"
    	play_btn.text = "PLAY"
    	play_btn.custom_minimum_size = Vector2(640.0, 164.0)
    	play_btn.add_theme_font_size_override("font_size", 64)
    	play_btn.pressed.connect(_on_play_pressed)
    	vbox.add_child(play_btn)

    	var hint := Label.new()
    	hint.text = "Toque para começar"
    	hint.add_theme_font_size_override("font_size", 24)
    	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	vbox.add_child(hint)

    	play_btn.grab_focus()

    func _on_play_pressed() -> void:
    	play_requested.emit()
    ```

    Crie `apps/mobile/tests/unit/test_main_menu_screen.gd`:

    ```gdscript
    extends GutTest

    ## Regressão da divisão de on_pushed() em _build_title_block()/_build_play_controls()
    ## (Regra 8 do CLAUDE.md — on_pushed() tinha 55 linhas).

    func test_on_pushed_builds_play_button_and_emits_play_requested() -> void:
    	var menu := MainMenuScreen.new()
    	watch_signals(menu)

    	menu.on_pushed()

    	var play_button: Button = menu.find_child("PlayButton", true, false)
    	assert_not_null(play_button, "on_pushed() deveria criar o botão PLAY")

    	play_button.pressed.emit()
    	assert_signal_emitted(menu, "play_requested")

    	menu.queue_free()
    ```
  </action>
  <acceptance_criteria>
    - `awk '/^func |^static func /{if(s){print NR-s} s=NR} END{if(s){print NR-s+1}}' apps/mobile/src/ui/screens/main_menu_screen.gd | sort -rn | head -1` é menor que 50
    - `test -f apps/mobile/tests/unit/test_main_menu_screen.gd`
    - `./tools/ci/validate-repo.sh` seção 8 não lista mais `main_menu_screen.gd`
  </acceptance_criteria>
  <verify>
    <automated>! ./tools/ci/validate-repo.sh 2>&1 | grep -A20 '== 8\.' | grep -q main_menu_screen.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>on_pushed() dividido em _build_title_block()/_build_play_controls(), ambos abaixo de 50 linhas; o teste novo prova que o botão PLAY continua sendo criado e emitindo play_requested; validate-repo.sh Regra 8 não lista mais main_menu_screen.gd; test-client.sh continua verde.</done>
</task>

</tasks>

<verification>
- `./tools/ci/validate-repo.sh` seção 8 não lista nenhum dos quatro arquivos deste plano (match_screen.gd, match_hud_builder.gd, match_field_renderer.gd, main_menu_screen.gd)
- `./tools/ci/lint_gdscript.sh` não lista os dois arquivos novos (tipagem completa)
- `./tools/ci/test-client.sh` sai com código 0, incluindo os 6 testes novos deste plano
</verification>

<success_criteria>
Nenhum arquivo de UI acima de 600 linhas e nenhuma função de UI acima de 50 linhas. A HUD, o
overlay de resultado, o desenho do campo e o menu principal produzem exatamente os mesmos nós
e o mesmo desenho de antes da divisão — provado pelos 6 testes novos e por test-client.sh
continuar verde.
</success_criteria>

<output>
Após completar, crie `.planning/phases/26.1-correcao-quality-gate/26.1-03-SUMMARY.md` seguindo
o template de summary.md, registrando os dois arquivos novos, a divisão de main_menu_screen.gd,
e o achado pré-existente sobre `_hud_header_top()`/`_safe_bottom_inset()` (não corrigido,
propositalmente fora de escopo).
</output>
