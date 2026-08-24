# GSD 03 — Tarefas

> Ordem importa muito nesta fase: o solver é escrito e provado **isolado** antes de encostar
> no jogo. Não integre antes da TERR-007.

---

### TERR-001 — `TerritoryGrid`: estrutura e consultas

**Objetivo:** a estrutura de dados base, com consultas O(1) e contagem incremental.
**Contexto:** ADR-0002; `docs/architecture/territory-system.md` §2.
**Dependências:** GSD 02.
**Arquivos:** `src/territory/territory_grid.gd`, `tests/unit/test_territory_grid.gd`.
**Passos:**
1. `_owner` e `_arc` como `PackedByteArray` de `width*height`; `255` = bloqueada.
2. `cell_index`, `cell_at(world_pos)`, `owner_of`, `arc_owner_of`, `is_blocked`.
3. `_claim_count: PackedInt32Array` mantido incrementalmente em toda escrita.
4. `setup(width, height, blocked)`, `reset()`, `seed_claim(runner_id, center, size)`,
   `release_claim(runner_id)`.
5. `claim_percent(runner_id)` sobre o total de células **jogáveis**.
**Testes:** consultas; `seed_claim` cria exatamente N² células; contagem bate com varredura
completa após 1 000 escritas aleatórias; `release_claim` zera e devolve ao neutro.
**DoD:** invariante `Σ claim_count + neutras + bloqueadas == total` verificada em teste.

---

### TERR-002 — Conversão mundo ↔ célula

**Objetivo:** a ponte entre a posição contínua do Runner e o grid discreto.
**Dependências:** TERR-001.
**Arquivos:** `src/territory/grid_space.gd`.
**Passos:**
1. `world_to_cell`, `cell_to_world_center`, `cell_rect`.
2. Arredondamento explícito e documentado (sem depender de comportamento implícito de float).
3. Clamp nos limites.
**Testes:** ida e volta em todos os cantos do Field; comportamento exato na fronteira entre
células (o caso que gera bug de "capturou uma célula a mais").
**DoD:** nenhuma outra classe faz conversão por conta própria.

---

### TERR-003 — Rasterização do Arc (supercover) ⚠️ RISK-002

**Objetivo:** garantir que o Arc é sempre 4-conectado. **Sem isso, o flood fill vaza e o jogo
captura o mapa inteiro.**
**Contexto:** `docs/architecture/territory-system.md` §3.
**Dependências:** TERR-002.
**Arquivos:** `src/territory/arc_rasterizer.gd`, `tests/unit/test_arc_rasterizer.gd`.
**Passos:**
1. Traçado supercover entre a célula do tick anterior e a atual, incluindo as ortogonais em
   toda transição diagonal.
2. Caso comum (0 ou 1 célula) sem custo extra.
3. Caso de salto longo (Overdrive, hitch) coberto pelo algoritmo geral.
**Testes:**
- **teste de propriedade:** 10 000 pares de pontos aleatórios → o conjunto resultante é sempre
  4-conectado e contém as duas extremidades;
- casos de mesa: horizontal, vertical, diagonal exata 45°, quase-diagonal, salto de 20 células;
- nenhuma célula duplicada.
**DoD:** teste de propriedade verde com 10 000 casos; documentado no `HANDOFF.md` como a
primeira defesa contra RISK-002.

---

### TERR-004 — `ArcTracker`

**Objetivo:** manter o Arc de cada Runner: ordem, comprimento, limpeza.
**Dependências:** TERR-003.
**Arquivos:** `src/territory/arc_tracker.gd`.
**Passos:**
1. `PackedInt32Array` por Runner com os índices na ordem de desenho (necessário para o VFX
   de dissolução e para o Overload).
2. `mark(runner_id, from_cell, to_cell)` usando o rasterizador; atualiza `_arc` e a lista.
3. `clear(runner_id)`; `length(runner_id)`; `contains(runner_id, index)`.
4. Detecção de auto-interseção: marcar uma célula que já é Arc próprio → sinal
   `self_intersect` (o **comportamento** é da GSD 04; aqui só a detecção).
5. Capacidade pré-alocada = `arc_max_cells`.
**Testes:** ordem preservada; limpeza total; auto-interseção detectada exatamente uma vez;
zero alocação depois do setup.
**DoD:** `_arc` e a lista nunca divergem (invariante verificada em teste).

---

### TERR-005 — Overload do Arc

**Objetivo:** limitar o comprimento do Arc sem punição arbitrária (E07).
**Dependências:** TERR-004.
**Arquivos:** `src/territory/arc_tracker.gd`, `resources/config/balance/territory.tres`.
**Passos:**
1. Ao atingir `arc_max_cells`, a cauda começa a se desfazer a `overload_decay` células/s.
2. Sinal `overload_warning` disparado 2 s antes do limite (baseado na velocidade atual).
3. Célula removida limpa `_arc` corretamente.
**Testes:** comprimento nunca ultrapassa o máximo; a cauda decai na taxa correta; o Seal após
Overload captura a região certa (contorno menor, não corrompido).
**DoD:** limite superior de memória do Arc garantido por construção.

---

### TERR-006 — `SealSolver` ⚠️ RISK-001

**Objetivo:** o algoritmo central, como **função pura**.
**Contexto:** `docs/architecture/territory-system.md` §4.
**Dependências:** TERR-004.
**Arquivos:** `src/territory/seal_solver.gd`, `seal_result.gd`, `tests/unit/test_seal_solver.gd`.
**Passos:**
1. Região de busca: união da bbox do Arc com a porção adjacente do Claim, expandida em 1 e
   cortada pelo Field.
2. Flood fill de 4 vizinhos a partir de todas as células não-barreira da **borda** da região.
3. Barreiras = Claim próprio ∪ Arc próprio.
4. Capturado = células da região não alcançadas e não-barreira, excluindo bloqueadas.
5. Buffers pré-alocados; `_visited` com epoch (sem `fill(0)` por Seal).
6. Retorna `SealResult` (capturadas, roubadas por dono, bbox, arcos inimigos engolidos,
   microssegundos) — **sem** emitir sinal e **sem** escrever no grid.
**Testes — 30 casos de mesa, com grid montado à mão e resultado esperado explícito:**
retângulo simples · forma em L · côncavo · contra a borda · contra o canto · com buraco ·
com célula bloqueada dentro · sem área interna · Arc de 2 células · região com território
inimigo · região com dois inimigos · Arc atravessando o Claim inimigo · Claim desconectado ·
região adjacente a outra região própria · Arc que toca o Claim em dois pontos · espiral ·
formato de U · U invertido · anel · anel com ilha · Arc colado no próprio Claim · Arc que sai
e volta pela mesma célula · região de 1 célula · região do mapa inteiro · Arc no comprimento
máximo · Claim côncavo maior que a bbox do Arc (B13) · região com Arc inimigo dentro ·
duas regiões fechadas pelo mesmo Arc · Arc que toca a borda em dois pontos · captura que zera
o Claim de um inimigo.
**DoD:** 30/30 verdes; solver puro (nenhuma dependência de partida); zero alocação por chamada.

---

### TERR-007 — Aplicação do Seal no grid

**Objetivo:** transformar o `SealResult` em mudança de estado, com eventos.
**Contexto:** `docs/architecture/territory-system.md` §4 (aplicação); regras R4.3–R4.6.
**Dependências:** TERR-006.
**Arquivos:** `src/territory/territory_grid.gd`, `src/territory/seal_applier.gd`.
**Passos:**
1. Aplicar dono e atualizar contadores (inclusive decrementando o dono anterior).
2. Converter o Arc em Claim e limpar.
3. Emitir `seal_completed(runner_id, cells, stolen, bbox)`.
4. Emitir `arc_swallowed(victim, by)` quando o Seal engolir Arc inimigo (R4.5).
5. Emitir `squeezed(victim, by)` quando um Claim zerar (R4.6).
6. Atualizar `dirty_rect`.
7. Ordem determinística entre Seals no mesmo tick, por `runner_id` crescente (R4.7).
**Testes:** contadores corretos após roubo; sinais emitidos com os dados certos; dois Seals no
mesmo tick resolvem na ordem correta e o segundo enxerga o primeiro.
**DoD:** invariante de soma de células verde após 10 000 Seals aleatórios.

---

### TERR-008 — Integração com o Runner e a FSM

**Objetivo:** o Runner realmente sai, desenha e captura.
**Dependências:** TERR-007.
**Arquivos:** `src/runner/runner.gd`, `src/runner/states/*.gd`, `src/gameplay/match_director.gd`.
**Passos:**
1. Adicionar `DrawingTrail` e `Sealing` à FSM do Runner, com as transições da tabela.
2. `MatchDirector`: no tick, após o movimento, atualizar o grid e detectar as condições.
3. `Sealing` resolve no mesmo tick e volta para `Safe` (R2.3) — o controle **nunca** trava.
4. `seed_claim` no spawn.
**Testes:** integração — sair inicia o Arc; voltar captura; `Safe` implica `arc_length == 0`
(assert em debug); o controle continua respondendo durante a captura.
**DoD:** o loop de 10 segundos existe e é jogável.

---

### TERR-009 — Renderização do território

**Objetivo:** ver o território, com custo constante.
**Contexto:** `docs/architecture/territory-system.md` §5.
**Dependências:** TERR-007.
**Arquivos:** `src/presentation/territory_renderer.gd`, `assets/shaders/territory.gdshader`.
**Passos:**
1. `Image`/`ImageTexture` do tamanho do grid; atualizar apenas o `dirty_rect`.
2. Shader: cor por dono a partir da paleta, borda por diferença de vizinhos, glow básico.
3. Filtro nearest; um único quad; **1 draw call**.
4. Cor provisória (`PLACEHOLDER-ART-002 / Replacement: GSD 08`).
**Testes:** captura de 20 % custa o mesmo que 1 % em tempo de render (benchmark B14);
1 draw call confirmado no monitor da engine.
**DoD:** território visível e atualizado corretamente; custo independente do tamanho da captura.

---

### TERR-010 — Renderização do Arc

**Objetivo:** ver o Arc, com brilho proporcional ao risco.
**Dependências:** TERR-004.
**Arquivos:** `src/presentation/arc_renderer.gd`, `assets/shaders/arc.gdshader`.
**Passos:**
1. `MultiMeshInstance2D` (ou `Line2D` alimentada pela lista ordenada) por Runner.
2. Intensidade do brilho = f(comprimento) — a base visual do Pilar 1.
3. Estado de Overload com cintilação distinta.
4. `PLACEHOLDER-ART-003 / Replacement: GSD 08`.
**Testes:** o Arc desenhado corresponde exatamente às células marcadas (comparação
grid × visual); nenhum nó por célula.
**DoD:** Arc de 1 200 células sem queda de FPS.

---

### TERR-011 — Animação de captura

**Objetivo:** o Seal precisa **parecer** um evento (Pilar 4), mesmo com arte provisória.
**Contexto:** `docs/design/game-feel.md`.
**Dependências:** TERR-009.
**Arquivos:** `src/presentation/seal_animation.gd`, shader de máscara.
**Passos:**
1. Máscara radial animada a partir do ponto de fechamento, com `ease_out_cubic`.
2. Duração de `capture_animation_duration` (config), sem bloquear input.
3. Onda de luz percorrendo o Arc antes do preenchimento.
4. VFX completo fica para a GSD 09 — aqui é a mecânica de animação, não o espetáculo.
**Testes:** a animação nunca atrasa a simulação; capturas em sequência não acumulam animação
nem estouram o pool.
**DoD:** capturar dá gostinho mesmo com quadrados coloridos.

---

### TERR-012 — Zoom dinâmico da câmera

**Objetivo:** o jogador **ver** o próprio domínio crescer (Pilar 4).
**Dependências:** TERR-008, MOVE-009.
**Arquivos:** `src/presentation/camera/game_camera.gd`.
**Passos:**
1. Zoom interpolado entre `zoom_range` conforme `claim_percent`.
2. Interpolação lenta (nunca salta) e limitada pelos limites do Field.
3. Zoom-out extra momentâneo em capturas grandes (a base do punch da GSD 09).
**Testes:** zoom acompanha o território sem oscilar; sem estouro de borda; sem enjoo em 2 min.
**DoD:** a diferença entre 5 % e 40 % de território é perceptível na câmera.

---

### TERR-013 — Serialização e benchmarks

**Objetivo:** medir e poder reproduzir. **RISK-001 vive ou morre aqui.**
**Contexto:** `docs/performance/territory-benchmarks.md`.
**Dependências:** TERR-007.
**Arquivos:** `src/territory/grid_serializer.gd`, `tools/benchmarks/territory_bench.gd`,
`tests/baselines/territory/`.
**Passos:**
1. Serialização binária conforme §10 do documento de território, com CRC32.
2. Implementar os 15 benchmarks (B01–B15).
3. Rodar em desktop **e** em dispositivo Android real.
4. Gravar o baseline; ligar a verificação de regressão (> 10 % reprova) ao CI.
**Testes:** round-trip de serialização; todos os benchmarks dentro do orçamento.
**DoD:** `docs/performance/territory-benchmarks.md` com a tabela de registro preenchida;
baseline versionado; CI comparando.

---

### TERR-014 — Invariantes e stress test do território

**Objetivo:** provar que não existe caso raro em que o território fica errado.
**Dependências:** TERR-001..013.
**Arquivos:** `tools/dev/simulate.gd`, `src/territory/territory_invariants.gd`.
**Passos:**
1. Implementar as invariantes de `docs/testing/testing-strategy.md` §3, verificadas a cada tick
   em modo de teste.
2. Runner de simulação com um Runner controlado por um "bot burro" (movimento aleatório com
   viés de retorno) — o bot de verdade é a GSD 05.
3. Rodar 500 partidas com seeds sequenciais.
4. Toda violação grava `seed`, estado serializado, eventos e `repro.sh`.
5. Corrigir tudo que aparecer. **Zero violação é critério de saída.**
**Testes:** 500 partidas com 0 crash, 0 invariante violada, 0 partida infinita.
**DoD:** relatório em `.reports/`; qualquer falha vira caso de mesa permanente em
`test_seal_solver.gd`.
