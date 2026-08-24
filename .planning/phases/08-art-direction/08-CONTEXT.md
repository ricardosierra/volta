# Phase 8: Art Direction - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

O jogo deixa de parecer protótipo — direção de arte aplicada, 8 temas verificados e zero placeholder

**Requisitos cobertos:** ART-01, ART-02, ART-03

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Partículas de celebração, câmera e som (é 09 — aqui é o visual base, não o juice)
- Skins alternativas (é 11)
- Arenas novas (é 13)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/08-art-direction/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Direção
- Minimalismo Neon Premium: geometria limpa, glow controlado, fundo escuro (luminância < 12 %), profundidade por luz.
- **Hierarquia visual é normativa**: Runner > Arc aberto > borda de Claim > preenchimento > grid/fundo. Nenhum efeito pode inverter isso.
- Tudo vetorial ou procedural. Nenhuma textura acima de 1024². Isso é o que mantém o app pequeno.

### Identificação de jogador
- Cor **+ forma + padrão de preenchimento**. O tema `Monochrome` é o teste extremo: se ele é jogável, a identificação por forma funciona.
- Cor do jogador humano é sempre `players[0]`, a mais saturada.
- Vermelho puro é reservado para perigo — nenhum Runner é vermelho.

### Elementos
- Claim: preenchimento translúcido (~35 %), padrão interno único por jogador, borda nítida com brilho que percorre.
- Arc: núcleo claro + halo, com intensidade e pulso em função do comprimento — é a tradução visual do Pilar 1.
- Seal: onda no Arc (0,12 s) → preenchimento radial (0,28 s) → faíscas → flash proporcional → `Steal Shatter` nas células roubadas.

### Qualidade
- Presets Low/Medium/High conforme a tabela de `docs/art/vfx.md`. `Auto` decide por RAM, núcleos, renderer e micro-benchmark de 1 s no boot, com resultado salvo e sobrescrevível.
- **Low não é castigo**: precisa continuar legível e satisfatório.

### Verificação
- Contraste e separação de matiz são verificados por script no CI, não por olho.
- Teste cego "onde está a ameaça?" com 10 capturas e 5 pessoas, meta ≥ 90 %.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/08-art-direction/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/08-art-direction/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/08-art-direction/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/08-art-direction/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/08-art-direction/TESTS.md` — os testes que precisam existir
- `.gsd/phases/08-art-direction/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/08-art-direction/`
- `docs/art/art-direction.md`
- `docs/art/themes.md`
- `docs/art/vfx.md`
- `docs/decisions/ADR-0011-theming-and-cosmetics.md`

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

*Phase: 08-art-direction*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
