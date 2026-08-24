# GSD 02 — Tarefas

---

### MOVE-001 — FSM genérica e FSM do jogo

**Objetivo:** máquina de estados tipada, com transições declaradas, e a FSM do jogo em cima dela.
**Contexto:** `docs/architecture/state-machines.md` §3.
**Dependências:** GSD 01.
**Arquivos:** `src/core/fsm/state_machine.gd`, `state.gd`, `src/gameplay/game_state.gd`,
`src/gameplay/states/*.gd`.
**Passos:**
1. `StateMachine` com `add_state`, `add_transition`, `request`, `tick`, sinal `state_changed`.
2. Transição inválida: `assert` em debug, log `ERROR` + ignorar em release.
3. Estados do jogo: Boot, Menu, Loading, Countdown, Playing, Paused, Results — com telas
   provisórias (rótulo de texto + botão).
4. `Paused` congela `_physics_process` de toda a simulação.
**Testes:** todas as transições da tabela do documento; ≥ 5 transições inválidas rejeitadas;
pause congela contadores.
**DoD:** navegação completa pelo ciclo de jogo com telas feias; nenhuma condição booleana
espalhada substituindo estado.

---

### MOVE-002 — Loop de simulação com tick fixo

**Objetivo:** o coração temporal do jogo (ADR-0014).
**Dependências:** MOVE-001.
**Arquivos:** `src/gameplay/match_director.gd`, `src/gameplay/simulation_clock.gd`.
**Passos:**
1. `MatchDirector` roda a simulação em `_physics_process`, em ordem fixa:
   input → (IA) → movimento → (território) → (regras) → eventos.
2. Sem `await` e sem dependência de `delta` variável.
3. Contador de tick, seed da partida, e API `step(dt)` para testes headless.
4. `Engine.max_fps` acompanha a taxa do painel.
**Testes:** headless — 600 `step()` produzem exatamente o mesmo estado com a mesma seed,
em 10 execuções.
**DoD:** determinismo comprovado; simulação roda sem nó visual.

---

### MOVE-003 — `Runner` (entidade de simulação)

**Objetivo:** a entidade, sem nada visual.
**Dependências:** MOVE-002.
**Arquivos:** `src/runner/runner.gd`, `runner_state.gd`, `movement.gd`, `stat_block.gd`.
**Passos:**
1. Estado: id, posição (`Vector2`), direção, direção desejada, velocidade, estado da FSM.
2. `StatBlock` com modificadores empilháveis (base para power-ups na GSD 14) resolvidos em um
   único ponto.
3. Movimento: girar em direção à desejada respeitando `turn_rate`, depois avançar por `speed`.
4. FSM do Runner com `Spawn`, `Safe`, `Eliminated` (os demais entram nas fases 03/04).
**Testes:** giro respeita a taxa máxima; direção oposta leva exatamente `180/turn_rate`
segundos; `StatBlock` soma e remove modificadores sem resíduo.
**DoD:** `Runner` sem nenhuma referência visual; velocidade e giro vindos de config.

---

### MOVE-004 — Interpolação visual

**Objetivo:** 120 Hz de verdade, com simulação a 60 Hz.
**Dependências:** MOVE-003.
**Arquivos:** `src/presentation/interpolated_visual.gd`, `src/presentation/runner_view.gd`.
**Passos:**
1. Componente único que guarda `prev`/`curr` e interpola em `_process` por
   `Engine.get_physics_interpolation_fraction()`.
2. `RunnerView` desenha um círculo provisório (`PLACEHOLDER-ART-001 / Replacement: GSD 08`).
3. Rotação também interpolada.
**Testes:** com simulação congelada, o visual não se move; em 120 Hz o movimento não mostra
degraus (verificação por gravação em câmera lenta).
**DoD:** nenhuma entidade visual implementa interpolação por conta própria.

---

### MOVE-005 — `InputRouter` e driver de swipe

**Objetivo:** o esquema padrão, excelente.
**Contexto:** `docs/gameplay/controls.md`.
**Dependências:** MOVE-003.
**Arquivos:** `src/input/input_router.gd`, `input_driver.gd`, `drivers/swipe_driver.gd`.
**Passos:**
1. Interface `InputDriver.poll(delta) -> Vector2`.
2. Swipe: zona morta em mm físicos (converter usando o DPI da tela), direção contínua enquanto
   o dedo estiver na tela, manutenção da direção ao soltar.
3. Eventos coletados sem perda e consumidos no tick.
4. Toque que começa sobre UI não vira movimento.
**Testes:** unitário com eventos sintéticos; zona morta equivalente em duas densidades;
toque em UI ignorado.
**DoD:** simulação recebe apenas um vetor de direção; nenhum `InputEvent` chega ao `Runner`.

---

### MOVE-006 — Buffer de input

**Objetivo:** nenhum toque descartado (Pilar 2).
**Dependências:** MOVE-005.
**Arquivos:** `src/input/input_buffer.gd`.
**Passos:**
1. Fila curta de direções desejadas com janela de validade.
2. Se a direção atual ainda não foi atingida e chega outra, enfileira em vez de substituir
   — a menos que a nova seja praticamente a mesma.
3. Descarte por idade, para não aplicar comando velho.
**Testes:** dois comandos no mesmo tick → ambos são executados na ordem; comando muito antigo
é descartado; comando redundante não enfileira.
**DoD:** medição de latência de MOVE-010 dentro do alvo mesmo em sequência rápida de swipes.

---

### MOVE-007 — Drivers de joystick e relativo

**Objetivo:** as outras duas opções de controle, com paridade de qualidade.
**Dependências:** MOVE-005.
**Arquivos:** `drivers/joystick_driver.gd`, `drivers/relative_driver.gd`,
`src/ui/screens/settings_controls.gd` (provisório).
**Passos:**
1. Joystick flutuante: aparece onde tocar, some ao soltar, raio e zona morta configuráveis,
   opção de fixar no canto.
2. Relativo: arraste horizontal gira proporcionalmente; sensibilidade configurável.
3. Tela provisória de settings para trocar de esquema em runtime, com **test drive** embutido.
**Testes:** troca de driver em runtime sem reiniciar; cada driver produz direção coerente com
eventos sintéticos.
**DoD:** os três esquemas jogáveis; trocar de esquema não toca em simulação.

---

### MOVE-008 — Arena e limites do Field

**Objetivo:** o espaço de jogo, ainda sem grid.
**Dependências:** MOVE-003.
**Arquivos:** `src/arena/arena_definition.gd`, `src/arena/arena.gd`, `resources/arenas/open_field.tres`.
**Passos:**
1. `ArenaDefinition` como `Resource`: dimensões em células, tamanho de célula, spawns, células
   bloqueadas (vazio agora).
2. `Arena` calcula os limites do mundo e contém o Runner: colidir com a borda **desliza**
   (o comportamento de Backwash chega na GSD 04, quando existir Arc).
3. Fundo provisório (`PLACEHOLDER-ART-006 / Replacement: GSD 08`).
**Testes:** Runner não sai do Field em nenhuma direção nem em velocidade máxima; deslize na
borda é suave (sem travar nem vibrar).
**DoD:** arena definida por dado; nenhuma dimensão hardcoded.

---

### MOVE-009 — Câmera

**Objetivo:** seguir o Runner de forma que ninguém repare na câmera.
**Contexto:** `docs/design/balance.md` §11.
**Dependências:** MOVE-004, MOVE-008.
**Arquivos:** `src/presentation/camera/game_camera.gd`.
**Passos:**
1. Follow com suavização exponencial + lookahead na direção do movimento.
2. Limites: a câmera não mostra além da borda do Field.
3. Zoom base a partir de config; API pronta para o zoom dinâmico da GSD 03 e para os punches
   da GSD 09 (sem implementá-los agora).
4. Atualização em `_process`, sobre a posição **interpolada** — nunca sobre a de simulação.
**Testes:** sem tremor em movimento constante; sem estouro de borda; comportamento idêntico em
16:9 e 20:9.
**DoD:** gravação de 60 s de movimento sem nenhum solavanco perceptível.

---

### MOVE-010 — Medição de latência e validação em dispositivo

**Objetivo:** provar com número que o controle responde (R02-14).
**Dependências:** MOVE-001..009.
**Arquivos:** `tools/dev/latency_test.gd`, `docs/performance/device-results.md`.
**Passos:**
1. Instrumentar: timestamp do `InputEvent` → tick em que a direção desejada muda → primeiro
   frame renderizado com a nova direção.
2. Rodar em dispositivo real, 100 amostras, reportar p50/p95.
3. Testar os três esquemas de controle.
4. Registrar em `device-results.md` e no `HANDOFF.md`.
5. Se p95 > 50 ms, **investigar antes de fechar a fase** (suspeitos: vsync, ordem de
   processamento de input, buffer, `max_physics_steps`).
**Testes:** a própria medição; e um teste de regressão que falha se a mediana passar do alvo.
**DoD:** p95 < 50 ms nos três esquemas, no aparelho Mid, documentado.
