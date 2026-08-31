---
phase: 26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick
plan: 1
type: execute
wave: 1
depends_on: []
files_modified:
  - docs/google-play/compatibility-audit.md
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "O estado atual do projeto (engine, camadas, Event Bus, loop de partida, gamificação já existente das fases 10/11/14/18, backend, Android e Google Play) está documentado com precisão, citando arquivos reais, antes de qualquer mudança de código de produção"
    - "Sistemas reaproveitáveis para a integração Google e o débito técnico relevante estão identificados com referência a caminhos de arquivo reais, não a descrições genéricas"
  artifacts:
    - path: "docs/google-play/compatibility-audit.md"
      provides: "Auditoria de compatibilidade: estado atual, inventário de sistemas, ativos reaproveitáveis, débito técnico e riscos preliminares (seções 1 a 6)"
      min_lines: 150
  key_links:
    - from: "docs/google-play/compatibility-audit.md"
      to: "apps/mobile/src/core/event_bus.gd"
      via: "referência textual ao Event Bus real durante a auditoria da seção 1.2"
      pattern: "event_bus\\.gd"
    - from: "docs/google-play/compatibility-audit.md"
      to: "apps/mobile/src/progression/achievements/achievement_service.gd"
      via: "mapeamento de sistema reaproveitável na tabela da seção 3"
      pattern: "achievement_service\\.gd"
---

<objective>
Auditar o estado ATUAL do repositório - arquitetura de cliente, Event Bus, loop de partida,
gamificação já implementada (Fases 10 Progression, 11 Cosmetics, 14 Power-ups, 18 Analytics),
backend/rede e setup Android/Google Play - e registrar tudo em
`docs/google-play/compatibility-audit.md`. Esta é a Fase 0 (Discovery) descrita em
`26-CONTEXT.md`: "Antes de modificar qualquer código: leia todo o repositório, entenda a
arquitetura, identifique o que já existe e o que pode ser reaproveitado, identifique conflitos
e débito técnico. Somente depois comece a implementação."

Purpose: as Fases 27-38 (Gamification Foundation até Release) vão construir sobre sistemas que
já existem (progression/, platform/analytics/, EventBus, leaderboards locais/remotos). Sem
este inventário fiel, essas fases arriscam recriar sistemas paralelos - proibido por
`26-CONTEXT.md` ("NÃO crie sistemas paralelos desnecessariamente").

Output: `docs/google-play/compatibility-audit.md` com as seções 1 a 6 completas (as seções 7 e
8 - registro de riscos consolidado e parecer go/no-go - são anexadas pelo Plano 03, depois que
os requisitos oficiais do Plano 02 estiverem disponíveis).

RESTRIÇÃO CRÍTICA: este plano só pode criar/modificar `docs/google-play/compatibility-audit.md`.
Nenhum arquivo em `apps/`, `packages/`, `services/` ou `tools/` pode ser tocado - esta é uma
fase de auditoria, não de implementação.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick/26-CONTEXT.md
@docs/architecture/overview.md
</context>

<interfaces>
Sinais reais já existentes no EventBus - usar exatamente estes nomes na seção 1.2, não
inventar nem generalizar. Extraído de apps/mobile/src/core/event_bus.gd:

    class_name EventBus
    extends Node
    ## Eventos globais de baixa frequência, desacoplados. PROIBIDO emitir por frame.
    signal config_loaded()
    signal config_load_failed(reason: String)
    signal save_loaded(result: int)
    signal save_written()

    const MAX_EMISSIONS_PER_SECOND: int = 5

Não existe hoje nenhum evento de domínio de gameplay (match_started, seal_completed,
achievement_unlocked, etc.) - apps/mobile/src/core/events/README.md confirma que payloads
tipados "entram aqui conforme necessário" e ainda não foram criados. Este é o gap central que
a Fase 27 (Gamification Foundation) precisa fechar, e que este plano deve documentar como fato,
não como suposição.
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Auditar arquitetura do cliente, Event Bus e loop de partida</name>
  <files>docs/google-play/compatibility-audit.md</files>
  <read_first>
    - docs/architecture/overview.md
    - apps/mobile/src/core/event_bus.gd
    - apps/mobile/src/core/events/README.md
    - apps/mobile/src/core/bootstrap.gd
    - apps/mobile/src/core/service_registry.gd
    - apps/mobile/src/gameplay/match_director.gd
    - apps/mobile/src/gameplay/game_state.gd
    - apps/mobile/src/gameplay/states/ (todos os *_state.gd)
    - apps/mobile/src/gameplay/score/score_service.gd
    - apps/mobile/src/gameplay/score/surge_service.gd
    - apps/mobile/src/gameplay/modes/match_rules.gd
    - apps/mobile/src/gameplay/powerups/power_up_service.gd
    - apps/mobile/src/gameplay/elimination_service.gd
  </read_first>
  <action>
    Crie `docs/google-play/compatibility-audit.md` (arquivo novo). A primeira linha não-vazia
    deve ser um título H1 (`# ...`) - `tools/ci/lint_docs.sh` reprova qualquer doc sem isso.
    Use exatamente estes cabeçalhos (nível de heading incluído), preenchidos com informação
    REAL extraída do código lido acima, nunca genérica ou inventada:

    # Auditoria de Compatibilidade — Google Play Games (VOLTA)
    ## 1. Estado Atual do Projeto
    ### 1.1 Engine e Build
    ### 1.2 Event Bus Atual
    ### 1.3 Loop de Partida e Gameplay

    - 1.1: versão do Godot e renderer (ver docs/architecture/overview.md e
      apps/mobile/project.godot), estrutura de camadas (core/ gameplay/ territory/ runner/
      ai/ arena/ input/ presentation/ ui/ progression/ platform/), a regra de dependência
      (camada só depende de camada abaixo) e a proibição de await no caminho de simulação -
      isso importa porque toda integração Google (I/O de rede/SDK) é inerentemente assíncrona e
      NUNCA pode entrar em territory/, runner/, ai/ ou gameplay/.
    - 1.2: liste os 4 sinais reais do EventBus (config_loaded, config_load_failed,
      save_loaded, save_written), o limite de 5 emissões/seg em debug
      (MAX_EMISSIONS_PER_SECOND), e declare explicitamente que nenhum evento de domínio de
      gameplay existe hoje (nada como match_started, seal_completed,
      achievement_unlocked) - cite apps/mobile/src/core/events/README.md como prova.
    - 1.3: descreva match_director.gd (dono do tick e das condições de fim),
      game_state.gd + states/*.gd (FSM Boot→Menu→Loading→Countdown→Playing→Paused→Results),
      score/score_service.gd + surge_service.gd (fórmula de score e Surge), modes/match_rules.gd
      (modos como dado), powerups/power_up_service.gd e elimination_service.gd.

    Não toque em nenhum arquivo fora de docs/google-play/.
  </action>
  <acceptance_criteria>
    - test -f docs/google-play/compatibility-audit.md
    - primeira linha do arquivo casa com o padrão '^# '
    - grep -q '### 1.2 Event Bus Atual' docs/google-play/compatibility-audit.md
    - grep -q 'config_loaded' docs/google-play/compatibility-audit.md (prova que os sinais reais foram inventariados, não inventados)
    - grep -q 'match_director.gd' docs/google-play/compatibility-audit.md
    - grep -qi 'nenhum evento de domínio\|não existe.*evento de domínio\|ainda não foram criados' docs/google-play/compatibility-audit.md (a lacuna precisa estar registrada como fato)
  </acceptance_criteria>
  <verify>
    <automated>test -f docs/google-play/compatibility-audit.md && grep -q "### 1.3 Loop de Partida e Gameplay" docs/google-play/compatibility-audit.md && grep -q "config_loaded" docs/google-play/compatibility-audit.md && grep -q "match_director.gd" docs/google-play/compatibility-audit.md && ./tools/ci/lint_docs.sh</automated>
  </verify>
  <done>docs/google-play/compatibility-audit.md existe com as seções 1, 1.1, 1.2 e 1.3 preenchidas com informação real extraída do código (sinais do EventBus citados por nome, arquivos de gameplay citados por nome), e nenhum arquivo fora de docs/google-play/ foi alterado.</done>
</task>

<task type="auto">
  <name>Task 2: Auditar gamificação já existente (Fases 10/11/14/18) e mapear ativos reaproveitáveis</name>
  <files>docs/google-play/compatibility-audit.md</files>
  <read_first>
    - apps/mobile/src/progression/profile.gd
    - apps/mobile/src/progression/xp_service.gd
    - apps/mobile/src/progression/wallet.gd
    - apps/mobile/src/progression/stats_service.gd
    - apps/mobile/src/progression/season_service.gd
    - apps/mobile/src/progression/achievements/achievement_service.gd
    - apps/mobile/src/progression/challenges/challenge_service.gd
    - apps/mobile/src/progression/cosmetics/catalog.gd
    - apps/mobile/src/progression/cosmetics/unlock_service.gd
    - apps/mobile/src/progression/leaderboard/leaderboard_repository.gd
    - apps/mobile/src/progression/leaderboard/local_leaderboard_repository.gd
    - apps/mobile/src/progression/leaderboard/remote_leaderboard_repository.gd
    - apps/mobile/src/progression/cloud_save_service.gd
    - apps/mobile/src/progression/profile_repository.gd
    - apps/mobile/src/platform/analytics/analytics_service.gd
    - apps/mobile/src/platform/analytics/remote_analytics.gd
    - apps/mobile/src/platform/analytics/noop_analytics.gd
    - apps/mobile/src/platform/api/api_client.gd
    - apps/mobile/src/platform/api/offline_queue.gd
    - apps/mobile/src/network/network_transport.gd
    - apps/mobile/src/gameplay/analytics_bridge.gd
    - docs/design/progression.md
    - docs/design/economy.md
    - docs/product/analytics-plan.md
    - docs/backend/api-design.md
  </read_first>
  <action>
    Anexe ao final de docs/google-play/compatibility-audit.md (não sobrescreva a Task 1) as
    seções exatas:

    ## 2. Gamificação Já Existente (Fases 10, 11, 14, 18)
    ### 2.1 Progressão (Perfil, XP, Stats, Season)
    ### 2.2 Conquistas e Desafios
    ### 2.3 Cosméticos e Carteira (Wallet)
    ### 2.4 Leaderboards e Cloud Save
    ### 2.5 Analytics, API e Fila Offline
    ## 3. Ativos Reaproveitáveis para a Integração Google

    Para 2.1-2.5: resuma responsabilidade real de cada arquivo lido (não invente campos que não
    existem no código). Para 2.4, deixe explícito que já existem repositórios Local* e Remote*
    (padrão de troca sem afetar gameplay, ver docs/architecture/networking.md se necessário) -
    isso é relevante porque Play Games Leaderboards e Saved Games seguirão o mesmo padrão de
    repositório.

    Para a seção 3, crie uma tabela markdown com EXATAMENTE estas colunas (cabeçalho literal):

    | Sistema existente | Arquivo | Reaproveitável para | Observação |

    Inclua no mínimo 6 linhas de dados, cobrindo obrigatoriamente:
    - achievement_service.gd → sincronização de Play Games Achievements (Fase 29)
    - xp_service.gd / stats_service.gd → Progression Stat / Repetitive Stats de Game Stats (Fase 30)
    - leaderboard/* (local + remote) → Play Games Leaderboards (Fase 32)
    - cloud_save_service.gd → Saved Games API (referenciar a fase que a consome, conforme
      docs/google-play/current-requirements.md quando existir; se ainda não existir no momento
      desta tarefa, apenas anote "confirmar contra current-requirements.md no Plano 03")
    - offline_queue.gd → padrão de fila para pending_game_events (Fase 27)
    - analytics_service.gd / remote_analytics.gd / analytics_bridge.gd → pipeline de telemetria
      reaproveitável para reportar Game Stats (Fase 30)

    Não toque em nenhum arquivo fora de docs/google-play/.
  </action>
  <acceptance_criteria>
    - grep -q '## 3. Ativos Reaproveitáveis para a Integração Google' docs/google-play/compatibility-audit.md
    - grep -q '| Sistema existente | Arquivo | Reaproveitável para | Observação |' docs/google-play/compatibility-audit.md
    - grep -q 'achievement_service.gd' docs/google-play/compatibility-audit.md
    - grep -q 'offline_queue.gd' docs/google-play/compatibility-audit.md
    - contagem de linhas de tabela markdown (`grep -c '^| '`) no arquivo é >= 7 (cabeçalho + 6 linhas de dados)
  </acceptance_criteria>
  <verify>
    <automated>grep -q "## 3. Ativos Reaproveitáveis para a Integração Google" docs/google-play/compatibility-audit.md && grep -q "achievement_service.gd" docs/google-play/compatibility-audit.md && grep -q "offline_queue.gd" docs/google-play/compatibility-audit.md && [ "$(grep -c '^| ' docs/google-play/compatibility-audit.md)" -ge 7 ] && ./tools/ci/lint_docs.sh</automated>
  </verify>
  <done>Seções 2 (com 2.1-2.5) e 3 anexadas, com a tabela de ativos reaproveitáveis citando pelo menos 6 sistemas reais por caminho de arquivo e a fase do ROADMAP que os consome.</done>
</task>

<task type="auto">
  <name>Task 3: Auditar setup Android/Google Play e registrar débito técnico e riscos preliminares</name>
  <files>docs/google-play/compatibility-audit.md</files>
  <read_first>
    - docs/mobile/android.md
    - docs/store/google-play.md
    - docs/deployment/release-process.md
    - tools/ci/make_export_presets.sh
    - apps/mobile/export_presets.cfg
    - .gsd/BACKLOG.md (grep por "BL-010" e por "google"/"play"/"sidekick")
    - .planning/STATE.md (seção Blockers/Concerns, decisões humanas H-01/H-02)
  </read_first>
  <action>
    Anexe ao final de docs/google-play/compatibility-audit.md as seções exatas:

    ## 4. Setup Android e Google Play Atual
    ## 5. Débito Técnico e Conflitos
    ## 6. Riscos Preliminares

    - 4: cite o package id real (com.sierratecnologia.volta, de
      tools/ci/make_export_presets.sh / apps/mobile/export_presets.cfg), minSdk 24 / targetSdk 34
      (docs/mobile/android.md), o estado do formulário/ficha de loja em docs/store/google-play.md
      (hoje só tem descrição curta/longa e checklist de assets - nenhuma menção a Play Games
      Services, Sidekick, Achievements ou Leaderboards), e o item de backlog BL-010 ("Vincular
      conta a Google Play Games / Game Center") como confirmação de que esta integração já era
      conhecida e estava propositalmente adiada.
    - 5: tabela markdown com colunas exatas
      `| Débito/Conflito | Onde | Impacto na integração Google | Fase que deve resolver |`
      com no mínimo 4 linhas, cobrindo obrigatoriamente: (a) EventBus sem eventos de domínio de
      gameplay → Fase 27; (b) nenhum SDK/plugin de Play Games Services no projeto hoje → Fase 28;
      (c) progression/ não conhece contas Google (sem play_games_player_id nem vínculo via Recall)
      → Fase 28; (d) ausência de infraestrutura de feature flags no projeto → Fase 27.
    - 6: tabela markdown com colunas exatas
      `| Risco | Impacto | Probabilidade | Mitigação Sugerida |` com no mínimo 5 linhas. Rotule
      explicitamente esta seção como preliminar: "riscos preliminares — o Plano 03 consolida o
      registro final na seção 7 depois de cruzar com docs/google-play/current-requirements.md".

    Não toque em nenhum arquivo fora de docs/google-play/. Ao final, rode
    `git status --porcelain -- apps packages services tools .github` e confirme que a saída é
    vazia (nada de produção foi tocado por este plano).
  </action>
  <acceptance_criteria>
    - grep -q '## 6. Riscos Preliminares' docs/google-play/compatibility-audit.md
    - grep -q 'BL-010' docs/google-play/compatibility-audit.md
    - grep -q 'com.sierratecnologia.volta' docs/google-play/compatibility-audit.md
    - grep -q '| Débito/Conflito | Onde | Impacto na integração Google | Fase que deve resolver |' docs/google-play/compatibility-audit.md
    - grep -q '| Risco | Impacto | Probabilidade | Mitigação Sugerida |' docs/google-play/compatibility-audit.md
    - `git status --porcelain -- apps packages services tools .github` retorna vazio
  </acceptance_criteria>
  <verify>
    <automated>grep -q "## 6. Riscos Preliminares" docs/google-play/compatibility-audit.md && grep -q "BL-010" docs/google-play/compatibility-audit.md && grep -q "com.sierratecnologia.volta" docs/google-play/compatibility-audit.md && ./tools/ci/lint_docs.sh && [ -z "$(git status --porcelain -- apps packages services tools .github)" ]</automated>
  </verify>
  <done>Seções 4, 5 e 6 anexadas com tabelas preenchidas por débito técnico e riscos reais, referenciando BL-010 e o package id real; nenhum arquivo de produção (apps/, packages/, services/, tools/, .github/) aparece como alterado por este plano.</done>
</task>

</tasks>

<verification>
- `test -f docs/google-play/compatibility-audit.md`
- `grep -c '^## ' docs/google-play/compatibility-audit.md` retorna 6 (seções 1 a 6)
- `./tools/ci/lint_docs.sh` passa (H1 presente)
- `git diff --name-only origin/master...HEAD | grep -v '^docs/' | grep -v '^\.planning/'` retorna vazio
</verification>

<success_criteria>
`docs/google-play/compatibility-audit.md` existe com as seções 1 a 6 completas, citando arquivos
reais do projeto (não descrições genéricas) para: arquitetura/Event Bus, gamificação já
implementada nas Fases 10/11/14/18, ativos reaproveitáveis, setup Android/Play, débito técnico
e riscos preliminares. Nenhuma linha de código de produção foi alterada.
</success_criteria>

<output>
Após completar, crie `.planning/phases/26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick/26-01-SUMMARY.md`
seguindo o template de summary.md, registrando quais sistemas foram auditados e quaisquer
descobertas inesperadas (ex.: sistema que parecia existir mas não existe, ou vice-versa).
</output>
