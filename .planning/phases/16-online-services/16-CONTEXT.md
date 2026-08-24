# Phase 16: Online Services - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Trocar `Local*` por `Remote*` sem que a ausência de rede mude qualquer coisa para quem está jogando

**Requisitos cobertos:** SRV-03, SRV-04

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/16-online-services/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Offline-first é o comportamento padrão
- Sem rede, o jogo é **100 % jogável** — isso não é modo degradado.
- Nenhuma chamada de rede no caminho de simulação, em `_process` ou `_physics_process`.
- Erro de rede **nunca** vira popup durante a partida. No máximo um ícone discreto no menu.
- O boot nunca espera rede: config e perfil são buscados de forma assíncrona, com embutido como padrão.

### Fila offline
- Persistida em `user://`, com deduplicação por chave e `Idempotency-Key` ponta a ponta.
- Precisa sobreviver ao app morto no meio da drenagem, preservando ordem e sem duplicar.

### Remote config
- Só sobrescreve chave **existente**, respeitando faixa declarada — validado no cliente também, não só no servidor.
- Nunca aplicado durante `Playing`. Qualquer falha cai no valor embutido.

### Cloud save
- Sincroniza em pontos seguros: boot, fim de partida, background.
- Em caso ambíguo, o jogador escolhe — nunca sobrescrever silenciosamente.

### Conta
- Vinculação a Google Play Games / Game Center é **opcional e reversível**. Jogar nunca exige login.

### Fechamento
- MOCK-001 (leaderboard), MOCK-003 (remote config) e MOCK-004 (desafios) precisam ser marcados como fechados em `.gsd/BACKLOG.md`.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/16-online-services/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/16-online-services/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/16-online-services/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/16-online-services/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/16-online-services/TESTS.md` — os testes que precisam existir
- `.gsd/phases/16-online-services/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/16-online-services/`
- `docs/architecture/networking.md`
- `docs/backend/api-design.md`
- `.gsd/BACKLOG.md` (MOCK-001

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

*Phase: 16-online-services*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
