# Como rodar o projeto com GSD

> Este repositório foi preparado para ser **executado por um agente**, incluindo modelos mais
> fracos. O plano inteiro já existe; a execução não deve tomar decisões de arquitetura.

## Começar

```bash
cd ~/Dev/Jogos/volta
claude                      # (opcional) /model sonnet
```

```text
/gsd:autonomous             executa todas as fases restantes: plan → execute por fase
```

Ou, com controle fase a fase (recomendado nas 3 primeiras, para calibrar):

```text
/gsd:plan-phase 1           gera os planos da fase 1
/gsd:execute-phase 1        executa os planos da fase 1
/gsd:progress               mostra onde está e o que vem depois
```

## O que já está preparado

| Item | Estado | Por que importa num modelo fraco |
|---|---|---|
| `.planning/ROADMAP.md` | 25 fases com **Success Criteria verificáveis** | o agente não precisa inventar o que é "pronto" |
| `.planning/phases/*/NN-CONTEXT.md` | **pré-preenchido** para as 25 fases | pula a etapa de discussão; nenhuma decisão fica em aberto |
| `.gsd/phases/*/TASKS.md` | 245 tarefas com passos e DoD | o planner copia a decomposição em vez de derivar |
| `CLAUDE.md` | 10 regras + mapa de onde as respostas moram | corta a deriva logo no começo |
| `tools/ci/validate-repo.sh` | 8 regras verificadas por máquina | erro vira falha de script, não julgamento |
| `.claude/settings.json` | allowlist dos comandos usados | menos interrupção por permissão |
| `.planning/config.json` | `mode: yolo`, gates desligados, `model_profile: budget` | roda sem parar a cada passo |

## Perfil de modelo

`.planning/config.json` está em `"model_profile": "budget"` — **todos** os subagentes usam
Sonnet, independentemente do modelo da sessão. É o ajuste previsível para rodar barato.

```text
/gsd:set-profile budget     sonnet em todos os agentes  (padrão aqui)
/gsd:set-profile inherit    todos seguem o modelo da sessão
/gsd:set-profile balanced   opus no planner, sonnet no resto
/gsd:set-profile quality    opus onde faz diferença
```

Se você rodar a sessão em Haiku, prefira `budget` a `inherit` — o planner é o ponto onde um
modelo fraco custa mais caro depois.

Verificações mantidas ligadas de propósito (`plan_check`, `verifier`, `nyquist_validation`):
elas são baratas e são justamente a rede de segurança de um modelo fraco. `research` está
desligado porque a pesquisa já está feita e vive em `docs/`.

## A ordem certa das fases

Execute na ordem. A fase **3 (Territory Engine)** é o gargalo técnico: 14 tarefas, 30 casos de
mesa e 15 benchmarks. Se ela sair errada, todas as fases seguintes pagam a conta. Vale rodar
essa fase com um modelo mais forte, ou pelo menos revisar o resultado dela com cuidado.

Marcos: **MVP** na fase 6 · **Alpha** na 14 · **Beta** na 20 · **Release v0.1.0** na 24.

## Se algo sair do trilho

```text
/gsd:progress               onde estou
/gsd:health                 integridade do .planning/
/gsd:resume-work            retomar depois de um reset de contexto
/gsd:debug                  investigação sistemática de bug
```

E, fora do GSD:

```bash
./tools/ci/validate-repo.sh   # as regras do repositório
./tools/dev/doctor.sh         # o ambiente
```

## Antes de começar, o humano precisa

- [ ] Godot **4.3 stable** instalado com os **export templates** da mesma versão
- [ ] Um aparelho Android intermediário real (a fase 2 mede latência de input nele)
- [ ] `git` configurado

As demais pendências humanas (contas de loja, hospedagem, marca, licença de fonte) só
aparecem a partir da fase 15 e estão listadas em `.gsd/DEPENDENCIES.md`.
