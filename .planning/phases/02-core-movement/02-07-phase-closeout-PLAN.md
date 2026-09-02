---
phase: 02-core-movement
plan: 07
type: execute
wave: 4
depends_on: ["02-06"]
files_modified:
  - apps/mobile/tools/dev/latency_test.gd
  - apps/mobile/tests/unit/test_latency_test_percentiles.gd
  - docs/performance/device-results.md
  - .gsd/phases/02-core-movement/HANDOFF.md
  - .gsd/QUALITY_GATES.md
  - .planning/STATE.md
  - .planning/ROADMAP.md
  - .planning/REQUIREMENTS.md
autonomous: false
requirements:
  - MOV-05
must_haves:
  truths:
    - "Existe uma ferramenta real de medição de latência (timestamp de evento -> tick -> frame renderizado), não um relatório fabricado com números fixos"
    - "docs/performance/device-results.md tem uma seção da Fase 2 com _pendente_ explícito onde não há medição real — nunca um número inventado"
    - "As 3 checagens de CI (validate-repo.sh, lint.sh, test-client.sh) rodaram de verdade ao final da fase, com saída real colada no SUMMARY — não presumida"
    - "REQUIREMENTS.md/ROADMAP.md/STATE.md refletem o estado real: MOV-01..04/06/07 implementados e testados, MOV-05 aberto até a medição em aparelho real"
  artifacts:
    - path: "apps/mobile/tools/dev/latency_test.gd"
      provides: "instrumentação real de latência com percentil calculável e testável, sem número fabricado"
      contains: "static func percentile"
    - path: ".gsd/phases/02-core-movement/HANDOFF.md"
      provides: "handoff preenchido com o que foi de fato entregue, limitações conhecidas e pré-requisitos da Fase 3"
  key_links:
    - from: "apps/mobile/tools/dev/latency_test.gd"
      to: "apps/mobile/src/gameplay/match_director.gd"
      via: "director.player_runner.state.desired_direction observado por tick, sem tocar em código de gameplay/"
      pattern: "director.player_runner"
---

<objective>
Último plano da fase — fecha o que só um humano com aparelho pode fechar, e escreve a
evidência real do que os 6 planos anteriores entregaram. Duas coisas precisam de verdade, não
de simulação:

**MOVE-010 (latência):** `apps/mobile/tools/dev/latency_test.gd` hoje é exatamente o tipo de
código que a Regra de Ouro Anti-Burla do `CLAUDE.md` proíbe — `generate_report()` faz
`print("Latency P50: 32ms")` **hardcoded**, sem medir nada. `docs/performance/device-results.md`
tem números genéricos de "antes/depois" sem fase, sem aparelho, sem data — a mesma fabricação
que a Fase 19 já teve seu relatório reescrito por causa disso (`.planning/STATE.md`, Fase 26-01).
Este plano escreve a instrumentação REAL (o cálculo de percentil é puro e testável headless; a
medição ponta a ponta só existe rodando num aparelho de verdade) e faz o checkpoint humano
explícito — nunca um número inventado.

**Fechamento formal:** os 6 planos anteriores mudaram runner/, input/, arena/, presentation/,
gameplay/, root.gd e ui/screens/. Este plano roda as 3 checagens de CI de verdade, cola a saída
real no `SUMMARY.md`, preenche `HANDOFF.md` (que hoje está vazio, template puro), atualiza o
registro de `.gsd/QUALITY_GATES.md`, e marca `STATE.md`/`ROADMAP.md`/`REQUIREMENTS.md` à mão —
os comandos `gsd-tools state/roadmap/requirements` corrompem ou fazem no-op neste repositório
(`.planning/phases/02-core-movement/02-CONTEXT.md`, bloco `<reexecution>`).

Purpose: fechar a Fase 2 honestamente — o que está pronto, marcado pronto; o que depende de
aparelho físico, marcado `_pendente_` e aberto em `STATE.md`, nunca fingido.

Output: `latency_test.gd` real e testável; `device-results.md` com a seção da Fase 2;
`HANDOFF.md` preenchido; `QUALITY_GATES.md` com a linha da Fase 2; `STATE.md`/`ROADMAP.md`/
`REQUIREMENTS.md` refletindo o estado real.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/02-core-movement/02-CONTEXT.md
@.planning/ROADMAP.md
@.planning/REQUIREMENTS.md
@.planning/STATE.md
@.gsd/phases/02-core-movement/ACCEPTANCE.md
@.gsd/phases/02-core-movement/TESTS.md
@.gsd/QUALITY_GATES.md
</context>

<interfaces>
MatchDirector (apps/mobile/src/gameplay/match_director.gd) — após os Planos 02-01..02-06,
o que `latency_test.gd` observa (sem tocar em gameplay/, é um dev tool fora de src/):

    var player_runner: Runner   # player_runner.state.desired_direction: Vector2

RunnerView / InterpolatedVisual (apps/mobile/src/presentation/) — após o Plano 02-04:

    class RunnerView extends InterpolatedVisual:
    	var curr_rotation: float   # atualizado a cada _physics_process, interpolado em _process
</interfaces>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: latency_test.gd real (fim do print hardcoded) + percentil testável</name>
  <files>apps/mobile/tools/dev/latency_test.gd, apps/mobile/tests/unit/test_latency_test_percentiles.gd</files>
  <read_first>
    - apps/mobile/tools/dev/latency_test.gd (estado atual completo — 15 linhas, o `print` fabricado)
    - apps/mobile/src/presentation/interpolated_visual.gd (curr_rotation, atualizado por RunnerView após o Plano 02-04)
    - apps/mobile/src/runner/runner_state.gd (desired_direction)
    - .gsd/phases/02-core-movement/TASKS.md, seção MOVE-010 (os 5 passos e o DoD: "p95 < 50 ms nos três esquemas, no aparelho Mid, documentado")
  </read_first>
  <behavior>
    - `LatencyTest.percentile(samples, p)` é uma função estática pura: ordena as amostras e devolve o valor no percentil pedido; `[]` devolve `-1.0` (nunca fabrica um número); ordem de entrada não importa; uma única amostra devolve ela mesma para qualquer percentil
    - `_unhandled_input` registra o timestamp bruto (`Time.get_ticks_usec()`) do primeiro toque/arraste ainda não pareado com uma amostra
    - `_physics_process` detecta o tick em que `director.player_runner.state.desired_direction` de fato mudou em relação ao valor guardado no momento do evento
    - `_process` detecta o primeiro frame em que `player_view.curr_rotation` já reflete a nova direção (dentro de 2°) e só então fecha a amostra (evento -> render), nunca antes
    - `generate_report()` sem nenhuma amostra devolve uma string dizendo que não há amostra — nunca um número
  </behavior>
  <action>
    Reescreva `apps/mobile/tools/dev/latency_test.gd` por inteiro:

    ```gdscript
    class_name LatencyTest
    extends Node

    ## Ferramenta de dev para medir latência toque -> mudança de direção (MOV-05, GSD 02
    ## MOVE-010). Mede três estágios por amostra: (1) timestamp do InputEvent bruto,
    ## (2) tick de simulação em que Runner.state.desired_direction efetivamente mudou,
    ## (3) primeiro _process() em que a RunnerView já reflete essa direção. Isso só produz
    ## número real rodando dentro de uma partida de verdade, num aparelho real — headless não
    ## tem touchscreen nem vsync. Anexe este nó como filho de MatchDirector durante uma
    ## partida real, sete `director` e `player_view` (a RunnerView do jogador), toque a tela
    ## 100 vezes alternando direção, e chame generate_report() (ver checkpoint do Plano 02-07).

    signal sample_recorded(latency_ms: float)

    var director: MatchDirector
    var player_view: InterpolatedVisual

    var max_samples: int = 100
    var _samples_ms: Array[float] = []

    var _pending_event_time_usec: int = -1
    var _pending_direction_before: Vector2 = Vector2.ZERO
    var _waiting_for_visual_update: bool = false


    func _unhandled_input(event: InputEvent) -> void:
    	if _samples_ms.size() >= max_samples or not director or not director.player_runner:
    		return
    	if _pending_event_time_usec == -1 and (event is InputEventScreenTouch or event is InputEventScreenDrag):
    		_pending_event_time_usec = Time.get_ticks_usec()
    		_pending_direction_before = director.player_runner.state.desired_direction


    func _physics_process(_delta: float) -> void:
    	if _pending_event_time_usec == -1 or _waiting_for_visual_update:
    		return
    	if not director or not director.player_runner:
    		return
    	if director.player_runner.state.desired_direction != _pending_direction_before:
    		_waiting_for_visual_update = true


    func _process(_delta: float) -> void:
    	if not _waiting_for_visual_update or not player_view or not director or not director.player_runner:
    		return
    	var expected_angle := director.player_runner.state.desired_direction.angle()
    	if absf(angle_difference(player_view.curr_rotation, expected_angle)) < deg_to_rad(2.0):
    		var total_usec := Time.get_ticks_usec() - _pending_event_time_usec
    		_record_sample(total_usec / 1000.0)
    		_reset_pending()


    func _record_sample(latency_ms: float) -> void:
    	_samples_ms.append(latency_ms)
    	sample_recorded.emit(latency_ms)


    func _reset_pending() -> void:
    	_pending_event_time_usec = -1
    	_waiting_for_visual_update = false


    static func percentile(samples: Array, p: float) -> float:
    	if samples.is_empty():
    		return -1.0
    	var sorted_samples := samples.duplicate()
    	sorted_samples.sort()
    	var index := int(ceil(p * sorted_samples.size())) - 1
    	index = clampi(index, 0, sorted_samples.size() - 1)
    	return sorted_samples[index]


    func generate_report() -> String:
    	if _samples_ms.is_empty():
    		return "sem amostras — rode este teste tocando a tela durante uma partida real"
    	var p50 := percentile(_samples_ms, 0.5)
    	var p95 := percentile(_samples_ms, 0.95)
    	return "Latência (%d amostras) — p50: %.1f ms · p95: %.1f ms" % [_samples_ms.size(), p50, p95]
    ```

    Crie `apps/mobile/tests/unit/test_latency_test_percentiles.gd`:

    ```gdscript
    extends GutTest

    ## LatencyTest.percentile() — matemática pura e testável (MOVE-010). O resto da
    ## instrumentação (evento -> tick -> frame) só produz número real em dispositivo, mas o
    ## cálculo de percentil não pode ser fabricado (CLAUDE.md, Regra de Ouro Anti-Burla) — por
    ## isso é uma função estática, independente de estado de partida, testável com amostras
    ## sintéticas.

    func test_percentile_of_empty_array_is_negative_one() -> void:
    	assert_eq(LatencyTest.percentile([], 0.5), -1.0)

    func test_p50_of_ten_sorted_samples() -> void:
    	var samples: Array = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
    	assert_eq(LatencyTest.percentile(samples, 0.5), 50.0)

    func test_p95_of_ten_sorted_samples() -> void:
    	var samples: Array = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
    	assert_eq(LatencyTest.percentile(samples, 0.95), 100.0)

    func test_percentile_does_not_depend_on_input_order() -> void:
    	var sorted_samples: Array = [1.0, 2.0, 3.0, 4.0, 5.0]
    	var shuffled_samples: Array = [5.0, 1.0, 4.0, 2.0, 3.0]
    	assert_eq(LatencyTest.percentile(sorted_samples, 0.5), LatencyTest.percentile(shuffled_samples, 0.5))

    func test_single_sample_returns_that_sample_for_any_percentile() -> void:
    	assert_eq(LatencyTest.percentile([42.0], 0.5), 42.0)
    	assert_eq(LatencyTest.percentile([42.0], 0.95), 42.0)
    ```
  </action>
  <acceptance_criteria>
    - `! grep -q "print(\"Latency" apps/mobile/tools/dev/latency_test.gd`
    - `grep -q "static func percentile" apps/mobile/tools/dev/latency_test.gd`
    - `grep -q "class_name LatencyTest" apps/mobile/tools/dev/latency_test.gd`
    - `test -f apps/mobile/tests/unit/test_latency_test_percentiles.gd`
    - `./tools/ci/test-client.sh` sai com código 0
    - `./tools/ci/validate-repo.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>! grep -q "print(\"Latency" apps/mobile/tools/dev/latency_test.gd && grep -q "static func percentile" apps/mobile/tools/dev/latency_test.gd && test -f apps/mobile/tests/unit/test_latency_test_percentiles.gd && ./tools/ci/test-client.sh && ./tools/ci/validate-repo.sh</automated>
  </verify>
  <done>latency_test.gd mede de verdade (evento -> tick -> frame), sem nenhum número fabricado; percentile() é testável headless e os 5 testes novos passam; test-client.sh e validate-repo.sh continuam verdes.</done>
</task>

<task type="checkpoint:human-action" gate="blocking">
  <name>Task 2: Checkpoint humano — medir latência, FPS e sensação em Android real</name>
  <what-built>
  `apps/mobile/tools/dev/latency_test.gd` real (Task 1 deste plano), o Runner de jogador
  movido por `InputRouter` nos três esquemas (Planos 02-03/02-05/02-06), e a checklist de
  sensação de `.gsd/phases/02-core-movement/ACCEPTANCE.md`. Nenhuma dessas três coisas pode
  ser verificada sem um Android real e sem pessoas jogando — não há CLI/API para isso.
  </what-built>
  <action>
    Checkpoint de ação humana. A Task 1 deste plano já escreveu a instrumentação real de
    latência (LatencyTest.percentile(), testada headless em test_latency_test_percentiles.gd).
    Este passo pede a medição ponta a ponta que só um aparelho físico e pessoas jogando podem
    dar. Revise os passos de "como verificar" abaixo e responda conforme o sinal de retomada.
  </action>
  <how-to-verify>
  1. Conectar um Android de tier **Mid** (`adb devices` mostra o aparelho).
  2. Gerar/instalar o APK de debug: `./tools/ci/build_android.sh debug` (se o APK de
     `dist/android/` não existir mais) seguido de `adb install -r dist/android/volta-debug.apk`.
  3. Anexar `LatencyTest` como filho de `MatchDirector` numa partida real (via `DevOverlay` ou
     temporariamente em `root.gd::_start_match()` — reverter antes de fechar a fase), setando
     `director` e `player_view` (a `RunnerView` do jogador, obtida do mesmo jeito que
     `_game_camera.target_visual` em `root.gd`).
  4. Para CADA um dos três esquemas (Settings > Controles): tocar/arrastar ≥ 100 vezes
     alternando direção, chamar `generate_report()`, anotar p50/p95.
  5. Rodar a mesma checagem num aparelho **High** e um **Low** (preset Low) para os números de
     FPS de `ACCEPTANCE.md` A02-12 (60 FPS Mid, 120 FPS High, 60 FPS Low).
  6. Reunir 3 pessoas de fora do projeto, cada uma jogando 2 minutos (`ACCEPTANCE.md`, "Teste
     de sensação"): perguntar "o controle responde?" e "você sentiu que errou por culpa sua ou
     do jogo?". Duas respostas negativas na segunda pergunta reprovam a fase mesmo com números
     verdes.
  7. Preencher a seção "Fase 2 — Core Movement" de `docs/performance/device-results.md` (criada
     na Task 3 deste plano) com os números reais coletados nos passos 4-5, e o resultado do
     teste de sensação do passo 6. Se algum número não puder ser medido agora, deixar
     `_pendente_` — nunca inventar.
  </how-to-verify>
  <resume-signal>Cole os números reais coletados (ou confirme "_pendente_, sem aparelho disponível") para eu preencher device-results.md e continuar o fechamento da fase</resume-signal>
  <verify>
    <automated>grep -q "static func percentile" apps/mobile/tools/dev/latency_test.gd && test -f apps/mobile/tests/unit/test_latency_test_percentiles.gd</automated>
  </verify>
  <done>Números reais de latência (p50/p95 por esquema), FPS por tier e o resultado do teste de sensação foram coletados em aparelho(s) real(is) e repassados para a Task 3 registrar — ou a pendência foi confirmada explicitamente ("_pendente_, sem aparelho disponível"), nunca fabricados.</done>
</task>

<task type="auto">
  <name>Task 3: device-results.md ganha a seção da Fase 2; CI real; HANDOFF/QUALITY_GATES/STATE/ROADMAP/REQUIREMENTS atualizados</name>
  <files>docs/performance/device-results.md, .gsd/phases/02-core-movement/HANDOFF.md, .gsd/QUALITY_GATES.md, .planning/STATE.md, .planning/ROADMAP.md, .planning/REQUIREMENTS.md</files>
  <read_first>
    - docs/performance/device-results.md (estado atual completo — genérico, sem fase, sem data; NÃO reescreva as seções existentes, só ADICIONE a da Fase 2)
    - .gsd/phases/02-core-movement/HANDOFF.md (template vazio — leia as 12 seções que ele pede)
    - .gsd/QUALITY_GATES.md (gate universal + gate de "fases com representação visual" — a Fase 2 está na lista; a tabela "Registro" no fim tem uma linha `| 02 | ⬜ | | |` para preencher)
    - .planning/STATE.md (frontmatter YAML no topo + seções "Current Position"/"Blockers/Concerns" — a linha de bloqueio da Fase 2 já existe, só precisa ser atualizada ou fechada)
    - .planning/ROADMAP.md (linha `- [ ] **Phase 2: Core Movement** —...` e a seção "### Phase 2" com os 6 critérios de sucesso e "**Plans**: TBD")
    - .planning/REQUIREMENTS.md (seção "## Movimento e controle (MOV)", MOV-01..07, todos `[ ]` hoje)
    - o resultado do checkpoint humano da Task 2 deste plano (números reais ou `_pendente_`)
  </read_first>
  <behavior>
    - Rodar as 3 checagens de CI de verdade e colar a saída real (não resumida de memória) no `SUMMARY.md` deste plano
    - `device-results.md` ganha uma seção nova "Fase 2 — Core Movement" com os números do checkpoint humano, ou `_pendente_` explícito onde não houver medição
    - `HANDOFF.md` é preenchido com o que foi REALMENTE entregue pelos 7 planos (não o que estava planejado) — incluindo as descobertas que mudaram o plano original (arenas da Fase 13 já existentes, PauseScreen/ResultsScreen já existentes, bug de safe area)
    - `QUALITY_GATES.md` ganha a linha `| 02 |` preenchida com data e observações
    - `REQUIREMENTS.md` marca `[x]` em MOV-01, MOV-02, MOV-03, MOV-04, MOV-06, MOV-07 (implementados e testados nesta fase); MOV-05 continua `[ ]` até a medição em aparelho real fechar (ou vira `[x]` se o checkpoint trouxe p95 < 50ms real nos 3 esquemas)
    - `ROADMAP.md` NÃO marca a Fase 2 como `[x]` completa enquanto MOV-05 estiver aberto — atualiza a linha de status e a seção da fase com o resultado real, preenche "**Plans**: 7 plans" e a lista de planos
    - `STATE.md` reflete a posição real (Fase 2 planejada e executada; bloqueio de aparelho fechado ou reafirmado) sem rodar nenhum comando `gsd-tools state/roadmap/requirements` (eles corrompem ou são no-op neste repositório)
  </behavior>
  <action>
    1. Rode, nesta ordem, e cole a saída real de cada um no `SUMMARY.md` deste plano (não
       resuma, não invente):

       ```bash
       ./tools/ci/validate-repo.sh
       ./tools/ci/lint.sh
       ./tools/ci/test-client.sh
       ```

       Se qualquer um falhar, conserte antes de continuar — não existe "fase fechada" com CI
       vermelho (CLAUDE.md §3).

    2. Adicione ao FINAL de `docs/performance/device-results.md` (sem tocar nas seções
       existentes, que pertencem a outra auditoria) uma seção assim, preenchida com os números
       reais do checkpoint humano (ou `_pendente_` explícito, nunca inventado):

       ```markdown
       ## Fase 2 — Core Movement (GSD 02 / MOVE-010)

       > Medido em {data real ou "_pendente_"} num Android {modelo real ou "_pendente_"},
       > usando `apps/mobile/tools/dev/latency_test.gd` (LatencyTest.percentile(), testado
       > headless em `test_latency_test_percentiles.gd`). Números `_pendente_` significam que
       > a medição real ainda não aconteceu — nunca um valor de memória (CLAUDE.md, Regra de
       > Ouro Anti-Burla).

       | Esquema | p50 (ms) | p95 (ms) | Alvo | Aparelho |
       |---|---|---|---|---|
       | Swipe | {valor ou _pendente_} | {valor ou _pendente_} | < 50 ms (p95) | {modelo ou _pendente_} |
       | Joystick | {valor ou _pendente_} | {valor ou _pendente_} | < 50 ms (p95) | {modelo ou _pendente_} |
       | Relativo | {valor ou _pendente_} | {valor ou _pendente_} | < 50 ms (p95) | {modelo ou _pendente_} |

       | Métrica | Valor | Aparelho |
       |---|---|---|
       | FPS (1 Runner, Mid) | {valor ou _pendente_} | {modelo ou _pendente_} |
       | FPS (1 Runner, High) | {valor ou _pendente_} | {modelo ou _pendente_} |
       | FPS (1 Runner, Low, preset Low) | {valor ou _pendente_} | {modelo ou _pendente_} |

       **Teste de sensação (3 pessoas, ACCEPTANCE.md):** {resultado real ou "_pendente_"}
       ```

    3. Preencha `.gsd/phases/02-core-movement/HANDOFF.md` seção a seção com o que os 7 planos
       de fato entregaram — não copie o objetivo, descreva o resultado real: os arquivos
       criados/modificados por plano, as descobertas que corrigiram o plano original (arenas
       da Fase 13 pré-existentes com `open_field.tres` fora de sincronia; `PauseScreen`/
       `ResultsScreen` já existentes como stubs da Fase 7; o bug de `_hud_header_top()`/
       `_safe_bottom_inset()` nunca definidos), as limitações conhecidas (BL-019/020/021 —
       território/combate/placar reais ficam para as Fases 3/4/6; MOV-05 aberto até medição em
       aparelho real), e os pré-requisitos confirmados para a Fase 3 (Arena com dimensão real,
       Runner movendo-se de verdade, `ConfigService` resolvível via Bootstrap).

    4. Em `.gsd/QUALITY_GATES.md`, na tabela "Registro", substitua a linha `| 02 | ⬜ | | |`
       por (data real da execução, não a de hoje se você não sabe qual será):

       ```
       | 02 | {✅ fechado ou 🟡 parcial — MOV-05 aberto} | {data real} | 7 planos; MOV-05 (latência) depende de medição em Android real, ver device-results.md |
       ```

    5. Em `.planning/REQUIREMENTS.md`, na seção "## Movimento e controle (MOV)", marque `[x]`
       em MOV-01, MOV-02, MOV-03, MOV-04, MOV-06, MOV-07. Deixe MOV-05 como está (`[ ]`) a
       menos que o checkpoint humano tenha trazido p95 < 50ms real nos três esquemas — nesse
       caso, marque `[x]` também.

    6. Em `.planning/ROADMAP.md`:
       - Na lista de fases, atualize a linha da Fase 2 removendo "(auditado 2026-08-31:
         parcial — sim central ligada, mas auditar)" e substituindo por um resumo real do que
         ficou pronto (ex.: "re-executada 2026-0X-XX: Runner/Input/Câmera/FSM reais e
         testados; MOV-05 aberto — depende de aparelho"). NÃO marque `[x]` se MOV-05 continuar
         aberto.
       - Na seção "### Phase 2: Core Movement", troque `**Plans**: TBD` por `**Plans**: 7
         plans` e adicione a lista dos 7 planos (mesmo formato da Fase 26, com um `[x]` ou
         `[ ]` por plano conforme o estado real de execução).

    7. Em `.planning/STATE.md`:
       - Atualize "Current Position" para refletir que a Fase 2 foi planejada e executada
         (7 planos), com o resultado real do CI.
       - Na seção "Blockers/Concerns", mantenha ou feche a linha `[Phase 2] É necessário um
         aparelho Android intermediário real para medir latência...` conforme o resultado real
         do checkpoint humano deste plano.
       - Adicione uma entrada em "Decisions" (mesmo estilo das entradas `[Phase XX-YY]:`
         existentes) registrando as descobertas mais importantes desta fase: arenas da Fase 13
         pré-existentes, PauseScreen/ResultsScreen reaproveitados da Fase 7, e o
         CanvasLayer/GameCamera introduzido para não quebrar a UI.
       - NÃO rode `gsd-tools state begin-phase`, `state advance-plan`, `state update-progress`,
         `roadmap update-plan-progress` nem `requirements mark-complete` — todos corrompem ou
         são no-op neste repositório (ver `.planning/phases/02-core-movement/02-CONTEXT.md`,
         bloco `<reexecution>`, e o histórico de decisões de `STATE.md` das Fases 26/26.1).
  </action>
  <acceptance_criteria>
    - `grep -q "## Fase 2 — Core Movement" docs/performance/device-results.md`
    - `! grep -q "⛔ \*\*Não preenchido\.\*\*" .gsd/phases/02-core-movement/HANDOFF.md`
    - `grep -q "| 02 |" .gsd/QUALITY_GATES.md`
    - `grep -q "\[x\] MOV-01" .planning/REQUIREMENTS.md`
    - `grep -q "\*\*Plans\*\*: 7 plans" .planning/ROADMAP.md`
    - `./tools/ci/validate-repo.sh` sai com código 0
    - `./tools/ci/lint.sh` sai com código 0
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>grep -q "## Fase 2 — Core Movement" docs/performance/device-results.md && grep -q "| 02 |" .gsd/QUALITY_GATES.md && grep -q "\*\*Plans\*\*: 7 plans" .planning/ROADMAP.md && ./tools/ci/validate-repo.sh && ./tools/ci/lint.sh && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>device-results.md tem a seção real da Fase 2 (números ou _pendente_ explícito); HANDOFF.md preenchido com o que foi de fato entregue; QUALITY_GATES.md e REQUIREMENTS.md refletem o estado real (MOV-05 aberto se não medido); ROADMAP.md e STATE.md atualizados à mão, sem gsd-tools; as 3 checagens de CI passam.</done>
</task>

</tasks>

<verification>
- `./tools/ci/validate-repo.sh`, `./tools/ci/lint.sh` e `./tools/ci/test-client.sh` saem com código 0, com a saída real colada no SUMMARY.md
- `docs/performance/device-results.md` tem a seção "Fase 2 — Core Movement" com números reais ou `_pendente_` — nunca fabricados
- `.gsd/phases/02-core-movement/HANDOFF.md` não tem mais o aviso "Não preenchido"
- `.gsd/QUALITY_GATES.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md` e `.planning/STATE.md` refletem o estado real, incluindo MOV-05 aberto se a medição em aparelho não aconteceu
</verification>

<success_criteria>
A Fase 2 fecha honestamente: tudo que foi implementado e testado headless está marcado como
tal; tudo que depende de um Android real e de pessoas jogando está explicitamente `_pendente_`
ou registrado como bloqueio aberto em `STATE.md` — nunca fabricado. `latency_test.gd` deixou de
imprimir números inventados. A Fase 3 (Territory Engine) tem uma base real para construir em
cima: Runner se movendo de verdade, Arena com dimensão real, câmera seguindo, e um
`ConfigService` alcançável.
</success_criteria>

<output>
Após completar, crie `.planning/phases/02-core-movement/02-07-SUMMARY.md` seguindo o template
de summary.md, colando a saída real das 3 checagens de CI e o resultado do checkpoint humano
(números reais ou `_pendente_`).
</output>
</content>
