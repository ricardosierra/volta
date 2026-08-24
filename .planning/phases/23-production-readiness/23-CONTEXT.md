# Phase 23: Production Readiness - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Última chance de encontrar problema antes dos jogadores — QA completo, regressão, migração de save e rollback ensaiado. Nenhuma feature nova

**Requisitos cobertos:** QLT-05

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/23-production-readiness/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Escopo congelado
- **Nenhuma feature nova.** Nenhuma. A partir daqui só correção. Qualquer ideia vai para pós-launch.
- A tentação de "só mais uma coisinha" é o risco número um desta fase.

### QA
- Roteiro versionado em `tests/qa/release_checklist.md`, executado nas duas plataformas e **assinado**, em sessões separadas para evitar erro por cansaço.
- Registrar tudo, inclusive o que for cosmético.

### Migração de save
- Fixtures de **todas** as versões usadas em teste, versionadas em `tests/fixtures/saves/`.
- Testar a cadeia completa até a versão atual, mais corrompido, versão futura e vazio.

### Crash
- Matar o app em 10 momentos diferentes (boot, menu, loading, partida, captura, resultado, compra, sincronização, background, com fila pendente) e verificar integridade do progresso em cada um.

### Rollback
- Ensaiar de verdade: halt de rollout no Play, pausa de phased release na App Store, e desativação de feature por remote config. Documentar com capturas do procedimento real.
- Descobrir como parar durante o incêndio é tarde demais.

### Segurança
- Checklist de `docs/backend/security.md` assinada, `composer audit` limpo, backup restaurado em ambiente limpo de novo.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/23-production-readiness/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/23-production-readiness/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/23-production-readiness/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/23-production-readiness/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/23-production-readiness/TESTS.md` — os testes que precisam existir
- `.gsd/phases/23-production-readiness/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/23-production-readiness/`
- `docs/deployment/release-process.md`
- `docs/backend/security.md`
- `docs/architecture/save-system.md`

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

*Phase: 23-production-readiness*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
