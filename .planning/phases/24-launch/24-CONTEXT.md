# Phase 24: Launch - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Publicar a v0.1.0 com rollout gradual, monitoramento ativo e rollback armado

**Requisitos cobertos:** QLT-06

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/24-launch/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Versão
- O projeto **começa em v0.1.0**. `v1.0.0` é reservado para maturidade em produção com base de usuários relevante — **não** é o primeiro release.
- CHANGELOG no formato **Release Notes** deste repositório: `### ✨ Novidades`, `### 🎨 Melhorias`, `### 🐛 Correções`, `### 🔧 Técnico`, itens em `- [x]`, cabeçalho `## [vX.Y.Z (AAAA-MM-DD)]` com link de comparação. Nunca Keep-a-Changelog.
- Tag anotada criada em `main`, com merge `--no-ff` e merge de volta em `develop`.

### Builds
- Geradas **a partir da tag**, pelo CI, com símbolos guardados para desofuscar crash depois.

### Rollout
- 5 % → 20 % → 50 % → 100 %, com **24 h de métrica saudável entre degraus**. A regra é rígida.
- Crash-free ≥ 99,5 % antes de cada degrau. Ao primeiro sinal ruim, o rollout para.
- Nunca 100 % de imediato.

### Checklist
- Cada item da checklist de release marcado **com evidência** (link, captura, número). Nenhum "provavelmente ok".

### Pós-72h
- Monitorar crash-free, ANR, retenção D1, funil de onboarding, avaliações e erros da API. Responder avaliações na primeira semana. Escrever o relatório de 72 h — ele vira a entrada da fase 25.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/24-launch/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/24-launch/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/24-launch/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/24-launch/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/24-launch/TESTS.md` — os testes que precisam existir
- `.gsd/phases/24-launch/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/24-launch/`
- `docs/deployment/release-process.md`
- `CHANGELOG.md`

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

*Phase: 24-launch*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
