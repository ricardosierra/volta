# Direção de arte

> O jogo não pode parecer um projeto de tutorial de engine. Também não pode parecer um
> festival de partículas onde ninguém enxerga a ameaça. O nome da direção é
> **Minimalismo Neon Premium**: geometria limpa, energia contida, profundidade por luz.

## 1. Conceito

Um plano escuro, quase líquido, atravessado por linhas de energia. Territórios são **campos de
luz** com borda viva; o Arc é um **fio incandescente**; o Runner é uma forma geométrica simples
com núcleo brilhante. Nada de textura fotográfica, nada de gradiente sujo, nada de skeumorfismo.

Referências de linguagem (não de conteúdo): design de interface de ficção científica sóbrio,
tipografia geométrica suíça, arte generativa de linhas, neon fotografado com lente limpa.

## 2. Hierarquia visual — a regra que manda em tudo

```text
1. Runners (o seu, em destaque máximo)
2. Arcs abertos (perigo e oportunidade)
3. Fronteiras de Claim
4. Preenchimento de Claim
5. Grid / fundo atmosférico
```

Nenhum efeito pode inverter essa ordem. Se um VFX de captura esconde um Arc inimigo, o VFX
está errado — não a leitura do jogador. Toda tarefa de arte é avaliada contra esta lista.

## 3. Elementos

### Field (fundo)
Gradiente escuro com vinheta suave. Grid sutil (opacidade baixíssima), que **pulsa levemente**
ao ritmo da música. Partículas ambientais raras e lentas, apenas para dar profundidade —
nunca perto do centro da ação.

### Claim (território)
Preenchimento translúcido na cor do jogador (≈ 35 % de opacidade), com um padrão geométrico
interno de baixíssimo contraste e **exclusivo por jogador** (linhas diagonais, pontos, malha,
chevrons…). A borda é uma linha nítida de 2 px com glow curto e um brilho que percorre a
borda lentamente — o território parece **vivo**, não pintado.

### Arc (rastro)
Linha de 6 unidades com núcleo claro e halo. Brilho e frequência de pulso **crescem com o
comprimento** — o risco é sentido antes de ser lido. Perto do limite de Overload, ganha
cintilação âmbar e ruído na cauda.

### Runner
Forma geométrica simples, sólida, com núcleo brilhante e um anel fino. Rotação suave alinhada à
direção. Deixa um rastro curtíssimo de movimento (não confundir com o Arc — o rastro é opaco e
some em 0,2 s). Skins mudam a silhueta e o padrão do núcleo, **nunca** o tamanho nem a hitbox.

### Seal (captura)
O momento mais importante do jogo:
1. onda de luz percorre o Arc do ponto de fechamento até a origem (0,12 s);
2. preenchimento radial da região capturada, com máscara animada (0,28 s);
3. faíscas nas bordas novas, seguindo o perímetro;
4. flash breve na cor do jogador, com intensidade proporcional à área;
5. as células roubadas de inimigos "quebram" antes de virar sua cor — o roubo é **visível**.

## 4. Cor

- Fundo sempre escuro (luminância < 12 %), para o neon ter contraste.
- Cada jogador tem uma cor de **matiz bem separada** das demais (≥ 40° no círculo cromático).
- Cor do jogador humano é sempre a mais saturada e brilhante do lote.
- Branco puro é reservado para acentos e para o núcleo do Runner. Não é cor de time.
- Vermelho é reservado para perigo (morte, tempo acabando). Nenhum Runner é vermelho puro.

Paletas completas em [`themes.md`](themes.md).

## 5. Movimento

| Elemento | Regra |
|---|---|
| Câmera | seguimento suave com lookahead; punches curtos, nunca solavanco |
| Runner | squash/stretch leve em aceleração e impacto |
| Claim | borda com brilho que percorre lentamente |
| Grid | pulso quase imperceptível ao ritmo da música |
| UI | entra em 120–200 ms, escalonada por elemento |

## 6. O que é proibido

- ❌ Bloom estourado que apaga a leitura do campo.
- ❌ Partículas no centro da tela durante gameplay normal.
- ❌ Fundo animado que compita com o Field.
- ❌ Mais de 3 fontes de brilho intenso simultâneas na mesma região.
- ❌ Texto sobre o campo de jogo sem fundo ou sombra própria.
- ❌ Assets, paletas ou silhuetas derivadas de qualquer outro jogo.

## 7. Assets e pipeline

- **Tudo é vetorial ou procedural.** SVG → import; formas simples desenhadas com shader.
  Consequência: peso mínimo de app e nitidez em qualquer densidade.
- Nenhuma textura maior que 1024 × 1024. A maioria dos elementos não usa textura alguma.
- Shaders escritos à mão, comentados, com custo medido no orçamento de GPU.
- Fonte: uma família geométrica variável, com subconjunto latino estendido.
- Todo asset de terceiros (fonte, som) entra em `assets/CREDITS.md` com licença — verificado no CI.

## 8. Rastreamento de placeholders

Até GSD 08, toda arte é placeholder e **rastreada**:

```text
PLACEHOLDER-ART-001  Runner (círculo branco)              → GSD 08 / ART-002
PLACEHOLDER-ART-002  Claim (retângulo de cor chapada)     → GSD 08 / ART-003
PLACEHOLDER-ART-003  Arc (Line2D simples)                 → GSD 08 / ART-004
PLACEHOLDER-ART-004  Fonte padrão do Godot                → GSD 08 / ART-001
PLACEHOLDER-ART-005  Ícones de UI (formas básicas)        → GSD 08 / ART-007
PLACEHOLDER-ART-006  Fundo (cor sólida)                   → GSD 08 / ART-005
```

Nenhum placeholder pode sobreviver ao gate da Alpha. O CI falha se um marcador
`PLACEHOLDER-ART-*` existir no código depois da fase declarada.
