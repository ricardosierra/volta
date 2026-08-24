# ADR-0005 — Arquitetura de multiplayer

## Context

Multiplayer em tempo real é um objetivo declarado, mas **depois** do core estar sólido (GSD 17).
A dificuldade específica deste jogo: o estado autoritativo não é só posição — é o **território**,
que muda por um algoritmo (flood fill) sensível a qualquer divergência. Um Seal calculado
diferente no cliente e no servidor é o pior bug possível.

## Decision

**Servidor autoritativo rodando a mesma simulação**, em **Godot headless**, com o **mesmo
código** de `territory/`, `runner/`, `gameplay/` e `ai/` do cliente. O Laravel orquestra
(matchmaking, alocação de instância, resultado); a partida em si roda no servidor Godot.

Modelo:
- cliente envia **input** (direção desejada) a ~20 Hz;
- servidor simula a 60 Hz e é autoridade total;
- servidor envia snapshots delta a ~15 Hz;
- cliente **prediz** só o próprio Runner e reconcilia; interpola os demais com buffer de ~100 ms;
- **território nunca é predito**: o Seal só é confirmado pelo servidor (a animação local começa
  otimista e reverte se negada — evento raro e visualmente suave).

Explicitamente proibido: replicar `Node`s do Godot pela rede e esperar que a física concorde.
Sincronizamos estado de simulação, que é determinístico por construção (regra R8.5).

## Alternatives

| Alternativa | Por que não |
|---|---|
| **P2P / host é um jogador** | Trapaça trivial, host com vantagem, migração de host complexa |
| **Servidor autoritativo em outra linguagem** | Exigiria reimplementar o `SealSolver` — garantia de divergência no subsistema mais crítico |
| **Lockstep determinístico** | Elegante e barato em banda, mas um cliente lento trava todo mundo; ruim para mobile com rede instável |
| **Só resultado validado (sem tempo real)** | É o que fazemos em GSD 16 para leaderboard — não substitui multiplayer |
| **Netcode de rollback** | Excelente para jogos de luta 1v1; caro demais para 6–8 entidades com estado de mundo grande |

## Consequences

**Positivas:** uma única implementação da simulação (impossível divergir); anti-cheat forte por
construção; determinismo já é requisito de teste, então a base já existe.

**Negativas / mitigações:**
- Custo de infraestrutura por partida → instâncias headless leves, uma por partida, encerradas
  ao fim; começar com região única.
- Latência afeta a sensação → predição local do próprio Runner + interpolação; alvo ≤ 120 ms RTT.
- Godot headless como servidor é menos comum → protótipo de carga em GSD 17 **antes** de
  qualquer promessa de produto.

**Compromissos:** GSD 17 entrega arquitetura + protótipo validado, **não** um recurso lançável.
Multiplayer em produção fica para pós-launch.

## Status

**Accepted** — 2026-08-24. Detalhamento em `docs/architecture/networking.md`.
