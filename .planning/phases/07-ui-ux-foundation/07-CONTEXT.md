# Phase 7: UI/UX Foundation - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Design system em tokens, todas as telas navegáveis, settings que funcionam de verdade, i18n desde o primeiro texto e onboarding dentro da partida

**Requisitos cobertos:** UIX-01, UIX-02, UIX-03, UIX-04, UIX-05

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Fontes, ícones e paleta definitivos (é 08)
- Telas de Skins, Challenges, Leaderboard, Shop (são 10/11/16/25)
- VFX e som de UI definitivos (é 09)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/07-ui-ux-foundation/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Design system
- Tokens em `Resource`: espaçamento (escala de 4), raio, tipografia, cor **semântica**, elevação, movimento.
- Componentes pedem papéis (`accent`, `fg.muted`), nunca hex. Trocar tema muda tudo sem reiniciar.
- Profundidade vem de brilho e borda, não de sombra difusa — coerente com a arte neon.

### Layout
- Toda tela é `SafeAreaContainer > MarginContainer > conteúdo`. Sem exceção — o `validate-repo.sh` verifica.
- Ação primária sempre na metade inferior (zona do polegar). Nada interativo a menos de 16 dp da safe area.
- Alvo de toque mínimo 48 dp em toda a UI.

### Movimento
- Nenhuma transição acima de 300 ms; troca de tela em 250 ms. Nenhuma bloqueia o toque.

### i18n
- Chave de tradução desde o **primeiro** texto. en e pt-BR juntos — nunca "traduzimos depois".
- pt-BR é mais longo que en: todo layout precisa sobreviver a isso em escala 1,25.

### Onboarding
- 6 passos como `TutorialStepResource` (gatilho, texto, condição de saída, evento).
- Cada dica some quando o jogador **demonstra** o comportamento, não por timer.
- Primeira execução vai direto para a partida, com 2 bots Rookie. O menu só aparece depois.
- Nenhuma dica aparece com inimigo a menos de 10 células — não se ensina no meio de um susto.

### Settings
- Nenhuma opção decorativa: tudo persiste e tem efeito imediato.
- O test drive de controles é obrigatório — trocar de esquema sem poder experimentar é hostil.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/07-ui-ux-foundation/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/07-ui-ux-foundation/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/07-ui-ux-foundation/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/07-ui-ux-foundation/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/07-ui-ux-foundation/TESTS.md` — os testes que precisam existir
- `.gsd/phases/07-ui-ux-foundation/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/07-ui-ux-foundation/`
- `docs/ui/design-system.md`
- `docs/ui/screens.md`
- `docs/ui/accessibility.md`
- `docs/design/onboarding.md`
- `docs/decisions/ADR-0009-ui-framework.md`

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

*Phase: 07-ui-ux-foundation*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
