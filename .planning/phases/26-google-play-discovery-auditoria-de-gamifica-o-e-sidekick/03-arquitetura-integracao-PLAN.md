---
phase: 26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick
plan: 3
type: execute
wave: 2
depends_on: ["01-inventario-existente-PLAN", "02-requisitos-google-PLAN"]
files_modified:
  - docs/google-play/architecture.md
  - docs/google-play/compatibility-audit.md
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "A arquitetura Gameplay → Domain Events → Gamification Engine → Integração Google foi validada contra o Event Bus e as camadas reais descritas em docs/architecture/overview.md, sem violar a regra de dependência entre camadas do projeto"
    - "Cada fase de 27 a 38 tem um mapeamento explícito de qual superfície Google e qual sistema existente ela consome"
    - "Existe um parecer go/no-go explícito, fundamentado no registro de riscos consolidado da auditoria e dos requisitos oficiais pesquisados"
  artifacts:
    - path: "docs/google-play/architecture.md"
      provides: "Arquitetura de integração validada (pipeline, compatibilidade de camadas, tabela de eventos de domínio, feature flags/fila offline, mapeamento fase-a-fase 27-38)"
      min_lines: 100
    - path: "docs/google-play/compatibility-audit.md"
      provides: "Seções 7 (registro de riscos consolidado) e 8 (parecer go/no-go) anexadas ao documento do Plano 01"
  key_links:
    - from: "docs/google-play/architecture.md"
      to: "docs/google-play/compatibility-audit.md"
      via: "referência cruzada aos sistemas e riscos já auditados"
      pattern: "compatibility-audit\\.md"
    - from: "docs/google-play/architecture.md"
      to: "docs/google-play/current-requirements.md"
      via: "validação da arquitetura contra requisitos oficiais pesquisados"
      pattern: "current-requirements\\.md"
    - from: "docs/google-play/architecture.md"
      to: "apps/mobile/src/core/event_bus.gd"
      via: "validação de compatibilidade de camadas contra o Event Bus real"
      pattern: "event_bus\\.gd"
---

<objective>
Com a auditoria do estado atual (Plano 01) e os requisitos oficiais pesquisados (Plano 02)
prontos, desenhar e VALIDAR a arquitetura de integração Gameplay → Domain Events →
Gamification Engine → Integração Google contra o código real do projeto, produzir o
mapeamento fase-a-fase (Fases 27-38) e consolidar o registro final de riscos + parecer go/no-go
em `docs/google-play/compatibility-audit.md`.

Purpose: esta é a última peça do Success Criterion 3 do ROADMAP da Fase 26 ("a arquitetura de
integração foi validada e documentada para este projeto") e fecha o gate de discovery antes que
a Fase 27 (Gamification Foundation) comece a escrever código.

Output: `docs/google-play/architecture.md` (novo) e as seções 7-8 anexadas a
`docs/google-play/compatibility-audit.md`.

RESTRIÇÃO CRÍTICA: este plano só pode criar/modificar os dois arquivos acima, ambos sob
`docs/google-play/`. Nenhum arquivo em `apps/`, `packages/`, `services/` ou `tools/` pode ser
tocado.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick/26-CONTEXT.md
@.planning/ROADMAP.md
@docs/architecture/overview.md
@docs/google-play/compatibility-audit.md
@docs/google-play/current-requirements.md
</context>

<interfaces>
Sinais reais já existentes no EventBus (apps/mobile/src/core/event_bus.gd) — a arquitetura
proposta deve ESTENDER este padrão, não substituí-lo nem contorná-lo:

    class_name EventBus
    extends Node
    signal config_loaded()
    signal config_load_failed(reason: String)
    signal save_loaded(result: int)
    signal save_written()
    const MAX_EMISSIONS_PER_SECOND: int = 5

Regra de camadas (docs/architecture/overview.md §1): `territory/`, `runner/`, `ai/` e
`gameplay/` são simulação pura e nunca importam `presentation/` ou `ui/`. Por extensão direta
dessa regra: nenhum SDK ou código de integração Google pode ser importado por `territory/`,
`runner/`, `ai/` — apenas `gameplay/` pode EMITIR eventos de domínio (via EventBus, nunca por
chamada direta a um SDK Google), e quem CONSOME esses eventos para falar com o Google vive em
`platform/` (ou um novo módulo de mesmo nível, nunca abaixo de `core/`).
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Desenhar e validar a arquitetura de integração (Gameplay → Domain Events → Gamification Engine → Google)</name>
  <files>docs/google-play/architecture.md</files>
  <read_first>
    - docs/google-play/compatibility-audit.md
    - docs/google-play/current-requirements.md
    - docs/architecture/overview.md
    - apps/mobile/src/core/event_bus.gd
    - apps/mobile/src/core/events/README.md
    - apps/mobile/src/gameplay/match_director.gd
    - apps/mobile/src/gameplay/elimination_service.gd
    - apps/mobile/src/gameplay/score/score_service.gd
    - apps/mobile/src/progression/xp_service.gd
    - apps/mobile/src/progression/achievements/achievement_service.gd
    - apps/mobile/src/progression/challenges/challenge_service.gd
    - apps/mobile/src/platform/api/offline_queue.gd
    - .planning/ROADMAP.md (seções "### Phase 27" até "### Phase 38")
  </read_first>
  <action>
    Crie `docs/google-play/architecture.md` (arquivo novo, primeira linha H1) com exatamente
    estes cabeçalhos:

    # Arquitetura de Integração — Google Play Games (VOLTA)
    ## 1. Visão Geral do Pipeline
    ## 2. Compatibilidade com a Arquitetura Existente
    ## 3. Eventos de Domínio Necessários
    ## 4. Feature Flags e Fila Offline
    ## 5. Mapeamento de Fases (27-38)

    - Seção 1: descreva as 4 camadas do pipeline Gameplay → Domain Events → Gamification Engine
      → Integração Google, dizendo ONDE cada uma vive na estrutura de pastas real
      (`gameplay/` emite; um conjunto novo de payloads tipados em `core/events/` carrega os
      dados, seguindo o padrão já anotado no README daquele diretório; um Gamification Engine
      novo — extensão de `progression/` e/ou novo módulo — consome os eventos e decide regras
      de XP/conquistas/quests; `platform/` hospeda o adaptador de integração Google). Cite
      explicitamente que gameplay/ NUNCA importa o SDK do Google diretamente — só emite eventos.
    - Seção 2: parágrafo de validação explícita confirmando que o desenho NÃO viola a regra de
      camadas de `docs/architecture/overview.md` §1, e que o `EventBus` atual (citando os 4
      sinais reais por nome) é o padrão a estender — não substituir — para os novos eventos de
      domínio. Mencione o limite de 5 emissões/seg em debug e como eventos de fim de partida
      (baixa frequência) respeitam esse limite.
    - Seção 3: tabela markdown com colunas EXATAS
      `| Evento | Payload | Emissor | Consumidores | Fase que implementa |`
      com no mínimo 8 linhas, cobrindo pelo menos: MatchStarted, MatchEnded, SealCompleted,
      RunnerEliminated, AchievementProgressed, LevelUp, DailyChallengeCompleted,
      PowerUpCollected — cruzando "Emissor" com arquivos reais já auditados (ex.:
      match_director.gd, elimination_service.gd, achievement_service.gd, xp_service.gd) e "Fase
      que implementa" com fases do ROADMAP (27 a 33 majoritariamente).
    - Seção 4: descreva a convenção de nome de feature flag (ex.: `google_play_sidekick`,
      `game_stats`, alinhado ao texto do Success Criterion 3 da Fase 27 no ROADMAP), e o desenho
      da fila offline `pending_game_events`, reaproveitando explicitamente o padrão já existente
      em `apps/mobile/src/platform/api/offline_queue.gd` (citar o arquivo pelo nome).
    - Seção 5: tabela markdown com colunas EXATAS
      `| Fase | Superfície Google | Sistema Existente Reaproveitado | Novo Componente Necessário |`
      com EXATAMENTE 12 linhas de dados, uma para cada fase 27 a 38 (nessa ordem), derivadas dos
      goals de `.planning/ROADMAP.md`.

    Não toque em nenhum arquivo fora de docs/google-play/.
  </action>
  <acceptance_criteria>
    - test -f docs/google-play/architecture.md
    - primeira linha do arquivo casa com o padrão '^# '
    - grep -q '## 5. Mapeamento de Fases (27-38)' docs/google-play/architecture.md
    - grep -q '| Fase | Superfície Google | Sistema Existente Reaproveitado | Novo Componente Necessário |' docs/google-play/architecture.md
    - contagem de linhas de tabela (`grep -c '^| '`) no arquivo é >= 21 (>= 9 da tabela de eventos + >= 13 da tabela de fases, cabeçalhos incluídos)
    - grep -q 'event_bus.gd' docs/google-play/architecture.md
    - grep -q 'pending_game_events' docs/google-play/architecture.md
    - grep -q 'offline_queue.gd' docs/google-play/architecture.md
  </acceptance_criteria>
  <verify>
    <automated>test -f docs/google-play/architecture.md && grep -q "## 5. Mapeamento de Fases (27-38)" docs/google-play/architecture.md && grep -q "event_bus.gd" docs/google-play/architecture.md && grep -q "pending_game_events" docs/google-play/architecture.md && [ "$(grep -c '^| ' docs/google-play/architecture.md)" -ge 21 ] && ./tools/ci/lint_docs.sh</automated>
  </verify>
  <done>docs/google-play/architecture.md existe com as 5 seções, a tabela de eventos de domínio (>=8 linhas de dados) e a tabela de mapeamento de fases (exatamente 12 linhas, Fases 27-38), validada explicitamente contra o EventBus real e a regra de camadas do projeto.</done>
</task>

<task type="auto">
  <name>Task 2: Consolidar registro de riscos e parecer go/no-go</name>
  <files>docs/google-play/compatibility-audit.md</files>
  <read_first>
    - docs/google-play/compatibility-audit.md (seções 1-6, escritas pelo Plano 01 — não sobrescrever)
    - docs/google-play/current-requirements.md
    - docs/google-play/architecture.md (recém-criado pela Task 1 deste plano)
    - .planning/STATE.md (seção Blockers/Concerns — decisões humanas H-01/H-02 já registradas)
  </read_first>
  <action>
    Anexe ao final de docs/google-play/compatibility-audit.md as seções exatas:

    ## 7. Registro de Riscos Consolidado
    ## 8. Parecer Go/No-Go

    - Seção 7: tabela markdown com colunas EXATAS
      `| Risco | Origem | Impacto | Probabilidade | Mitigação | Fase Responsável |`
      com no mínimo 8 linhas, consolidando: os riscos preliminares da seção 6 (Plano 01), riscos
      extraídos da seção "14. Resumo de Disponibilidade" de current-requirements.md (ex.:
      qualquer superfície marcada como Beta/Invite-only/Regional/Não confirmado vira risco aqui,
      com a coluna "Origem" = "current-requirements.md §14"), e riscos arquiteturais identificados
      na Task 1 deste plano (ex.: extensão do EventBus sem violar o limite de 5 emissões/seg em
      debug — coluna "Origem" = "architecture.md §2"). Cada linha da coluna "Origem" deve
      apontar para um dos três documentos (compatibility-audit.md §6, current-requirements.md
      §14 ou architecture.md).
    - Seção 8: parágrafo de decisão explícita — "Prosseguir com a integração faseada (Fases
      27-38)" OU uma condição contrária fundamentada — citando: (a) bloqueadores nomeados, se
      existirem, com a superfície Google e a fase afetada; (b) dependências humanas já
      conhecidas no projeto (ex.: contas Google Play/Apple Developer = decisão H-02 em
      `.planning/STATE.md`) que não bloqueiam a Fase 27 mas bloqueiam fases de publicação
      (34/38); (c) uma frase de fechamento explícita contendo a palavra "Go" ou "No-Go".

    Ao final, rode `git status --porcelain -- apps packages services tools .github` e confirme
    saída vazia.
  </action>
  <acceptance_criteria>
    - grep -q '## 7. Registro de Riscos Consolidado' docs/google-play/compatibility-audit.md
    - grep -q '## 8. Parecer Go/No-Go' docs/google-play/compatibility-audit.md
    - grep -q '| Risco | Origem | Impacto | Probabilidade | Mitigação | Fase Responsável |' docs/google-play/compatibility-audit.md
    - contagem de linhas de tabela na seção 7 (`grep -c '^| '` no arquivo inteiro, cumulativo) é >= 22 (soma das tabelas das seções 3, 5, 6 do Plano 01 mais a nova da seção 7)
    - grep -qiE 'Go\b|No-Go' docs/google-play/compatibility-audit.md
    - `git status --porcelain -- apps packages services tools .github` retorna vazio
    - `git diff --name-only origin/master...HEAD | grep -v '^docs/' | grep -v '^\.planning/'` retorna vazio
  </acceptance_criteria>
  <verify>
    <automated>grep -q "## 8. Parecer Go/No-Go" docs/google-play/compatibility-audit.md && grep -qiE "Go\b|No-Go" docs/google-play/compatibility-audit.md && ./tools/ci/lint_docs.sh && [ -z "$(git status --porcelain -- apps packages services tools .github)" ] && [ -z "$(git diff --name-only origin/master...HEAD | grep -v '^docs/' | grep -v '^\.planning/')" ]</automated>
  </verify>
  <done>Seções 7 e 8 anexadas a compatibility-audit.md com registro de riscos consolidado (>= 8 linhas, três origens citadas) e parecer go/no-go explícito; confirmado por git que nenhum arquivo de produção foi tocado durante toda a Fase 26.</done>
</task>

</tasks>

<verification>
- `test -f docs/google-play/architecture.md`
- `grep -c '^## ' docs/google-play/architecture.md` retorna 5
- `grep -q '## 8. Parecer Go/No-Go' docs/google-play/compatibility-audit.md`
- `grep -c '^## ' docs/google-play/compatibility-audit.md` retorna 8 (seções 1 a 8 completas)
- `./tools/ci/lint_docs.sh` passa
- `git diff --name-only origin/master...HEAD | grep -v '^docs/' | grep -v '^\.planning/'` retorna vazio (Success Criterion 4 do ROADMAP para a Fase 26 inteira)
</verification>

<success_criteria>
`docs/google-play/architecture.md` existe, validado contra o EventBus e as camadas reais do
projeto, com tabela de eventos de domínio e mapeamento completo das 12 fases (27-38).
`docs/google-play/compatibility-audit.md` está completo (seções 1-8), incluindo registro de
riscos consolidado e parecer go/no-go explícito. Os três Success Criteria documentais do
ROADMAP da Fase 26 estão satisfeitos, e nenhuma linha de código de produção foi alterada em
nenhum dos três planos da fase.
</success_criteria>

<output>
Após completar, crie `.planning/phases/26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick/26-03-SUMMARY.md`
seguindo o template de summary.md, registrando a decisão go/no-go e quaisquer bloqueadores
nomeados para as Fases 27-38.
</output>
