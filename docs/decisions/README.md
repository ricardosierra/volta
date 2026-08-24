# Architecture Decision Records

Registro de decisões arquiteturais. Uma decisão importante que não está aqui é uma decisão que
vai ser refeita, mal, daqui a três meses.

## Formato

Todo ADR tem exatamente estas seções: **Context · Decision · Alternatives · Consequences · Status**.

`Status`: `Proposed` · `Accepted` · `Superseded by ADR-XXXX` · `Deprecated`.
ADR aceito **não se edita**: cria-se um novo que o substitui.

## Quando criar um ADR

- A decisão é cara de reverter.
- Existem alternativas defensáveis.
- Alguém vai perguntar "por que assim?" daqui a seis meses.
- A escolha limita ou habilita fases futuras.

Não criar ADR para: escolha de nome de variável, formatação, decisão local a um arquivo.

## Índice

| ADR | Título | Status | Fase |
|---|---|---|---|
| [0001](ADR-0001-engine.md) | Engine e versão | Accepted | 00 |
| [0002](ADR-0002-territory-representation.md) | Representação do território | Accepted | 00 |
| [0003](ADR-0003-save-system.md) | Save, versionamento e migração | Accepted | 00 |
| [0004](ADR-0004-backend.md) | Stack de backend | Accepted | 00 |
| [0005](ADR-0005-networking.md) | Arquitetura de multiplayer | Accepted | 00 |
| [0006](ADR-0006-movement-model.md) | Modelo de movimento | Accepted | 00 |
| [0007](ADR-0007-self-collision-rule.md) | Regra de auto-colisão | Accepted | 00 |
| [0008](ADR-0008-bot-ai-architecture.md) | Arquitetura da IA | Accepted | 00 |
| [0009](ADR-0009-ui-framework.md) | UI e escala de tela | Accepted | 00 |
| [0010](ADR-0010-analytics-abstraction.md) | Abstração de analytics | Accepted | 00 |
| [0011](ADR-0011-theming-and-cosmetics.md) | Temas e cosméticos | Accepted | 00 |
| [0012](ADR-0012-branching-and-release-flow.md) | Branching e releases | Accepted | 00 |
| [0013](ADR-0013-testing-stack.md) | Stack de testes | Accepted | 00 |
| [0014](ADR-0014-simulation-tick-model.md) | Tick de simulação e refresh rate | Accepted | 00 |
