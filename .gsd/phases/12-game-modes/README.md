# GSD 12 — Additional Game Modes

**Status:** ⬜ pendente · **Depende de:** GSD 06 (e, na prática, 11) · **Tarefas:** 9 · **Prefixo:** `MODE`
**Branch:** `feature/gsd-12-game-modes`

## Objetivo

> Multiplicar o valor do core sem multiplicar o código: Time Attack, Survival, Domination e
> Endless, todos sobre a mesma simulação, definidos por `MatchRulesResource`.

## Escopo

**Entra:** os 4 modos novos · seleção de modo · 3 arquétipos de bot adicionais (`Vulture`,
`Nemesis`, `Baron`) · dificuldade adaptativa por ondas no Survival · *Reset Pulse* do Endless ·
bônus de tempo por Seal no Time Attack · HUD de progresso de todos no Domination · leaderboard
e recorde por modo · stress test dos 5 modos.

**NÃO entra:** arenas novas (é 13) · power-ups (é 14) · modos online (fora do v0.1.0).

## Regra estrutural

Nenhum `if mode == ...` espalhado pelo código. Um modo é um `Resource`. Se um modo exigir uma
condição nova, ela vira **campo** do recurso, não ramo no código.
