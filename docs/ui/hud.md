# HUD

> Regra dura: **no máximo 5 elementos** na tela durante a partida. Cada pixel de HUD é um
> pixel a menos de campo de jogo — e o campo de jogo é onde a informação de verdade está.

## Elementos permitidos

| Elemento | Posição | Conteúdo | Sempre visível? |
|---|---|---|---|
| **Território** | topo-esquerda | `34,2 %` com barra fina na cor do jogador | ✅ |
| **Posição** | topo-centro | `2/6` + seta de tendência (subindo/caindo) | ✅ |
| **Tempo** | topo-direita | `1:24`, vira vermelho e pulsa nos últimos 30 s | modos com tempo |
| **Risco / Surge** | acima do Runner, discreto | `×1,8` enquanto desenha; medidor de Surge quando ativo | contextual |
| **Pause** | topo-direita, canto | ícone 48 dp dentro da safe area | ✅ |

Nada mais. Nem minimapa, nem lista de jogadores, nem chat, nem botão de power-up (power-up é
automático ao coletar), nem publicidade.

## Elementos efêmeros (aparecem e somem)

| Elemento | Duração | Regra |
|---|---|---|
| `+3,4 %` após Seal | 0,9 s | sobe a partir do ponto de fechamento, não do topo da tela |
| Nome de bônus (`MEGA SEAL`) | 0,9 s | empilha no centro-alto, máximo 3 simultâneos |
| `BREAK!` + streak | 0,9 s | centro, com impacto |
| `BACKWASH` | 0,8 s | âmbar, discreto — é um erro, não uma festa |
| Aviso de Overload | até resolver | barra fina no topo do Arc |
| Ícone de power-up ativo | duração do efeito | canto inferior-direito, timer radial |
| Seta de ameaça periférica | enquanto a ameaça existir | borda da tela, na direção do inimigo próximo do Arc |
| Aviso de Final Push | 1,5 s | banner curto + mudança de cor da moldura da HUD |

## Layout

```text
┌─────────────────────────────────┐
│ ▓ 34,2%      2/6 ▲      1:24 ⏸ │  ← safe area top + 8dp
│                                 │
│                                 │
│            [campo]              │
│                                 │
│              ×1,8               │  ← flutua acima do Runner
│                                 │
│                          ⬢ 3,2s │  ← power-up ativo
└─────────────────────────────────┘
        ↑ nada nos últimos 20% (zona do polegar / gestos do sistema)
```

## Regras

1. Números usam figuras tabulares — o layout **não pode tremer** quando o valor muda.
2. HUD tem opacidade reduzida (~85 %) e nunca cobre o Runner nem um Arc próximo.
3. A HUD inteira pode ser reduzida ou escondida em `Settings > Display > HUD` (Completa ·
   Mínima · Oculta) — jogadores avançados pedem isso, e é barato oferecer.
4. Nenhuma animação de HUD chama mais atenção que um evento do campo de jogo.
5. Ao morrer, a HUD escurece nas bordas mas **não** some: o jogador precisa ver o placar final.
6. Durante o tutorial, a HUD entra **progressivamente**: território no 1º Seal, posição no
   primeiro contato com inimigo, tempo desde o começo.
7. A HUD respeita mão dominante (`Settings > Controls`), espelhando os cantos.
