# Bots

> Um bot que dá voltas aleatórias destrói a fantasia em 15 segundos. O objetivo aqui não é
> *bot difícil*, é **bot com intenção legível**: o jogador precisa conseguir dizer
> "ele está tentando me cortar" ou "ele está fugindo".

Arquitetura: **IA por utilidade** (ver [`ADR-0008`](../decisions/ADR-0008-bot-ai-architecture.md)).
A cada ciclo de decisão o bot pontua um conjunto de ações candidatas e executa a de maior nota.
Sem árvore de comportamento gigante, sem FSM de 30 estados.

```text
Percepção  →  ThreatMap + OpportunityMap  →  Candidatas  →  Utilidade  →  Ação  →  Steering
   (raio limitado)                            (10–20)      (pesos do perfil)
```

---

## Perfil de bot (`BotProfileResource`)

| Parâmetro | Faixa | O que muda |
|---|---|---|
| `risk_tolerance` | 0–1 | quão longe do Claim ele aceita ir antes de fechar |
| `aggression` | 0–1 | peso de "cortar arco inimigo" contra "expandir" |
| `target_selection` | enum | `nearest` · `weakest` · `leader` · `revenge` |
| `expansion_preference` | enum | `frontier` (colado no próprio Claim) · `deep` (arcos longos) · `contested` (rouba do vizinho) |
| `enemy_awareness` | 0–1 | raio de percepção e frequência de reavaliação |
| `escape_threshold` | 0–1 | com que folga ele aborta e corre para casa |
| `reaction_delay_ms` | 60–400 | atraso humano proposital de reação |
| `error_rate` | 0–0,25 | chance de escolher a 2ª melhor opção (imperfeição de propósito) |

`reaction_delay_ms` e `error_rate` existem para que o bot **erre como gente**, e não para
disfarçar burrice. Bot difícil erra pouco; bot fácil erra de forma plausível.

---

## Arquétipos

| Arquétipo | Personalidade | Perfil dominante | Entra em |
|---|---|---|---|
| **Grazer** | Pastador. Expande em fatias pequenas e seguras, evita conflito. | risco baixo, agressão baixa, `frontier` | GSD 05 |
| **Raider** | Oportunista agressivo. Expande, mas desvia para cortar arco exposto perto. | risco médio, agressão alta, `contested` | GSD 05 |
| **Hunter** | Caçador. Escolhe uma presa e persegue o arco dela. | risco alto, agressão máxima, `nearest` | GSD 05 |
| **Warden** | Guardião. Fica perto do próprio Claim, intercepta invasores, raramente arrisca. | risco baixo, agressão média, `frontier` | GSD 05 |
| **Vulture** | Abutre. Espera alguém morrer e corre para o território neutro liberado. | risco médio, agressão baixa, `contested` | GSD 12 |
| **Nemesis** | Vingativo. Marca quem o matou e prioriza esse alvo pelo resto da partida. | risco alto, `revenge` | GSD 12 |
| **Baron** | Territorialista. Mira a liderança de percentual, ignora brigas, faz arcos longos. | risco alto, agressão baixa, `deep` | GSD 12 |

---

## Percepção

O bot **não** enxerga o mapa inteiro. Ele consulta:

- Runners dentro do raio de percepção (derivado de `enemy_awareness`);
- células de Arc inimigo dentro desse raio;
- o próprio Claim, sempre (é dele);
- densidade local de território por *chunk* (grade grossa, atualizada por evento, não por frame).

Nada disso lê estado privado de outro Runner. O que o bot sabe, o jogador também poderia saber
olhando a tela — respeitadas as fronteiras da tela.

---

## Ações candidatas

| Ação | Quando pontua alto |
|---|---|
| `expand_frontier` | Claim pequeno, sem ameaça próxima |
| `expand_deep` | mapa neutro grande e livre, risco tolerável |
| `steal_from(target)` | vizinho com muito território e pouca defesa |
| `intercept(target)` | inimigo com Arc longo e trajetória previsível |
| `flee_home` | ameaça dentro do raio crítico, ou Arc muito longo |
| `seal_now` | valor da região já cercada × risco atual acima do limiar |
| `patrol_border` | perfil `Warden` com invasor no território |
| `bait` | (GSD 12+) fingir vulnerabilidade perto do próprio Claim |

Cada ação retorna `(score, direção sugerida)`. A escolha vira alvo de *steering*, nunca
teleporte nem caminho perfeito.

---

## Segurança e sanidade

- **Anti-travamento:** se o bot não mudar de célula por 1,5 s, ele força reavaliação; se
  repetir 3 vezes, escolhe uma direção de emergência para longe do obstáculo.
- **Anti-suicídio:** antes de aceitar uma direção, valida se existe rota de retorno estimada
  dentro do orçamento de risco. Bot fácil pula essa checagem com frequência (por isso ele morre).
- **Anti-partida infinita:** se todos os bots estiverem em `Safe` por mais de 20 s, o
  `MatchDirector` aumenta a pressão de expansão de todos.
- **Orçamento de CPU:** decisões são escalonadas por bot (round-robin) — no máximo **2 bots
  decidem por tick** (ver `performance/performance-budget.md`).

---

## Dificuldade

Três níveis para o jogador + uma curva adaptativa em Survival:

| Nível | Percepção | Reação | Erro | Agressão | Comportamento |
|---|---|---|---|---|---|
| **Rookie** | curta | lenta | alta | baixa | expande, quase não ataca, comete erros visíveis |
| **Skilled** | média | média | média | média | ataca oportunidades, foge quando pressionado |
| **Elite** | longa | rápida | baixa | alta | intercepta rotas, defende território, força erro |

Em nenhum nível a velocidade base muda. `enemySpeed *= 2` é proibido — ver R8.1 em
[`rules.md`](rules.md).

---

## Como validamos que os bots são bons

1. **Distribuição de vitória** em 500 partidas headless: nenhum arquétipo pode vencer
   mais de 45 % nem menos de 8 % em composições mistas equivalentes.
2. **Duração média de partida** dentro da janela projetada por modo.
3. **Legibilidade**: em playtest, ≥ 70 % dos jogadores descrevem corretamente a intenção de
   um bot `Hunter` em vídeo de 20 s ("ele estava me caçando").
4. **Sem travamento**: zero ocorrência de bot parado > 3 s no stress test.
