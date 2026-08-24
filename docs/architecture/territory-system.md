# Sistema de território

> **O sistema mais crítico do projeto.** Se ele estiver errado, o jogo está errado. Se ele
> estiver lento, o jogo está lento. Tudo mais é negociável; isto não é.
>
> Decisão de representação: [`ADR-0002`](../decisions/ADR-0002-territory-representation.md).
> Implementado em **GSD 03**, otimizado em **GSD 19**.

---

## 1. Requisitos

| # | Requisito |
|---|---|
| T1 | Consultar o dono de uma célula em O(1) |
| T2 | Marcar/limpar células de Arc em O(1) |
| T3 | Resolver um Seal em tempo proporcional à **região afetada**, nunca ao mapa inteiro |
| T4 | Suportar Claims desconectados, buracos, roubo e captura contra a borda |
| T5 | Ser determinístico: mesma entrada → mesma saída, em qualquer plataforma |
| T6 | Não alocar no caminho quente |
| T7 | Permitir renderização incremental (só o que mudou) |
| T8 | Rodar 8 Runners, 128×128, a 60 Hz, dentro do orçamento de CPU |
| T9 | Ser serializável (replay, futuro servidor autoritativo) |

---

## 2. Representação

**Grid denso**, dois arrays paralelos de bytes, indexados por `y * width + x`:

```gdscript
var _owner: PackedByteArray   # 0 = neutra, 1..N = runner_id, 255 = bloqueada
var _arc:   PackedByteArray   # 0 = sem arco, 1..N = runner_id dono do arco
```

Para 128×128: **16 KB por array**, 32 KB no total. Cabe em cache. Zero indireção, zero
ponteiro, zero `Dictionary` no caminho quente.

Estruturas auxiliares:

```gdscript
var _claim_count: PackedInt32Array   # células por runner, mantido incrementalmente
var _arc_cells:   Array[PackedInt32Array]  # índices do arco de cada runner, na ordem de desenho
var _dirty_rect:  Rect2i             # região alterada no tick, para o renderer
var _fill_buffer: PackedInt32Array   # pilha do flood fill, pré-alocada (w*h)
var _visited:     PackedByteArray    # marcação do flood fill, com epoch para não zerar
```

**Truque de epoch:** `_visited` guarda um número de "geração" em vez de booleano. Cada Seal
incrementa a geração; comparar `_visited[i] == epoch` substitui limpar o array inteiro.
Elimina o custo de `fill(0)` a cada captura.

### Por que grid denso e não outra coisa

| Alternativa | Por que não |
|---|---|
| Polígonos / `Geometry2D` | união e diferença de polígonos com buracos é frágil, alocadora e não determinística entre plataformas; um `Claim` real vira centenas de vértices |
| Quadtree | ganho de memória irrelevante em 32 KB; consulta O(log n) pior que O(1); código muito mais complexo |
| Bitmask por jogador (N arrays de bits) | consulta de "quem é o dono" vira loop por jogador; roubo fica caro |
| Chunks esparsos | só compensa em mapas gigantes; nossas arenas são limitadas por design |
| `TileMap` do Godot | acopla simulação a nó visual — quebra a regra número um da arquitetura |

Chunks e bitmasks **voltam à mesa** se algum dia existir arena acima de 512×512 (registrado
como possível ADR futuro).

---

## 3. Rasterização do Arc

O Runner tem posição contínua. O Arc precisa ser **4-conectado** no grid, senão o flood fill
vaza pela diagonal e o Seal captura o mapa inteiro (bug clássico do gênero).

Algoritmo: traçado *supercover* entre a célula do tick anterior e a do tick atual.

```text
para cada tick:
    c0 = célula do frame anterior
    c1 = célula atual
    se c0 == c1: nada a fazer
    senão: marcar todas as células atravessadas pelo segmento c0→c1,
           incluindo as duas ortogonais em toda transição diagonal
```

Como a velocidade máxima por tick é bem menor que uma célula em condições normais, o caminho
típico marca 0 ou 1 célula. O algoritmo geral existe para picos (Overdrive, hitches, tick longo).

**Invariante testável:** para qualquer sequência de posições, o conjunto de células do Arc é
4-conectado. Teste de propriedade com posições aleatórias (GSD 03).

---

## 4. O Seal

### Ideia

Não procuramos "a região cercada". Procuramos **o que escapa**. Tudo que não escapa foi cercado.

```text
barreiras := células do meu Claim ∪ células do meu Arc
região de busca := bounding box do Arc, expandida em 1 célula, cortada pelo Field
flood fill de 4 vizinhos a partir de TODAS as células não-barreira da borda da região de busca
capturado := células da região de busca que não foram alcançadas e não são barreira
```

### Por que a bounding box basta

O Arc, junto com o Claim, forma o contorno. Qualquer célula cercada está, por definição,
dentro da bounding box do Arc **ou** já era do Claim. Células fora da bbox alcançam a borda
externa por caminhos fora dela. A expansão em 1 célula garante que a "borda de saída" da busca
esteja fora do contorno.

Sutileza tratada: quando o Claim é côncavo, uma região pode ser cercada por Claim + Arc em uma
área **maior** que a bbox do Arc. Por isso a região de busca é a **união das bboxes do Arc e
da porção de Claim adjacente ao Arc**, cortada pelo Field. O custo continua local — verificado
por benchmark, não por fé (GSD 03/19).

### Custo

`O(área da região de busca)`, não `O(mapa)`. Um Seal típico de 3 % em 128×128 percorre algumas
centenas de células. O pior caso (Arc atravessando o mapa inteiro) é 16 384 células — ainda
trivial, e medido no benchmark `worst_case_full_map_seal`.

### Aplicação

```text
para cada célula capturada:
    se dono anterior != 0 e != eu:  _claim_count[anterior] -= 1 ; marcar "roubada"
    _owner[i] = eu ; _claim_count[eu] += 1
para cada célula do meu Arc:
    _owner[i] = eu ; limpar _arc[i]
se algum Arc inimigo tinha células capturadas:  emitir arc_swallowed(inimigo)
se _claim_count[algum inimigo] == 0:            emitir squeezed(inimigo)
atualizar _dirty_rect
emitir seal_completed(runner, células, roubadas, bbox)
```

Ordem entre Seals no mesmo tick: crescente por `runner_id` (R4.7). O segundo solver enxerga o
resultado do primeiro. Determinismo acima de "justiça" percebida — e a probabilidade de
empate exato é desprezível.

---

## 5. Renderização

O renderer **nunca** lê célula por célula todo frame.

| Camada | Técnica |
|---|---|
| Claims | textura `Image`/`ImageTexture` do tamanho do grid, atualizada só no `_dirty_rect`, esticada com filtro nearest e um shader que aplica cor do tema, borda e brilho |
| Arcs | `MultiMeshInstance2D` ou `Line2D` por Runner, alimentado pela lista ordenada de células |
| Animação de Seal | shader com máscara de progresso radial a partir do ponto de fechamento (a região já é do jogador na simulação; a animação é só apresentação) |
| Bordas | detectadas no shader por diferença de vizinhos — sem custo de CPU |

Consequência: **capturar 20 % do mapa custa o mesmo que capturar 1 %** em tempo de CPU de
render. É o que permite Mega Seals espetaculares sem perder frame.

---

## 6. Colisões

Todas resolvidas por consulta ao grid — sem `Area2D`, sem física do engine, sem broadphase:

```gdscript
var cell := grid.cell_at(runner.position)
var arc_owner := grid.arc_owner(cell)
if arc_owner != 0 and arc_owner != runner.id:
    emit_break(victim = arc_owner, killer = runner.id)
elif arc_owner == runner.id and runner.state == DRAWING:
    emit_backwash(runner.id)
```

O2(1) por Runner por tick. 8 Runners = 8 consultas. Isso é o "sistema de colisão" inteiro.
Colisão Runner↔Runner (repulsão suave, R5.3) usa distância direta — são no máximo 8 entidades.

---

## 7. Casos de borda (todos com teste obrigatório em GSD 03/04)

| # | Caso | Comportamento |
|---|---|---|
| B01 | Arc encosta na borda do Field | borda conta como barreira: cercar contra a parede funciona |
| B02 | Seal sem nenhuma célula interna | válido; Arc vira Claim; zero pontos de área (R4.8) |
| B03 | Claim vira duas regiões desconectadas | permitido; contagem é global |
| B04 | Buraco dentro do Claim (região neutra cercada) | **é capturado** no Seal seguinte que a inclua na busca |
| B05 | Arc cruza Claim inimigo | permitido; ao selar, as células são roubadas |
| B06 | Seal engole Arc inimigo | inimigo sofre Backwash; bônus `Cut` |
| B07 | Dois Seals no mesmo tick | resolvidos por `runner_id` crescente |
| B08 | Runner morre no mesmo tick do Seal | Seal primeiro, morte depois |
| B09 | Arc atinge o comprimento máximo | Overload: cauda decai; célula removida limpa `_arc` |
| B10 | Célula bloqueada dentro da região | não capturada, não conta no percentual |
| B11 | Claim do inimigo zerado | Squeeze: eliminação + respawn conforme o modo |
| B12 | Arc marcado sobre célula que virou Claim de outro | permitido: `_owner` e `_arc` são independentes |
| B13 | Seal com Claim côncavo abraçando área fora da bbox do Arc | região de busca inclui o Claim adjacente (§4) |
| B14 | Runner desconecta o Arc por teleporte/Overdrive extremo | impossível: rasterização supercover garante continuidade |

---

## 8. Orçamento de performance

| Operação | Orçamento por tick (16,6 ms) 🎯 |
|---|---|
| Marcação de Arc (8 Runners) | < 0,05 ms |
| Colisões (8 Runners) | < 0,02 ms |
| Seal típico (3 % do mapa) | < 0,8 ms |
| Seal de pior caso (mapa inteiro) | < 4,0 ms |
| Atualização de textura (`_dirty_rect`) | < 0,5 ms |
| **Total do módulo território** | **< 2,0 ms em regime, < 5,0 ms em pico** |

Medido em dispositivo Android intermediário, não em desktop. Benchmarks e resultados em
[`../performance/territory-benchmarks.md`](../performance/territory-benchmarks.md).

---

## 9. Interface pública

```gdscript
class_name TerritoryGrid

func setup(width: int, height: int, blocked: PackedByteArray) -> void
func reset() -> void

func cell_index(cell: Vector2i) -> int
func cell_at(world_pos: Vector2) -> Vector2i
func owner_of(index: int) -> int
func arc_owner_of(index: int) -> int
func is_blocked(index: int) -> bool

func claim_cells(runner_id: int) -> int
func claim_percent(runner_id: int) -> float

func mark_arc(runner_id: int, from_cell: Vector2i, to_cell: Vector2i) -> void
func clear_arc(runner_id: int) -> void
func arc_length(runner_id: int) -> int

func seed_claim(runner_id: int, center: Vector2i, size: int) -> void
func release_claim(runner_id: int) -> void     # morte: território vira neutro

signal seal_completed(runner_id: int, cells: int, stolen: int, bbox: Rect2i)
signal arc_swallowed(victim_id: int, by_id: int)
signal squeezed(victim_id: int, by_id: int)
signal cells_changed(rect: Rect2i)
```

```gdscript
class_name SealSolver
func solve(grid: TerritoryGrid, runner_id: int) -> SealResult
# SealResult: cells_captured, cells_stolen, bbox, swallowed_arcs, elapsed_us
```

`SealSolver` é **puro**: recebe o grid, devolve o resultado, não emite sinal, não toca em VFX,
não sabe o que é uma partida. É por isso que ele é testável com 30 casos de mesa.

---

## 10. Serialização

```text
[uint16 width][uint16 height][uint8 runner_count]
[owner: width*height bytes][arc: width*height bytes]
[por runner: uint32 claim_count][uint32 crc32]
```

Usado em: snapshot de replay, teste de regressão com estado congelado ("golden state") e,
futuramente, sincronização com o servidor autoritativo. Comprimido: ~2–4 KB por snapshot.
