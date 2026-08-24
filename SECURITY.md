# Política de Segurança

## Versões suportadas

Enquanto o projeto estiver em `v0.x`, apenas a **última minor publicada** recebe correções
de segurança.

| Versão | Suporte |
|---|---|
| `v0.1.x` | ✅ (a partir do primeiro release) |
| `< v0.1.0` | ❌ pré-release |

## Reportando uma vulnerabilidade

**Não abra issue pública.** Envie para **sierra.csi@gmail.com** com:

1. descrição do problema e impacto;
2. passos de reprodução (ou PoC);
3. versão do app / commit / plataforma;
4. sua avaliação de severidade.

Retorno inicial em até **72 horas**. Correção alvo: crítico ≤ 7 dias, alto ≤ 30 dias.

## Escopo

Em escopo: API (`services/api`), autenticação, submissão de score, leaderboard, inventário,
progressão, cloud save, integridade de compras, e o cliente no que se refere a segredos
embutidos ou armazenamento local sensível.

Fora de escopo: engenharia reversa do APK sem impacto no servidor, DoS por volume,
vulnerabilidades já conhecidas do Godot ou de dependências sem exploração demonstrada aqui.

## Princípios adotados

- **O cliente nunca é fonte de verdade** para score, moeda, inventário ou progresso
  (ver `docs/backend/security.md` e `docs/backend/anti-cheat.md`).
- Segredos jamais no repositório — apenas `.env.example` com chaves vazias.
- Toda escrita autenticada passa por rate limit e validação de plausibilidade.
- Assinatura e validação de payload de partida antes de aceitar recorde.
