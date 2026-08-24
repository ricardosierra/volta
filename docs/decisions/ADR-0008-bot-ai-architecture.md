# ADR-0008 — Arquitetura da IA

## Context

Os bots carregam a experiência inteira no v0.1.0 (não há multiplayer). Precisam: parecer
intencionais, ter personalidades distinguíveis, escalar em dificuldade **por comportamento**
(nunca por velocidade — regra R8.1), custar pouca CPU (≤ 1,2 ms por tick para todos), ser
determinísticos para os testes e ser ajustáveis por dado.

## Decision

**IA por utilidade (utility AI).** A cada ciclo de decisão (~150 ms por bot, escalonado, no
máximo 2 bots por tick), o bot pontua um conjunto de ações candidatas e executa a melhor:

```text
expand_frontier · expand_deep · steal_from(alvo) · intercept(alvo)
flee_home · seal_now · patrol_border · bait
```

O peso de cada ação vem de um `BotProfileResource` (`risk_tolerance`, `aggression`,
`target_selection`, `expansion_preference`, `enemy_awareness`, `escape_threshold`,
`reaction_delay_ms`, `error_rate`). **Arquétipo** = conjunto de pesos; **dificuldade** = percepção,
reação e taxa de erro. Ambos são dados, não código.

A imperfeição é explícita: `reaction_delay_ms` e `error_rate` (chance de escolher a segunda
melhor ação) fazem o bot errar de forma plausível em vez de parecer burro.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **FSM** | Vira espaguete de transições quando o comportamento depende de 6 variáveis contínuas; personalidades exigiriam máquinas separadas |
| **Behavior Tree** | Boa ferramenta, mas prioridade fixa não expressa bem "o quanto" uma opção é boa; ajustar personalidade vira reestruturar a árvore |
| **GOAP / planejamento** | Custo de CPU alto para horizonte curto; nosso problema é de avaliação contínua, não de encadear pré-condições |
| **Machine learning** | Não determinístico, difícil de ajustar, impossível de explicar quando o bot faz besteira, e sem dados no dia 1 |
| **Scripts por arquétipo** | Duplicação massiva e comportamentos que não se misturam |

## Consequences

**Positivas:** personalidade é um `.tres` (um designer cria um arquétipo novo sem tocar em
código); dificuldade escala honestamente; barato de rodar; **inspecionável** — o overlay de
debug mostra a ação escolhida e a segunda colocada, o que torna "o bot está burro" um problema
diagnosticável.

**Negativas / mitigações:**
- Ajustar pesos é arte → o stress test (500+ partidas) mede distribuição de vitórias por
  arquétipo e vira o critério objetivo.
- Utilidade pode oscilar entre duas ações empatadas → histerese (a ação atual ganha um bônus) e
  tempo mínimo de compromisso por decisão.
- Sem planejamento de longo prazo → aceito: o horizonte do jogo é curto; `expand_deep` cobre a
  ambição necessária.

**Compromissos:** decisões escalonadas; nenhuma busca de caminho global por frame; overlay de
intenção obrigatório; validação por distribuição de vitórias e por legibilidade em playtest.

## Status

**Accepted** — 2026-08-24. Detalhamento em `docs/gameplay/bots.md`.
