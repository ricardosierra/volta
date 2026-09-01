---
phase: 26.1-correcao-quality-gate
plan: 4
type: execute
wave: 1
depends_on: []
files_modified:
  - packages/shared/config/balance/bonuses.tres
  - packages/shared/config/bots/rookie.tres
  - packages/shared/config/bots/archetypes/hunter.tres
  - packages/shared/config/bots/archetypes/nemesis.tres
  - packages/shared/config/bots/archetypes/grazer.tres
  - packages/shared/config/bots/archetypes/raider.tres
  - packages/shared/config/bots/archetypes/baron.tres
  - packages/shared/config/bots/archetypes/vulture.tres
  - packages/shared/config/bots/archetypes/warden.tres
  - packages/shared/config/modes/classic.tres
  - packages/shared/config/modes/time_attack.tres
  - packages/shared/config/modes/survival.tres
  - packages/shared/config/modes/domination.tres
  - packages/shared/config/modes/endless.tres
  - packages/shared/config/quality/low.tres
  - packages/shared/config/quality/medium.tres
  - packages/shared/config/quality/high.tres
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "packages/shared/config e apps/mobile/resources/config têm exatamente o mesmo conteúdo, e é a fonte única (packages/) que passou a conter os 17 arquivos que só existiam no app"
    - "Rodar apps/mobile/tools/dev/sync_config.sh não altera nenhum byte de apps/mobile/resources/config — a sincronia é idempotente"
  artifacts:
    - path: "packages/shared/config/modes/classic.tres"
      provides: "Definição do modo Classic promovida à fonte única de configuração (CLAUDE.md Regra 4)"
      contains: "[gd_resource"
    - path: "packages/shared/config/quality/low.tres"
      provides: "Preset de qualidade Low promovido à fonte única"
      contains: "[gd_resource"
---

<objective>
`./tools/ci/validate-repo.sh` seção 10 falha: `packages/shared/config` e
`apps/mobile/resources/config` divergem. Hoje a fonte única (`packages/shared/config/`) contém
apenas `balance/` com 6 `.tres`, enquanto o projeto Godot tem 17 arquivos a mais —
`balance/bonuses.tres` e os diretórios inteiros `bots/`, `modes/` e `quality/`.

A direção da correção está fixada em `26.1-CONTEXT.md`: **promover** os 17 arquivos para
`packages/shared/config/`, nunca apagá-los do app. `CLAUDE.md` Regra 4 diz que número de
gameplay mora em `.tres` sob `packages/shared/config/` — hoje 17 arquivos de números de
gameplay estão fora da fonte única, o que é exatamente a dívida que a regra 10 detecta.

Purpose: fazer a fonte única voltar a ser fonte única, sem alterar um único valor.

Output: `packages/shared/config/` com os 17 arquivos, e `sync_config.sh` idempotente.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/26.1-correcao-quality-gate/26.1-CONTEXT.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Promover os 17 arquivos de config para a fonte única, preservando bytes</name>
  <files>packages/shared/config/</files>
  <read_first>
    - apps/mobile/tools/dev/sync_config.sh (a direção da sincronia é packages/ -> apps/, nunca o contrário)
    - tools/ci/validate-repo.sh (seção 10 — como a divergência é medida)
    - CLAUDE.md (Regra 4 — número de gameplay mora em packages/shared/config/)
  </read_first>
  <action>
    Copie, **sem editar conteúdo**, os arquivos que hoje só existem no projeto Godot para a
    fonte única. Use `cp` preservando bytes — estes `.tres` foram escritos à mão para bater
    exatamente com `docs/design/balance.md` (ver decisão registrada em `.planning/STATE.md`:
    "hand-written in Godot text-resource format for byte-exact balance.md values"), então
    qualquer round-trip por editor ou por `ResourceSaver` é proibido.

    ```bash
    cd /Users/sierra/Dev/Jogos/volta
    mkdir -p packages/shared/config/bots/archetypes packages/shared/config/modes packages/shared/config/quality
    cp -p apps/mobile/resources/config/balance/bonuses.tres packages/shared/config/balance/bonuses.tres
    cp -p apps/mobile/resources/config/bots/rookie.tres      packages/shared/config/bots/rookie.tres
    cp -p apps/mobile/resources/config/bots/archetypes/*.tres packages/shared/config/bots/archetypes/
    cp -p apps/mobile/resources/config/modes/*.tres          packages/shared/config/modes/
    cp -p apps/mobile/resources/config/quality/*.tres        packages/shared/config/quality/
    ```

    Confirme que a cópia é byte-idêntica antes de seguir:

    ```bash
    diff -r packages/shared/config apps/mobile/resources/config
    ```

    A saída tem de ser vazia. Se `diff` acusar `.import` ou `.uid` que existem só do lado do
    app, **não** copie esses arquivos para a fonte única — eles são gerados pelo Godot. Em vez
    disso, registre a exceção na Task 2 ajustando a comparação, e explique no SUMMARY.
  </action>
  <acceptance_criteria>
    - `diff -r packages/shared/config apps/mobile/resources/config` imprime nada e sai com código 0
    - `find packages/shared/config -name '*.tres' | wc -l` retorna 23 (6 de balance + 17 promovidos)
    - `test -f packages/shared/config/modes/classic.tres && test -f packages/shared/config/quality/low.tres && test -f packages/shared/config/balance/bonuses.tres`
    - `git diff --stat -- apps/mobile/resources/config` imprime nada (o lado do app não foi tocado)
  </acceptance_criteria>
  <verify>
    <automated>diff -r packages/shared/config apps/mobile/resources/config && [ "$(find packages/shared/config -name '*.tres' | wc -l | tr -d ' ')" -eq 23 ] && [ -z "$(git diff --stat -- apps/mobile/resources/config)" ]</automated>
  </verify>
  <done>Os 17 arquivos existem em packages/shared/config/ byte-idênticos aos do app; nenhum arquivo do app foi alterado.</done>
</task>

<task type="auto">
  <name>Task 2: Provar que sync_config.sh é idempotente e que a regra 10 passa</name>
  <files>packages/shared/config/</files>
  <read_first>
    - apps/mobile/tools/dev/sync_config.sh
    - tools/ci/validate-repo.sh (seção 10)
  </read_first>
  <action>
    Rode a sincronia oficial e prove que ela não altera nada — se alterar, a fonte única e o
    app ainda divergem e a Task 1 está incompleta:

    ```bash
    ./apps/mobile/tools/dev/sync_config.sh
    git status --porcelain -- apps/mobile/resources/config
    ```

    A segunda linha tem de imprimir vazio.

    Em seguida confirme que a seção 10 do verificador passou:

    ```bash
    ./tools/ci/validate-repo.sh 2>&1 | sed -n '/== 10\./,$p'
    ```

    Deve imprimir `OK: packages/shared/config <-> apps/mobile/resources/config em sincronia`
    (ou a mensagem `ok` equivalente do script), e não `FALHA`.

    Não altere `sync_config.sh` neste plano. Se a idempotência falhar, a causa é diferença de
    conteúdo, e o conserto é na Task 1.
  </action>
  <acceptance_criteria>
    - `./apps/mobile/tools/dev/sync_config.sh` sai com código 0
    - `git status --porcelain -- apps/mobile/resources/config` imprime nada depois da sincronia
    - `./tools/ci/validate-repo.sh 2>&1 | sed -n '/== 10\./,$p' | grep -q FALHA` é falso
  </acceptance_criteria>
  <verify>
    <automated>./apps/mobile/tools/dev/sync_config.sh && [ -z "$(git status --porcelain -- apps/mobile/resources/config)" ] && ! ./tools/ci/validate-repo.sh 2>&1 | sed -n '/== 10\./,$p' | grep -q FALHA</automated>
  </verify>
  <done>sync_config.sh roda sem alterar nada e a seção 10 do validate-repo.sh não falha mais.</done>
</task>

</tasks>

<verification>
- `diff -r packages/shared/config apps/mobile/resources/config` vazio
- `./tools/ci/validate-repo.sh` seção 10 sem FALHA
- Nenhum valor de configuração alterado: `git diff -- apps/mobile/resources/config` vazio
</verification>

<success_criteria>
`packages/shared/config/` volta a ser a fonte única real de todos os números de gameplay, com
os 17 arquivos que estavam só no projeto Godot promovidos byte-a-byte. A sincronia é
idempotente e a regra 10 do quality gate passa.
</success_criteria>

<output>
Crie `.planning/phases/26.1-correcao-quality-gate/26.1-04-SUMMARY.md` seguindo o template,
listando os 17 arquivos promovidos e registrando qualquer exceção de `.import`/`.uid`.
</output>
