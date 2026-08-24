# VOLTA

**Last updated:** 2026-08-24

## Core Value

Um arcade mobile de conquista territorial em partidas de 90–180 segundos, onde o jogador sai
da zona segura, desenha um arco luminoso e captura tudo que cercou ao fechar a volta — com
controle que responde, bots com intenção legível e monetização que nunca vende vantagem.

## What This Is

Jogo mobile (Android primário, iOS secundário) feito em Godot 4.3 com GDScript tipado.
Referência de gênero apenas no conceito de loop territorial; **regras, arte, UI, bots, economia,
nomes e arquitetura são próprios**. Nenhum código, asset ou interface de terceiros é usado.

## Vocabulário do produto

| Termo | Significado |
|---|---|
| Runner | entidade controlada por jogador ou bot |
| Field | a arena (grid lógico + camada visual) |
| Claim | território de um Runner |
| Arc | trilha desenhada fora do Claim — vulnerável |
| Seal | fechar o Arc e capturar a região cercada |
| Break | eliminar alguém cortando o Arc dele |
| Backwash | penalidade não-letal por tocar o próprio Arc ou uma barreira |
| Surge | sistema de combo |
| Spark / Prism | moeda soft / moeda premium |

## Pilares (ordem de desempate)

1. **Risco legível** — o jogador sempre sabe quanto está arriscando
2. **Resposta imediata** — nenhum toque ignorado; latência < 50 ms
3. **Clareza em movimento** — em 0,2 s dá para ver onde estou, o que é meu, o que é ameaça
4. **Expansão como recompensa** — cada Seal é um evento audiovisual
5. **Justiça** — nada comprável muda a simulação

North Star: `Fun > Responsiveness > Clarity > Game Feel > Performance > Visual Quality > Retention > Monetization`

## Stack

| Camada | Decisão | ADR |
|---|---|---|
| Engine | Godot 4.3 stable, GDScript tipado, renderer Mobile | ADR-0001 |
| Território | grid denso (`PackedByteArray`) + flood fill do exterior | ADR-0002 |
| Save | JSON versionado, escrita atômica, migrações encadeadas | ADR-0003 |
| Backend | Laravel 11 + PostgreSQL 16 + Redis 7 (a partir da fase 15) | ADR-0004 |
| Multiplayer | servidor autoritativo em Godot headless (mesmo código) | ADR-0005 |
| Movimento | ângulo livre com taxa de giro; Arc rasterizado supercover | ADR-0006 |
| Auto-colisão | Backwash, **não** morte | ADR-0007 |
| IA | utilidade com perfis em `.tres` | ADR-0008 |
| UI | Control nativo + design system em tokens | ADR-0009 |
| Analytics | interface própria + adapters | ADR-0010 |
| Temas | `ThemePalette` como Resource; cosmético é dado | ADR-0011 |
| Branching | Git Flow simplificado, uma fase por branch | ADR-0012 |
| Testes | GUT + runner headless próprio + benchmarks | ADR-0013 |
| Tick | simulação 60 Hz fixa, render livre, interpolação manual | ADR-0014 |

## Restrições inegociáveis

- A simulação (`territory/`, `runner/`, `ai/`, `gameplay/`) **não conhece** apresentação nem UI.
- A simulação é **determinística**: mesma seed + mesmos inputs → mesmo resultado.
- Nenhum número de gameplay no código — tudo em `.tres` (`packages/shared/config/`).
- Nenhum arquivo-depósito (`utils.gd`, `manager.gd`, `global.gd`…).
- Nenhum item comprável altera a simulação.
- 60 FPS estáveis no aparelho intermediário é requisito, não meta.

## Documentação autoritativa

| Assunto | Caminho |
|---|---|
| Regras do jogo (numeradas) | `docs/gameplay/rules.md` |
| Todos os números | `docs/design/balance.md` |
| Sistema de território | `docs/architecture/territory-system.md` |
| Arquitetura e convenções | `docs/architecture/overview.md` |
| Decisões | `docs/decisions/` |
| Plano por fase | `.gsd/phases/NN-*/` |
| Orçamento de performance | `docs/performance/performance-budget.md` |

## Key Decisions

| Decisão | Motivo |
|---|---|
| Grid denso + flood fill do exterior | determinismo, captura local, 1 draw call |
| Auto-colisão = Backwash | com ângulo livre, morrer por tocar o próprio rastro parece injusto |
| Lista de causas de morte **fechada** | "você só morre se cortarem seu arco" — Pilar 1 |
| Simulação headless desde o dia 1 | viabiliza 500 partidas de teste por noite |
| Bots por utilidade, não FSM | personalidade vira dado; dificuldade por comportamento |
| Multiplayer só como protótipo no v0.1.0 | território não pode divergir; provar antes de prometer |
| Monetização só cosmética | Pilar 5 |

## Requirements

Lista completa e rastreável em `.planning/REQUIREMENTS.md` (11 grupos, IDs usados no ROADMAP:
FND, MOV, TER, CMB, BOT, MTC, UIX, ART, PRG, SRV, QLT).

Requisitos detalhados por fase em `.gsd/phases/NN-*/REQUIREMENTS.md`, com identificadores
próprios (`R03-01`…) referenciáveis em código e teste.

## Milestones

| Marco | Fecha em | Critério |
|---|---|---|
| MVP | fase 6 | jogo completo do início ao fim, feio, 60 FPS |
| Alpha | fase 14 | parece produto: arte, feel, progressão, 5 modos, 5 arenas |
| Beta | fase 20 | backend, analytics, acessibilidade, crash-free ≥ 99 % |
| Release v0.1.0 | fase 24 | checklist de release inteiro fechado |

## Pendências humanas

| # | Assunto | Prazo |
|---|---|---|
| H-01 | Busca de marca do nome "VOLTA" | antes da fase 21 |
| H-02 | Contas Google Play e Apple Developer | fases 21/22 |
| H-03 | Hospedagem da API e domínio | fase 15 |
| H-04 | Licença de fonte comercial | fase 8 |
