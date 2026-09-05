# VOLTA — regras do repositório

> Jogo mobile arcade de conquista territorial. Godot 4.3 + GDScript tipado.
> **Este arquivo tem prioridade sobre qualquer suposição sua.** Em caso de dúvida entre o que
> você acha e o que está escrito aqui ou em `docs/`, o documento vence.

---

## 1. A regra mais importante

> **Este projeto já foi planejado por inteiro. Você está EXECUTANDO, não projetando.**

Antes de escrever código para a fase N, leia **nesta ordem**:

1. `.gsd/phases/NN-*/README.md` — o que entra e, principalmente, **o que NÃO entra**
2. `.gsd/phases/NN-*/TASKS.md` — as tarefas, com passos e Definition of Done
3. `.gsd/phases/NN-*/ACCEPTANCE.md` — como se prova que ficou pronto
4. `.gsd/phases/NN-*/TESTS.md` — os testes que precisam existir

Se a tarefa cita um documento (`docs/...`), **leia o documento**. Ele existe porque a decisão
já foi tomada. Não reinvente.

**Nunca:**
- decida arquitetura por conta própria quando já existe um ADR em `docs/decisions/`;
- implemente algo de uma fase futura "já que estou aqui" — vai para `.gsd/BACKLOG.md`;
- reduza o escopo da fase silenciosamente. Se algo não deu, escreva isso no SUMMARY.

## 1.1 Dois diretórios, um plano

| Diretório | O que é | Precedência |
|---|---|---|
| `.gsd/` | **O plano.** 26 fases × 7 documentos, ADRs, riscos, quality gates, backlog | **autoritativo** |
| `.planning/` | A interface que os comandos `/gsd:*` leem e escrevem | projeção |
| `docs/` | A especificação do produto (regras, números, arquitetura) | **autoritativo** |

Discordância entre eles = bug na projeção. **Corrija `.planning/`, nunca `docs/` ou `.gsd/`**,
a menos que a decisão tenha mudado de verdade — e aí atualize os três no mesmo PR.

## 2. Onde as respostas moram

| Pergunta | Arquivo |
|---|---|
| Qual é a regra do jogo? | `docs/gameplay/rules.md` (regras numeradas: R4.2, R6.3…) |
| Qual é o número? | `docs/design/balance.md` — **o único lugar com números** |
| Por que essa decisão? | `docs/decisions/ADR-0001..0014` |
| Como o território funciona? | `docs/architecture/territory-system.md` |
| Onde este arquivo mora? | `docs/architecture/overview.md` §8 |
| Qual é o orçamento de performance? | `docs/performance/performance-budget.md` |
| Como a UI se comporta? | `docs/ui/design-system.md` |
| O que a fase exige? | `.gsd/phases/NN-*/` |

## 3. Regras de código (verificadas por máquina)

```text
1. GDScript com TIPAGEM ESTÁTICA em parâmetro, retorno e membro. Sem exceção.
2. Um tipo por arquivo. Arquivo em snake_case.gd, class_name em PascalCase.
3. PROIBIDO criar: utils.gd, helpers.gd, manager.gd, global.gd, misc.gd, common.gd
4. PROIBIDO número de gameplay no código. Vai para .tres em packages/shared/config/
5. PROIBIDO que territory/, runner/, ai/ e gameplay/ importem presentation/ ou ui/
6. TODO só no formato: # TODO(GSD-15/API-003): descrição
7. Mock precisa de bloco "## MOCK" com "Replacement Phase:" e "Replacement Task:"
8. Placeholder de arte precisa de "PLACEHOLDER-ART-NNN" + "Replacement: GSD XX"
9. Arquivo acima de 600 linhas é bloqueio. Função acima de 50 linhas, idem.
10. Nada de await no caminho de simulação (quebra o determinismo).
```

Rode antes de terminar qualquer tarefa:

```bash
./tools/ci/validate-repo.sh    # sempre — as 10 regras acima
./tools/ci/lint.sh             # a partir da GSD 01
./tools/ci/test-client.sh      # a partir da GSD 01
```

Se `validate-repo.sh` falhar, **conserte antes de continuar**. Ele não dá falso positivo.

## 4. Arquitetura em uma frase

> A **simulação** (`territory/`, `runner/`, `ai/`, `gameplay/`) roda sem nenhum nó visual, a
> 60 Hz fixo, de forma determinística. A **apresentação** (`presentation/`, `ui/`) só lê.

Isso é o que permite testar o jogo com 500 partidas headless. Quebrar isso quebra o projeto.

## 5. Git

- Commits semânticos: `feat(territory): implement incremental flood fill seal`
- Escopos: `gameplay territory runner ai arena camera audio vfx ui input progression save analytics net config android ios api gsd tools`
- **Nunca** adicione `Co-Authored-By` de IA.
- Uma fase = um branch `feature/gsd-NN-nome`.

### 5.1 Commit com índice compartilhado (obrigatório)

Planos da mesma fase executam **em paralelo na mesma árvore de trabalho**, e o índice do git é
um só. `git add` seguido de `git commit` sem pathspec **varre para dentro do seu commit os
arquivos que outro plano deixou staged** — aconteceu de verdade em quatro planos da Fase 26.1.

```bash
# CERTO — compara working-tree contra HEAD só no caminho dado, ignora o resto do índice
git commit -m "feat(runner): ..." -- apps/mobile/src/runner/runner.gd apps/mobile/src/runner/runner.gd.uid

# ERRADO — leva junto o que não é seu
git add . && git commit -m "..."
git add <arquivo> && git commit -m "..."
```

- Sempre inclua o `.uid` junto do `.gd`/`.tres` no mesmo pathspec.
- Confira com `git diff --cached --name-status` antes de commitar se precisou usar `git add`.
- Para desfazer staging alheio: `git restore --staged <path>`. Nunca `HEAD^` num reset
  (é relativo e outro plano pode ter commitado no meio) — use o hash fixo.

## 6. Versionamento

Começa em `v0.1.0`. `v1.0.0` é reservado para produção madura — **não** é o primeiro release.
CHANGELOG segue o formato **Release Notes** deste repositório (`### ✨ Novidades`,
`### 🎨 Melhorias`, `### 🐛 Correções`, `### 🔧 Técnico`, itens em `- [x]`).
Nunca use Keep-a-Changelog.

## 7. Quando parar e perguntar

Pergunte ao humano **apenas** para: custo, credencial, jurídico, publicação em loja, ou
decisão irreversível relevante. Todo o resto já está decidido nos documentos — se você acha
que falta uma decisão, procure primeiro em `docs/decisions/` e `.gsd/DECISIONS.md`.

## 8. Definition of Done (toda tarefa)

```text
[ ] código existe    [ ] funciona    [ ] testado    [ ] edge cases considerados
[ ] doc atualizada   [ ] sem TODO sem tarefa       [ ] sem regressão
[ ] respeita a arquitetura           [ ] funciona no jogo real
```

Fase só fecha com o quality gate de `.gsd/QUALITY_GATES.md` inteiro marcado — **verificado,
não presumido**.

## Regra de Ouro da GSD (Anti-Burla)
11. **Nunca burle o planejamento ou a execução da GSD.** Você não deve jamais gerar "stubs" vazios, classes contendo apenas `pass` ou funções não-implementadas com a intenção de fingir que uma fase foi concluída. Cada passo da GSD exige código real, testável e robusto. Arquivos de configuração, ferramentas, shaders e lógicas internas devem ser programados por completo antes de avançar o tracker.
