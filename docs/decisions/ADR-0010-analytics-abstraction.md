# ADR-0010 — Abstração de analytics e telemetria

## Context

Precisamos medir onboarding, retenção, balanceamento e performance real. Ao mesmo tempo, não
queremos: SDK de terceiro dentro do gameplay, dependência que trava upgrade de engine, coleta de
PII, nem eventos que mudam de nome a cada versão e destroem a série histórica.

## Decision

**Interface própria (`AnalyticsService`) com adapters.** O gameplay emite eventos com nome
`snake_case` estável e um dicionário de propriedades; quem decide o destino é o adapter
registrado no bootstrap:

```text
AnalyticsService (interface)
├── NoopAnalytics        padrão, inclusive em produção até GSD 18
├── LocalFileAnalytics   debug/QA — grava JSONL em user://
└── RemoteAnalytics      API própria, em lote, com fila offline
```

Regras:
- nomes de evento são **imutáveis** depois de publicados;
- contexto comum (`session_id`, `app_version`, `device_tier`, `locale`) é injetado pelo serviço,
  nunca pelo chamador;
- zero PII; id de jogador é UUID local rotacionável pelo próprio jogador;
- opt-out real em `Settings > Privacy` — desliga o envio, não só a interface;
- nenhum evento por frame; performance é amostrada e agregada.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **SDK de terceiro direto no gameplay** | Acoplamento no pior lugar, risco de trocar de fornecedor virar refatoração, e o SDK passa a ditar a política de privacidade |
| **Firebase Analytics** | Traz dependências de Play Services, complica o build e coleta mais do que queremos por padrão |
| **Sem analytics** | Balanceamento e onboarding viram achismo; o gate da Alpha depende de número |
| **Logs crus enviados ao servidor** | Volume e custo altos, sem esquema estável para agregação |

## Consequences

**Positivas:** trocar de fornecedor é trocar um adapter; testes rodam com `Noop` sem rede;
privacidade fácil de auditar (um único ponto de saída); esquema estável desde o dia 1.

**Negativas / mitigações:**
- Construir e manter o próprio pipeline dá trabalho → começamos com ingestão simples em lote na
  nossa própria API (já existente a partir de GSD 15).
- Sem dashboards prontos de mercado → GSD 18 entrega consultas e um painel mínimo; o custo é
  aceito em troca de controle total sobre os dados dos jogadores.

## Status

**Accepted** — 2026-08-24. Detalhamento em `docs/product/analytics-plan.md`.
