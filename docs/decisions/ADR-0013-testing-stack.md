# ADR-0013 — Stack de testes

## Context

A estratégia de QA depende de rodar a simulação **sem render**, milhares de vezes, com seed fixa.
Também precisamos de testes unitários rápidos no CI e de testes de integração que cubram fluxos
entre sistemas. E de um jeito de medir performance com orçamento e detectar regressão.

## Decision

Três camadas, três ferramentas:

1. **Unit e integration: [GUT](https://github.com/bitwes/Gut)** — framework de testes maduro
   para Godot, roda headless (`--headless -s addons/gut/gut_cmdln.gd`), integra com CI.
2. **Gameplay e stress: runner próprio** (`tools/dev/simulate.sh` + script headless) que instancia
   a simulação sem nós visuais, roda N partidas com seeds determinísticas, verifica invariantes a
   cada tick e serializa o estado quando algo quebra.
3. **Performance: benchmarks próprios** (`tools/benchmarks/`) com resultados em JSON, baseline
   versionado por dispositivo e falha de CI em regressão > 10 %.

Backend: **Pest** (PHPUnit por baixo) + Pint + PHPStan nível 6+.

Regras: todo bug corrigido ganha um teste que falhava antes; nenhum teste depende de tempo real,
rede ou ordem; teste intermitente é bug (do teste ou do jogo), nunca "flaky aceito".

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Só testes manuais** | Não escala; não encontraria os bugs de topologia do território, que são raros e catastróficos |
| **GdUnit4 em vez do GUT** | Alternativa legítima; GUT foi escolhido por maturidade e simplicidade de linha de comando. Trocar seria um ADR novo, não um detalhe |
| **Testes só com render (integração visual)** | Lentos demais para milhares de partidas; frágeis |
| **Framework de benchmark de terceiros** | Não existe padrão em Godot; nosso caso é específico (orçamento por subsistema em dispositivo real) |

## Consequences

**Positivas:** a decisão de manter a simulação desacoplada da apresentação (ADR-0002, overview
de arquitetura) é o que torna tudo isso possível — e os testes, por sua vez, protegem essa
separação; regressão de território e de performance é detectada automaticamente.

**Negativas / mitigações:**
- GUT é uma dependência de terceiros → fica em `addons/`, isolada, versão pinada, e só roda em
  contexto de teste; nunca entra no build de release.
- O runner próprio é código que precisa de manutenção → tratado como produto interno, com sua
  própria seção em `docs/testing/stress-testing.md`.

## Status

**Accepted** — 2026-08-24.
