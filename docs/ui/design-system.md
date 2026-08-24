# Design System

> UI mobile-first, portrait, feita para polegar. Um sistema de tokens em `Resource`, não uma
> pilha de valores mágicos em cada cena. Ver [`ADR-0009`](../decisions/ADR-0009-ui-framework.md).

## 1. Tokens

Tudo vive em `ui/design_system/tokens/*.tres` e é consumido por tema do Godot + componentes.

### Espaçamento (escala de 4)

```text
xs 4 · sm 8 · md 16 · lg 24 · xl 32 · 2xl 48 · 3xl 64
```

Margem lateral padrão da tela: `lg` (24). Nunca menos que `md` (16) em nenhuma borda.

### Raio

```text
sm 8 · md 16 · lg 24 · pill 999
```

### Tipografia

Uma família geométrica com bom suporte a latim estendido (definida em GSD 08; até lá, a fonte
padrão do projeto é placeholder rastreado `PLACEHOLDER-ART-004`).

| Papel | Tamanho (dp) | Peso | Uso |
|---|---|---|---|
| `display` | 48 | 800 | logo, número grande do resultado |
| `title` | 32 | 700 | título de tela |
| `heading` | 24 | 700 | seção |
| `body` | 16 | 500 | texto corrido |
| `label` | 14 | 600 | rótulos, botões pequenos |
| `caption` | 12 | 500 | metadados |
| `hud` | 20 | 700 | números da HUD (tabular, largura fixa) |

Números da HUD usam **figuras tabulares**: percentual mudando não pode fazer o layout tremer.

### Cores (semânticas, resolvidas pelo tema ativo)

```text
bg.deep      fundo atmosférico
bg.surface   cartões e painéis
bg.raised    elementos acima de cartões
fg.primary   texto principal
fg.muted     texto secundário
fg.inverse   texto sobre cor de destaque
accent       ação primária, energia da marca
accent.alt   apoio
danger       perigo, morte, erro
warning      Overload, Backwash
success      captura, desbloqueio
player.1..8  cores de Runner (por tema; ver art/themes.md)
```

Nenhum componente conhece hex. Componentes pedem **papéis**.

### Elevação

Sem sombra difusa pesada: profundidade vem de brilho e contraste (coerente com a arte neon).

```text
flat · raised (borda 1px + glow 4) · overlay (dim de fundo 60 % + blur leve)
```

### Movimento

```text
instant 0 · fast 120ms · base 200ms · slow 280ms
easing padrão: ease_out_quad (entrada) · ease_in_quad (saída) · ease_out_back (ênfase)
```

Nada acima de 300 ms. Transição de tela: 250 ms.

## 2. Componentes

| Componente | Regras |
|---|---|
| `VButton` | altura mínima 56 dp, alvo de toque ≥ 48 dp, 3 variantes (primary, secondary, ghost), estados: normal, pressed, disabled, loading; háptico mínimo no toque |
| `VIconButton` | 48 × 48 dp mínimo, sempre com rótulo acessível |
| `VCard` | `bg.surface`, raio `md`, padding `md` |
| `VToggle` | rótulo à esquerda, estado à direita, área de toque cobre a linha inteira |
| `VSlider` | valor numérico sempre visível; passo definido; feedback háptico nos extremos |
| `VTabs` | máximo 4 abas; indicador animado |
| `VModal` | dim de fundo, entra por escala 0,96→1, fecha por toque fora e por back |
| `VToast` | topo, 2,5 s, nunca cobre a HUD durante a partida |
| `VProgressBar` | usado para XP e Domination; sempre com número junto |
| `VCurrencyPill` | ícone + valor tabular; anima contagem ao mudar |
| `VRunnerPreview` | preview animado do Runner com skin e Arc atuais |
| `SafeAreaContainer` | wrapper obrigatório de toda tela |

Todo componente é uma cena reutilizável + script tipado, com uma cena de *showcase* em
`ui/design_system/showcase.tscn` para inspeção visual rápida (e captura de regressão visual).

## 3. Layout

- **Stretch mode:** `canvas_items`, aspect `expand`, resolução base **1080 × 1920**.
- Toda tela é `SafeAreaContainer > MarginContainer > conteúdo`.
- A ação primária fica na **metade inferior** da tela (zona do polegar). O topo é informação.
- Nada interativo a menos de 16 dp de qualquer borda de safe area.
- Listas roláveis têm sempre um item "meio cortado" na borda, sinalizando que há mais.

## 4. Escala de UI

`Settings > Display > UI Scale`: 0,9 · 1,0 · 1,1 · 1,25. Multiplica tokens de tipografia e
espaçamento — não estica bitmap. Layouts precisam sobreviver a 1,25 sem sobreposição (testado
no gate de acessibilidade, GSD 20).

## 5. Regras invioláveis

1. Nenhum valor de espaçamento, cor, raio ou duração fora dos tokens.
2. Nenhum texto hardcoded: tudo por chave de tradução, desde GSD 07.
3. Todo estado interativo tem feedback visual em < 100 ms.
4. Nenhum elemento crítico depende só de cor (Pilar 3 e acessibilidade).
5. Toda tela funciona em 16:9 e em 20:9 sem ajuste manual.
6. Nenhum popup pode aparecer durante `Playing` sem ação do jogador.
