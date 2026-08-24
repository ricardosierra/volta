# ADR-0004 — Stack de backend

## Context

A partir de GSD 15 precisamos de: contas anônimas por dispositivo, perfis, leaderboards com
múltiplas janelas, cloud save, desafios diários iguais para todos, remote config, validação de
compras e ingestão de telemetria. Nada disso pode existir antes da hora, e nada pode bloquear o
jogo offline.

## Decision

**PHP 8.3 + Laravel 11 + PostgreSQL 16 + Redis 7**, com filas (Horizon), Sanctum para
autenticação e API REST versionada (`/api/v1`). Leaderboard com **Redis ZSET** como camada
quente e PostgreSQL como verdade durável.

O cliente fala com o backend **apenas** por trás das interfaces `*Repository` já definidas em
GSD 06 — trocar `Local*` por `Remote*` é um registro no bootstrap.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Node/NestJS** | Ótimo, mas a equipe é mais produtiva em Laravel; produtividade importa mais que preferência de linguagem aqui |
| **Go** | Melhor para o servidor de partidas (ADR-0005 resolve isso de outro jeito), excessivo para CRUD de meta |
| **Firebase / BaaS** | Lock-in, custo imprevisível em escala, controle limitado sobre validação de score — que é exatamente o que precisamos controlar |
| **Serverless puro** | Cold start e complexidade de estado para leaderboard em tempo quase real |
| **MySQL** | Serve, mas PostgreSQL tem melhor suporte a JSONB, índices parciais e janelas — úteis em leaderboard e telemetria |

## Consequences

**Positivas:** produtividade alta; ecossistema maduro (filas, agendamento, testes, migrações);
Redis resolve leaderboard e cache com uma dependência só; stack barata de hospedar.

**Negativas / mitigações:**
- PHP não é o ideal para conexões persistentes/WebSocket em escala → o servidor de partidas
  não é PHP (ADR-0005); o Laravel cuida do meta.
- Mais uma linguagem no repositório → isolada em `services/api`, com CI próprio e sem
  compartilhar código com o cliente (o contrato compartilhado vive em `packages/shared`).

**Compromissos:** nenhum endpoint bloqueia gameplay; toda escrita idempotente; rate limit por
rota; Pest + PHPStan nível 6+ obrigatórios.

## Status

**Accepted** — 2026-08-24. Detalhamento em `docs/backend/api-design.md`.
