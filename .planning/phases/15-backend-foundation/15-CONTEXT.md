# Phase 15: Backend Foundation - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

API Laravel que sustenta leaderboard confiável, cloud save e desafios — com o cliente nunca sendo fonte de verdade. O cliente não muda nesta fase

**Requisitos cobertos:** SRV-01, SRV-02, SRV-03

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/15-backend-foundation/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Princípio
- **O cliente nunca é fonte de verdade** para score, moeda, inventário ou progressão.
- O cliente **não muda** nesta fase. A integração é a fase 16.

### Stack
- PHP 8.3 + Laravel 11 + PostgreSQL 16 + Redis 7 + Horizon + Sanctum. Pest, Pint, PHPStan nível 6+.
- Leaderboard: Redis ZSET como camada quente, PostgreSQL como verdade durável, reconciliado por job.
- `Controller → FormRequest → Action/Service → Repository`. Nenhuma lógica em controller.

### Validação de partida
- O servidor **recalcula** o score a partir dos agregados e compara com o declarado, com tolerância explícita.
- Plausibilidade validada contra as regras físicas do jogo (duração, taxa de captura, Seals por segundo, Breaks possíveis, teto de Surge, `largest_seal <= claim_pct`).
- Falha → `422` + `flags`, **nunca** banimento automático. Falso positivo custa mais caro que um trapaceiro no top 100 por um dia.

### Contas
- Conta anônima por dispositivo, sem e-mail. `device_id` armazenado como **hash**.
- Apelido sanitizado com lista de bloqueio e normalização Unicode (homóglifos).

### Cloud save
- `updated_at` do **servidor**; reconciliação monotônica (XP, conquistas e inventário nunca diminuem); últimas 3 versões guardadas.

### Operação
- Backup diário com **restauração testada em ambiente limpo** — backup não testado não é backup.
- Nenhum segredo no repositório; nenhum log com PII ou token.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/15-backend-foundation/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/15-backend-foundation/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/15-backend-foundation/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/15-backend-foundation/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/15-backend-foundation/TESTS.md` — os testes que precisam existir
- `.gsd/phases/15-backend-foundation/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/15-backend-foundation/`
- `docs/backend/api-design.md`
- `docs/backend/security.md`
- `docs/backend/anti-cheat.md`
- `docs/decisions/ADR-0004-backend.md`

### Regras que valem em toda fase
- `CLAUDE.md` — as 10 regras de código verificadas por máquina
- `docs/architecture/overview.md` — camadas, convenções, o que não fazer
- `docs/design/balance.md` — **o único lugar com números de gameplay**
- `.gsd/QUALITY_GATES.md` — o que precisa ser verdade para a fase fechar

</canonical_refs>

<code_context>
## Existing Code Insights

### Padrões estabelecidos
- Simulação (`territory/`, `runner/`, `ai/`, `gameplay/`) **não importa** `presentation/` nem `ui/` — verificado pelo CI.
- Toda dependência externa entra por interface (`*Repository`, `*Service`), com implementação `Local*` antes de `Remote*`.
- Nenhum número de gameplay no código: tudo em `.tres` sob `packages/shared/config/`.
- Nenhum arquivo-depósito (`utils.gd`, `manager.gd`, `global.gd`…) — o CI reprova pelo nome.

### Verificação antes de fechar qualquer tarefa
```bash
./tools/ci/validate-repo.sh
./tools/ci/lint.sh
./tools/ci/test-client.sh
```

</code_context>

<deferred>
## Deferred Ideas

Tudo que estiver fora do escopo declarado acima vai para `.gsd/BACKLOG.md` com uma linha —
nunca para o código desta fase. O backlog já contém 18 itens deliberadamente adiados,
7 placeholders e 5 mocks, todos com fase de destino.

</deferred>

---

*Phase: 15-backend-foundation*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
