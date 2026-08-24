# Phase 21: Android Release - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

AAB assinado, validado e pronto para o Google Play, com privacidade e loja em ordem

**Requisitos cobertos:** QLT-04

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/21-android-release/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Build limpa
- `VOLTA_DEBUG_TOOLS=false`, nível de log `warn`, `Build.is_debug()` retornando `false`.
- `check_release_build.sh` precisa reprovar build com cena de debug, addon de teste, overlay, arquivo de teste ou `PLACEHOLDER-*` — provado por caso plantado.
- Nenhuma senha ou segredo pode aparecer em log de build.

### Assinatura
- Keystore guardado **fora do repositório**, com backup seguro documentado; senhas em secrets do CI.
- `export_presets.cfg` é **gerado por script** a partir de template + variáveis de ambiente, e continua fora do versionamento.
- `versionCode` monotônico derivado do semver (`major*10000 + minor*100 + patch`).

### Loja e privacidade
- Data Safety preenchido por **revisão cruzada linha a linha** com a auditoria de payload da fase 18. Nenhuma divergência entre o que o app faz e o que declara.
- Permissões reduzidas ao mínimo; cada uma justificada em `docs/mobile/android.md`.
- Política de privacidade publicada e ligada em `Settings > Sobre` e na ficha da loja.

### Pendências humanas
- H-01 (marca) tem prazo **antes** desta fase; H-02 (conta do Play) e H-06 (política publicada) também. Sem elas a build fica pronta, mas não publica — registrar isso explicitamente no SUMMARY.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/21-android-release/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/21-android-release/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/21-android-release/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/21-android-release/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/21-android-release/TESTS.md` — os testes que precisam existir
- `.gsd/phases/21-android-release/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/21-android-release/`
- `docs/mobile/android.md`
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

*Phase: 21-android-release*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
