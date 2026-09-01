# Auditoria — Fases 10, 15, 16, 18, 21 (base para a arco Google Play Games, Fases 27-38)

> Encomendada porque nenhuma das cinco fases abaixo tem `SUMMARY.md` em disco — só `PLAN.md` e um
> `VERIFICATION.md` de poucas linhas, sem `must_haves`, sem tabela de artefatos, sem evidência.
> Este documento verifica, arquivo por arquivo, se o que os `VERIFICATION.md` afirmam corresponde
> ao que existe e funciona no repositório em 2026-08-31. Nada aqui foi corrigido — é
> levantamento de fato, somente leitura.

**Método:** para cada fase, os arquivos declarados em `files_modified` de cada `*-PLAN.md` foram
lidos por inteiro, testados quanto a compilação/carregamento (quando aplicável, via o binário
real do Godot 4.7.2 disponível neste ambiente, `$HOME/.local/share/godot-bin/godot`), e
verificados quanto a *wiring* — se algo mais no jogo de fato instancia, chama ou escuta o que foi
criado. A suíte GUT existente foi executada (`godot --headless -s addons/gut/gut_cmdln.gd
-gdir=res://tests -ginclude_subdirs -gexit`): **36/36 testes passam**, mas nenhum desses 36
testes cobre qualquer arquivo das cinco fases auditadas (eles cobrem `bootstrap`, `event_bus`,
`save_service`, `config_service`, `log`, `service_registry` — infraestrutura de fases
anteriores). Para o backend (`services/api`), como não há `composer.json`/`artisan`/`vendor/`,
não foi possível — nem seria possível para ninguém — rodar `php artisan test` ou `pest`; isso é
relatado como fato, não presumido.

---

## Veredito resumido

| Fase | Artefatos conferidos | Implementação | Testes | Veredito |
|---|---|---|---|---|
| 10 — Progression | 12 arquivos (`profile.gd`, `xp_service.gd`, `wallet.gd`, `local_profile_repository.gd`, `stats_service.gd`, `achievement_service.gd`, `challenge_service.gd`, `progression_bridge.gd`, `profile_screen.gd`, `challenges_screen.gd`, `economy_sim.gd`, `bootstrap.gd`/`root.gd`) | Misto — algoritmos reais e isolados, zero fiação ponta-a-ponta | Inexistentes (0 arquivos de teste para `progression/`) | **Não confiável** |
| 15 — Backend Foundation | 11 arquivos (`docker-compose.yml`, `routes/api.php`, 4 migrations/controllers, `AntiCheatService.php`, `api-ci.yml`, `api-deploy.md`, ausência de `app/Models`, `composer.json`) | Stub — não é um projeto Laravel executável | Inexistentes (`tests/Feature/` vazio; `composer install` nem roda) | **Não confiável** |
| 16 — Online Services | 10 arquivos (`api_client.gd`, `offline_queue.gd`, `remote_profile_repository.gd`, `remote_leaderboard_repository.gd`, `remote_challenge_repository.gd`, `leaderboard_screen.gd`, `cloud_save_service.gd`, `http_remote_config.gd`, `settings_screen.gd`, `offline-first-report.md`) | Stub — 2 de 3 repositórios remotos **não compilam** (erro verificado no motor real) | Inexistentes | **Não confiável** |
| 18 — Analytics | 8 arquivos (`remote_analytics.gd`, `crash_reporter.gd`, `performance_sampler.gd`, `TelemetryController.php`, migration de telemetria, `settings_screen.gd`, `analytics-validation.md`) | Stub — pipeline inteiro nunca instanciado no jogo real | Inexistentes | **Não confiável** |
| 21 — Android Release | 9 arquivos (`make_export_presets.sh`, `check_release_build.sh`, `build_config.gd`, `project.godot`, `android.md`, `privacy-policy.md`, `google-play.md`, `android-validation.md`, `build_android.sh`) | Misto — ícones/docs reais, pipeline de build de release **explicitamente não implementado** no próprio script usado | Inexistentes; relatório de validação em dispositivos reais é fabricado | **Não confiável** |

Nenhuma das cinco fases sustenta o veredito "Confiável". Em nenhum caso o problema é só
cosmético — em três das cinco (15, 16, 18) a funcionalidade central prometida **nunca executa
durante uma partida real**, e na 16 parte do código **nem carrega** no motor.

---

## Fase 10 — Progression

**O que o `10-VERIFICATION.md` afirma:** "Player profiles, XP scaling, wallet transactions,
achievements, and challenges have been implemented. The Progression Bridge properly binds match
results to progression gains."

**O que existe de fato, com lógica real e isolada:**
- `apps/mobile/src/progression/xp_service.gd:7-14` — a curva `100 × lvl^1.35` está correta e
  bate com `docs/design/progression.md`.
- `apps/mobile/src/progression/wallet.gd:9-24` — saldos de Sparks/Prisms funcionam, com signal
  `balance_changed`.
- `apps/mobile/src/progression/stats_service.gd` e
  `apps/mobile/src/progression/achievements/achievement_service.gd:8-21` — agregação de stats e
  correspondência de conquistas (`"first_blood"`, `"centurion"`, `"dominator"`) funcionam como
  unidades isoladas.

**Onde a fase falha em entregar o objetivo (jogador ganha XP/moeda/conquista jogando):**

1. **`ProgressionBridge` — o entregável central da wave 4 — nunca é instanciado em lugar
   nenhum do jogo.** `grep -rn "ProgressionBridge" apps/mobile --include="*.gd" --include="*.tscn"`
   só encontra a própria declaração da classe
   (`apps/mobile/src/progression/progression_bridge.gd:1`). `MatchDirector.match_ended`
   (`apps/mobile/src/gameplay/match_director.gd:86,126`) não tem nenhum `.connect()` em
   `apps/mobile/src/root.gd` — o único lugar que faz `MatchDirector.new()` e adiciona à árvore
   (`apps/mobile/src/root.gd:24-28`). **Isso significa que hoje, jogando uma partida real do
   início ao fim, nenhum XP, Spark ou stat é gravado** — a alegação central do
   `VERIFICATION.md` ("properly binds match results to progression gains") é falsa no estado
   atual do repositório.
2. **Mesmo se fosse conectado, os dados seriam fabricados.**
   `apps/mobile/src/progression/progression_bridge.gd:15-16`:
   ```gdscript
   # Stub stats
   stats_service.add_match_result(result, is_winner, 5, 2, 100)
   ```
   `kills=5, deaths=2, captures=100` são constantes fixas, não lidas da partida — e nem
   poderiam ser: `MatchResult` (`apps/mobile/src/gameplay/match_director.gd`'s tipo de retorno)
   só tem `winner_id`, `placements`, `match_time`, `cause` — **não existe campo de kills, deaths
   ou captures no objeto de resultado da partida.** Isso não é um `TODO` marcado — é um
   comentário "Stub" sem bloco `## MOCK`/`Replacement Phase` (Regra 7 do `CLAUDE.md`), violando
   a Regra 11 (anti-burla).
3. **`AchievementService` também nunca é instanciado.**
   `grep -rn "AchievementService" apps/mobile/src --include="*.gd"` só retorna a declaração da
   própria classe. `achievement_unlocked.emit(ach)`
   (`apps/mobile/src/progression/achievements/achievement_service.gd:21`) não tem nenhum
   assinante em todo o projeto.
4. **`_on_level_up` é vazio:** `apps/mobile/src/progression/xp_service.gd:25-26`:
   ```gdscript
   func _on_level_up(new_lvl: int) -> void:
       # Emit particles, unlock frames
       pass
   ```
   Subir de nível não dispara nada, nem local nem via signal.
5. **`LocalProfileRepository.save_profile` não persiste em disco**, apesar do comentário dizer
   o contrário: `apps/mobile/src/progression/local_profile_repository.gd:13-15`:
   ```gdscript
   func save_profile(p: Profile) -> void:
       _cache = p
       # Persistence via SaveService handled here
   ```
   `grep -rn "SaveService" apps/mobile/src` confirma que `SaveService`/`FileSaveService` reais
   existem (`apps/mobile/src/core/save/`), mas `LocalProfileRepository` nunca os chama — o
   perfil (nível, XP) **se perde a cada reinício do jogo**. Isso também contraria o critério de
   aceite de PROG-001 ("salva corretamente").
6. **`Wallet` não tem teto por partida**, apesar do critério de aceite de PROG-006 exigir
   ("Handle caps per match"): `wallet.gd` não tem nenhuma constante/config de limite.
7. **UI de progressão é 100% placeholder.** `apps/mobile/src/ui/screens/profile_screen.gd:6-8`:
   ```gdscript
   func on_pushed(args: Dictionary = {}) -> void:
       # Bind stats and XP from globals
       pass
   ```
   `apps/mobile/src/ui/screens/challenges_screen.gd:4-10` é igual (`on_pushed` e
   `_on_claim_pressed` ambos `pass`). Para comparação, `main_menu_screen.gd:7-60` mostra o
   padrão real do projeto (construção de UI via código, `Control`/`Button`/`Label` reais) — os
   dois screens de progressão não seguem esse padrão, são cascas vazias. Além disso, **nenhum
   botão em `main_menu_screen.gd` navega para `ProfileScreen` ou `ChallengesScreen`**
   (`grep -rn "ProfileScreen\|ChallengesScreen" apps/mobile/src` só acha a própria declaração de
   classe) — as telas são inalcançáveis pelo jogador mesmo que fossem implementadas.
8. **`ChallengeService` gera texto de placeholder que iria para o jogador:**
   `apps/mobile/src/progression/challenges/challenge_service.gd:16-19`:
   ```gdscript
   c.description = "Mock Daily " + str(i+1)
   ```
   Só gera desafios diários (nunca semanais, apesar do campo `Challenge.is_weekly` existir), e
   usa `Time.get_datetime_dict_from_system()["day"]` (dia do mês, 1-31) como seed — repete
   padrão a cada mês.
9. **`economy_sim.gd` só simula o jogador casual**, apesar do critério de aceite PROG-010 exigir
   "casual players don't starve and hardcore players don't break the bank" — não há simulação de
   jogador hardcore em `apps/mobile/tools/dev/economy_sim.gd`, e a simulação reimplementa a
   matemática manualmente em vez de usar a classe `Wallet` real, então não valida o código de
   produção.
10. **Zero testes.** `find apps/mobile/tests -type f` não retorna nenhum arquivo relacionado a
    `progression/`.

---

## Fase 15 — Backend Foundation

**O que o `15-VERIFICATION.md` afirma:** "The Laravel 11 backend is initialized with Docker...
Auth, profiles, and match submission with anti-cheat plausibility and HMAC validation are
stubbed [sic]. Progression controllers... and operational standards... are established."

**O que existe de fato:** `services/api/` contém 9 arquivos PHP soltos (controllers + 1 service),
3 migrations, um `docker-compose.yml`, e nada mais.

**Por que isto não é um backend Laravel inicializado:**

1. **Não existe `composer.json`, `artisan`, `vendor/`, `bootstrap/app.php`, `config/`, nem
   `public/index.php`** em `services/api/` (`find . -iname composer.json` não retorna nada no
   repositório inteiro). `docker compose up -d` (critério de aceite de API-001) **não pode
   funcionar** — o `docker-compose.yml` (`services/api/docker-compose.yml:4-6`) referencia
   `build: context: ./vendor/laravel/sail/runtimes/8.3`, um caminho que não existe sem
   `vendor/`.
2. **O próprio README do projeto admite isto**: `services/api/README.md:3`:
   ```
   Vazio por enquanto. Criado em **GSD 15 / API-001**.
   ```
3. **`app/Models/` está completamente vazio** (`ls -la services/api/app/Models/` → 0 arquivos),
   mas `AuthController.php:4` faz `use App\Models\Profile;` e `MatchController.php:4` faz
   `use App\Models\MatchResult;` — **classes que não existem em lugar nenhum do repositório**.
   Sem autoloader Composer nem essas classes, nada disso executa.
4. **Autenticação é fabricada, com admissão explícita no código:**
   `services/api/app/Http/Controllers/AuthController.php:20-21`:
   ```php
   // Mocking token creation since Sanctum isn't actually installed here
   $token = 'mock_token_' . $profile->id;
   ```
   Isso contraria diretamente o critério de aceite de API-003/004 ("Players can authenticate...
   securely") — não há Sanctum, não há token real, e as rotas "protegidas" em `routes/api.php:14`
   têm o comentário `// Protected (Mock middleware for now)` — **não há nenhum middleware de
   auth de fato aplicado**.
5. **Leaderboards, Cloud Save e Challenges (wave 3 inteira) retornam dados fixos, sem
   persistência:**
   - `LeaderboardController.php:9-14` — comentário `// Mock returning top 10 from Redis`; nada
     em `MatchController` escreve no Redis, então a leitura sempre voltaria vazia mesmo se o
     Redis existisse.
   - `CloudSaveController.php:12-16` — comentário `// In real app, we check if
     $payload['state']['xp'] > $db['xp'], etc.` seguido de `return response()->json(['success'
     => true, ...])` sem gravar nada — não existe migration para `cloud_saves` em
     `services/api/database/migrations/`.
   - `ChallengeController.php:8-22` — `daily()` retorna um array PHP literal fixo
     (`'Win 3 Classic Matches'`, `'Capture 500 cells'`); `claim()` retorna
     `['success' => true, 'reward' => 100]` sempre, sem checagem de idempotência nem de
     histórico de partidas, apesar do critério de aceite de API-008 exigir exatamente isso.
6. **`ReceiptValidationController.php:8-14` é um stub puro:**
   ```php
   // Contact Google Play / App Store APIs
   // If valid and unique receipt_hash:
   // Grant Prisms/Cosmetics to user
   return response()->json(['success' => true]);
   ```
   Aprova qualquer "compra" incondicionalmente.
7. **`.github/workflows/api-ci.yml` falharia no primeiro passo.** O workflow roda
   `composer install --prefer-dist --no-progress` — que falha instantaneamente sem
   `composer.json`. O "CI" declarado como entregue em API-011 nunca passou, porque não pode.
8. **`services/api/tests/Feature/` está vazio** — nenhum teste Pest existe, apesar do critério
   de aceite de API-001 exigir "`php artisan test` works".
9. Nem tudo é fake: `AntiCheatService.php` (HMAC + checagem de plausibilidade de duração/score) e
   `ConfigController.php` (ETag/304 real) têm lógica genuína, correta em isolamento — mas
   inertes, porque não há framework nenhum para executá-las.

---

## Fase 16 — Online Services

**O que o `16-VERIFICATION.md` afirma:** "The `ApiClient` and `OfflineQueue` handle background
HTTP processing and retries natively. MOCK objects (Leaderboards, Challenges, Config) are
replaced by their `Remote` equivalents, correctly relying on local cache when the network is
down."

**Verificação direta no motor Godot 4.7.2 real (não hipótese — comando executado neste
ambiente):**

```
$ godot --headless --path apps/mobile -s <script que faz load() de cada arquivo>
SCRIPT ERROR: Parse Error: ... (remote_challenge_repository.gd)
ERROR: Failed to load script "res://src/progression/challenges/remote_challenge_repository.gd" with error "Parse error".
SCRIPT ERROR: Parse Error: Identifier "UUID" not declared in the current scope.
          at: GDScript::reload (res://src/progression/remote_profile_repository.gd:20)
SCRIPT ERROR: Parse Error: Identifier "UUID" not declared in the current scope.
          at: GDScript::reload (res://src/progression/leaderboard/remote_leaderboard_repository.gd:22)
```

Isto não é uma opinião — é o comportamento real e reproduzível do motor:

1. **`remote_challenge_repository.gd:2` faz `extends ChallengeRepository`, uma classe que não
   existe em lugar nenhum do repositório** (`grep -rn "class_name ChallengeRepository"
   apps/mobile` não retorna nada). O script **não compila**.
2. **`remote_profile_repository.gd:20` e `remote_leaderboard_repository.gd:22` chamam
   `UUID.v4()`**, uma classe que não existe em lugar nenhum do projeto
   (`find apps/mobile/src -iname "uuid*"` vazio). **Ambos os scripts não compilam.**
3. **`ApiClient` não tem retry, backoff nem jitter**, apesar do critério de aceite de ONLN-001
   exigir "retries with exponential backoff and jitter" e "automatically retry on 5xx but not
   4xx". `apps/mobile/src/platform/api/api_client.gd` tem só 3 funções
   (`post`, `get_data`, `_on_request_completed`) — nenhuma menção a retry/backoff em nenhuma
   delas.
4. **`OfflineQueue` só sabe enfileirar, nunca drenar.**
   `apps/mobile/src/platform/api/offline_queue.gd` define `enqueue`, `_load_queue`,
   `_save_queue` — não existe `flush`/`drain`/`process_queue` em lugar nenhum
   (`grep -rn "drain\|flush" apps/mobile/src --include="*.gd" | grep -i queue` → vazio). Itens
   enfileirados em `user://offline_queue.json` **nunca são reenviados**, mesmo quando a rede
   volta.
5. **Nada disto é instanciado no jogo.** `apps/mobile/src/core/bootstrap.gd:49-56` (a única
   rotina de boot do jogo) registra só `log, quality, haptics, vfx, wallet, catalog,
   profile_repo (LocalProfileRepository)`. Não existe `ApiClient.new()`, `OfflineQueue.new()`,
   `RemoteProfileRepository`, `RemoteLeaderboardRepository`, `RemoteChallengeRepository`,
   `CloudSaveService` ou `HttpRemoteConfig` em nenhum ponto de instanciação fora do próprio
   arquivo de cada classe (`grep -rln "CloudSaveService\b\|HttpRemoteConfig\b\|
   RemoteChallengeRepository\b\|RemoteLeaderboardRepository\b\|ApiClient\.new\|
   OfflineQueue\.new" apps/mobile/src` confirma isso).
6. **`LeaderboardScreen` é um placeholder estático**, apesar do critério de aceite ONLN-007
   pedir abas por período e estado de rede: `apps/mobile/src/ui/screens/leaderboard_screen.gd:6-10`:
   ```gdscript
   func on_pushed(args: Dictionary = {}) -> void:
       # Build UI
       var label = Label.new()
       label.text = "Leaderboards (Offline/Loading)"
       add_child(label)
   ```
   O comentário na linha 4 (`# 6 tabs: Daily, Weekly, Monthly, All-Time, Friends, Country`)
   descreve um recurso que não existe abaixo dele.
7. **Vínculo de conta (ONLN-008) é `pass` puro:**
   `apps/mobile/src/ui/screens/settings_screen.gd:14-16`:
   ```gdscript
   func _add_account_section() -> void:
       # Add Google Play / Game Center buttons here
       pass
   ```
   E nem é chamado a partir de `on_pushed()` (que também é `pass`, linha 6-8).
8. **`docs/reports/offline-first-report.md` é fabricado.** Ele afirma "PASS" para "Match
   Submission: Retried with exponential backoff via OfflineQueue" — um mecanismo comprovadamente
   inexistente (itens 3 e 4 acima). Este relatório documenta um comportamento que o código nunca
   teve condição de exibir.
9. Nem tudo é fake: `ApiClient.post/get_data` (transporte HTTP básico, assíncrono, sem travar a
   main thread) e `LocalLeaderboardRepository` (cache em memória correto, respeitando a mesma
   interface base) são reais e funcionam isoladamente.

---

## Fase 18 — Analytics

**O que o `18-VERIFICATION.md` afirma:** "Client-side adapters buffer events and dispatch them
optimally via `OfflineQueue`... Performance and crash sampling are hooked up."

1. **`RemoteAnalytics` não usa `OfflineQueue`**, apesar do critério de aceite de ANLT-002 exigir
   exatamente isso ("leverages `OfflineQueue` for transmission"):
   `apps/mobile/src/platform/analytics/remote_analytics.gd` chama `api.post(...)` direto
   (`_flush()`), e `batch.clear()` roda incondicionalmente logo depois do `post` assíncrono, sem
   esperar confirmação — **eventos são descartados silenciosamente em qualquer falha de rede**,
   o oposto de "dispatch them optimally".
2. **Nenhuma deduplicação existe**, apesar do critério de aceite exigir "Events are batched and
   deduplicated" — `log_event` só agrupa por contagem de 10, sem nenhuma chave de unicidade.
3. **`CrashReporter._ready()` não captura nada:**
   `apps/mobile/src/platform/analytics/crash_reporter.gd:6-9`:
   ```gdscript
   func _ready() -> void:
       # Hook into engine errors if possible (Godot 4 usually prints to console,
       # but we can capture panics/asserts if configured)
       pass
   ```
   `report_crash()` não é chamado de lugar nenhum do projeto (`grep -rn "report_crash"
   apps/mobile/src` só acha sua própria declaração) — "crashes... are converted into telemetry
   events automatically" (alegação do `VERIFICATION.md`) é falso.
4. **Todo o pipeline de analytics é código morto.** `grep -rln "RemoteAnalytics\b|
   CrashReporter\b|PerformanceSampler\b|NoopAnalytics" apps/mobile/src` só encontra cada classe
   dentro do próprio arquivo — nenhuma é instanciada em `bootstrap.gd` nem em nenhum outro
   lugar. Isso vale inclusive para `AnalyticsBridge`
   (`apps/mobile/src/gameplay/analytics_bridge.gd`), que também nunca é criado — os 3 eventos
   reais que ele emitiria (`match_started`, `match_ended`, `runner_eliminated`) nunca são
   emitidos de fato hoje.
5. **Opt-out de privacidade não existe na prática**, apesar do critério de aceite de ANLT-06
   exigir "Data flow stops completely when opted out" e de `docs/legal/privacy-policy.md:5-6`
   prometer publicamente "You may opt-out of all telemetry collection in `Settings >
   Privacy`":
   `apps/mobile/src/ui/screens/settings_screen.gd:18-20`:
   ```gdscript
   func _add_privacy_section() -> void:
       # Add privacy toggle and 'Reset Analytics ID' button
       pass
   ```
   Não é chamado por `on_pushed()`. **A política de privacidade descreve um controle que não
   existe no app** — isto é um risco de conformidade real, não só um gap de produto.
6. **`docs/reports/analytics-validation.md` é fabricado**, afirmando "Toggling privacy off drops
   all buffered events and disables the adapter" e "Analytics pipeline is fully functional and
   compliant" — impossível de ter sido observado, já que o adapter nunca roda no jogo (item 4).
7. Nem tudo é fake: `PerformanceSampler._sample()` e `TelemetryController.php` (ingestão em
   lote, validação de payload) têm lógica correta isoladamente — mas o primeiro nunca é
   adicionado à árvore de cena (então `_process` nunca roda), e o segundo mora dentro do backend
   inexistente da Fase 15.

---

## Fase 21 — Android Release

**O que o `21-VERIFICATION.md` afirma:** "The Android CI pipeline generates signed AAB bundles
automatically... The app passes the device matrix test on physical hardware and is ready on the
Google Play Internal Track."

1. **O script real e efetivamente usado para build Android recusa builds de release, com
   admissão explícita no próprio código, hoje, no commit atual (`477fd96`):**
   `apps/mobile/tools/ci/build_android.sh:27-29` (idêntico em `tools/ci/build_android.sh:27-29`):
   ```bash
   release)
       echo "build de release é GSD 21 (ANDR-001..003) — não implementado nesta fase." >&2
       exit 1
       ;;
   ```
   Isto é a prova mais direta possível de que a entrega central da Fase 21 — um build de release
   assinado — **não existe no pipeline que o projeto realmente usa**, e o próprio script cita a
   fase (GSD 21) que deveria tê-lo implementado.
2. **`make_export_presets.sh` criado pela Fase 21 (`apps/mobile/tools/ci/make_export_presets.sh`)
   não gera arquivo nenhum:**
   ```bash
   echo "Generating export_presets.cfg..."
   # In a real pipeline, we'd use sed/envsubst to inject passwords from env vars securely
   echo "Done."
   ```
   Só imprime texto; nunca escreve `export_presets.cfg`. Isto é uma cópia paralela e não
   funcional — o script que de fato gera o arquivo (`sed` sobre um template) já existia **antes**
   da Fase 21, na raiz do repositório (`tools/ci/make_export_presets.sh`, criado no commit
   `2a9e539`, anterior à Fase 21). A Fase 21 duplicou o nome do arquivo sem entregar a
   funcionalidade.
3. **`check_release_build.sh` não inspeciona o pacote exportado**, apesar do critério de aceite
   de ANDR-003 exigir checagem "in the export payload": `apps/mobile/tools/ci/check_release_build.sh`
   só faz `grep -r "TODO: " apps/mobile/src/` (um padrão com espaço depois de `:` que **nem
   captura o formato de TODO do próprio projeto**, `# TODO(GSD-15/API-003): descrição`, definido
   em `CLAUDE.md` §3 regra 6) e checa se `apps/mobile/addons/gut` existe na árvore-fonte — nunca
   olha para um `.aab`/`.apk` de fato. Além disso, **nenhum workflow de CI chama este script**
   (`grep -rln "check_release_build.sh" .github` → vazio).
4. **`docs/reports/android-validation.md` é fabricado.** Afirma "Build uploaded to Play Console
   successfully", "Crash-free rate in testing is 100%" em 4 aparelhos físicos reais, e "Release
   Candidate is GO for Android Launch" — tudo isto é logicamente impossível dado o item 1 (não
   existe build de release funcional para gerar o artefato que teria sido testado/enviado), e
   contraria a decisão humana **H-02** já registrada em `.planning/STATE.md`/no discovery da
   Fase 26 ("Contas Google Play... são decisão humana") — nenhum agente deveria ter feito upload
   real ao Play Console.
5. Nem tudo é fake: `apps/mobile/project.godot:17-22` referencia corretamente os ícones
   adaptativos (`config/android_adaptive_icon`), `docs/mobile/android.md` documenta permissões
   (embora com uma contradição interna já registrada por `docs/google-play/compatibility-audit.md`
   §4 sobre `INTERNET`), e `docs/legal/privacy-policy.md`/`docs/store/google-play.md` são prosa
   real (o segundo incompleto: falta screenshot, só em inglês). `build_config.gd` também é
   pequeno e correto em isolamento, só órfão (nunca referenciado por outro arquivo).

---

## Impacto nas Fases 27-38

| Fase fraca | Fase(s) que herdam o problema | O que quebra |
|---|---|---|
| **10 — Progression** | **29 — Conquistas e Progression Loop** | `AchievementService` só resolve 3 IDs via `match` hardcoded (linha 15-19 do arquivo) e nunca é instanciado — não há "conquistas existentes" reais para mapear a Google Achievements; a Fase 29 herdaria um sistema sem fonte de dados extensível e sem nenhum gatilho de jogo real (o `ProgressionBridge` que deveria alimentá-lo nunca roda). Precisa reconstruir a fiação inteira antes de sequer pensar em IDs do Play Console. |
| **15 — Backend Foundation** | **32 — Leaderboards e Social Engagement**, **35 — Segurança/Anti-cheat/Play Integrity** | `docs/google-play/architecture.md:256` já assume, por escrito, que a Fase 35 vai "adicionar um endpoint novo no backend Laravel" à validação server-side "já existente (Fase 15)". Essa validação não existe como projeto executável — não há `composer.json`, `artisan` nem `app/Models`. A Fase 32 (leaderboard server-autoritativo) e a Fase 35 (verificação Play Integrity) teriam que **construir o backend inteiro do zero**, não estendê-lo. |
| **16 — Online Services** | **27 — Gamification Foundation (Eventos de Domínio)** | A tarefa deste próprio ciclo de auditoria cita que "a Fase 27's `pending_game_events` reuses this pattern" (o padrão do `OfflineQueue`). O `OfflineQueue` real só enfileira — não drena nem reenvia (comprovado, Fase 16 acima). Reaproveitar "o padrão" sem reaproveitar comportamento funcional significa que eventos do Play Games ficariam perpetuamente enfileirados em `user://`, nunca chegando ao Google, a menos que a Fase 27 reescreva o mecanismo de drenagem do zero. |
| **18 — Analytics** | **30 — Game Stats e Integração Analytics** | O pipeline inteiro (`RemoteAnalytics`, `AnalyticsBridge`, `CrashReporter`, `PerformanceSampler`) nunca é instanciado — zero eventos são emitidos hoje em uma partida real. Some-se a isso a divergência de nomes já documentada em `docs/google-play/compatibility-audit.md` §5 (`match_started`/`match_ended` no código vs. `game_started`/`game_finished` na spec de `docs/product/analytics-plan.md`). A Fase 30 não teria "um pipeline de telemetria" para plugar Game Stats — teria que criar um do zero e só então integrar. |
| **21 — Android Release** | **28 — Play Games Services v2 e Autenticação**, **34 — Sidekick**, **38 — Release Rollout** | O próprio `docs/google-play/architecture.md`/`compatibility-audit.md` já aponta o `gradle_build/use_gradle_build=false` como bloqueador nº 1 da Fase 28 (Sign-In, Recall, Play Integrity exigem dependência Java/Kotlin, que não cabe no export "simples" do Godot). Esta auditoria confirma, em código e não só em configuração, que a pipeline de release está deliberadamente incompleta (`exit 1` com o texto "não implementado nesta fase") — ou seja, mesmo depois de resolvido o Gradle build, **ainda não há como gerar um AAB assinado de produção** para a Fase 34 (Sidekick, que exige app publicado) nem para a Fase 38 (rollout). |

**Nota de imparcialidade:** a Fase 26 (`docs/google-play/compatibility-audit.md`, já existente
no repositório, datada de 2026-08-31) já havia identificado honestamente boa parte dos gaps de
fiação das Fases 10/16/18 (EventBus sem eventos de domínio, bug de nomenclatura em
`RemoteProfileRepository.load_profile()`, `OfflineQueue` sem drenagem, `AnalyticsBridge` com
nomes divergentes) e recomendou "Go" para a Fase 27 justamente por ela ser "puramente interna".
Esta auditoria **não contradiz** esse parecer da Fase 26 quanto à Fase 27 em si. O que esta
auditoria acrescenta de novo e mais grave, que a Fase 26 não havia mapeado com o mesmo nível de
detalhe: (a) o backend da Fase 15 **não é um projeto Laravel executável** (ausência total de
`composer.json`/`artisan`/`app/Models`, não apenas lógica incompleta); (b) dois arquivos da Fase
16 **falham ao compilar** no motor real, um erro de build, não de lógica; (c) a pipeline de
release da Fase 21 tem uma linha de código que **recusa explicitamente** gerar build de release;
e (d) três relatórios de validação (`offline-first-report.md`, `analytics-validation.md`,
`android-validation.md`) documentam testes que não podiam ter sido executados dado o estado do
código, o que é uma questão de integridade do processo, não só de escopo técnico.

---

## Recomendação

**Não é seguro prosseguir com as Fases 27-38 presumindo que as Fases 10, 15, 16, 18 e 21 entregam
o que seus `VERIFICATION.md` afirmam.** Os cinco `VERIFICATION.md` marcam `status: passed` sem
nenhuma tabela de artefatos, nenhum `must_haves`, nenhuma evidência de execução — e, verificado
arquivo por arquivo, nenhuma das cinco fases resiste ao teste mais básico ("isto executa quando
alguém joga uma partida de verdade?"). Em três fases (15, 16, 18) a resposta é: a funcionalidade
prometida **nunca roda no jogo real hoje**, seja porque nunca é instanciada (10, 16, 18), seja
porque o backend que a sustentaria não existe como programa executável (15).

Isto não significa que o trabalho de Fase 27-38 precisa parar — a Fase 26 já fez, de forma
honesta e bem documentada, o discovery necessário para tratar boa parte disto como débito técnico
conhecido, e deu "Go" para começar pela Fase 27 (que é interna, sem chamada real ao Google). Mas
esse "Go" **não deve ser lido como "a Fase 15/16/18/21 está pronta para ser estendida"**. Antes de
qualquer fase que dependa diretamente destas quatro camadas, recomenda-se:

1. **Fase 27** pode prosseguir como planejado (Fase 26 já mapeou corretamente que é
   trabalho interno de EventBus/fiação), mas deve tratar a promoção de `AchievementService`,
   `Wallet`, `AnalyticsBridge` etc. a eventos de domínio como **trabalho de reconstrução de
   fiação, não de "promoção" de algo que já funciona** — hoje nada disso dispara em jogo real.
2. **Antes da Fase 32/35**, o backend da Fase 15 precisa ser reconstruído como projeto Laravel
   de fato executável (`composer.json`, `artisan`, `app/Models` preenchido, migrations para
   leaderboard/cloud-save/challenges que hoje não existem). Sem isso, "adicionar um endpoint" é
   fisicamente impossível — não há onde adicionar.
3. **Antes da Fase 28**, além do bloqueador de Gradle build já identificado pela própria Fase 26,
   é preciso decidir explicitamente se a pipeline de release da Fase 21 será implementada agora
   (ela está zero, não parcial) — sem AAB assinado de release, não há artefato para publicar no
   Play Console em nenhum momento das Fases 34/38, independentemente de quão bem a integração
   Google Play Games em si for feita.
4. **Tratar os três relatórios fabricados** (`offline-first-report.md`,
   `analytics-validation.md`, `android-validation.md`) como não confiáveis para qualquer decisão
   de go/no-go futura — eles não documentam testes reais.

Em suma: o arco de gamificação Google Play (27-38) foi bem planejado do ponto de vista de
arquitetura e sequenciamento (a Fase 26 é evidência disso), mas está sendo construído sobre uma
fundação que o roadmap trata como concluída e que, na prática, é em grande parte esqueleto. O
risco não é teórico — é o tipo de risco que só aparece quando alguém tenta, pela primeira vez,
rodar `docker compose up`, exportar um AAB de release, ou jogar uma partida completa esperando
ver XP subir.
