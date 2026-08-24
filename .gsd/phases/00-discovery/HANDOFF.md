# GSD 00 — Handoff

**Concluída em:** 2026-08-24
**Executada por:** sessão de planejamento inicial

## O que foi implementado

Nenhum código — por desenho. Foi construído o **Master Repository** e o **cérebro operacional**:

- Estrutura monorepo completa (`apps/`, `services/`, `packages/`, `assets/`, `tools/`,
  `tests/`, `docs/`, `.gsd/`, `.github/`)
- Arquivos-raiz: README, LICENSE (com seção própria para assets), CONTRIBUTING, CHANGELOG
  (formato Release Notes), CODE_OF_CONDUCT, SECURITY, `.editorconfig`, `.gitattributes`,
  `.gitignore`, `.env.example`
- **63 documentos** em `docs/`, cobrindo produto, design, gameplay, arquitetura, mobile, UI,
  arte, áudio, testes, performance, backend, deploy e diagramas
- **14 ADRs** aceitos
- Sistema GSD: `MASTER_PLAN`, `STATUS`, `DEPENDENCIES`, `DECISIONS`, `RISKS`, `QUALITY_GATES`,
  `BACKLOG`, `COMMANDS`, `GLOSSARY`
- **26 fases** planejadas, cada uma com 7 documentos e tarefas executáveis
- CI inicial e scripts de validação em `tools/`

## Decisões importantes

1. **Grid denso + flood fill do exterior** para território (ADR-0002) — determinismo e
   captura local; render em 1 draw call.
2. **Movimento em ângulo livre com taxa de giro** (ADR-0006) — fluidez mobile, com Arc
   rasterizado por traçado supercover.
3. **Auto-colisão dispara Backwash, não morte** (ADR-0007) — a lista de causas de morte é
   fechada, e o Arc reinicia na hora para não virar rota de fuga.
4. **Simulação 60 Hz fixa, render livre, interpolação manual** (ADR-0014) — determinismo é
   pré-requisito de teste, replay e servidor autoritativo.
5. **Servidor autoritativo em Godot headless** (ADR-0005) — a simulação de território precisa
   ser literalmente o mesmo código nos dois lados.
6. **IA por utilidade com perfis em dados** (ADR-0008) — personalidade e dificuldade viram
   `.tres`; nunca `enemySpeed *= 2`.
7. **Godot 4.3 pinado** (ADR-0001), com avaliação de upgrade agendada para a GSD 20.
8. Nome **VOLTA** como título de trabalho, com pendência jurídica registrada (RISK-012 / H-01).

## Arquivos criados

Todo o repositório. Destaques:
`README.md` · `docs/architecture/territory-system.md` · `docs/gameplay/rules.md` ·
`docs/design/balance.md` · `docs/decisions/ADR-0001..0014` · `.gsd/MASTER_PLAN.md` ·
`.gsd/phases/**` (26 × 7 documentos) · `tools/ci/*`

## Arquivos modificados

Nenhum — repositório novo.

## Testes adicionados

Nenhum teste de código. Verificações de consistência do plano em `TESTS.md`, algumas
automatizadas em `tools/ci/validate-repo.sh` e `tools/ci/check_links.sh`.

## Limitações conhecidas

- Números de balanceamento são alvos de design (🎯), não valores validados. Primeiro ajuste
  real na GSD 05, com o stress test.
- Fases 15–25 têm tarefas mais grossas que as fases 01–14; devem ser refinadas com
  `Plan GSD XX` antes da execução, à luz do que for aprendido.
- Nenhuma medição de performance existe: todo orçamento é alvo, não observação.
- Dependências externas (contas de loja, hospedagem, licença de fonte, marca) têm dono humano
  e ainda não foram resolvidas — nenhuma bloqueia até a GSD 15.

## Pré-requisitos para a próxima fase

Para executar a **GSD 01 — Repository Foundation**:

- [x] ADRs 0001–0014 aceitos
- [x] Estrutura do repositório criada
- [x] Convenções de código documentadas
- [x] Estratégia de testes definida
- [ ] Godot 4.3 stable instalado localmente com export templates
      *(a engine está disponível nesta máquina em `/Applications/Godot_CLI.app`; os export
      templates são verificados na tarefa `REPO-001`)*

## Comando recomendado

```text
Execute GSD 01
```
