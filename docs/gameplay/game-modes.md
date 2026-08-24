# Modos de jogo

Todos os modos usam a **mesma simulação** e as mesmas regras de
[`rules.md`](rules.md). Um modo é apenas um `MatchRules` (Resource) + condições de fim.
Nenhum modo pode introduzir uma nova causa de morte sem alterar R5.7.

```gdscript
# packages/shared/config/modes/*.tres  →  MatchRulesResource
mode_id, duration_s, runner_count, respawn_enabled, respawn_delay_s,
domination_target, difficulty_curve, arena_pool, powerups_enabled,
final_push_enabled, score_profile
```

---

## Classic — o modo padrão

| | |
|---|---|
| **Fase** | GSD 06 (MVP) |
| **Duração** | 180 s |
| **Runners** | 6 (1 humano + 5 bots) |
| **Respawn** | sim, com atraso curto |
| **Fim** | tempo esgotado · alguém atinge a meta de domínio · resta um vivo |
| **Vitória** | maior % de Claim; desempate por score |

O modo de referência para balanceamento. Se algo não funciona no Classic, não funciona.

---

## Time Attack — corrida contra o relógio

| | |
|---|---|
| **Fase** | GSD 12 |
| **Duração** | 90 s |
| **Runners** | 4 |
| **Respawn** | sim, atraso maior (morrer custa tempo, e tempo é tudo) |
| **Fim** | tempo esgotado |
| **Vitória** | maior % de Claim acumulado |

**Twist:** cada Seal adiciona segundos ao relógio, proporcional ao tamanho — jogo agressivo se
auto-sustenta. Ideal para sessões de 2 minutos e para desafios diários.

---

## Survival — quanto você aguenta

| | |
|---|---|
| **Fase** | GSD 12 |
| **Duração** | infinita até a morte |
| **Runners** | começa em 3, sobe por onda |
| **Respawn** | **não** |
| **Fim** | jogador humano sofre Break |
| **Vitória** | tempo sobrevivido + território acumulado |

A dificuldade sobe por **comportamento**, nunca por velocidade (Pilar 5):

| Onda | O que muda |
|---|---|
| 1–2 | Bots `Grazer` — expandem longe do jogador |
| 3–4 | Entra `Raider` — passa a cortar arcos por oportunidade |
| 5–6 | Entra `Hunter` — persegue ativamente o arco do jogador |
| 7–8 | Entra `Warden` — defende território e fecha rotas de fuga |
| 9+ | Composição mista, percepção maior, tolerância a risco maior, mais Runners simultâneos |

---

## Domination — o primeiro a dominar

| | |
|---|---|
| **Fase** | GSD 12 |
| **Duração** | até a meta, com teto de segurança |
| **Runners** | 4 |
| **Respawn** | sim |
| **Fim** | alguém atinge a meta de domínio (padrão 50 %) |
| **Vitória** | quem chegar primeiro |

Partidas mais longas e táticas: roubar 5 % do líder vale mais que capturar 5 % neutros, porque
a diferença conta duas vezes. A HUD mostra barras de progresso de todos os Runners — é o único
modo em que a informação do adversário é explícita o tempo todo.

---

## Endless — o modo de recorde

| | |
|---|---|
| **Fase** | GSD 12 |
| **Duração** | infinita |
| **Runners** | 6, reposição contínua |
| **Respawn** | sim, ilimitado |
| **Fim** | só quando o jogador sair |
| **Vitória** | não existe; existe **recorde** |

Zero pressão, foco em score máximo acumulado e em leaderboard. O território é reciclado
periodicamente (*Reset Pulse*, telegrafado) para impedir que o jogador domine 100 % e o modo morra.

---

## Comparativo

| | Classic | Time Attack | Survival | Domination | Endless |
|---|---|---|---|---|---|
| Duração típica | 3 min | 1,5 min | 1–8 min | 2–5 min | livre |
| Respawn | ✅ | ✅ | ❌ | ✅ | ✅ |
| Power-ups | ✅ | ✅ | ✅ | ❌ | ✅ |
| Final Push | ✅ | ✅ | ❌ | ❌ | ❌ |
| Leaderboard | score | % capturado | tempo vivo | tempo até a meta | score |
| Público | todos | sessão curta | competitivo | tático | recordista |

---

## Regras para adicionar um modo novo

1. Ele nasce como `MatchRulesResource` — **sem** `if mode == ...` espalhado pelo código.
2. Precisa de leaderboard próprio e de um critério de recorde legível.
3. Precisa passar no stress test com 500 partidas headless sem crash e sem partida infinita.
4. Precisa responder: *"o que este modo faz que o Classic não faz?"* — se a resposta for
   "é igual, mas mais rápido", ele vira um preset, não um modo.
