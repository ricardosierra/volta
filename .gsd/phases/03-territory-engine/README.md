# GSD 03 — Territory Engine ⚠️ FASE CRÍTICA

**Status:** ⬜ pendente
**Depende de:** GSD 02
**Branch:** `feature/gsd-03-territory-engine`
**Tarefas:** 14 · **Prefixo de ID:** `TERR`

## Objetivo

> Sair do Claim desenha um Arc. Voltar ao Claim captura tudo que ficou cercado. Correto,
> rápido, determinístico e bonito de ver acontecer.

## Por que esta fase é a mais importante do projeto

Todas as 22 fases seguintes assumem que o território funciona. Um erro de topologia aqui
aparece como "às vezes o jogo captura o mapa inteiro" na fase 12, e a essa altura ninguém
lembra por quê. Dois riscos de score 15 vivem aqui: **RISK-001** (lento/incorreto) e
**RISK-002** (Arc vazando pela diagonal).

Por isso: mais tarefas, benchmark desde a primeira linha, e o solver escrito como **função
pura** antes de qualquer integração com o jogo.

## Escopo

**Entra:**
- `TerritoryGrid`: dois `PackedByteArray`, contagem incremental, consultas O(1)
- Rasterização do Arc por traçado *supercover*, com garantia de 4-conectividade
- `SealSolver`: flood fill do exterior, bounding box, buffers pré-alocados, epoch
- Aplicação do Seal: captura, roubo, limpeza do Arc, eventos
- Claim inicial no spawn; percentual de território
- Overload do Arc (comprimento máximo com decaimento da cauda)
- Renderização por textura com `dirty_rect` — 1 draw call, com animação de preenchimento
- Zoom dinâmico da câmera conforme o território cresce
- Serialização do estado do grid
- Os 15 benchmarks (B01–B15) e as invariantes do stress test

**NÃO entra:**
- Colisão com Arc inimigo, Break, morte, Backwash (é 04 — aqui só a mecânica de captura)
- Bots (é 05)
- Score (é 06)
- Arte final (é 08)

## Resultado esperado

> Um Runner sozinho na arena consegue sair, desenhar e capturar território repetidamente,
> com preenchimento animado, sem nenhum caso em que a captura fique errada — provado por
> 30 casos de mesa, teste de propriedade e 500 partidas headless de invariantes.

## Leitura obrigatória antes de começar

1. [`docs/architecture/territory-system.md`](../../../docs/architecture/territory-system.md) — inteiro
2. [`docs/decisions/ADR-0002`](../../../docs/decisions/ADR-0002-territory-representation.md)
3. [`docs/gameplay/rules.md`](../../../docs/gameplay/rules.md) §4 e §9
4. [`docs/performance/territory-benchmarks.md`](../../../docs/performance/territory-benchmarks.md)
