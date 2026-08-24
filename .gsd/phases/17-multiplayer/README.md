# GSD 17 — Multiplayer Architecture

**Status:** ⬜ pendente · **Depende de:** GSD 16 · **Tarefas:** 9 · **Prefixo:** `MPLY`
**Branch:** `feature/gsd-17-multiplayer`

## Objetivo

> Provar a arquitetura de multiplayer autoritativo com um **protótipo funcional e medido** —
> não lançar multiplayer. Esta fase entrega conhecimento e código de base; o recurso em
> produção fica para depois do launch.

**Fora do caminho crítico do release.** Se o cronograma apertar, esta fase pode ser adiada
sem bloquear a GSD 18 em diante (registrar em `STATUS.md` se isso acontecer).

## Escopo

**Entra:** servidor autoritativo em Godot headless (mesmo código de simulação) · protocolo de
input e snapshot delta · predição local e reconciliação · interpolação dos outros Runners ·
território **nunca** predito · matchmaking simples com preenchimento por bots · reconexão ·
validação de input no servidor · teste de latência e de carga · relatório de viabilidade.

**NÃO entra:** produção, escala, regiões, ranqueamento online, anti-cheat avançado.
