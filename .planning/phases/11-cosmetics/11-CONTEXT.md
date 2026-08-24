# Phase 11: Cosmetics - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Identidade visual para o jogador e a única fonte legítima de receita — catálogo como dado, com zero impacto de gameplay

**Requisitos cobertos:** PRG-04

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/11-cosmetics/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Cosmético é dado
- Item é `Resource` com id, tipo, raridade, preço, fonte de desbloqueio e assets. **O schema não aceita campo de gameplay.**
- Adicionar item novo = adicionar `.tres`. Nenhum código.

### Equidade (testada, não prometida)
- Hitbox idêntica em todas as skins; largura efetiva de Arc idêntica em todos os estilos; duração e custo idênticos em todos os efeitos de Seal.
- Nenhum Arc Style pode esconder o próprio Arc do adversário, nem destacar o do inimigo.
- Todo item precisa continuar legível nos 8 temas — a auditoria é uma matriz item × tema com capturas.

### Loja
- Estados na grade comunicados sem depender de texto: possuído, equipado, bloqueado (com requisito), comprável.
- Saldo insuficiente informa e oferece o caminho legítimo (jogar). **Nunca** empurra compra.
- Nenhum dark pattern da lista de `docs/product/monetization.md`: sem contagem falsa, sem "última chance" recorrente, sem botão de compra disfarçado.
- Item comprado é permanente, inclusive de temporada passada.

### Preview
- O preview mostra exatamente o que será aplicado, antes de equipar — Runner animado desenhando um Arc em loop.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/11-cosmetics/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/11-cosmetics/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/11-cosmetics/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/11-cosmetics/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/11-cosmetics/TESTS.md` — os testes que precisam existir
- `.gsd/phases/11-cosmetics/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/11-cosmetics/`
- `docs/decisions/ADR-0011-theming-and-cosmetics.md`
- `docs/product/monetization.md`
- `docs/art/themes.md`

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

*Phase: 11-cosmetics*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
