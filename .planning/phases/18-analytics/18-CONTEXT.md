# Phase 18: Analytics & Telemetry - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Passar a saber em vez de achar — onboarding, retenção, balanceamento, performance e crashes — com privacidade levada a sério e nenhum SDK dentro do gameplay

**Requisitos cobertos:** SRV-05

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/18-analytics/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Regra de ouro
- O gameplay **nunca** chama um SDK. Emite evento numa interface própria; um adapter decide o destino.
- `AnalyticsBridge` é o único tradutor entre eventos de simulação e eventos de produto.

### Esquema
- Nomes em `snake_case`, **imutáveis** depois de publicados. Mudou o significado? Evento novo.
- Contexto comum (`session_id`, `app_version`, `device_tier`, `locale`) é injetado pelo serviço — o chamador nunca passa isso à mão.
- **Nenhum evento por frame.** Performance é amostrada a cada 15 s e agregada.
- Congelar a lista de eventos (ANLT-001) **antes** de implementar qualquer adapter.

### Privacidade
- **Zero PII.** Sem e-mail, contatos, localização precisa ou ID de publicidade.
- Id de jogador é UUID local, rotacionável pelo próprio jogador.
- Opt-out **desliga o envio**, não só esconde o botão — verificado por proxy.
- A auditoria de payload desta fase alimenta diretamente o Data Safety (fase 21) e o Privacy Label (fase 22).

### Retenção
- Bruto por 90 dias, agregado por 2 anos. Volume e custo estimados antes de ligar.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/18-analytics/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/18-analytics/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/18-analytics/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/18-analytics/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/18-analytics/TESTS.md` — os testes que precisam existir
- `.gsd/phases/18-analytics/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/18-analytics/`
- `docs/product/analytics-plan.md`
- `docs/decisions/ADR-0010-analytics-abstraction.md`

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

*Phase: 18-analytics*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
