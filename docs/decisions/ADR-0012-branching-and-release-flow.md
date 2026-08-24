# ADR-0012 — Branching e fluxo de release

## Context

O projeto é executado por **fases GSD**, cada uma com escopo fechado, critérios de aceite e
handoff. Grande parte da execução é feita por agentes de desenvolvimento em sessões separadas.
Precisamos de um fluxo que: dê rastreabilidade fase↔branch↔PR, mantenha `main` sempre
publicável, permita correção urgente sem atrapalhar a fase em andamento e funcione com um
número pequeno de pessoas.

## Decision

**Git Flow simplificado, com uma fase GSD por branch:**

```text
main       só recebe merge de release/* e hotfix/*; sempre com tag
develop    integração das fases
feature/gsd-XX-nome   uma fase GSD inteira
fix/<slug>            correção pontual em develop
hotfix/<slug>         correção urgente a partir de main
release/vX.Y.Z        congelamento, bump, QA final
```

- Commits semânticos: `tipo(escopo): resumo`. **Sem** trailers de coautoria de IA.
- Um PR por fase, com o `HANDOFF.md` da fase no corpo.
- `main` nunca recebe commit direto; branch protegido.
- Merge com `--no-ff` para preservar a topologia das fases no histórico.
- Tag anotada `vX.Y.Z` a cada release, criada em `main`.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Trunk-based com feature flags** | Ótimo para times grandes e entrega contínua; aqui, uma fase é um bloco coeso que se beneficia de isolamento, e não temos entrega contínua para mobile |
| **GitHub Flow (só `main` + feature)** | Sem `develop`, integrar 5 fases parcialmente prontas deixaria `main` não publicável |
| **Um branch por tarefa** | Fragmentação excessiva: 214 tarefas viram 214 PRs de revisão |
| **Sem branches (commit direto)** | Impossível revisar, impossível reverter fase |

## Consequences

**Positivas:** rastreabilidade direta entre fase, branch, PR e handoff; `main` sempre em estado
publicável; reverter uma fase inteira é um `revert` de merge commit.

**Negativas / mitigações:**
- Branch de fase pode viver muito tempo e divergir → rebase/merge de `develop` obrigatório a
  cada tarefa concluída; fases são desenhadas para durar dias, não semanas.
- Dois branches de longa duração exigem disciplina → automatizado no CI (gate de merge) e
  descrito em `CONTRIBUTING.md`.

## Status

**Accepted** — 2026-08-24.
