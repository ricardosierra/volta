---
phase: 02-core-movement
plan: 06
type: execute
wave: 3
depends_on: ["02-05"]
files_modified:
  - apps/mobile/src/ui/screens/pause_screen.gd
  - apps/mobile/src/ui/screens/results_screen.gd
  - apps/mobile/src/ui/screens/settings_controls.gd
  - apps/mobile/src/ui/screens/match_hud_builder.gd
  - apps/mobile/src/ui/screens/match_screen.gd
  - apps/mobile/src/ui/screens/match_field_renderer.gd
  - apps/mobile/src/root.gd
  - apps/mobile/tests/unit/test_match_hud_builder.gd
  - apps/mobile/tests/integration/test_match_field_renderer.gd
  - apps/mobile/tests/integration/test_pause_and_results_screens.gd
  - apps/mobile/tests/integration/test_match_screen_wiring.gd
  - .gsd/BACKLOG.md
autonomous: true
requirements:
  - MOV-01
  - MOV-02
  - MOV-03
must_haves:
  truths:
    - "MatchScreen não roda mais nenhuma simulação própria (_update_player/_update_bots/_resolve_combat/_seal_trail, PLAYER_SPEED, BOT_SPEED) — o que o jogador vê vem do MatchDirector real"
    - "O jogador pode pausar (congela de verdade via SceneTree.paused), retomar, desistir (chega a Results) e trocar de esquema de controle em runtime, tudo por telas alcançáveis a partir da partida"
    - "O que a tela perdeu (trilha/captura visual, feedback de eliminação, placar real, restart sem menu) está registrado em .gsd/BACKLOG.md com a fase de destino"
    - "MatchScreen.on_pushed() não crasha mais — o bug pré-existente de _hud_header_top()/_safe_bottom_inset() chamados sem estarem definidos (achado da Fase 26.1, fora de escopo até agora) está corrigido"
  artifacts:
    - path: "apps/mobile/src/ui/screens/match_screen.gd"
      provides: "tela ligada ao MatchDirector/InputRouter reais, sem loop de simulação próprio"
      contains: "func set_match_director(director: MatchDirector)"
    - path: "apps/mobile/src/ui/screens/pause_screen.gd"
      provides: "tela provisória do estado Paused, com botões reais (CONTINUAR/DESISTIR) e pausa real via SceneTree"
      contains: "get_tree().paused = true"
    - path: "apps/mobile/src/ui/screens/results_screen.gd"
      provides: "tela provisória do estado Results, alcançável a partir de Paused->Desistir"
      contains: "extends Screen"
  key_links:
    - from: "apps/mobile/src/ui/screens/match_screen.gd"
      to: "apps/mobile/src/ui/screens/pause_screen.gd"
      via: "botão PAUSAR empilha PauseScreen e transiciona GameState.Id.PAUSED"
      pattern: "PauseScreen.new"
    - from: "apps/mobile/src/ui/screens/match_screen.gd"
      to: "apps/mobile/src/ui/screens/settings_controls.gd"
      via: "botão CONTROLES empilha SettingsControls, ligado ao InputRouter real (test drive ao vivo)"
      pattern: "SettingsControls.new"
    - from: "apps/mobile/src/root.gd"
      to: "apps/mobile/src/ui/screens/match_screen.gd"
      via: "match_screen.set_match_director(_match_director) / set_input_router(_input_router)"
      pattern: "set_match_director"
---

<objective>
Este é o plano que faz o "loop de brinquedo" da re-execução parar de dirigir o jogo. Hoje,
tocar PLAY empilha `MatchScreen` (588 linhas), que roda a SUA PRÓPRIA simulação inteira dentro
de `_process(delta)`: `_update_player`/`_update_bots` movem círculos com
`const PLAYER_SPEED = 340.0`/`const BOT_SPEED = 205.0` hardcoded, `_resolve_combat`/`_seal_trail`
fingem território e combate que pertencem às Fases 3/4, e `_input(event: InputEvent)` lê
`InputEventScreenTouch`/`InputEventKey` diretamente — violando ao mesmo tempo ADR-0014 (tick
fixo), "nenhum número de gameplay no código" e "nenhum `InputEvent` chega ao Runner". As
`RunnerView`s reais criadas pelo `RunnerViewSpawner` (Plano 02-04/02-05) ficam desenhadas por
baixo, nunca vistas, enquanto a tela desenha seus próprios círculos por cima.

**Descoberta ao investigar:** `apps/mobile/src/ui/screens/` já tem `pause_screen.gd` e
`results_screen.gd` — dois stubs vazios da Fase 7 (sinais declarados mas nunca emitidos, sem
nenhum botão real; `ResultsScreen` nem estende `Screen`, então `ScreenStack.push()` recusaria
tipá-lo). Eles são exatamente as telas provisórias que MOVE-001 pede para os estados `Paused` e
`Results` ("rótulo de texto + botão") — **usar e completar minimamente essas duas classes já
existentes é melhor e mais correto do que inventar um overlay novo dentro de MatchScreen**, e é
trabalho desta fase (a FSM e sua alcançabilidade são MOVE-001), não da Fase 7 (que depois vai
enriquecer essas mesmas telas com áudio/gráficos/acessibilidade). `settings_controls.gd`
(diferente de `settings_screen.gd`, que é da Fase 7) também precisa virar uma `Screen` de
verdade para poder ser empilhada — hoje ela `extends Control` sem `on_pushed`/`handle_back_button`.

**Bug pré-existente que este plano corrige por necessidade:** `match_screen.gd` chama
`_hud_header_top()` e `_safe_bottom_inset()`, mas nenhuma das duas está definida em lugar
nenhum do projeto — GDScript só falha nisso em runtime (não no parse), e como nada hoje chama
`MatchScreen.on_pushed()` num teste, o bug nunca disparou. A Fase 26.1 já tinha registrado isso
como achado fora do seu escopo. Como este plano precisa que `on_pushed()` rode de verdade (para
provar que a tela é alcançável), ele implementa as duas funções usando o mesmo padrão de
`ui/components/safe_area_container.gd` (`DisplayServer.get_display_safe_area()`).

Purpose: MatchScreen deixa de simular e passa a mostrar o que o Plano 02-05 já entrega — Runners
reais se movendo na arena via câmera real —, com um HUD provisório honesto sobre o que existe
(rivais, tempo) e navegação real para pausar/desistir/trocar controle.

Output: `match_screen.gd` sem nenhum vestígio da simulação própria; `PauseScreen`/`ResultsScreen`
funcionais (mínimo: rótulo + botões); `SettingsControls` empilhável e ligada ao `InputRouter`
real; `MatchFieldRenderer` reduzido ao que ainda faz sentido (moldura do campo); o que foi
perdido temporariamente, registrado em `.gsd/BACKLOG.md`.
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
@docs/architecture/state-machines.md
</context>

<interfaces>
Screen (apps/mobile/src/ui/navigation/screen.gd) — já existe, NÃO MUDA:

    class_name Screen
    extends Control
    signal back_requested
    signal exit_requested
    func on_pushed(args: Dictionary = {}) -> void: pass
    func on_popped() -> void: pass
    func handle_back_button() -> bool: return false

ScreenStack (apps/mobile/src/ui/navigation/screen_stack.gd) — já existe, NÃO MUDA:

    class_name ScreenStack
    extends Control
    func push(screen: Screen, args: Dictionary = {}) -> void: ...  # esconde o topo atual, empilha
    func pop() -> void: ...        # só faz algo se _stack.size() > 1; mostra o novo topo
    func can_pop() -> bool: ...

PauseScreen (apps/mobile/src/ui/screens/pause_screen.gd) — estado ATUAL (stub vazio, Fase 7):

    class_name PauseScreen
    extends Screen
    signal resume_requested
    signal restart_requested
    signal settings_requested
    signal quit_requested
    func on_pushed(args: Dictionary = {}) -> void:
    	get_tree().paused = true
    func on_popped() -> void:
    	get_tree().paused = false
    func handle_back_button() -> bool:
    	resume_requested.emit()
    	return true

ResultsScreen (apps/mobile/src/ui/screens/results_screen.gd) — estado ATUAL (stub vazio,
`extends Control` — não dá para empilhar como Screen):

    class_name ResultsScreen
    extends Control
    signal play_again_requested
    func show_results(result: MatchResult) -> void:
    	show()
    func _on_play_again_pressed() -> void:
    	play_again_requested.emit()

SettingsControls (apps/mobile/src/ui/screens/settings_controls.gd) — estado ATUAL (`extends
Control`, sem navegação, os 3 botões de driver já funcionam):

    class_name SettingsControls
    extends Control
    signal driver_changed(new_driver: InputDriver)
    func _ready() -> void:
    	... # 3 botões: Swipe/Joystick/Relative, cada um emite driver_changed(NovoDriver.new())

MatchDirector (apps/mobile/src/gameplay/match_director.gd) — após o Plano 02-05:

    var game_state: GameState        # game_state.current_state() -> GameState.Id
    var player_runner: Runner
    var runners: Array[Runner]
    var time_elapsed: float

InputRouter (apps/mobile/src/input/input_router.gd) — após o Plano 02-03:

    func set_driver(new_driver: InputDriver) -> void: ...

MatchHudBuilder (apps/mobile/src/ui/screens/match_hud_builder.gd) — estado ATUAL completo
(240 linhas — leia o arquivo inteiro antes de editar; aqui só a forma das duas funções
públicas, que mudam de conteúdo):

    static func build_hud(parent: Control, header_top: float) -> Dictionary: ...
    static func build_result_overlay(parent: Control, elements: Dictionary) -> void: ...  # REMOVIDA neste plano
    static func make_button(text: String, minimum_size: Vector2, font_size: int) -> Button: ...  # não muda
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: PauseScreen e ResultsScreen ganham UI real (rótulo + botão) e emitem os sinais que já declaram</name>
  <files>apps/mobile/src/ui/screens/pause_screen.gd, apps/mobile/src/ui/screens/results_screen.gd, apps/mobile/tests/integration/test_pause_and_results_screens.gd</files>
  <read_first>
    - apps/mobile/src/ui/screens/pause_screen.gd (estado atual completo — bem pequeno)
    - apps/mobile/src/ui/screens/results_screen.gd (estado atual completo — bem pequeno)
    - apps/mobile/src/ui/navigation/screen.gd (contrato Screen: on_pushed/on_popped/handle_back_button/exit_requested)
    - apps/mobile/src/ui/screens/match_hud_builder.gd (make_button — reutilize para os botões destas duas telas, mesmo alvo de toque mínimo)
    - .gsd/phases/02-core-movement/TASKS.md, seção MOVE-001 (Passos 3: "Estados do jogo... com telas provisórias (rótulo de texto + botão)")
  </read_first>
  <behavior>
    - `PauseScreen.on_pushed()` continua pausando a SceneTree (comportamento já existente) e agora também constrói um rótulo "PAUSADO" + 2 botões: "CONTINUAR" (emite `resume_requested`) e "DESISTIR" (emite `quit_requested`)
    - `PauseScreen` processa input mesmo com a árvore pausada (`process_mode = PROCESS_MODE_ALWAYS`) — senão os próprios botões da pausa ficariam inclicáveis
    - `PauseScreen.handle_back_button()` continua emitindo `resume_requested` (comportamento já existente, sem mudança)
    - `ResultsScreen` passa a `extends Screen` (era `Control`) — sem isso `ScreenStack.push()` recusa o tipo estaticamente
    - `ResultsScreen.on_pushed()` constrói um rótulo "PARTIDA ENCERRADA" + texto explicando que território/combate/placar chegam nas Fases 3/4/6 + 2 botões: "JOGAR NOVAMENTE" (emite `play_again_requested`) e "VOLTAR AO MENU" (emite `menu_requested`, sinal novo)
    - `ResultsScreen.show_results(result)` continua existindo sem corpo real — é da Fase 6, não toque nela além de manter a assinatura
  </behavior>
  <action>
    Reescreva `apps/mobile/src/ui/screens/pause_screen.gd`:

    ```gdscript
    class_name PauseScreen
    extends Screen

    ## Tela provisória do estado Paused (MOVE-001, "rótulo de texto + botão" —
    ## .gsd/phases/02-core-movement/TASKS.md). Empilhada por MatchScreen quando o jogador toca
    ## PAUSAR. Congela via SceneTree.paused — GameState.PausedState (gameplay/states/paused_state.gd)
    ## também congela pela FSM; as duas camadas são redundantes de propósito: uma cobre o jogo
    ## real (aqui), a outra cobre testes headless que chamam _physics_process sem SceneTree.

    signal resume_requested
    signal restart_requested
    signal settings_requested
    signal quit_requested

    func on_pushed(_args: Dictionary = {}) -> void:
    	get_tree().paused = true
    	process_mode = Node.PROCESS_MODE_ALWAYS
    	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	mouse_filter = Control.MOUSE_FILTER_STOP
    	_build_ui()

    func on_popped() -> void:
    	get_tree().paused = false

    func handle_back_button() -> bool:
    	resume_requested.emit()
    	return true

    func _build_ui() -> void:
    	var dimmer := ColorRect.new()
    	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	dimmer.color = Color(0.02, 0.04, 0.08, 0.88)
    	add_child(dimmer)

    	var center := CenterContainer.new()
    	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	add_child(center)

    	var box := VBoxContainer.new()
    	box.add_theme_constant_override("separation", 24)
    	center.add_child(box)

    	var label := Label.new()
    	label.text = "PAUSADO"
    	label.add_theme_font_size_override("font_size", 64)
    	label.add_theme_color_override("font_color", Color("f8fbff"))
    	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	box.add_child(label)

    	var resume_button := MatchHudBuilder.make_button("CONTINUAR", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 40)
    	resume_button.pressed.connect(func(): resume_requested.emit())
    	box.add_child(resume_button)

    	var quit_button := MatchHudBuilder.make_button("DESISTIR", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 38)
    	quit_button.pressed.connect(func(): quit_requested.emit())
    	box.add_child(quit_button)
    ```

    Reescreva `apps/mobile/src/ui/screens/results_screen.gd`:

    ```gdscript
    class_name ResultsScreen
    extends Screen

    ## Tela provisória do estado Results (MOVE-001, "rótulo de texto + botão"). Nesta fase o
    ## jogo não tem território/combate/placar (Fases 3/4/6) — show_results() com um MatchResult
    ## real fica para a Fase 6 (MTC-01..04, docs/design/scoring.md); por enquanto on_pushed()
    ## mostra um resumo genérico e os dois botões de saída.

    signal play_again_requested
    signal menu_requested

    func on_pushed(_args: Dictionary = {}) -> void:
    	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	mouse_filter = Control.MOUSE_FILTER_STOP
    	_build_ui()

    func show_results(result: MatchResult) -> void:
    	# Display placements, highlight personal best, etc.
    	pass

    func handle_back_button() -> bool:
    	menu_requested.emit()
    	return true

    func _build_ui() -> void:
    	var dimmer := ColorRect.new()
    	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	dimmer.color = Color(0.02, 0.04, 0.08, 0.88)
    	add_child(dimmer)

    	var center := CenterContainer.new()
    	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	add_child(center)

    	var box := VBoxContainer.new()
    	box.add_theme_constant_override("separation", 24)
    	center.add_child(box)

    	var title := Label.new()
    	title.text = "PARTIDA ENCERRADA"
    	title.add_theme_font_size_override("font_size", 64)
    	title.add_theme_color_override("font_color", Color("f8fbff"))
    	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	box.add_child(title)

    	var detail := Label.new()
    	detail.text = "Território, combate e placar chegam nas fases 3, 4 e 6."
    	detail.add_theme_font_size_override("font_size", 32)
    	detail.add_theme_color_override("font_color", Color("b9cce0"))
    	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    	detail.custom_minimum_size = Vector2(600.0, 0.0)
    	box.add_child(detail)

    	var play_again_button := MatchHudBuilder.make_button("JOGAR NOVAMENTE", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 40)
    	play_again_button.pressed.connect(func(): play_again_requested.emit())
    	box.add_child(play_again_button)

    	var menu_button := MatchHudBuilder.make_button("VOLTAR AO MENU", Vector2(440.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 38)
    	menu_button.pressed.connect(func(): menu_requested.emit())
    	box.add_child(menu_button)
    ```

    Crie `apps/mobile/tests/integration/test_pause_and_results_screens.gd`:

    ```gdscript
    extends GutTest

    ## PauseScreen + ResultsScreen (MOVE-001). As duas existiam como stubs vazios da Fase 7
    ## (sinais declarados mas nunca emitidos, sem nenhum botão real). Prova o mínimo que a
    ## Fase 2 exige: pausar de verdade (SceneTree.paused) e emitir os sinais que MatchScreen
    ## vai escutar (Task 3 deste plano).

    func _find_button(node: Node, text: String) -> Button:
    	for child in node.get_children():
    		if child is Button and (child as Button).text == text:
    			return child
    		var found := _find_button(child, text)
    		if found:
    			return found
    	return null

    func test_pause_screen_pauses_tree_on_pushed_and_unpauses_on_popped() -> void:
    	var pause := add_child_autofree(PauseScreen.new())
    	pause.on_pushed()
    	assert_true(get_tree().paused)

    	pause.on_popped()
    	assert_false(get_tree().paused)

    func test_pause_screen_resume_button_emits_resume_requested() -> void:
    	var pause := add_child_autofree(PauseScreen.new())
    	pause.on_pushed()
    	watch_signals(pause)

    	_find_button(pause, "CONTINUAR").pressed.emit()

    	assert_signal_emitted(pause, "resume_requested")
    	pause.on_popped()

    func test_pause_screen_quit_button_emits_quit_requested() -> void:
    	var pause := add_child_autofree(PauseScreen.new())
    	pause.on_pushed()
    	watch_signals(pause)

    	_find_button(pause, "DESISTIR").pressed.emit()

    	assert_signal_emitted(pause, "quit_requested")
    	pause.on_popped()

    func test_pause_screen_handle_back_button_emits_resume_requested() -> void:
    	var pause := add_child_autofree(PauseScreen.new())
    	pause.on_pushed()
    	watch_signals(pause)

    	assert_true(pause.handle_back_button())
    	assert_signal_emitted(pause, "resume_requested")
    	pause.on_popped()

    func test_results_screen_is_a_screen_and_emits_both_signals() -> void:
    	var results := add_child_autofree(ResultsScreen.new())
    	assert_true(results is Screen, "ResultsScreen precisa estender Screen para ser empilhável")

    	results.on_pushed()
    	watch_signals(results)

    	_find_button(results, "JOGAR NOVAMENTE").pressed.emit()
    	assert_signal_emitted(results, "play_again_requested")

    	_find_button(results, "VOLTAR AO MENU").pressed.emit()
    	assert_signal_emitted(results, "menu_requested")
    ```
  </action>
  <acceptance_criteria>
    - `grep -q "extends Screen" apps/mobile/src/ui/screens/results_screen.gd`
    - `grep -q "process_mode = Node.PROCESS_MODE_ALWAYS" apps/mobile/src/ui/screens/pause_screen.gd`
    - `grep -q "signal menu_requested" apps/mobile/src/ui/screens/results_screen.gd`
    - `test -f apps/mobile/tests/integration/test_pause_and_results_screens.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "extends Screen" apps/mobile/src/ui/screens/results_screen.gd && grep -q "process_mode = Node.PROCESS_MODE_ALWAYS" apps/mobile/src/ui/screens/pause_screen.gd && test -f apps/mobile/tests/integration/test_pause_and_results_screens.gd && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>PauseScreen e ResultsScreen têm rótulo + botões reais, emitem os sinais que já declaravam; ResultsScreen agora estende Screen; os 5 testes novos passam; test-client.sh continua verde.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: MatchHudBuilder perde território/kills/overlay de resultado; SettingsControls vira Screen empilhável</name>
  <files>apps/mobile/src/ui/screens/match_hud_builder.gd, apps/mobile/src/ui/screens/settings_controls.gd, apps/mobile/tests/unit/test_match_hud_builder.gd</files>
  <read_first>
    - apps/mobile/src/ui/screens/match_hud_builder.gd (arquivo inteiro, 240 linhas — leia com o Read tool)
    - apps/mobile/src/ui/screens/settings_controls.gd (estado atual completo — pequeno)
    - apps/mobile/tests/unit/test_match_hud_builder.gd (o teste que este plano precisa ATUALIZAR)
    - docs/gameplay/controls.md (seção "Configurações" — test drive obrigatório, botão de fechar implícito em qualquer navegação)
  </read_first>
  <behavior>
    - `build_hud()` não cria mais `territory_label`/`kills_label`/`territory_bar` (não há território nem combate nesta fase) — só `opponents_label` ("RIVAIS N") e `time_label` ("00:00") na barra superior
    - `_build_actions()` cria 3 botões numa `HBoxContainer`: "PAUSAR", "CONTROLES", "VOLTAR AO MENU"
    - `build_result_overlay()`, `_build_result_shell()`, `_build_result_content()` e `make_result_label()` são REMOVIDAS — o fim de partida agora é a tela `ResultsScreen` (Task 1)
    - `SettingsControls` passa a `extends Screen` (era `Control`), ganha um botão "Fechar" que emite o `exit_requested` já herdado de `Screen` — sem inventar sinal novo
    - Os 3 botões de driver (Swipe/Joystick/Relative) continuam funcionando exatamente como antes
  </behavior>
  <action>
    Em `apps/mobile/src/ui/screens/match_hud_builder.gd`, aplique estas mudanças (mantendo
    `_build_countdown_label`, `_build_hint_label`, `make_hud_label`, `make_button`, `style_box`
    exatamente como estão):

    Substitua `_build_top_bar` por:

    ```gdscript
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

    	var opponents_label := make_hud_label("RIVAIS 0", HORIZONTAL_ALIGNMENT_LEFT, 38)
    	opponents_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    	top_bar.add_child(opponents_label)

    	var time_label := make_hud_label("00:00", HORIZONTAL_ALIGNMENT_RIGHT, 38)
    	time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    	top_bar.add_child(time_label)

    	elements["top_bar"] = top_bar
    	elements["opponents_label"] = opponents_label
    	elements["time_label"] = time_label
    ```

    Substitua `_build_status_row` por (sem a `territory_bar`, texto genérico de movimento):

    ```gdscript
    static func _build_status_row(parent: Control, header_top: float, elements: Dictionary) -> void:
    	var status_label := make_hud_label("PARTIDA  •  VIRE PARA EXPLORAR A ARENA", HORIZONTAL_ALIGNMENT_CENTER, 36)
    	status_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
    	status_label.offset_left = MatchScreen.FIELD_MARGIN
    	status_label.offset_top = header_top + 130.0
    	status_label.offset_right = -MatchScreen.FIELD_MARGIN
    	status_label.offset_bottom = header_top + 176.0
    	parent.add_child(status_label)

    	elements["status_label"] = status_label
    ```

    Substitua `_build_actions` por (3 botões numa fileira):

    ```gdscript
    static func _build_actions(parent: Control, elements: Dictionary) -> void:
    	var actions := CenterContainer.new()
    	actions.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    	actions.offset_top = -236.0
    	actions.offset_bottom = -92.0
    	actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
    	parent.add_child(actions)

    	var row := HBoxContainer.new()
    	row.add_theme_constant_override("separation", 20)
    	actions.add_child(row)

    	var pause_button := make_button("PAUSAR", Vector2(260.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 36)
    	row.add_child(pause_button)

    	var settings_button := make_button("CONTROLES", Vector2(280.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 36)
    	row.add_child(settings_button)

    	var exit_button := make_button("VOLTAR AO MENU", Vector2(360.0, MatchScreen.MIN_TOUCH_TARGET_HEIGHT), 36)
    	row.add_child(exit_button)

    	elements["actions"] = actions
    	elements["pause_button"] = pause_button
    	elements["settings_button"] = settings_button
    	elements["exit_button"] = exit_button
    ```

    REMOVA por completo as funções `build_result_overlay`, `_build_result_shell`,
    `_build_result_content` e `make_result_label` (o overlay de resultado virou `ResultsScreen`,
    Task 1 deste plano). Deixe um comentário no topo do arquivo, logo abaixo do comentário de
    classe já existente:

    ```gdscript
    ## Desde o Plano 02-06 (Fase 2): território/kills saíram da HUD (Fases 3/4 religam) e o
    ## overlay de fim de partida virou a tela dedicada ResultsScreen
    ## (apps/mobile/src/ui/screens/results_screen.gd), empilhada quando o jogo entra em
    ## GameState.Id.RESULTS — não existe mais build_result_overlay() aqui.
    ```

    Reescreva `apps/mobile/src/ui/screens/settings_controls.gd`:

    ```gdscript
    class_name SettingsControls
    extends Screen

    ## Tela de test drive de controles (MOVE-007, docs/gameplay/controls.md — "o test drive é
    ## obrigatório"). Empilhada por MatchScreen sobre a partida em andamento: a simulação
    ## continua rodando por baixo, então trocar de esquema aqui já é o test drive ao vivo — não
    ## precisa de uma mini-arena separada nesta fase (isso é polimento de Fase 7).

    signal driver_changed(new_driver: InputDriver)

    func on_pushed(_args: Dictionary = {}) -> void:
    	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	mouse_filter = Control.MOUSE_FILTER_STOP
    	_build_ui()

    func handle_back_button() -> bool:
    	exit_requested.emit()
    	return true

    func _build_ui() -> void:
    	var dimmer := ColorRect.new()
    	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	dimmer.color = Color(0.02, 0.04, 0.08, 0.88)
    	add_child(dimmer)

    	var center := CenterContainer.new()
    	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	add_child(center)

    	var vbox := VBoxContainer.new()
    	vbox.add_theme_constant_override("separation", 16)
    	center.add_child(vbox)

    	var title := Label.new()
    	title.text = "ESCOLHA O CONTROLE (test drive ao vivo)"
    	title.add_theme_font_size_override("font_size", 32)
    	title.add_theme_color_override("font_color", Color("f8fbff"))
    	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    	vbox.add_child(title)

    	var btn_swipe := Button.new()
    	btn_swipe.text = "Swipe"
    	btn_swipe.pressed.connect(func(): driver_changed.emit(SwipeDriver.new()))
    	vbox.add_child(btn_swipe)

    	var btn_joy := Button.new()
    	btn_joy.text = "Joystick"
    	btn_joy.pressed.connect(func(): driver_changed.emit(JoystickDriver.new()))
    	vbox.add_child(btn_joy)

    	var btn_rel := Button.new()
    	btn_rel.text = "Relative"
    	btn_rel.pressed.connect(func(): driver_changed.emit(RelativeDriver.new()))
    	vbox.add_child(btn_rel)

    	var btn_close := Button.new()
    	btn_close.text = "Fechar"
    	btn_close.pressed.connect(func(): exit_requested.emit())
    	vbox.add_child(btn_close)
    ```

    Atualize `apps/mobile/tests/unit/test_match_hud_builder.gd` por inteiro:

    ```gdscript
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
    ```
  </action>
  <acceptance_criteria>
    - `! grep -q "func build_result_overlay" apps/mobile/src/ui/screens/match_hud_builder.gd`
    - `! grep -q "territory_label\|kills_label\|territory_bar" apps/mobile/src/ui/screens/match_hud_builder.gd`
    - `grep -q "pause_button\"\] = pause_button" apps/mobile/src/ui/screens/match_hud_builder.gd`
    - `grep -q "extends Screen" apps/mobile/src/ui/screens/settings_controls.gd`
    - `grep -q "exit_requested.emit()" apps/mobile/src/ui/screens/settings_controls.gd`
    - `./tools/ci/test-client.sh` sai com código 0
    - `./tools/ci/lint.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>! grep -q "func build_result_overlay" apps/mobile/src/ui/screens/match_hud_builder.gd && grep -q "extends Screen" apps/mobile/src/ui/screens/settings_controls.gd && ./tools/ci/test-client.sh && ./tools/ci/lint.sh</automated>
  </verify>
  <done>MatchHudBuilder só cria HUD com dado real (rivais/tempo) e 3 botões de ação; overlay de resultado removido; SettingsControls é uma Screen empilhável com botão de fechar; test_match_hud_builder.gd atualizado passa; test-client.sh e lint.sh continuam verdes.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: MatchScreen para de simular; MatchFieldRenderer reduzido; root.gd liga tudo; BACKLOG.md atualizado</name>
  <files>apps/mobile/src/ui/screens/match_screen.gd, apps/mobile/src/ui/screens/match_field_renderer.gd, apps/mobile/src/root.gd, apps/mobile/tests/integration/test_match_field_renderer.gd, apps/mobile/tests/integration/test_match_screen_wiring.gd, .gsd/BACKLOG.md</files>
  <read_first>
    - apps/mobile/src/ui/screens/match_screen.gd (arquivo inteiro, 588 linhas — leia com o Read tool; é o arquivo mais importante desta tarefa)
    - apps/mobile/src/ui/screens/match_field_renderer.gd (arquivo inteiro, 182 linhas)
    - apps/mobile/src/ui/components/safe_area_container.gd (o padrão que você vai replicar para `_hud_header_top()`/`_safe_bottom_inset()` — método `_apply_safe_area()`)
    - apps/mobile/src/root.gd (após o Plano 02-05 — `_start_match()` termina no loop que acha a RunnerView do jogador)
    - apps/mobile/tests/integration/test_match_field_renderer.gd (o teste que este plano precisa ATUALIZAR)
    - .gsd/BACKLOG.md (tabela "Itens adiados" — próximo ID livre é BL-019)
  </read_first>
  <behavior>
    - `MatchScreen` não define mais `PLAYER_SPEED`, `BOT_SPEED`, nem `_update_player`, `_update_bots`, `_resolve_combat`, `_seal_trail`, `_eliminate_bot`, `_check_win`, `_read_direction`, `_input(event)`, `_set_gesture_direction`, `_direction_for_key`, `_polyline_hits_circle`, `_distance_to_segment` — nenhum InputEvent é lido pela tela
    - `MatchScreen._hud_header_top()` e `_safe_bottom_inset()` existem e usam `DisplayServer.get_display_safe_area()` (mesmo padrão de `SafeAreaContainer`), com fallback `0.0` quando a safe area não é reportada (headless/editor)
    - `set_match_director(director)`/`set_input_router(router)` guardam as referências; `_process(delta)` lê `director.game_state.current_state()` para mostrar/esconder o contador de countdown, e `director.time_elapsed`/`director.runners.size()` para o HUD
    - Botão PAUSAR: transiciona `GameState.Id.PAUSED` e empilha `PauseScreen`; CONTINUAR (de `PauseScreen`) volta a `PLAYING` e desempilha; DESISTIR desempilha `PauseScreen`, transiciona para `GameState.Id.RESULTS` e empilha `ResultsScreen`; os dois botões de `ResultsScreen` desempilham e emitem `exit_requested` (Fase 2 não tem restart real — MTC-04 é Fase 6, ambos voltam ao menu, registrado no BACKLOG)
    - Botão CONTROLES: empilha `SettingsControls`, conectada ao `InputRouter` real (`driver_changed` -> `router.set_driver`)
    - `MatchFieldRenderer.draw()` só desenha a moldura do campo (fundo + campo + cantos + rodapé) — Runners são desenhados pelas `RunnerView`s reais (Plano 02-04/02-05), não mais por `_draw()` de `MatchScreen`
    - `root.gd` passa `_match_director`/`_input_router` para a `match_screen` depois de `setup_match()`
    - `.gsd/BACKLOG.md` ganha 3 linhas novas (BL-019, BL-020, BL-021) registrando o que a tela perdeu
  </behavior>
  <action>
    Reescreva `apps/mobile/src/ui/screens/match_screen.gd` por inteiro:

    ```gdscript
    class_name MatchScreen
    extends Screen

    signal restart_requested
    signal match_finished(won: bool)

    const FIELD_MARGIN: float = 72.0
    const FIELD_TOP: float = 260.0
    const FIELD_BOTTOM: float = 1470.0
    const PANEL_MARGIN: float = 48.0
    const MIN_TOUCH_TARGET_HEIGHT: float = 136.0

    var _match_director: MatchDirector
    var _input_router: InputRouter
    var _bot_count: int = 0
    var _countdown_display: float = 3.0

    var _opponents_label: Label
    var _time_label: Label
    var _status_label: Label
    var _countdown_label: Label
    var _hint_label: Label
    var _top_bar: HBoxContainer
    var _actions: CenterContainer


    func on_pushed(_args: Dictionary = {}) -> void:
    	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    	mouse_filter = Control.MOUSE_FILTER_IGNORE
    	_build_hud()
    	resized.connect(_layout_hud)
    	call_deferred("_layout_hud")


    func set_bot_count(count: int) -> void:
    	_bot_count = clampi(count, 0, 4)
    	_update_opponents_label()


    func set_match_director(director: MatchDirector) -> void:
    	_match_director = director


    func set_input_router(router: InputRouter) -> void:
    	_input_router = router


    func _process(delta: float) -> void:
    	if not _match_director or not _match_director.game_state:
    		return

    	var current := _match_director.game_state.current_state()
    	if current == GameState.Id.COUNTDOWN:
    		_countdown_display = maxf(0.0, _countdown_display - delta)
    		_countdown_label.visible = true
    		_countdown_label.text = str(ceili(_countdown_display)) if _countdown_display > 0.0 else "VAI!"
    	else:
    		_countdown_display = 3.0
    		_countdown_label.visible = false

    	_update_all_labels()


    func _draw() -> void:
    	MatchFieldRenderer.draw(self, {
    		"size": size,
    		"field": _field_rect(),
    	})


    func _build_hud() -> void:
    	var header_top := _hud_header_top()
    	var elements := MatchHudBuilder.build_hud(self, header_top)
    	_top_bar = elements["top_bar"]
    	_opponents_label = elements["opponents_label"]
    	_time_label = elements["time_label"]
    	_status_label = elements["status_label"]
    	_countdown_label = elements["countdown_label"]
    	_hint_label = elements["hint_label"]
    	_actions = elements["actions"]
    	(elements["pause_button"] as Button).pressed.connect(_on_pause_pressed)
    	(elements["settings_button"] as Button).pressed.connect(_on_settings_pressed)
    	(elements["exit_button"] as Button).pressed.connect(_on_exit_pressed)


    func _layout_hud() -> void:
    	if not is_instance_valid(_top_bar):
    		return

    	var header_top := _hud_header_top()
    	_top_bar.offset_top = header_top + 14.0
    	_top_bar.offset_bottom = header_top + 112.0
    	_status_label.offset_top = header_top + 130.0
    	_status_label.offset_bottom = header_top + 176.0

    	var field := _field_rect()
    	_hint_label.offset_top = field.end.y + 58.0
    	_hint_label.offset_bottom = field.end.y + 118.0

    	var bottom_offset := maxf(92.0, _safe_bottom_inset() + 48.0)
    	_actions.offset_bottom = -bottom_offset
    	_actions.offset_top = -bottom_offset - 144.0


    ## Safe area do topo (notch/status bar), em pixels. Mesmo padrão de
    ## ui/components/safe_area_container.gd — headless/editor sem safe area reportada cai em 0.
    func _hud_header_top() -> float:
    	var safe_area := DisplayServer.get_display_safe_area()
    	if safe_area.size.y > 0:
    		return float(safe_area.position.y)
    	return 0.0


    ## Safe area de baixo (gesture bar/home indicator), em pixels.
    func _safe_bottom_inset() -> float:
    	var safe_area := DisplayServer.get_display_safe_area()
    	var window_size := DisplayServer.window_get_size()
    	if safe_area.size.y > 0:
    		return float(window_size.y - (safe_area.position.y + safe_area.size.y))
    	return 0.0


    func _on_pause_pressed() -> void:
    	if not _match_director or not _match_director.game_state:
    		return
    	_match_director.game_state.request_transition(GameState.Id.PAUSED)

    	var pause := PauseScreen.new()
    	pause.resume_requested.connect(_on_pause_resume_requested)
    	pause.quit_requested.connect(_on_pause_quit_requested)
    	(get_parent() as ScreenStack).push(pause)


    func _on_pause_resume_requested() -> void:
    	_match_director.game_state.request_transition(GameState.Id.PLAYING)
    	(get_parent() as ScreenStack).pop()


    func _on_pause_quit_requested() -> void:
    	(get_parent() as ScreenStack).pop()
    	_match_director.game_state.request_transition(GameState.Id.RESULTS)

    	var results := ResultsScreen.new()
    	results.menu_requested.connect(_on_results_menu_requested)
    	# Fase 2 não tem restart real (MTC-04 é Fase 6) — os dois botões voltam ao menu, ver BACKLOG BL-021.
    	results.play_again_requested.connect(_on_results_menu_requested)
    	(get_parent() as ScreenStack).push(results)


    func _on_results_menu_requested() -> void:
    	(get_parent() as ScreenStack).pop()
    	exit_requested.emit()


    func _on_settings_pressed() -> void:
    	var settings := SettingsControls.new()
    	if _input_router:
    		settings.driver_changed.connect(_input_router.set_driver)
    	settings.exit_requested.connect(func(): (get_parent() as ScreenStack).pop())
    	(get_parent() as ScreenStack).push(settings)


    func _field_rect() -> Rect2:
    	var top := minf(FIELD_TOP, size.y * 0.22)
    	var bottom := minf(FIELD_BOTTOM, size.y - 350.0)
    	return Rect2(
    		Vector2(FIELD_MARGIN, top),
    		Vector2(maxf(420.0, size.x - FIELD_MARGIN * 2.0), maxf(480.0, bottom - top))
    	)


    func _update_all_labels() -> void:
    	_update_opponents_label()
    	if is_instance_valid(_time_label):
    		_time_label.text = _format_time(_match_director.time_elapsed if _match_director else 0.0)
    	if is_instance_valid(_hint_label):
    		_hint_label.text = "DESLIZE OU USE AS SETAS PARA VIRAR"


    func _update_opponents_label() -> void:
    	if not is_instance_valid(_opponents_label):
    		return
    	var active := (_match_director.runners.size() - 1) if _match_director else _bot_count
    	_opponents_label.text = "RIVAIS %d" % maxi(0, active)


    func _format_time(seconds: float) -> String:
    	var whole_seconds := int(seconds)
    	return "%02d:%02d" % [whole_seconds / 60, whole_seconds % 60]


    func _on_exit_pressed() -> void:
    	exit_requested.emit()


    func handle_back_button() -> bool:
    	exit_requested.emit()
    	return true
    ```

    Reescreva `apps/mobile/src/ui/screens/match_field_renderer.gd` (mantendo
    `_draw_background`, `_draw_field`, `_draw_field_brackets`, `_draw_footer` byte a byte
    idênticos — só o corpo de `draw()` muda, e as 5 funções de Runners/bots/claim/trail saem):

    ```gdscript
    class_name MatchFieldRenderer
    extends RefCounted

    ## Desenha a moldura do campo de MatchScreen. Extraído por tamanho de função (Regra 8 do
    ## CLAUDE.md). Desde o Plano 02-06 (Fase 2): Runners não são mais desenhados aqui — as
    ## RunnerView reais (apps/mobile/src/presentation/runner_view.gd), sob a GameCamera real,
    ## já os mostram. Este renderer só desenha a moldura estática do campo.

    static func draw(canvas: CanvasItem, state: Dictionary) -> void:
    	var size: Vector2 = state["size"]
    	if size.x <= 0.0 or size.y <= 0.0:
    		return

    	_draw_background(canvas, state)
    	_draw_field(canvas, state)
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

    Atualize `apps/mobile/tests/integration/test_match_field_renderer.gd` (o state agora só
    precisa de `size`/`field`):

    ```gdscript
    extends GutTest

    ## Regressão da extração de MatchFieldRenderer (Regra 8 do CLAUDE.md): uma Control mínima
    ## delega para MatchFieldRenderer.draw() dentro do ciclo real de _draw() do motor e não
    ## pode lançar erro. Desde o Plano 02-06, o renderer só desenha a moldura do campo — o
    ## state não carrega mais bots/claim/trail.

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

    Em `apps/mobile/src/root.gd`, dentro de `_start_match()`, logo depois do bloco que já
    procura a `RunnerView` do jogador para virar alvo da câmera (o `for view in
    _runner_view_spawner.get_children(): ...`), adicione:

    ```gdscript
    	match_screen.set_match_director(_match_director)
    	match_screen.set_input_router(_input_router)
    ```

    Crie `apps/mobile/tests/integration/test_match_screen_wiring.gd`:

    ```gdscript
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
    	var screen := add_child_autofree(MatchScreen.new())
    	screen.size = Vector2(1080, 1920)

    	screen.on_pushed()

    	assert_true(is_instance_valid(screen))

    func test_opponents_label_reflects_real_match_director_runner_count() -> void:
    	var screen := add_child_autofree(MatchScreen.new())
    	screen.size = Vector2(1080, 1920)
    	screen.on_pushed()

    	var director: MatchDirector = add_child_autofree(MatchDirector.new())
    	var config := Resource.new()
    	config.set_meta("bot_count", 3)
    	director.setup_match(config)

    	screen.set_match_director(director)
    	screen._process(0.016)

    	assert_eq(screen._opponents_label.text, "RIVAIS 3")
    ```

    Adicione estas 3 linhas ao final da tabela "Itens adiados" de `.gsd/BACKLOG.md`, logo após
    a linha `BL-018`:

    ```
    | BL-019 | feature | Trilha e captura de território desenhadas em MatchScreen (MatchFieldRenderer perdeu _draw_claim_and_trail ao remover a simulação própria da tela) | 02 | 03 |
    | BL-020 | feature | Feedback visual de eliminação/combate em MatchScreen (flash de bot eliminado, corte de rastro, hoje sem territ/combate para mostrar) | 02 | 04 |
    | BL-021 | feature | ResultsScreen.show_results() com placar/colocação reais e PLAY AGAIN reiniciando sem passar pelo menu (hoje os dois botões só voltam ao menu) | 02 | 06 |
    ```
  </action>
  <acceptance_criteria>
    - `! grep -q "PLAYER_SPEED\|BOT_SPEED" apps/mobile/src/ui/screens/match_screen.gd`
    - `! grep -q "func _update_player\|func _update_bots\|func _resolve_combat\|func _seal_trail" apps/mobile/src/ui/screens/match_screen.gd`
    - `! grep -q "func _input(event: InputEvent)" apps/mobile/src/ui/screens/match_screen.gd`
    - `grep -q "func _hud_header_top() -> float" apps/mobile/src/ui/screens/match_screen.gd`
    - `grep -q "func _safe_bottom_inset() -> float" apps/mobile/src/ui/screens/match_screen.gd`
    - `grep -q "func set_match_director(director: MatchDirector)" apps/mobile/src/ui/screens/match_screen.gd`
    - `wc -l < apps/mobile/src/ui/screens/match_screen.gd` imprime um número ≤ 600
    - `grep -q "match_screen.set_match_director(_match_director)" apps/mobile/src/root.gd`
    - `grep -q "BL-019" .gsd/BACKLOG.md`
    - `test -f apps/mobile/tests/integration/test_match_screen_wiring.gd`
    - `./tools/ci/test-client.sh` sai com código 0
    - `./tools/ci/validate-repo.sh` sai com código 0
    - `./tools/ci/lint.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>! grep -q "PLAYER_SPEED\|BOT_SPEED" apps/mobile/src/ui/screens/match_screen.gd && grep -q "func _hud_header_top() -> float" apps/mobile/src/ui/screens/match_screen.gd && grep -q "match_screen.set_match_director(_match_director)" apps/mobile/src/root.gd && grep -q "BL-019" .gsd/BACKLOG.md && [ "$(wc -l < apps/mobile/src/ui/screens/match_screen.gd)" -le 600 ] && ./tools/ci/test-client.sh && ./tools/ci/validate-repo.sh && ./tools/ci/lint.sh</automated>
  </verify>
  <done>MatchScreen não simula mais nada por conta própria, mostra dados reais do MatchDirector, navega para Pause/Settings/Results de verdade; o bug pré-existente de safe area está corrigido; MatchFieldRenderer só desenha a moldura; root.gd liga tela e director/router; BACKLOG.md tem as 3 linhas novas; os 3 arquivos de teste (2 atualizados + 1 novo) passam; as 3 checagens de CI continuam verdes.</done>
</task>

</tasks>

<verification>
- `./tools/ci/test-client.sh` sai com código 0
- `./tools/ci/validate-repo.sh` sai com código 0
- `./tools/ci/lint.sh` sai com código 0
- `wc -l < apps/mobile/src/ui/screens/match_screen.gd` ≤ 600 (estava em 588, e este plano remove muito mais do que adiciona)
- Jogar manualmente (checkpoint humano no Plano 02-07): PLAY mostra Runners reais se movendo; PAUSAR congela; DESISTIR chega a uma tela de resultado; CONTROLES troca de esquema ao vivo
</verification>

<success_criteria>
O jogo real deixou de mentir: o que aparece na tela é exatamente o que `MatchDirector` simula,
não um clone paralelo. O ciclo `Countdown -> Playing -> Paused -> Playing -> Results -> Menu`
é navegável por um humano, não só provado por teste headless. Nenhum `InputEvent` chega perto
de um Runner. O que foi perdido (visualização de território/combate, placar real) está
registrado com destino em `.gsd/BACKLOG.md`, não escondido nem fingido.
</success_criteria>

<output>
Após completar, crie `.planning/phases/02-core-movement/02-06-SUMMARY.md` seguindo o template
de summary.md, registrando a remoção do loop de brinquedo, a correção do bug de safe area, e as
3 linhas novas do BACKLOG.
</output>
</content>
