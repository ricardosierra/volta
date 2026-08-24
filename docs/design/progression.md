# Progressão

> Progressão existe para dar **motivo de voltar**, nunca para dar vantagem. Nada aqui altera
> a simulação (Pilar 5). Um jogador nível 60 e um nível 1 correm na mesma velocidade.

## Camadas

```text
Partida  →  XP  →  Rank  →  desbloqueios cosméticos
   ↓
Estatísticas  →  Conquistas (permanentes)
   ↓
Desafios diários/semanais  →  Sparks  →  loja cosmética
```

## 1. XP e Rank

- XP vem de score, Breaks e vitória (fórmula em [`balance.md`](balance.md)).
- **Toda** partida dá XP. Perder dá menos, nunca zero — punir tempo jogado é o caminho mais
  curto para o desinstalar.
- Curva: `xp_for_level(n) = round(100 × n^1,35)`. Níveis iniciais rápidos (o primeiro sobe na
  primeira partida, sempre), níveis altos longos.
- Não existe nível máximo. Depois do 50 vira "prestígio visual" (moldura do avatar muda de tier).

**Recompensas de Rank** (a cada nível): Sparks; a cada 5 níveis: um cosmético garantido;
a cada 10: um título de perfil.

## 2. Estatísticas (perfil)

Rastreadas para sempre e mostradas em `Profile`:

`partidas` · `vitórias` · `winrate` · `território total capturado` · `maior Seal único` ·
`Breaks` · `mortes` · `K/D` · `maior Surge atingido` · `tempo total vivo` · `melhor score por modo` ·
`sequência atual de vitórias` · `melhor sequência` · `Squeezes` · `Cuts` · `distância percorrida`

Servem para três coisas: conquistas, leaderboards e o prazer bobo de ver número subir.

## 3. Conquistas

Permanentes, sem timer. Três famílias:

| Família | Exemplos |
|---|---|
| **Marco** | 1ª vitória · 100 partidas · 1 000 Seals · nível 25 |
| **Habilidade** | Seal de 20 % em uma tacada · 5 Breaks numa partida · vencer sem morrer · Surge nível 6 |
| **Curiosidade** | vencer sem eliminar ninguém · sobreviver 3 min sem sair do Claim · Close Call 10× |

Cada uma dá Sparks e, nas de habilidade, cosméticos exclusivos. Nenhuma exige gastar dinheiro.
Nenhuma exige sorte pura.

## 4. Desafios

**Diários:** 3 por dia, 1 reroll gratuito, expiram à meia-noite local.
**Semanais:** 3 por semana, mais difíceis, recompensa maior.

Exemplos (gerados a partir de um pool com pesos, nunca dois do mesmo tipo no mesmo dia):

```text
Capture 25% do mapa em uma partida
Elimine 3 inimigos
Faça 10 capturas
Sobreviva 3 minutos
Faça uma captura de 15% em uma tacada
Vença sem eliminar ninguém
Atinja Surge nível 4
Jogue uma partida de cada modo
Vença em Domination sem sofrer Backwash
```

Regras: nenhum desafio pode exigir comportamento antidivertido (ficar parado, perder de
propósito, farmar em modo específico por 20 partidas). Todo desafio precisa ser cumprível em
≤ 4 partidas por um jogador mediano.

## 5. Títulos e molduras

Cosméticos de perfil ganhos por conquista e por rank — aparecem no leaderboard e no resultado.
Exemplos: `Cartógrafo` · `Predador` · `Intocável` · `Arquiteto` · `Tempestade`.

## 6. O que NÃO existe

- ❌ Árvore de habilidades, upgrades de velocidade, "níveis de Runner".
- ❌ Energia, vidas, timers de espera.
- ❌ Item que expira e precisa ser recomprado.
- ❌ Progressão que trava conteúdo de jogo (todos os modos e arenas ficam disponíveis cedo —
  no máximo atrás de um nível baixo, para não afogar o jogador novo em opções).

## 7. Implementação

| Fase | Entrega |
|---|---|
| GSD 10 | Profile, XP, ranks, estatísticas, conquistas, desafios diários (local) |
| GSD 11 | Desbloqueio e seleção de cosméticos |
| GSD 16 | Desafios servidos pela API, progressão em nuvem, leaderboards online |

Toda a camada é local por trás de `ProfileRepository` / `ChallengeRepository`, com
implementação `Local*` primeiro e `Remote*` depois — sem mudar o gameplay.
