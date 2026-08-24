# Phase 9: Game Feel & Polish - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Toda ação principal responde nos sete canais — Gameplay, Animation, VFX, SFX, Haptics, Camera e UI Feedback — com intensidade proporcional ao evento

**Requisitos cobertos:** ART-04, ART-05, ART-06

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- Novos assets de arte (é 08, já feito)
- Progressão (é 10)
- Efeitos de Seal cosméticos (é 11)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/09-game-feel/README.md`.

</domain>

<decisions>
## Implementation Decisions

### Contrato dos sete canais
- Toda ação da tabela de `docs/design/game-feel.md` precisa responder em Gameplay, Animation, VFX, SFX, Haptics, Camera e UI Feedback. Canal vazio reprova a tarefa.
- Intensidade é **função contínua** do tamanho do evento — capturar 1 % e 20 % não podem soar nem tremer igual.

### Regras rígidas
- Nada bloqueia o controle. Nem captura, nem morte, nem slow-mo (que é escala de tempo visual, nunca de leitura de input).
- Screen shake só em Break e Mega Seal, sempre escalado por configuração, podendo ser **zero**.
- Legibilidade acima de espetáculo: em conflito, o efeito perde.
- Silêncio existe — nem toda ação pede som.

### Implementação
- Pool obrigatório: nenhum `GPUParticles2D` instanciado durante a partida.
- Um material por tipo, com parâmetros por instância, para não quebrar o batching.
- Nenhum efeito lê o grid célula a célula na CPU.
- Toda redução de acessibilidade é aplicada em **um único ponto** (`AccessibilitySettings`), não espalhada por efeito.

### Áudio
- Música em 6 camadas com crossfade de 0,4 s **sincronizado ao compasso** — nunca cortando no meio da batida.
- SFX com 3–4 variações e randomização de ±3 % de tom; máximo 3 sons simultâneos do mesmo tipo, com prioridade.
- Mixagem validada **no alto-falante do celular**, não em fone de estúdio.

### Háptico
- Padrões por evento, três níveis (Off/Light/Full), nunca vibração contínua.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/09-game-feel/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/09-game-feel/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/09-game-feel/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/09-game-feel/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/09-game-feel/TESTS.md` — os testes que precisam existir
- `.gsd/phases/09-game-feel/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/09-game-feel/`
- `docs/design/game-feel.md`
- `docs/audio/audio-direction.md`
- `docs/art/vfx.md`
- `docs/ui/accessibility.md`

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

*Phase: 09-game-feel*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
