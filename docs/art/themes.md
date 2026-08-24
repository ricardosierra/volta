# Temas e paletas

Um tema é um `Resource` que resolve **todos** os papéis de cor do jogo — UI e gameplay.
Trocar de tema é trocar um `.tres`. Nenhum hex existe fora daqui.
Ver [`ADR-0011`](../decisions/ADR-0011-theming-and-cosmetics.md).

## Estrutura

```gdscript
class_name ThemePalette extends Resource
@export var id: StringName
@export var display_name: String
@export var bg_deep: Color
@export var bg_surface: Color
@export var bg_raised: Color
@export var fg_primary: Color
@export var fg_muted: Color
@export var accent: Color
@export var accent_alt: Color
@export var danger: Color
@export var warning: Color
@export var success: Color
@export var players: PackedColorArray   # 8 cores, matizes separadas por >= 40 graus
@export var grid_tint: Color
@export var glow_intensity: float
```

## Temas do v0.1.0

| Tema | Clima | Fundo | Destaque | Desbloqueio |
|---|---|---|---|---|
| **Neon** *(padrão)* | noite elétrica | quase preto azulado | ciano vibrante | inicial |
| **Ocean** | profundidade calma | azul-marinho profundo | turquesa | rank 5 |
| **Sunset** | calor de fim de tarde | roxo escuro | laranja/rosa | rank 10 |
| **Cyber** | industrial ácido | grafite | verde-limão + magenta | rank 15 |
| **Midnight** | sóbrio, alto contraste | preto puro | branco-azulado | rank 20 |
| **Candy** | doce e claro | ameixa clara | rosa/menta | loja (✦) |
| **Pastel** | suave, baixa saturação | cinza-lavanda | pêssego | loja (✦) |
| **Monochrome** | minimalismo absoluto | preto | branco (Runners por **forma e padrão**) | conquista |

`Monochrome` é o teste extremo da regra "cor + forma": se o jogo é jogável nele, a
identificação por forma está funcionando de verdade.

## Temas de acessibilidade (GSD 20)

`Deuteranopia`, `Protanopia`, `Tritanopia` — sempre disponíveis, nunca atrás de desbloqueio,
listados em `Settings > Accessibility`, não na loja.

## Regras

1. Todo tema declara **8** cores de jogador, com separação mínima de matiz e de luminância.
2. Todo tema passa no verificador de contraste (texto 4,5:1, UI 3:1) — script no CI.
3. Todo tema é testado com o simulador de daltonismo antes de entrar.
4. A cor do jogador humano é sempre `players[0]`, a mais saturada do conjunto.
5. Trocar de tema **nunca** altera legibilidade a ponto de dar vantagem — nada de tema que
   deixa o Arc inimigo mais visível que os outros. Todos os temas são auditados quanto a isso.
6. Tema é cosmético: não afeta simulação, hitbox nem informação disponível.

## Arenas e temas

Arenas têm layout próprio, mas herdam a paleta do tema ativo. Uma arena **não** traz cores
próprias — isso quebraria a leitura consistente entre partidas.

| Arena | Layout | Efeito estratégico | Fase |
|---|---|---|---|
| **Open Field** | vazia | baseline | 03 |
| **Archipelago** | ilhas separadas por vazio intransponível | expansão em pedaços, rotas obrigatórias | 13 |
| **Rift** | fenda central letal (única exceção de R5.7, telegrafada) | mapa dividido, travessia arriscada | 13 |
| **Crossroads** | corredores em cruz com centro aberto | disputa pelo centro, emboscadas | 13 |
| **Halo** | anel jogável com centro bloqueado | perseguições circulares, cerco fácil | 13 |
| **Lattice** | labirinto largo | arcos curtos, jogo de leitura | pós-launch |
| **Drift** | paredes que se movem lentamente | território precisa ser reconquistado | pós-launch |
| **Gate** | portais que teletransportam | rotas surpresa, exige aviso visual forte | pós-launch |
