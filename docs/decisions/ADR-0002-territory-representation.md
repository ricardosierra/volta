# ADR-0002 — Representação do território

## Context

O território é o coração do jogo. Precisamos: consultar dono de célula em O(1); marcar arco em
O(1); resolver uma captura em tempo proporcional à região afetada; suportar territórios
desconectados, buracos, roubo e captura contra a borda; ser determinístico entre plataformas
(pré-requisito de testes, replay e servidor autoritativo); não alocar no caminho quente; e
permitir render incremental. Tudo isso dentro de ~2 ms de CPU por tick num Android intermediário.

## Decision

**Grid denso** de células, com dois `PackedByteArray` paralelos: `_owner` e `_arc`, indexados
por `y * width + x`. Captura resolvida por **flood fill de 4 vizinhos a partir do exterior**,
restrito à bounding box do Arc (unida à porção adjacente do Claim) expandida em 1 célula: o que
não alcança o exterior foi cercado.

Buffers do solver são pré-alocados e reutilizados; a marcação de visitados usa **epoch** (número
de geração) em vez de limpar o array a cada captura.

Arena padrão 128×128 = 16 384 células = 32 KB para os dois arrays. Cabe em cache.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Polígonos / operações booleanas 2D** | União e diferença com buracos é frágil, alocadora e sensível a precisão de ponto flutuante → risco de divergência entre cliente e servidor. Um Claim real vira centenas de vértices. |
| **Quadtree** | Ganho de memória irrelevante frente a 32 KB; consulta O(log n) pior que O(1); complexidade alta para benefício nulo |
| **Bitmask por jogador** | "Quem é o dono desta célula?" vira loop por jogador; roubo fica caro |
| **Chunks esparsos** | Só compensa em mapas muito maiores que os nossos; adiciona indireção no caminho quente |
| **`TileMap` do Godot** | Acopla simulação a nó visual — quebra a regra número um da arquitetura e impede simulação headless barata |
| **Flood fill do interior** | Exige achar um ponto interno confiável; o método do exterior não precisa disso e trata buracos naturalmente |

## Consequences

**Positivas:** consultas O(1); capturas locais e baratas; determinismo trivial (inteiros, sem
ponto flutuante na topologia); serialização direta para replay e snapshot; render em **1 draw
call** via textura do grid; colisão sem física de engine (consulta de célula).

**Negativas / mitigações:**
- Resolução do território é discreta → tamanho de célula (16 u) escolhido para que o serrilhado
  fique invisível sob o shader de borda; a arte é desenhada sabendo disso.
- Arena gigante custaria memória linear → limite de tamanho documentado; chunks ficam como
  caminho de evolução registrado, não implementado preventivamente.
- O Arc precisa ser 4-conectado, senão o fill vaza → rasterização *supercover* com teste de
  propriedade obrigatório (GSD 03).

**Compromissos:** `SealSolver` é função pura e testável isoladamente; zero alocação por captura;
benchmarks (B01–B15) desde a primeira implementação.

## Status

**Accepted** — 2026-08-24. Detalhamento em `docs/architecture/territory-system.md`.
