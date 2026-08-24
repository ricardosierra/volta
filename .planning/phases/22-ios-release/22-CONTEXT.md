# Phase 22: iOS Release - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Build validada no TestFlight, com assinatura, ícones, Privacy Label e loja prontos

**Requisitos cobertos:** QLT-04

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/22-ios-release/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Pipeline
- Godot exporta o projeto Xcode; o IPA sai de `xcodebuild` por script (`build_ios.sh` + `archive_ios.sh`). Nada manual e irreprodutível.
- `CFBundleShortVersionString` = semver; `CFBundleVersion` monotônico.

### Assets obrigatórios
- Conjunto **completo** do `AppIcon` (1024² sem canal alfa) — o iOS não perdoa um tamanho faltando e a validação do Xcode precisa passar sem aviso.
- Launch screen em **storyboard**, com cor do tema e logo. Nada de imagem estática por tamanho.

### Privacidade
- Privacy Nutrition Label preenchido a partir da auditoria da fase 18. **Sem ATT no v0.1.0** — não usamos IDFA nem tracking.
- Nenhum entitlement especial.

### Comportamento de sistema
- Safe area com notch, Dynamic Island e home indicator; nada interativo nos últimos 20 pt.
- Áudio com categoria de sessão correta e retomada limpa após ligação, alarme e botão de silencioso.
- Salvar em `NOTIFICATION_APPLICATION_PAUSED` sem exceção.
- Core Haptics quando disponível, com fallback silencioso.

### Paridade
- Comportamento igual ao Android; qualquer diferença precisa ser justificada e isolada em `platform/`.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/22-ios-release/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/22-ios-release/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/22-ios-release/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/22-ios-release/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/22-ios-release/TESTS.md` — os testes que precisam existir
- `.gsd/phases/22-ios-release/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/22-ios-release/`
- `docs/mobile/ios.md`
- `docs/deployment/release-process.md`

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

*Phase: 22-ios-release*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
