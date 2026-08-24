# GSD 05 — Bot AI

**Status:** ⬜ pendente
**Depende de:** GSD 04
**Branch:** `feature/gsd-05-bot-ai`
**Tarefas:** 11 · **Prefixo de ID:** `BOTS`

## Objetivo

> Adversários que parecem ter intenção. O jogador precisa conseguir dizer *"ele está tentando
> me cortar"* ou *"ele está fugindo"* só olhando a tela.

No v0.1.0 não existe multiplayer: **os bots são a experiência inteira** (RISK-003, score 15).

## Escopo

**Entra:**
- `BotBrain` com IA por utilidade (ADR-0008)
- Percepção com raio limitado (`ThreatMap`, `OpportunityMap`)
- 8 ações candidatas com função de utilidade
- 4 arquétipos do MVP: `Grazer`, `Raider`, `Hunter`, `Warden`
- 3 níveis de dificuldade por comportamento (nunca por velocidade)
- Imperfeição proposital: atraso de reação e taxa de erro
- Segurança: anti-travamento, anti-suicídio, anti-partida-parada
- Escalonamento de decisões (máx. 2 bots por tick)
- Overlay de debug de intenção
- Stress test de 500 partidas com métricas de balanceamento

**NÃO entra:**
- `Vulture`, `Nemesis`, `Baron` (é 12, junto com os modos que os pedem)
- Dificuldade adaptativa de Survival (é 12)
- Score (é 06)

## Resultado esperado

> Uma partida completa, offline, contra 5 bots, do começo ao fim, divertida — e 500 partidas
> headless sem crash, sem bot travado e com distribuição de vitórias saudável.
