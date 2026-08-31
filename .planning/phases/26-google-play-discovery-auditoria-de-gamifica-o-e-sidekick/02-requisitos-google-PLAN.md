---
phase: 26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick
plan: 2
type: execute
wave: 1
depends_on: []
files_modified:
  - docs/google-play/current-requirements.md
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "Todo requisito oficial vigente do Google Play Games relevante para VOLTA foi pesquisado AO VIVO (WebSearch/WebFetch), não escrito de memória, e registrado com fonte e data de consulta"
    - "A disponibilidade/elegibilidade de cada superfície (algumas são beta, invite-only ou regionais) está documentada explicitamente, nunca presumida"
  artifacts:
    - path: "docs/google-play/current-requirements.md"
      provides: "Requisitos oficiais datados e citados por superfície do Google Play Games (PGS v2, Recall, Saved Games, Play Integrity, Achievements, Leaderboards, Game Stats, Play Points, Play Pass, Sidekick, Level Up, LiveOps/Quests, Rewards)"
      min_lines: 150
  key_links:
    - from: "docs/google-play/current-requirements.md"
      to: "https://developer.android.com"
      via: "citação de fonte oficial com data de consulta em cada seção"
      pattern: "https://developer(s)?\\.(android|google)\\.com"
---

<objective>
Consultar AO VIVO a documentação oficial ATUAL do Google (developer.android.com/games,
developers.google.com) para cada superfície do ecossistema Google Play Games que as Fases
27-38 vão implementar, e registrar os requisitos, com fonte e data, em
`docs/google-play/current-requirements.md`. Conforme `26-CONTEXT.md`: "Antes de implementar:
consultar a documentação oficial atual [...] Registrar tudo em
docs/google-play/current-requirements.md."

Purpose: requisitos de SDK/API do Google mudam com frequência (versões descontinuadas,
programas que viram invite-only, APIs que mudam de nome). Planejar as Fases 27-38 em cima de
memória desatualizada é o maior risco desta fase 26 — por isso cada requisito registrado aqui
PRECISA ter uma URL oficial e uma data de consulta, nunca vir de conhecimento prévio do modelo.

Output: `docs/google-play/current-requirements.md` com 14 seções (13 superfícies + resumo de
disponibilidade), cada uma citando fonte(s) oficial(is) com data.

RESTRIÇÃO CRÍTICA: este plano só pode criar/modificar `docs/google-play/current-requirements.md`.
Nenhum arquivo em `apps/`, `packages/`, `services/` ou `tools/` pode ser tocado.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick/26-CONTEXT.md
@.planning/ROADMAP.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Pesquisar requisitos oficiais — Play Games Services v2, Recall API, Saved Games/Cloud Save e Play Integrity API</name>
  <files>docs/google-play/current-requirements.md</files>
  <read_first>
    - .planning/phases/26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick/26-CONTEXT.md
  </read_first>
  <action>
    Use WebSearch para localizar a página oficial vigente e depois WebFetch para lê-la, para
    CADA uma das 4 superfícies abaixo. NUNCA escreva um requisito de memória — se não conseguir
    confirmar algo ao vivo, escreva "não confirmado na consulta de hoje, verificar antes de
    implementar" em vez de adivinhar.

    Superfícies desta tarefa (buscar em developer.android.com/games e developers.google.com):
    1. Play Games Services v2 — fluxo de sign-in/autenticação para Android
    2. Recall API (vínculo entre a identidade do Play Games e a conta própria do jogo/servidor)
    3. Saved Games / Cloud Save (Play Games Services)
    4. Play Integrity API

    Crie `docs/google-play/current-requirements.md` (arquivo novo) começando com:

    # Requisitos Oficiais Vigentes — Google Play Games (VOLTA)
    > Cada seção cita a fonte oficial e a data de consulta. Nada aqui foi escrito de memória —
    > se um requisito não pôde ser confirmado ao vivo, isso está dito explicitamente na seção.

    Depois, para CADA superfície, use exatamente esta subestrutura (numeração sequencial global
    1-4 nesta tarefa):

    ## 1. Play Games Services v2 — Sign-In
    ### Fontes Oficiais Consultadas
    ### Requisitos Vigentes
    ### Disponibilidade / Elegibilidade
    ### Impacto para VOLTA

    (repita para ## 2. Recall API, ## 3. Saved Games / Cloud Save, ## 4. Play Integrity API)

    Em "Fontes Oficiais Consultadas", cada linha no formato:
    `- <URL completa> — Consultado em: <YYYY-MM-DD>`
    usando a data real de hoje (comando `date +%Y-%m-%d` se precisar confirmar).

    Em "Disponibilidade / Elegibilidade", declare se a superfície é GA (disponível geralmente),
    beta, invite-only ou tem pré-requisitos de elegibilidade (ex.: quantidade mínima de
    instalações, país do desenvolvedor, categoria do app) — não presuma que está disponível.

    Em "Impacto para VOLTA", conecte o requisito a algo concreto do jogo (ex.: package
    com.sierratecnologia.volta, minSdk 24) quando a fonte oficial exigir uma versão mínima de
    SDK/API/minSdk incompatível ou compatível.
  </action>
  <acceptance_criteria>
    - test -f docs/google-play/current-requirements.md
    - grep -q '## 1. Play Games Services v2' docs/google-play/current-requirements.md
    - grep -q '## 4. Play Integrity API' docs/google-play/current-requirements.md
    - contagem de `grep -c 'Consultado em: 2026-'` no arquivo é >= 4
    - contagem de `grep -cE 'https://developer(s)?\.(android|google)\.com'` no arquivo é >= 4
  </acceptance_criteria>
  <verify>
    <automated>test -f docs/google-play/current-requirements.md && grep -q "## 4. Play Integrity API" docs/google-play/current-requirements.md && [ "$(grep -c 'Consultado em: 2026-' docs/google-play/current-requirements.md)" -ge 4 ] && [ "$(grep -cE 'https://developer(s)?\.(android|google)\.com' docs/google-play/current-requirements.md)" -ge 4 ]</automated>
  </verify>
  <done>Seções 1-4 existem com fontes oficiais citadas e datadas (mínimo 4 URLs, mínimo 4 citações "Consultado em: 2026-"), requisitos vigentes, disponibilidade/elegibilidade e impacto para VOLTA — nada escrito de memória.</done>
</task>

<task type="auto">
  <name>Task 2: Pesquisar requisitos oficiais — Achievements, Leaderboards, Game Stats, Play Points e Play Pass</name>
  <files>docs/google-play/current-requirements.md</files>
  <read_first>
    - docs/google-play/current-requirements.md (seções 1-4 já escritas pela Task 1 — não sobrescrever)
  </read_first>
  <action>
    Repita o processo da Task 1 (WebSearch + WebFetch em fontes oficiais, mesma subestrutura de
    4 sub-cabeçalhos, citação com data real) para estas 5 superfícies, anexando ao final do
    arquivo com numeração sequencial contínua:

    ## 5. Achievements
    ## 6. Leaderboards
    ## 7. Game Stats
    ## 8. Play Points
    ## 9. Play Pass

    Pontos que a pesquisa precisa responder por superfície:
    - Achievements: tipos (incremental vs. standard), limites de quantidade, requisitos de ícone/i18n.
    - Leaderboards: tipos de ordenação, janelas de tempo suportadas nativamente vs. que exigem
      backend próprio (cruzar mentalmente com o fato de VOLTA já ter leaderboard próprio via
      packages/backend — mas não edite nada fora deste arquivo).
    - Game Stats: quais "stat types" existem hoje (ex.: progression stat, repetitive stat) e como
      são configurados (Play Console vs. API).
    - Play Points: like é concedido, se há SDK cliente ou é só server-side/Play Console.
    - Play Pass: critérios de elegibilidade do TÍTULO para submissão (isso é frequentemente
      curated/convite — declare isso explicitamente se a fonte confirmar).
  </action>
  <acceptance_criteria>
    - grep -q '## 9. Play Pass' docs/google-play/current-requirements.md
    - grep -q '## 7. Game Stats' docs/google-play/current-requirements.md
    - contagem cumulativa de `grep -c 'Consultado em: 2026-'` no arquivo é >= 9
    - contagem cumulativa de `grep -cE 'https://developer(s)?\.(android|google)\.com'` no arquivo é >= 9
    - seções 1-4 da Task 1 continuam presentes (`grep -q '## 1. Play Games Services v2'`)
  </acceptance_criteria>
  <verify>
    <automated>grep -q "## 9. Play Pass" docs/google-play/current-requirements.md && grep -q "## 1. Play Games Services v2" docs/google-play/current-requirements.md && [ "$(grep -c 'Consultado em: 2026-' docs/google-play/current-requirements.md)" -ge 9 ] && [ "$(grep -cE 'https://developer(s)?\.(android|google)\.com' docs/google-play/current-requirements.md)" -ge 9 ]</automated>
  </verify>
  <done>Seções 5-9 anexadas (Achievements, Leaderboards, Game Stats, Play Points, Play Pass), cada uma com fonte oficial datada; contagem cumulativa de citações e URLs >= 9; seções 1-4 preservadas intactas.</done>
</task>

<task type="auto">
  <name>Task 3: Pesquisar Sidekick, Level Up, LiveOps/Quests e Rewards; sintetizar resumo de disponibilidade</name>
  <files>docs/google-play/current-requirements.md</files>
  <read_first>
    - docs/google-play/current-requirements.md (seções 1-9 já escritas — não sobrescrever)
  </read_first>
  <action>
    Repita o processo de pesquisa ao vivo para estas 4 superfícies finais, anexando com
    numeração sequencial contínua:

    ## 10. Google Play Games Sidekick
    ## 11. Level Up (Programa de Qualidade do Google Play)
    ## 12. LiveOps / Quests (conteúdo dirigido por servidor)
    ## 13. Play Games Rewards

    Para o Sidekick (10): confirme se é uma feature de overlay do sistema/launcher (não um SDK
    que o app integra diretamente) e o que o app PRECISA fazer para aparecer nele corretamente
    (ex.: ter Achievements/Leaderboards configurados, Game Stats reportadas) — isso é
    fundamental para o Plano 03 desenhar a arquitetura.

    Para Level Up (11): confirme se é um programa/checklist de qualidade do Google Play para
    jogos (critérios de elegibilidade, o que ele exige tecnicamente) — a Fase 36 do ROADMAP
    referencia `docs/google-play/level-up-quality.md`, então aqui basta registrar os requisitos
    oficiais, não produzir aquele documento (fora de escopo desta fase).

    Para LiveOps/Quests (12): confirme se existe uma feature de "Quests" nativa do Play Games ou
    se isso é só um padrão de arquitetura (server-driven config) que o próprio jogo implementa —
    não presuma que existe um SDK de quests do Google se a fonte não confirmar.

    Para Rewards (13): confirme o mecanismo real de concessão de recompensas do Play Games
    (client SDK vs. Play Console vs. inexistente como feature separada de Play Points).

    Ao final, adicione a seção de síntese:

    ## 14. Resumo de Disponibilidade

    Com uma tabela markdown de colunas EXATAS:
    `| Superfície | Status (GA/Beta/Invite-only/Regional/Não confirmado) | Bloqueador para VOLTA | Fase que consome |`

    com exatamente 13 linhas de dados (uma por superfície das seções 1-13), usando os nomes de
    fase do ROADMAP (Fases 27 a 34 majoritariamente).
  </action>
  <acceptance_criteria>
    - grep -q '## 14. Resumo de Disponibilidade' docs/google-play/current-requirements.md
    - grep -q '| Superfície | Status (GA/Beta/Invite-only/Regional/Não confirmado) | Bloqueador para VOLTA | Fase que consome |' docs/google-play/current-requirements.md
    - contagem de linhas de tabela (`grep -c '^| '`) na seção 14 é >= 14 (cabeçalho + 13 superfícies)
    - contagem cumulativa de `grep -c 'Consultado em: 2026-'` no arquivo inteiro é >= 13 (>= 8, conforme piso mínimo desta fase)
    - contagem cumulativa de `grep -cE 'https://developer(s)?\.(android|google)\.com'` no arquivo inteiro é >= 8
    - `git status --porcelain -- apps packages services tools .github` retorna vazio
  </acceptance_criteria>
  <verify>
    <automated>grep -q "## 14. Resumo de Disponibilidade" docs/google-play/current-requirements.md && [ "$(grep -c 'Consultado em: 2026-' docs/google-play/current-requirements.md)" -ge 8 ] && [ "$(grep -cE 'https://developer(s)?\.(android|google)\.com' docs/google-play/current-requirements.md)" -ge 8 ] && ./tools/ci/lint_docs.sh && [ -z "$(git status --porcelain -- apps packages services tools .github)" ]</automated>
  </verify>
  <done>Seções 10-14 anexadas, com tabela de resumo de disponibilidade cobrindo as 13 superfícies pesquisadas, ligadas às fases do ROADMAP que as consomem; documento completo tem >= 8 citações datadas e >= 8 URLs oficiais; nenhum arquivo de produção foi tocado.</done>
</task>

</tasks>

<verification>
- `test -f docs/google-play/current-requirements.md`
- `grep -c '^## ' docs/google-play/current-requirements.md` retorna 14
- `[ "$(grep -c 'Consultado em: 2026-' docs/google-play/current-requirements.md)" -ge 8 ]`
- `[ "$(grep -cE 'https://developer(s)?\.(android|google)\.com' docs/google-play/current-requirements.md)" -ge 8 ]`
- `./tools/ci/lint_docs.sh` passa
- `git diff --name-only origin/master...HEAD | grep -v '^docs/' | grep -v '^\.planning/'` retorna vazio
</verification>

<success_criteria>
`docs/google-play/current-requirements.md` existe com 14 seções cobrindo as 13 superfícies
oficiais do ecossistema Google Play Games relevantes para VOLTA (PGS v2, Recall, Saved Games,
Play Integrity, Achievements, Leaderboards, Game Stats, Play Points, Play Pass, Sidekick, Level
Up, LiveOps/Quests, Rewards) mais o resumo de disponibilidade, todas citadas com fonte oficial e
data de consulta real — nada escrito de memória. Nenhuma linha de código de produção foi
alterada.
</success_criteria>

<output>
Após completar, crie `.planning/phases/26-google-play-discovery-auditoria-de-gamifica-o-e-sidekick/26-02-SUMMARY.md`
seguindo o template de summary.md, listando as URLs oficiais efetivamente consultadas e
quaisquer superfícies cuja disponibilidade não pôde ser confirmada (para o Plano 03 tratar como
risco).
</output>
