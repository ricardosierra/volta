# Phase 17: Multiplayer Architecture - Context

**Gathered:** 2026-08-24
**Status:** Ready for planning

> **Este contexto foi pré-gravado no planejamento mestre, não numa conversa.** As decisões
> abaixo já estão fechadas e documentadas — o planner e o executor devem **segui-las**, não
> revisitá-las. Se algo parecer faltar, a resposta está nos documentos canônicos listados
> mais abaixo. Não invente decisão nova.

<domain>
## Phase Boundary

Provar com números se o multiplayer autoritativo é viável nesta arquitetura — entregando protótipo e relatório, **não** um recurso lançável

**Requisitos cobertos:** SRV-06

**Fora do escopo desta fase** (vai para a fase indicada ou para `.gsd/BACKLOG.md`):

- (ver o README da fase em `.gsd/`)

O escopo completo — o que entra e o que não entra — está em `.gsd/phases/17-multiplayer/README.md`.

</domain>

<decisions>
## Implementation Decisions

### O que esta fase entrega
- **Protótipo medido + relatório de viabilidade.** Não é um recurso lançável. Está fora do caminho crítico do release.
- Um relatório honesto dizendo "não vale a pena assim" é resultado **válido**, desde que fundamentado com números.

### Arquitetura (ADR-0005)
- Servidor autoritativo em **Godot headless rodando o mesmo código** de simulação. Reimplementar o `SealSolver` em outra linguagem seria garantir divergência no subsistema mais crítico.
- Cliente envia apenas **input** (~20 Hz); servidor simula a 60 Hz e envia snapshot delta (~15 Hz).
- **Proibido replicar `Node` do Godot pela rede.** Sincronizamos estado de simulação, que é determinístico por construção.

### Predição
- O cliente prediz **apenas o próprio Runner** e reconcilia; erro pequeno corrige suave, erro grande faz snap.
- **Território nunca é predito.** A animação de Seal começa otimista e reverte se o servidor negar — e a reversão precisa ser suave e rara.
- Outros Runners interpolados com buffer de ~100 ms, com extrapolação limitada em perda de pacote.

### Validação
- Teste de paridade com checksum do grid a cada 60 ticks: divergência de território é o pior bug possível aqui.
- Medir de verdade: 60/120/250/400 ms de latência, 0/2/5/10 % de perda, banda por cliente, partidas por vCPU.

### Claude's Discretion
Nomes internos de variáveis e métodos, organização de arquivos dentro da pasta já definida
pela arquitetura, ordem interna de implementação dentro de uma tarefa, e detalhes de teste
além dos exigidos. **Tudo o mais já está decidido** nos documentos canônicos.

</decisions>

<specifics>
## Specific Ideas

As tarefas desta fase já estão quebradas, numeradas e com passos em `.gsd/phases/17-multiplayer/TASKS.md`.
Cada tarefa traz objetivo, contexto, dependências, arquivos prováveis, passos de
implementação, testes e Definition of Done.

**Use aquele arquivo como fonte das tarefas do plano.** Não re-derive a decomposição.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Plano desta fase (ler primeiro, na ordem)
- `.gsd/phases/17-multiplayer/README.md` — escopo, e principalmente o que NÃO entra
- `.gsd/phases/17-multiplayer/TASKS.md` — as tarefas com passos e Definition of Done
- `.gsd/phases/17-multiplayer/ACCEPTANCE.md` — como se prova que ficou pronto
- `.gsd/phases/17-multiplayer/TESTS.md` — os testes que precisam existir
- `.gsd/phases/17-multiplayer/RISKS.md` — o que costuma dar errado aqui

### Especificação do produto
- `.gsd/phases/17-multiplayer/`
- `docs/architecture/networking.md` §3
- `docs/decisions/ADR-0005-networking.md`

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

*Phase: 17-multiplayer*
*Context gathered: 2026-08-24 (pré-gravado no planejamento mestre)*
