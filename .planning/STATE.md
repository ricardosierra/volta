---
gsd_state_version: 1.0
milestone: v0.1
milestone_name: milestone
current_phase: 2
current_phase_name: Core Movement
current_plan: 0
status: in_progress
stopped_at: "Fase 2 re-executada em 2026-09-05: 7/7 planos, composition root real, 127 testes verdes, 4 gates de CI limpos. A fase NAO fecha: MOV-05 medido em Galaxy S23 e REPROVADO (p95 108-126 ms contra meta de 50 ms) e MOV-06 com zoom ainda estatico. Bug critico achado e corrigido no aparelho: a UI engolia todo toque e o jogo estava sem controle."
last_updated: "2026-09-05T19:30:46Z"
last_activity: 2026-09-05
progress:
  total_phases: 38
  completed_phases: 3
  total_plans: 107
  completed_plans: 23
  percent: 21
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-24)

**Core value:** Arcade mobile de conquista territorial em partidas de 90–180 s — sair da zona segura, desenhar o arco, fechar a volta e capturar — com controle que responde, bots com intenção legível e monetização que nunca vende vantagem.
**Current focus:** Phase 26 concluída (Google Play Discovery). Phase 27 (Gamification Foundation) aguarda planejamento antes de ser executada.

## Current Position

Current Phase: 26 (completa — 3/3 planos)
Current Phase Name: Google Play Discovery - Auditoria de Gamificação e Sidekick
Total Phases: 38
Current Plan: 3
Total Plans in Phase: 3
Status: Complete
Last Activity: 2026-08-31

Progress: [███████░░░] 68%

## Performance Metrics

**Velocity:**

- Total plans completed: 3
- Average duration: 38min
- Total execution time: 115min

**By Phase:**

| Phase | Duration | Tasks | Files |
|-------|----------|-------|-------|
| Phase 01 P01 | 15min | 2 tasks | 28 files |
| Phase 01 P02 | 20min | 2 tasks | 10 files |
| Phase 01 P03 | 21min | 2 tasks | 223 files |
| Phase 01 P04 | 12min | 2 tasks | 22 files |
| Phase 01 P8 | 8min | 2 tasks | 9 files |
| Phase 01 P05 | 28min | 2 tasks | 6 files |
| Phase 01 P6 | 6min | 1 tasks | 3 files |
| Phase 01 P07 | 12min | 2 tasks | 3 files |
| Phase 01 P09 | 6min | 2 tasks | 5 files |
| Phase 01 P10 | 20min | 3 tasks | 8 files |
| Phase 01 P11 | 15min | 2 tasks | 2 files |
| Phase 26 P01 | 55min | 3 tasks | 1 files |
| Phase 26 P02 | 50min | 3 tasks | 1 files |
| Phase 26 P03 | 45min | 2 tasks | 2 files |
| Phase 26.1 P01 | 20min | 2 tasks | 5 files |
| Phase 26.1 P02 | 17min | 2 tasks | 2 files |
| Phase 26.1 P04 | 8min | 2 tasks | 17 files |
| Phase 26.1 P05 | 17min | 4 tasks | 3 files |
| Phase 26.1 P03 | 25min | 3 tasks | 7 files |
| Phase 02 P01 | 15min | 2 tasks | 6 files |
| Phase 02 P02 | 20min | 2 tasks | 6 files |
| Phase 02 P03 | 30min | 3 tasks | 12 files |
| Phase 02 P04 | 50min | 2 tasks | 5 files |
| Phase 02 P05 | 25min | 3 tasks | 7 files |
| Phase 02 P06 | 35min | 3 tasks | 10 files |

## Accumulated Context

### Decisions

Decisões arquiteturais completas em `docs/decisions/ADR-0001..0014` e resumidas em
`.gsd/DECISIONS.md`. As que mais afetam a execução:

- **A simulação não conhece a apresentação.** `territory/`, `runner/`, `ai/` e `gameplay/` nunca importam `presentation/` ou `ui/` — é isso que permite rodar 500 partidas headless por noite.
- **Território é grid denso** (`PackedByteArray`) com flood fill **do exterior**, restrito à bounding box do Arc. O Arc precisa ser 4-conectado (traçado supercover) ou o fill vaza e captura o mapa inteiro.
- **Simulação a 60 Hz fixo**, render livre, interpolação visual manual. Nada de `await` no caminho de simulação — quebra o determinismo.
- **Auto-colisão dá Backwash, não morte.** O Arc reinicia na hora, para não virar rota de fuga. A lista de causas de morte é fechada (R5.7).
- **Nenhum número de gameplay no código.** Tudo em `.tres` sob `packages/shared/config/`, com os valores de `docs/design/balance.md`.
- **Dificuldade de bot por comportamento**, nunca por velocidade. `enemySpeed *= 2` é proibido.
- **Nada comprável altera a simulação.**
- [Phase 01-01]: check-project.sh ganhou filtro temporario e documentado para 'GutTest nao encontrado', ate o addon GUT ser instalado no Plano 01-03
- [Phase 01-01]: 2 links quebrados pre-existentes em 01-07-PLAN.md e 01-10-PLAN.md (falsos positivos de check_links.sh) logados em deferred-items.md, nao corrigidos por estarem fora do escopo deste plano
- [Phase 01]: [Phase 01-02]: Log e Bootstrap sem class_name (excecao de engine documentada); [autoload] fechado com exatamente Log entao Bootstrap
- [Phase 01]: [Phase 01-02]: flakiness transitoria em check-project.sh durante execucao paralela com 01-03 (race no cache .godot/ compartilhado), resolvida por retry, sem alterar script
- [Phase 01]: GUT pinado corrigido de v9.7.1 (exige Godot 4.7+) para v9.4.0 (compatível com Godot 4.3), conforme versions.json do proprio addon
- [Phase 01]: validate-repo.sh passou a excluir apps/mobile/addons/** (codigo de terceiros vendorizado) das checagens de nome/TODO/tamanho de arquivo
- [Phase 01]: [Phase 01-04]: .tres hand-written in Godot text-resource format for byte-exact balance.md values, no ResourceSaver round-trip
- [Phase 01]: [Phase 01-04]: ConfigValidator range bounds come from @export_range introspection, not hardcoded — same mechanism catches out-of-range and 'missing field' (zeroed below floor)
- [Phase 01]: lint.sh: heuristica de tipagem estatica (var/param/retorno) + H1 de docs, provada com 3 fixtures negativas reais
- [Phase 01]: test_bootstrap.gd (Plano 01-02) corrigido para := no lugar de var sem tipo; config_validator.gd (Plano 01-04) deixado fora de escopo, resolvido pelo proprio 01-04 em paralelo
- [Phase 01]: [Phase 01-05]: profile.json e settings.json sao arquivos independentes com a mesma primitiva _write_atomic/_load_with_recovery; corrupcao de um nunca afeta o outro (verificado por teste)
- [Phase 01]: [Phase 01-05]: JSON nao distingue int/float, e Dictionary/Array == no Godot e type-strict por elemento; testes de round-trip usam comparacao recursiva tolerante a numero em vez de == cru
- [Phase 01]: [Phase 01-06]: EventBus com 4 sinais tipados (sem emit por string) e trava de debug (5 emissoes/seg) via Build.is_debug(); GDScript captura lambda por valor, testes usam Array de 1 elemento como caixa mutavel
- [Phase 01]: [Phase 01-07]: PLACEHOLDER-XXX-NNN / Replacement: GSD NN e' same-line (confirmado contra uso real em TASKS.md); big_func exclui addons/** (GUT tem 12 funcoes >50 linhas de terceiros)
- [Phase 01]: [Phase 01-09]: setup_godot.sh separa TAG (hifen, ex. 4.3-stable) de VERSION (ponto, ex. 4.3.stable) via VERSION/.stable/-stable; nunca misturar os dois nomes de asset/diretorio
- [Phase 01]: [Phase 01-09]: client-ci.yml ganhou passo check-project.sh (Rule 2 - nao estava no texto literal da tarefa, mas fecha a lacuna entre 'pipeline completo' e o que realmente rodava); branch protection documentada como pendencia humana, nao fabricada como feita (sem git remote configurado)
- [Phase 01]: [Phase 01-10]: export_presets.template.cfg precisa de export_filter/include_filter/exclude_filter/script_export_mode (Godot 4.3 le sem default, nao estava no texto literal do plano); project.godot precisa de rendering/textures/vram_compression/import_etc2_astc=true ou o export Android falha com config_error vazio (bug de mensagem do Godot 4.3, rastreado no source upstream) — sem essa flag, build_android.sh debug nunca produz APK
- [Phase 01]: [Phase 01-10]: PLACEHOLDER-ART-006 documentado em dev_overlay.gd, nao em main.tscn, porque .tscn nao aceita comentario de linha arbitrario — exatamente o fallback que o proprio plano ja previa
- [Phase 01]: [Phase 01-11]: nenhum Android real conectado (adb devices vazio em 2026-08-25); checkpoint humano DEFERIDO conforme fallback do risco F01-07 — device-results.md linha Phase 1 permanece _pendente_, gate registrado explicitamente em Blockers/Concerns, A01-12/A01-13/A01-14 e Success Criterion 6 do ROADMAP continuam abertos ate um humano rodar o APK num aparelho fisico
- [Phase 26-01]: engine real do projeto e Godot 4.7.2 (migrada do 4.3 no commit 477fd96), mas CLAUDE.md e docs/mobile/android.md ainda citam 4.3 — debito de documentacao registrado em docs/google-play/compatibility-audit.md, nao corrigido por estar fora do escopo (fase de auditoria, sem tocar codigo/doc fora de docs/google-play/)
- [Phase 26-01]: nenhum evento de dominio de gameplay existe hoje no EventBus (apps/mobile/src/core/events/README.md confirma) — gap central que a Fase 27 precisa fechar; eventos hoje sao so signals locais dispersos (MatchDirector.match_ended, EliminationService.runner_eliminated, AchievementService.achievement_unlocked etc.)
- [Phase 26-01]: regra de camadas e aplicada por grep textual na secao 7 de tools/ci/validate-repo.sh, nao por um tools/ci/check_layering.gd (nao existe, apesar de docs/architecture/overview.md cita-lo); nao existe nenhuma checagem de CI para "sem await no caminho de simulacao" — risco para I/O assincrono de SDK do Play Games
- [Phase 26-01]: bug real pre-existente encontrado (nao corrigido, fora de escopo de auditoria): RemoteProfileRepository.load_profile() chama local_cache.load_profile(), metodo que nao existe em LocalProfileRepository (so tem get_profile())
- [Phase 26-01]: QLT-06 (requisito do plano) NAO foi marcado completo em REQUIREMENTS.md — a fase 26 tem 3 planos e so o 01 terminou; QLT-06 cobre a fase inteira (26-38), sera fechado quando o ultimo plano relevante fechar, nao antes
- [Phase 26-02]: WebSearch/WebFetch nao estavam disponiveis neste executor; pesquisa ao vivo feita via curl+pandoc contra developer.android.com/developers.google.com/play.google.com, mesma garantia de "nada de memoria" exigida pelo plano (cada linha com URL + "Consultado em: 2026-08-31")
- [Phase 26-02]: achado critico — NAO existe "Quests API" nem "LiveOps API" do Google (4 URLs candidatas retornaram 404); Quests/Leagues/Social Challenges sao mecanicas server-side do Google construidas sobre Achievements API + Game Stats API + Play Games Rewards que o jogo ja envia — a Fase 33 precisa continuar usando o backend proprio de seasons/quests do VOLTA (season service da Fase 25), nao um SDK de quests que nao existe
- [Phase 26-02]: achados de data: Game Stats UI publica ("You tab") so vira GA em setembro/2026 (hoje still beta/teste); Play Games Rewards so entra em vigor em 01/09/2026 (1 dia apos a pesquisa); Level Up tem rate card com rollout regional faseado a partir de 30/set/2026
- [Phase 26-02]: Play Points e Play Pass confirmados invite-only/curated (allowlist e "express interest", respectivamente) — Fase 31/33 nao podem presumir acesso automatico; FAQ oficial de Play Pass tem informacao de disponibilidade regional aparentemente desatualizada, registrada como Nao confirmado
- [Phase 26-02]: export Android do VOLTA usa gradle_build/use_gradle_build=false — nao ha build.gradle customizado hoje para adicionar dependencies Java de PGS v2/Recall/Play Integrity; pre-requisito tecnico transversal para o Plano 03 decidir
- [Phase 26-03]: arquitetura validada — Gamification Engine mora em progression/gamification/ (novo), nunca abaixo de core/; gameplay/territory/runner/ai nunca chamam SDK Google direto, so emitem via EventBus (apps/mobile/src/core/event_bus.gd), mesmo a regra de camadas permitindo gameplay->platform diretamente (decisao de arquitetura, nao lacuna da regra)
- [Phase 26-03]: OfflineQueue (apps/mobile/src/platform/api/offline_queue.gd) confirmado sem flush/drain hoje; fila nova pending_game_events da Fase 27 precisa suprir isso, nao so copiar o padrao existente
- [Phase 26-03]: parecer final Go para a Fase 27, com 4 bloqueadores nomeados (Gradle build customizado -> Fase 28; Play Points/Play Pass invite-only -> Fase 31; ausencia de Quests API -> Fase 33; achievements badge de tracao -> Fase 34) e H-02 mapeada para bloquear Fases 34/38, nao a 27 — Fase 26 encerrada (3/3 planos), docs/google-play/compatibility-audit.md completo (secoes 1-8) e docs/google-play/architecture.md criado
- [Phase 26-03]: gsd-tools `state advance-plan` tambem corrompe STATE.md neste repo (zerou completed_phases para 2 e completed_plans para 14 ao rodar) — adicionado a lista de comandos a evitar; STATE.md/ROADMAP.md seguem editados a mao
- [Phase 26.1-01]: Regra 7 do quality gate corrigida por inversao de dependencia (nao supressao): match_director.gd emite runner_spawned(runner), RunnerViewSpawner (presentation/) escuta e cria a RunnerView; root.gd conecta os dois como composition root. Texto do plano para o comentario de rastreio continha a propria substring 'presentation/' que o grep da Regra 7 varre — reescrito como 'camada de apresentacao' para nao autoinvalidar a correcao.
- [Phase 26.1-01]: execucao paralela de ate 5 planos da fase 26.1 na mesma arvore/indice git causou corridas reais: minhas mudancas de match_director.gd e do teste novo foram varridas para dentro de commits de outros planos (efcb19a, df97838) por `git add` deixado no indice compartilhado durante um comando longo (test-client.sh). Conteudo conferido identico. A partir dai, commits passaram a usar `git add <path> && git commit` em sequencia imediata (sem comandos longos no meio) e, quando possivel, `git commit -m ... -- <path>` para nao depender do indice compartilhado — mesmo padrao adotado independentemente pelo plano 02 (ver deferred-items.md da fase).
- [Phase 26.1-02]: SealSolver.solve() (102 linhas) decomposto em _compute_bounding_box/_flood_fill_exterior/_collect_captured_cells/_enqueue_if_exterior, todas < 50 linhas, sem mudar nenhuma condicao/ordem/valor — provado por 4 testes de caracterizacao (test_seal_solver.gd) escritos e comprovados 4/4 verdes ANTES de tocar no arquivo, e continuam 4/4 depois. Nenhum bug de logica encontrado na leitura linha a linha.
- [Phase 26.1-02]: mesma corrida de indice git compartilhado do plano 01 confirmada do outro lado: test_seal_solver.gd (staged, nao commitado) foi varrido para dentro de efcb19a (commit do plano 05); ao corrigir a atribuicao do .uid que faltava, um git commit sem pathspec arrastou por engano arquivo do plano 01 (test_match_director_runner_spawned.gd) — corrigido com `git reset <hash-fixo> -- <path>` (nunca HEAD^, que e relativo e mudou de commit no meio por causa de outro commit concorrente) devolvendo o indice ao estado igual ao HEAD, sem apagar arquivo de outro plano do disco. `git rm --cached` esta bloqueado pelo sandbox de permissoes deste ambiente. A partir dai todo commit usou `git commit -m ... -- <caminho-absoluto>` (compara working-tree vs HEAD so no caminho dado, ignora o resto do indice compartilhado).
- [Phase 26.1-04]: os 17 arquivos promovidos (balance/bonuses.tres, bots/, modes/, quality/) nao tinham nenhum .import/.uid do lado do app dentro dessas pastas — a excecao prevista no plano para arquivos gerados pelo Godot nao foi necessaria; `diff -r` saiu vazio na primeira tentativa e sync_config.sh comprovadamente idempotente.
- [Phase 26.1-05]: regra 4 do validate-repo.sh ganhou limite de palavra a direita `TODO([^A-Za-z]|$)` — deixa de casar TODOS/TODOs em portugues e a string literal do proprio check_release_build.sh (agora excluido por caminho), continua pegando TODO real (provado por prova negativa: arquivo temporario com TODO sem referencia de tarefa foi reprovado, depois removido).
- [Phase 26.1-05]: bug real adicional achado ao corrigir RemoteProfileRepository.load_profile() -> get_profile(): `UUID.v4()` (usado em save_profile() para idempotency_key) referenciava uma classe que nunca existiu no projeto, quebrando a compilacao do arquivo inteiro (confirmado com `godot --check-only`). Corrigido com um gerador de UUID v4 local ao proprio arquivo (sem criar classe/arquivo compartilhado, fora do escopo do plano). O mesmo bug existe em remote_leaderboard_repository.gd (fora do files_modified de qualquer plano desta fase) — registrado em deferred-items.md, nao corrigido.
- [Phase 26.1-05]: confirmando o padrao de corrida de indice ja descrito pelos planos 01/02: `git add tools/ci/validate-repo.sh` + `git commit -m` sem pathspec (Task 1) varreu match_director.gd (plano 01) e test_seal_solver.gd (plano 02) para dentro de efcb19a. Conteudo conferido intacto para os tres; nao reescrevi historico (ja havia commit de outro plano em cima). A partir da Task 3 usei `git commit -m ... -- <caminho>` isolado em cada commit.
- [Phase 26.1-03]: match_screen.gd (867 linhas, 3 funcoes >50) decomposto em MatchHudBuilder (fabrica de HUD/overlay) e MatchFieldRenderer (desenho de campo), ambos RefCounted so com static func, sem estado proprio — parent/canvas e Dictionary de estado recebidos por parametro para nao mudar nenhum valor/cor/offset/ordem de add_child ou draw_*; arquivo cai para 588 linhas. main_menu_screen.gd: on_pushed() (55 linhas) dividido em _build_title_block()/_build_play_controls(). _hud_header_top()/_safe_bottom_inset() preservados dentro de MatchScreen de proposito (bug pre-existente fora do escopo de QLT-06, ja registrado pela auditoria da Fase 26).
- [Phase 26.1-03]: mesma corrida de indice git compartilhado ja descrita pelos planos 01/02/05: `git add` dos meus 3 arquivos da Task 2 tambem capturou uma exclusao (D) de test_match_director_runner_spawned.gd staged pelo plano 01 — corrigido com `git restore --staged <path>` nos dois caminhos (arquivo .gd e .uid) antes de commitar, sem tocar no worktree. Confirmado por `git diff --cached --name-status` antes de cada commit.
- [Phase 02-02]: game_state.gd ganhou fsm.add_transition(Id.BOOT, Id.LOADING), fechando as 11 transicoes de docs/architecture/state-machines.md par.2; ArenaDefinition ganhou width_cells/height_cells/cell_size (default 128/128/16.0) + get_pixel_size(), que arena.gd ja chamava sem existir (bug real de runtime); open_field.tres corrigido de 100x100@32 com campo orfao blocked_cells para 128x128@16 (2048x2048), uid preservado; as 4 arenas da Fase 13 (archipelago/crossroads/halo/rift) confirmadas intocadas.
- [Phase 02-02]: teste de GameState fora da arvore precisa de add_child_autofree(gs) em vez de chamar gs._ready() direto — PausedState.new(get_tree()) reclama "Parameter data.tree is null" se o Node nunca entrou na SceneTree; assert(false) de transicao invalida em StateMachine.request vira erro de engine no GUT, consumido com assert_engine_error_count (contagem cumulativa por chamada — soma-se uma vez, com o total, apos o loop, nao a cada iteracao).
- [Phase 02-01]: StatBlock/Runner fechavam a lacuna MOVE-003 (literais 300.0/180.0 em vez de RunnerBalance 220.0/540.0); Bootstrap ganhou o passo "config" (ConfigService.new()+load_all(), primeiro da lista), resolvivel via Bootstrap.registry.resolve("config") no jogo real — desbloqueia o Plano 02-05 (MatchDirector) sem precisar de um segundo mecanismo de acesso a config.
- [Phase 02-01]: lambda multilinha (3 instrucoes) dentro de dict aninhado em array literal quebra o parser do GDScript 4.7 ("Unindent doesn't match the previous indentation level", confirmado com --check-only) — a fabrica do passo "config" precisou virar metodo privado nomeado (_make_config_service()) chamado por uma lambda de uma linha, em vez da lambda multilinha inline que o texto do plano especificava; mesmo comportamento, so muda a forma da factory.
- [Phase 02-02]: variante nova da corrida de indice/arquivo compartilhado (alem da ja documentada em git add+commit sem pathspec): STATE.md/ROADMAP.md/REQUIREMENTS.md sao editados a mao por CADA plano em paralelo, e `git commit -m ... -- <path>` comita o CONTEUDO ATUAL do arquivo no disco, nao um snapshot exclusivo do meu proprio plano — o commit `72fe091` (plano 02-01) rodou depois que eu tinha escrito minhas edicoes de 02-02 nesses 3 arquivos e acabou levando as duas juntas (verificado com `git show 72fe091` — conteudo de ambos os planos presente e correto). Meu commit de fechamento (`133eddb`) ficou so com o SUMMARY.md porque os 3 arquivos ja nao tinham diff contra HEAD nesse ponto. Nada foi perdido, mas o pathspec no commit NAO protege um arquivo de metadado compartilhado contra ficar com o credito trocado entre planos — so protege contra arrastar arquivos de OUTROS planos para dentro do commit errado.
- [Phase 02-01]: bug de teste (nao de codigo) no caso-limite de virada de 180 graus: rotate_toward() do Godot resolve a ambiguidade UP->DOWN sempre girando no sentido negativo (wrapf(PI,-PI,PI)==-PI), entao angle_to() um tick antes de completar e negativo, nao positivo — assert_gt precisou comparar absf(angle_to(...)) em vez do valor bruto; a asserção final de completude (angulo == 0 no tick previsto) nao mudou.
- [Phase 02-03]: InputRouter ganhou InputBuffer interno no caminho de poll_direction() (ADR-0014) e SwipeDriver ganhou mm_to_px() estatico testavel sem DisplayServer real; InputRouter passou a rastrear _last_pushed_direction para so enfileirar quando a direcao muda de fato — sem isso, o toque inicial e o toque solto empurravam a direcao "parada" como comando fantasma, na frente do comando real do arraste seguinte (achado pelo proprio teste que o plano pediu). 19 testes novos (test_input_router, test_swipe_driver, test_input_buffer, test_joystick_driver, test_relative_driver) provam InputBuffer (MOVE-006) e paridade de qualidade dos 3 esquemas de controle (MOVE-007) sem mudar InputBuffer/JoystickDriver/RelativeDriver.
- [Phase 02-03]: test_build.gd::test_version_matches_project_settings falha de forma pre-existente e estavel (project.godot tem config/version="0.1.2" do release F-Droid, commit 480eef0, anterior a este plano; teste espera "0.1.0") — fora do escopo de apps/mobile/src/input/, registrado em .planning/phases/02-core-movement/deferred-items.md, nao corrigido.
- [Phase 02-04]: RunnerView passou a extends InterpolatedVisual (nao mais Node2D vazio), amostrando Runner.state a cada _physics_process e delegando a interpolacao ao _process() herdado; circulo provisorio em _draw() rastreado como PLACEHOLDER-ART-001/Replacement: GSD 08. RunnerViewSpawner guarda view.runner = runner em vez de so copiar a posicao de spawn uma vez. Testes do Runner usam Runner.new() com 3 argumentos (sem o balance opcional que o Plano 02-01, paralelo, adiciona) para nao depender da ordem de conclusao entre planos da mesma wave.
- [Phase 02-04]: bug real corrigido em GameCamera._process(): o clamp de borda (clamp(value,min,max)) invertia min>max sempre que a metade da viewport excedia a metade da Arena num eixo, colando a camera num canto arbitrario — exposto pelo proprio teste de borda usando a viewport real do runner GUT headless (1920x1920, medida em runtime, nao suposta). Extraido _clamp_to_arena_axis(): centraliza nesse eixo quando o clamp seria invalido, comportamento normal preservado para arenas maiores que a viewport (caso real de producao, ex. open_field.tres 2048x2048 do Plano 02-02). setup(balance, arena) agora aplica follow_smoothing/lookahead/zoom_base reais de CameraBalance (8.0/90.0/1.0), removendo os @export inventados (5.0/150.0).
- [Phase 02-05]: MatchDirector ganhou configure(config, arena_definition, router) (injecao de dependencia do composition root, defaults seguros quando nao chamado) e setup_match() passou a criar sempre um Runner de jogador (id 0, sem BotBrain) ANTES dos bots — runner_spawned/runners.size() viram bot_count+1 em qualquer configuracao, inclusive zero bots; step() aplica input_router.poll_direction() no jogador, tick(delta) em todos os Runners e arena.resolve_boundaries() quando configurada, na ordem fixa CMBT-007; o Camera2D cru dentro de gameplay/ foi removido.
- [Phase 02-05]: root.gd virou o composition root completo da fase: ScreenStack passou a viver dentro de um CanvasLayer proprio (risco descoberto no proprio plano — sem isso, a Camera2D real que passou a existir afetaria a UI inteira, panando/dando zoom junto com o jogo); ConfigService resolvido uma unica vez de Bootstrap.registry.resolve("config"); InputRouter/MatchDirector/RunnerViewSpawner/GameCamera criados e ligados na ordem que respeita as dependencias de cada um (configure() antes de setup_match(), watch() antes de setup_match(), GameCamera.setup()+make_current() antes do loop que acha a RunnerView do jogador).
- [Phase 02-05]: ./tools/ci/lint.sh tem debito de tipagem estatica pre-existente (confirmado identico em HEAD via git stash) em arquivos totalmente fora do escopo deste plano (gameplay/score/*, progression/**, presentation/** fora dos tocados aqui, arena/arena.gd, input/input_buffer.gd, runner/states/*_state.gd) — registrado em deferred-items.md, nao corrigido (Scope Boundary); os 7 arquivos deste plano passam limpos isoladamente. MOV-01 marcado completo em REQUIREMENTS.md (simulacao 60Hz fixa com Runner real + interpolacao ja entregue pelo 02-04, agora fiada de ponta a ponta).
- [Phase 02-06]: MatchScreen caiu de 588 para 198 linhas — removido todo o loop de brinquedo (_update_player/_update_bots/_resolve_combat/_seal_trail/_eliminate_bot/_check_win/_read_direction/_input(event)/_set_gesture_direction/_direction_for_key/_polyline_hits_circle/_distance_to_segment com PLAYER_SPEED/BOT_SPEED hardcoded); a tela agora so le MatchDirector.game_state/time_elapsed/runners via set_match_director()/set_input_router(), ligados por root.gd apos setup_match(). Bug pre-existente da Fase 26.1 corrigido: _hud_header_top()/_safe_bottom_inset() (chamados sem nunca terem sido definidos) agora implementados com DisplayServer.get_display_safe_area(), mesmo padrao de safe_area_container.gd.
- [Phase 02-06]: PauseScreen e ResultsScreen (stubs vazios da Fase 7) ganharam UI real; ResultsScreen passou a extends Screen (era Control) para ser empilhavel. SettingsControls tambem passou a extends Screen com botao Fechar emitindo exit_requested herdado, ligada ao InputRouter real via driver_changed -> set_driver (test drive ao vivo). MatchHudBuilder perdeu territory/kills/overlay de resultado (fim de partida agora e ResultsScreen); MatchFieldRenderer so desenha a moldura do campo (Runners vem de RunnerView real). BL-019/020/021 registrados no BACKLOG para trilha/captura visual (Fase 3), feedback de eliminacao (Fase 4) e placar real/restart sem menu (Fase 6).
- [Phase 02-06]: ordem de execucao entre tasks do mesmo plano (nao arquivo compartilhado entre planos): Task 2 removeu build_result_overlay() de match_hud_builder.gd, que match_screen.gd (so reescrito na Task 3) ainda chamava — se rodado isoladamente entre as duas tasks, test-client.sh quebraria por erro de compilacao em cascata. Mesmo padrao ja registrado no Plano 02-05: verificacao completa (test-client/validate-repo/lint) rodada uma unica vez com as edicoes de Task 2 e Task 3 juntas na arvore, commits separados por pathspec exato do files_modified de cada task. 119/119 testes verdes ao final, validate-repo.sh 10/10.


- [Phase 02]: BUG CRITICO achado so no aparelho, com 124 testes headless verdes: ScreenStack (Control full rect) nunca setava mouse_filter, ficava com o MOUSE_FILTER_STOP padrao e consumia todo toque; o InputRouter escuta _unhandled_input e nunca era chamado — o jogo estava SEM CONTROLE no Android. root.gd tinha o mesmo problema e a MatchScreen so setava IGNORE dentro de on_pushed(). Corrigido em f0be3b2 com regressao ponta a ponta (test_touch_reaches_input_router.gd) que empurra o evento por get_tree().root.push_input() em vez de chamar o InputRouter direto — que era exatamente por que a suite nao pegava.
- [Phase 02]: o texto do plano 02-07 definia a amostra de latencia como "view chega a 2 graus da direcao desejada", o que mede a DURACAO DO GIRO (540 graus/s => 167ms para 90 graus), nao a latencia; p95 < 50ms seria impossivel por construcao. docs/gameplay/controls.md e autoritativo e diz "toque -> mudanca de direcao", entao a amostra passou a fechar na primeira mudanca visivel (> 0.5 grau). Antes: p50 141.7/p95 174.1. Depois: p50 75.1/p95 108.0.
- [Phase 02]: MOV-05 REPROVADO com medicao real (Galaxy S23, toque sintetico via adb): swipe p95 108.0ms, joystick 109.0ms, relativo 126.4ms. Todas as ressalvas trabalham a favor da meta (adb subestima ~5-15ms do digitalizador; S23 e tier High e o alvo e Mid), entao o vao de 58ms e real. Investigar a origem dos ~75ms de p50 e trabalho de fase propria.
- [Phase 02]: lint.sh estava vermelho com 155 violacoes de tipagem em 63 arquivos herdados das fases 3-25 (fora do escopo da fase, mas e um dos tres gates obrigatorios do CLAUDE.md secao 3 — toda fase futura fecharia com check reprovando). Zerado. Onde ':=' nao infere, tipo explicito: get_meta() devolve Variant, pop_front()/back() em Array devolvem Variant, 'var x := null' precisa da classe.
- [Phase 02]: gsd-tools phase-plan-index casa o SUMMARY pelo id COMPLETO do plano — 02-02-SUMMARY.md nao e detectado, 02-02-fsm-arena-foundation-SUMMARY.md e. Dois planos abreviaram e a fase parecia inacabada; corrigido com git mv.

### Auditoria de 2026-08-31 (reabertura das fases 2-25)

- `apps/mobile/src/core/bootstrap.gd` registra 6 de 32 servicos; so ha 2 autoloads (Bootstrap, Log).
- `match_ended` (`match_director.gd:126`) nao tem nenhum ouvinte conectado.
- `SealSolver`/`SealApplier` (captura de territorio, Fase 3) tem zero chamadores — `match_director.gd:25` tem so o comentario `# 5. resolve seals`.
- `SurgeService` (Fase 6, MVP), `PowerUpService` (Fase 14, Alpha), `SfxService` (Fase 9), `MatchRules` (Fase 12) e todo o pipeline de analytics (Fase 18) tem zero referencias.
- `services/api/` nao e projeto Laravel executavel (sem composer.json/artisan).
- `tools/ci/build_android.sh:27-29` — ramo release sai com `exit 1`.
- `.github/workflows/godot-ci.yml:15` roda `simulate.gd`, que imprime "All 2500 simulations passed" sem instanciar partida.
- Relatorios fabricados em `docs/reports/` reescritos com o estado real (commit e6803b5).
- Fase 13 (arenas) e Fase 1 sao as unicas partes confirmadamente solidas.
- Relatorios: `.planning/AUDIT-PHASES-10-25.md`, `.planning/audit/AUDIT-11-14.md`, `AUDIT-17-20.md`, `AUDIT-22-25.md`.

### Roadmap Evolution
- Phase 26 added: Google Play Discovery - Auditoria de Gamificação e Sidekick
- Phase 27 added: Gamification Foundation - Eventos de Dominio e Integracao
- Phase 28 added: Play Games Services v2 e Autenticacao
- Phase 29 added: Sistema de Conquistas e Progression Loop
- Phase 30 added: Game Stats e Integracao Analytics
- Phase 31 added: Gamificacao Avancada - XP Quests e Rewards
- Phase 32 added: Leaderboards e Social Engagement
- Phase 33 added: LiveOps - Seasons e Quests Dinamicas
- Phase 34 added: Google Play Games Sidekick - Integracao Completa
- Phase 35 added: Seguranca Anti-cheat e Play Integrity
- Phase 36 added: QA Gamificacao e Sidekick
- Phase 37 added: Performance Gamificacao e Otimizacao
- Phase 38 added: Release - Rollout Google Play Games

### Pending Todos

- Backlog completo em `.gsd/BACKLOG.md` (18 itens adiados, 7 placeholders e 5 mocks rastreados, todos com fase de destino).

### Blockers/Concerns

- [Phase 1] GATE ABERTO (F01-07): `dist/android/volta-debug.apk` foi gerado (Plano 01-10) mas ainda NÃO foi instalado/verificado num Android real — A01-12/A01-13/A01-14 e Success Criterion 6 pendentes. Para fechar: conectar um Android (tier Mid), `./tools/ci/build_android.sh debug` se o APK não existir mais, `adb install -r dist/android/volta-debug.apk`, seguir o roteiro de 01-11-PLAN.md Task 2 e preencher a linha Phase 1 de docs/performance/device-results.md.
- [Phase 2] **MOV-05 REPROVADO, não pendente.** Medido em 2026-09-05 num Galaxy S23 (SM-S911B): swipe p95 108,0 ms · joystick 109,0 ms · relativo 126,4 ms, contra meta dura de 50 ms em `docs/gameplay/controls.md`. O melhor caso é 2,2× a meta e as ressalvas (toque sintético via adb, tier High em vez de Mid) trabalham a favor da meta. Precisa de uma fase de otimização de latência — candidatos: quantização do tick de 60 Hz, cadeia `_unhandled_input`→`InputBuffer`→`poll_direction`, e separar o custo de injeção do adb com medição de dedo real.
- [Phase 2] MOV-06 não fecha: `GameCamera` tem follow e lookahead, mas o zoom é estático — falta o "zoom dinâmico" do requisito.
- [Phase 2] FPS em tier Mid e Low e o teste de sensação com 3 pessoas seguem pendentes (só havia um aparelho High disponível; sensação exige gente de fora jogando).
- [Phase 2] A moldura de campo da `MatchScreen` não coincide com onde os `RunnerView`s aparecem (tela vs. mundo sob a `GameCamera`) — precisa de dono antes de a Fase 3 desenhar território.
- [Phase 15] Hospedagem da API e domínio dependem de decisão humana (H-03). Desenvolvimento roda em Docker local, então não bloqueia.
- [Phase 21] Busca de anterioridade da marca "VOLTA" é decisão humana (H-01) com prazo **antes** desta fase.
- [Phase 21/22] Contas Google Play e Apple Developer são decisão humana (H-02).

## Session Continuity

Last session: 2026-09-05
Stopped at: Completed 02-06-match-screen-desimulation-PLAN.md (Wave 3, depende do 02-05 ja concluido). MatchScreen parou de rodar sua propria simulacao (588 -> 198 linhas) e passou a mostrar o MatchDirector/RunnerView reais; PauseScreen/ResultsScreen/SettingsControls viraram telas empilhaveis reais com navegacao PAUSAR/CONTROLES/DESISTIR completa; bug pre-existente de safe area corrigido. 119/119 testes verdes, validate-repo.sh 10/10. Falta 02-07 (fechamento da fase, com checkpoint humano de verificacao visual) para a Fase 2 completar.
Resume file: .planning/phases/02-core-movement/02-06-match-screen-desimulation-SUMMARY.md
