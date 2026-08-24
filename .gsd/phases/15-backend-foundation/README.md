# GSD 15 — Backend Foundation

**Status:** ⬜ pendente · **Depende de:** GSD 10 · **Tarefas:** 12 · **Prefixo:** `API`
**Branch:** `feature/gsd-15-backend-foundation`

## Objetivo

> Construir a API que sustenta leaderboards confiáveis, cloud save e desafios online — com o
> princípio inegociável de que **o cliente nunca é fonte de verdade**.

O cliente **não muda** nesta fase: a integração é a GSD 16.

## Escopo

**Entra:** projeto Laravel 11 · Docker de desenvolvimento (Postgres + Redis) · migrações e
modelos · auth por dispositivo (Sanctum) · perfil · submissão e validação de partida ·
leaderboards (Redis ZSET + Postgres) · cloud save · desafios diários · remote config ·
rate limiting · idempotência · filas · testes Pest · CI da API · deploy documentado.

**NÃO entra:** integração do cliente (é 16) · multiplayer (é 17) · telemetria (é 18) ·
compras (é 25).

## Dependências humanas (H-03)

Hospedagem, domínio e certificado precisam existir para o deploy. O desenvolvimento e os
testes rodam local em Docker — a fase **não** fica bloqueada esperando infraestrutura.
