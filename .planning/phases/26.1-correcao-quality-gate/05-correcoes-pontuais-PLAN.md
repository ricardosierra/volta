---
phase: 26.1-correcao-quality-gate
plan: 5
type: execute
wave: 1
depends_on: []
files_modified:
  - tools/ci/validate-repo.sh
  - apps/mobile/src/ui/design_system/theme_service.gd
  - apps/mobile/src/progression/remote_profile_repository.gd
  - apps/mobile/tests/unit/test_remote_profile_repository.gd
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "A regra 4 do validate-repo.sh continua pegando um TODO real sem referência de tarefa, mas deixou de casar com a palavra portuguesa TODOS"
    - "RemoteProfileRepository.load_profile() chama um método que existe em LocalProfileRepository, provado por teste"
  artifacts:
    - path: "tools/ci/validate-repo.sh"
      provides: "Regra 4 com limite de palavra à direita e check_release_build.sh na lista de verificadores excluídos"
      contains: "TODO([^A-Za-z]|$)"
    - path: "apps/mobile/tests/unit/test_remote_profile_repository.gd"
      provides: "Teste que instancia RemoteProfileRepository e chama load_profile() sem erro de método inexistente"
      min_lines: 20
  key_links:
    - from: "apps/mobile/src/progression/remote_profile_repository.gd"
      to: "apps/mobile/src/progression/local_profile_repository.gd"
      via: "load_profile() delega ao cache local pelo método que de fato existe lá"
      pattern: "get_profile"
---

<objective>
Três defeitos pequenos e independentes, agrupados porque nenhum se relaciona com os outros
planos desta fase e juntos fecham as regras 4 e 6 do quality gate mais um bug real:

1. **Regra 4 — dois falsos positivos do próprio verificador.** O regex
   `(^|[^A-Za-z])TODO` (`tools/ci/validate-repo.sh:52`) não tem limite de palavra à direita,
   então casa com a string portuguesa `"TODOS OS ADVERSÁRIOS ELIMINADOS"`
   (`match_screen.gd:342` e `:347`) e com `"Unresolved TODOs found"`
   (`check_release_build.sh:6`). Nenhum dos dois é um TODO.
2. **Regra 6 — placeholder rastreado na linha errada.** `theme_service.gd:87` declara
   `PLACEHOLDER-ART-004`, e o `Replacement: GSD 08` está na linha **88**. O verificador casa
   a linha do placeholder e depois filtra por `Replacement:` naquela mesma linha, então a
   marcação não é vista. `dev_overlay.gd:10` faz certo, na mesma linha.
3. **Bug de produção achado na auditoria da Fase 26.**
   `remote_profile_repository.gd:16` chama `local_cache.load_profile()`, mas
   `LocalProfileRepository` define `get_profile()` (linha 6). Quebra em execução.

Purpose: fechar as regras 4 e 6 sem enfraquecer nenhuma delas, e corrigir o bug com teste.

Output: verificador com limite de palavra, placeholder na linha certa, chamada corrigida.
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
  <name>Task 1: Limite de palavra na regra 4, provando que TODO real continua sendo pego</name>
  <files>tools/ci/validate-repo.sh</files>
  <read_first>
    - tools/ci/validate-repo.sh (linhas 51-58 — a regra 4 inteira)
    - apps/mobile/tools/ci/check_release_build.sh (o script que dispara o falso positivo da linha 5)
    - apps/mobile/src/ui/screens/match_screen.gd (linhas 340-350 — a string "TODOS OS ADVERSÁRIOS ELIMINADOS")
  </read_first>
  <action>
    Em `tools/ci/validate-repo.sh`, na regra 4, troque o padrão de busca para exigir também um
    limite de palavra **à direita**, e acrescente `check_release_build.sh` à lista de
    verificadores já excluídos (ele é um script que procura por `TODO: ` — mesma natureza de
    `validate-repo.sh` e `run_negative_checks.sh`, que já estão excluídos por caminho).

    Substitua exatamente esta linha:

        bad_todo=$(grep -rnE '(^|[^A-Za-z])TODO' --include='*.gd' --include='*.php' --include='*.sh' \

    por:

        bad_todo=$(grep -rnE '(^|[^A-Za-z])TODO([^A-Za-z]|$)' --include='*.gd' --include='*.php' --include='*.sh' \

    E acrescente, logo depois da linha `| grep -v 'tests/tools/run_negative_checks.sh' \`, esta:

        | grep -v 'tools/ci/check_release_build.sh' \

    Por que o limite à direita é seguro e não afrouxa a regra:
    - `TODO: consertar` → depois de `TODO` vem `:`, não-letra → **continua sendo pego**
    - `TODO(GSD-15/API-003)` → vem `(`, não-letra → casa o grep e é filtrado pelo
      `grep -vE 'TODO\(GSD-...'` seguinte, como hoje → **continua correto**
    - `TODOS` / `TODOs` → vem `S`/`s`, letra → **deixa de ser pego**, que é o objetivo

    NÃO adicione `match_screen.gd` nem qualquer arquivo de código à lista de exclusão — o
    conserto tem de ser no regex, não em supressão de arquivo.
  </action>
  <acceptance_criteria>
    - `grep -c "TODO(\[^A-Za-z\]|\$)" tools/ci/validate-repo.sh` retorna 1
    - `grep -c "check_release_build.sh" tools/ci/validate-repo.sh` retorna 1
    - `grep -c "match_screen" tools/ci/validate-repo.sh` retorna 0 (nenhuma supressão de código)
    - `./tools/ci/validate-repo.sh 2>&1 | sed -n '/== 4\./,/== 5\./p' | grep -q FALHA` é falso
  </acceptance_criteria>
  <verify>
    <automated>grep -q 'TODO(\[\^A-Za-z\]|\$)' tools/ci/validate-repo.sh && grep -q 'check_release_build.sh' tools/ci/validate-repo.sh && [ "$(grep -c match_screen tools/ci/validate-repo.sh)" -eq 0 ] && ! ./tools/ci/validate-repo.sh 2>&1 | sed -n '/== 4\./,/== 5\./p' | grep -q FALHA</automated>
  </verify>
  <done>Regra 4 passa; o regex ganhou limite de palavra à direita e nenhum arquivo de código foi suprimido.</done>
</task>

<task type="auto">
  <name>Task 2: Provar que a regra 4 ainda pega um TODO real (prova negativa)</name>
  <files>tools/ci/validate-repo.sh</files>
  <read_first>
    - tools/ci/validate-repo.sh (regra 4, já ajustada na Task 1)
    - apps/mobile/tests/tools/run_negative_checks.sh (padrão de prova negativa do repositório)
  </read_first>
  <action>
    Prove empiricamente que o afrouxamento não aconteceu. Crie um arquivo temporário com um
    TODO sem referência de tarefa, rode o verificador, confirme que ele reprova, e apague:

    ```bash
    cd /Users/sierra/Dev/Jogos/volta
    printf 'extends Node\n\nfunc _ready() -> void:\n\t# TODO: isto deve ser pego pelo verificador\n\tpass\n' > apps/mobile/src/core/_tmp_negative_todo.gd
    ./tools/ci/validate-repo.sh 2>&1 | sed -n '/== 4\./,/== 5\./p' | tee /tmp/neg4.txt
    rm -f apps/mobile/src/core/_tmp_negative_todo.gd
    grep -q '_tmp_negative_todo.gd' /tmp/neg4.txt && echo "PROVA NEGATIVA OK" || echo "PROVA NEGATIVA FALHOU"
    ```

    Se imprimir `PROVA NEGATIVA FALHOU`, o regex da Task 1 está errado e afrouxou a regra —
    conserte antes de seguir. Registre o resultado desta prova no SUMMARY.

    Garanta que o arquivo temporário foi removido: `git status --porcelain` não pode listar
    `_tmp_negative_todo.gd`.
  </action>
  <acceptance_criteria>
    - A prova negativa imprime `PROVA NEGATIVA OK`
    - `test ! -f apps/mobile/src/core/_tmp_negative_todo.gd`
    - `git status --porcelain | grep -c _tmp_negative_todo` retorna 0
  </acceptance_criteria>
  <verify>
    <automated>[ ! -f apps/mobile/src/core/_tmp_negative_todo.gd ] && [ "$(git status --porcelain | grep -c _tmp_negative_todo)" -eq 0 ]</automated>
  </verify>
  <done>Provado que um TODO sem referência de tarefa continua sendo reprovado pela regra 4, e o arquivo de prova foi removido.</done>
</task>

<task type="auto">
  <name>Task 3: Placeholder ART-004 na mesma linha do marcador</name>
  <files>apps/mobile/src/ui/design_system/theme_service.gd</files>
  <read_first>
    - apps/mobile/src/ui/design_system/theme_service.gd (linhas 84-92)
    - apps/mobile/src/core/dev_overlay.gd (linha 10 — o formato correto, que já passa)
    - tools/ci/validate-repo.sh (linhas 69-74 — a regra 6)
  </read_first>
  <action>
    Em `apps/mobile/src/ui/design_system/theme_service.gd`, reescreva o comentário de duas
    linhas (87-88) para que `PLACEHOLDER-ART-004` e `Replacement: GSD 08` fiquem na **mesma
    linha**, como em `dev_overlay.gd:10`. Substitua:

    	# PLACEHOLDER-ART-004: família geométrica definitiva ainda não vendorizada; até lá a
    	# SystemFont do projeto, que já tem latim estendido. Replacement: GSD 08

    por:

    	# PLACEHOLDER-ART-004: família geométrica definitiva ainda não vendorizada. Replacement: GSD 08
    	# Até lá, a SystemFont do projeto, que já tem latim estendido.

    Não mude nenhuma linha de código — só o comentário. Mantenha a indentação com TAB, como o
    resto do arquivo.
  </action>
  <acceptance_criteria>
    - `grep -c 'PLACEHOLDER-ART-004.*Replacement: GSD 08' apps/mobile/src/ui/design_system/theme_service.gd` retorna 1
    - `./tools/ci/validate-repo.sh 2>&1 | sed -n '/== 6\./,/== 7\./p' | grep -q FALHA` é falso
    - `git diff --stat apps/mobile/src/ui/design_system/theme_service.gd` mostra apenas linhas de comentário alteradas
  </acceptance_criteria>
  <verify>
    <automated>[ "$(grep -c 'PLACEHOLDER-ART-004.*Replacement: GSD 08' apps/mobile/src/ui/design_system/theme_service.gd)" -eq 1 ] && ! ./tools/ci/validate-repo.sh 2>&1 | sed -n '/== 6\./,/== 7\./p' | grep -q FALHA</automated>
  </verify>
  <done>PLACEHOLDER-ART-004 tem Replacement: GSD 08 na mesma linha e a regra 6 passa.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 4: Corrigir RemoteProfileRepository.load_profile() e cobrir com teste</name>
  <files>apps/mobile/src/progression/remote_profile_repository.gd, apps/mobile/tests/unit/test_remote_profile_repository.gd</files>
  <read_first>
    - apps/mobile/src/progression/remote_profile_repository.gd (inteiro — 20 linhas)
    - apps/mobile/src/progression/local_profile_repository.gd (inteiro — confirma que o método é get_profile(), linha 6)
    - apps/mobile/src/progression/profile_repository.gd (a interface que ambos estendem)
    - apps/mobile/src/platform/api/offline_queue.gd (assinatura de enqueue, usada no _init)
    - apps/mobile/tests/unit/test_service_registry.gd (padrão de teste GUT do repo)
  </read_first>
  <behavior>
    - chamar load_profile() em um RemoteProfileRepository devolve o Profile do cache local, sem erro de método inexistente
  </behavior>
  <action>
    Em `apps/mobile/src/progression/remote_profile_repository.gd`, linha 16, troque

    	return local_cache.load_profile()

    por

    	return local_cache.get_profile()

    `LocalProfileRepository` define `get_profile()` (linha 6) e `save_profile()` (linha 13) —
    `load_profile()` nunca existiu ali. Não mexa em `ApiClient`, `OfflineQueue` nem no resto do
    arquivo: ligar esses serviços ao jogo é trabalho de uma fase de religação, não desta.

    Crie `apps/mobile/tests/unit/test_remote_profile_repository.gd`:

    ```gdscript
    extends GutTest

    ## Cobre o bug encontrado na auditoria da Fase 26: load_profile() chamava um método
    ## inexistente em LocalProfileRepository (get_profile é o nome real).

    func test_load_profile_delegates_to_local_cache() -> void:
    	var cache := LocalProfileRepository.new()
    	var repo := RemoteProfileRepository.new(null, null, cache)

    	var profile: Profile = repo.load_profile()

    	assert_not_null(profile, "load_profile() deve devolver o Profile vindo do cache local")
    ```

    Se `RemoteProfileRepository.load_profile()` fizer `api.get_data(...)` com `api == null` e
    isso quebrar o teste, **não** mude o teste para contornar: guarde a chamada com
    `if api != null:` no repositório, o que é o comportamento correto de qualquer forma quando
    não há cliente de API configurado, e registre o desvio no SUMMARY.
  </action>
  <acceptance_criteria>
    - `grep -c 'local_cache.load_profile' apps/mobile/src/progression/remote_profile_repository.gd` retorna 0
    - `grep -c 'local_cache.get_profile' apps/mobile/src/progression/remote_profile_repository.gd` retorna 1
    - `test -f apps/mobile/tests/unit/test_remote_profile_repository.gd`
    - `./tools/ci/test-client.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>[ "$(grep -c 'local_cache.load_profile' apps/mobile/src/progression/remote_profile_repository.gd)" -eq 0 ] && [ "$(grep -c 'local_cache.get_profile' apps/mobile/src/progression/remote_profile_repository.gd)" -eq 1 ] && ./tools/ci/test-client.sh</automated>
  </verify>
  <done>load_profile() delega para get_profile(), coberto por teste que passa.</done>
</task>

</tasks>

<verification>
- `./tools/ci/validate-repo.sh` seções 4 e 6 sem FALHA
- Prova negativa confirmou que um TODO real continua sendo reprovado
- `./tools/ci/test-client.sh` sai com código 0
- Nenhum arquivo de código foi adicionado a lista de exclusão do verificador
</verification>

<success_criteria>
Regras 4 e 6 do quality gate passam por correção real — regex com limite de palavra e
placeholder na linha certa —, e o bug de `RemoteProfileRepository` está corrigido e coberto por
teste. Nenhuma regra foi enfraquecida, provado empiricamente.
</success_criteria>

<output>
Crie `.planning/phases/26.1-correcao-quality-gate/26.1-05-SUMMARY.md` seguindo o template,
registrando o resultado da prova negativa da Task 2.
</output>
