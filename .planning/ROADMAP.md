# Roadmap: VOLTA

## Milestones

- 🚧 **v0.1.0** — Phases 1–25 (in progress)
  - MVP fecha na Phase 6 · Alpha na Phase 14 · Beta na Phase 20 · Release na Phase 24

**Fonte autoritativa de cada fase:** `.gsd/phases/NN-*/` (README, REQUIREMENTS, TASKS,
ACCEPTANCE, TESTS, RISKS). O plano detalhado já existe — as fases são de **execução**, não
de descoberta.

## Phases

- [ ] **Phase 1: Repository Foundation** — projeto Godot, config em dados, save, log, CI e verificadores
- [ ] **Phase 2: Core Movement** — tick fixo, Runner, três esquemas de input, câmera, FSM do jogo
- [ ] **Phase 3: Territory Engine** — grid, Arc rasterizado, flood fill, Seal, render incremental
- [ ] **Phase 4: Combat & Elimination** — Break, Backwash, Squeeze, respawn, aviso de ameaça
- [ ] **Phase 5: Bot AI** — IA por utilidade, 4 arquétipos, 3 dificuldades, stress test
- [ ] **Phase 6: Complete Match Loop** — countdown, score, Surge, resultado, restart (MVP)
- [ ] **Phase 7: UI/UX Foundation** — design system, telas, navegação, settings, i18n, onboarding
- [ ] **Phase 8: Art Direction** — paletas, shaders, zero placeholder, presets de qualidade
- [ ] **Phase 9: Game Feel & Polish** — VFX, câmera, háptico, SFX, música adaptativa
- [x] **Phase 10: Progression** — perfil, XP, ranks, estatísticas, conquistas, desafios (completed 2026-08-25)
- [x] **Phase 11: Cosmetics** — skins, Arc styles, temas, efeitos de Seal, desbloqueio (completed 2026-08-26)
- [x] **Phase 12: Additional Game Modes** — Time Attack, Survival, Domination, Endless (completed 2026-08-26)
- [x] **Phase 13: Maps & Arena Variations** — Archipelago, Rift, Crossroads, Halo (completed 2026-08-26)
- [x] **Phase 14: Power-ups** — os 6 power-ups com contra-jogo (fecha Alpha) (completed 2026-08-26)
- [x] **Phase 15: Backend Foundation** — Laravel, auth, score validado, leaderboard, cloud save (completed 2026-08-26)
- [x] **Phase 16: Online Services** — repositórios remotos, fila offline, leaderboard, cloud save (completed 2026-08-26)
- [x] **Phase 17: Multiplayer Architecture** — servidor autoritativo headless (protótipo medido) (completed 2026-08-26)
- [x] **Phase 18: Analytics & Telemetry** — eventos, crash reporting, métricas de performance (completed 2026-08-26)
- [x] **Phase 19: Optimization** — profiling, orçamentos, memória, carregamento, bateria (completed 2026-08-26)
- [x] **Phase 20: Accessibility & Device Compatibility** — matriz de aparelhos, a11y (fecha Beta) (completed 2026-08-26)
- [x] **Phase 21: Android Release** — AAB assinado, ícones, permissões, Data Safety, loja (completed 2026-08-26)
- [x] **Phase 22: iOS Release** — Xcode, assinatura, Privacy Label, TestFlight, loja (completed 2026-08-26)
- [x] **Phase 23: Production Readiness** — QA, regressão, migração de save, rollback (completed 2026-08-26)
- [ ] **Phase 24: Launch** — versão, changelog, tag, rollout gradual, monitoramento
- [ ] **Phase 25: Post Launch** — balanceamento por dados, monetização, temporadas, conteúdo

## Phase Details

### Phase 1: Repository Foundation
**Goal**: O projeto Godot abre, roda num Android real, tem configuração orientada a dados, save resiliente, logging estruturado, testes headless e CI que reprova quem quebra as convenções
**Depends on**: nothing
**Requirements**: FND-01, FND-02, FND-03, FND-04, FND-05, FND-06
**Canonical refs**: `.gsd/phases/01-repository-foundation/`, `docs/architecture/overview.md`, `docs/architecture/save-system.md`, `docs/architecture/configuration.md`, `docs/architecture/logging.md`, `docs/decisions/ADR-0001-engine.md`, `docs/decisions/ADR-0003-save-system.md`, `docs/decisions/ADR-0013-testing-stack.md`
**Success Criteria** (what must be TRUE):
  1. `godot --headless --path apps/mobile --check-only` roda sem erro nem warning, com a versão pinada em `.godot-version` (4.3.stable) e renderer `mobile`, stretch `canvas_items/expand`, resolução base 1080×1920, portrait travado e `physics_ticks_per_second = 60`
  2. `ConfigService` carrega os `.tres` de `packages/shared/config/balance/` com os valores de `docs/design/balance.md`, valida faixas e rejeita config inválida (3 testes: válida, fora de faixa, campo ausente)
  3. `SaveService` passa em 6 testes: round-trip, escrita atômica interrompida, JSON corrompido → backup, backup ruim → recriação preservando arquivos como `.corrupt-*`, migração fake 1→2, campo desconhecido preservado
  4. `./tools/ci/validate-repo.sh` detecta as 8 violações que promete — provado por 8 casos plantados em `tests/tools/` que fazem o script **falhar**
  5. `./tools/ci/test-client.sh` roda GUT headless e retorna código ≠ 0 quando um teste falha; `./tools/ci/lint.sh` reprova arquivo GDScript sem tipagem estática
  6. Um APK de debug instala num Android real, abre em menos de 1,5 s, mostra versão e FPS, mantém 60 FPS e respeita safe area; resultado registrado em `docs/performance/device-results.md`
**Plans:** 11/11 plans executed

Plans:
- [x] 01-01-PLAN.md — Scaffold do projeto Godot 4.3 (project.godot, .godot-version, estrutura de src/) + Build/BuildFlags
- [x] 01-02-PLAN.md — Log (autoload, categorias/níveis, rotação de arquivo) + ServiceRegistry/Bootstrap (autoload)
- [x] 01-03-PLAN.md — GUT instalado em addons/ + tools/ci/test-client.sh
- [x] 01-04-PLAN.md — 6 Resources de balance + ConfigService/ConfigValidator + sync_config.sh
- [x] 01-05-PLAN.md — SaveService (escrita atômica, recuperação de corrupção, migração encadeada)
- [x] 01-06-PLAN.md — EventBus (sinais tipados, limite de emissão em debug)
- [x] 01-07-PLAN.md — validate-repo.sh (10 regras) + prova negativa em tests/tools/
- [x] 01-08-PLAN.md — lint.sh (tipagem estática GDScript + título H1 de docs) + prova negativa
- [x] 01-09-PLAN.md — tools/ci/setup_godot.sh + validate.yml/client-ci.yml
- [x] 01-10-PLAN.md — Cena principal (main.tscn + DevOverlay) + build_android.sh debug + device-results.md
- [x] 01-11-PLAN.md — Checkpoint: confirmação em Android real (cold start, FPS, safe area) — DEFERIDO: nenhum aparelho conectado, pendência explícita em STATE.md (F01-07)

### Phase 2: Core Movement
**Goal**: O Runner navega pela arena com controle que responde — latência abaixo de 50 ms, simulação determinística a 60 Hz e câmera que ninguém percebe
**Depends on**: Phase 1
**Requirements**: MOV-01, MOV-02, MOV-03, MOV-04, MOV-05, MOV-06, MOV-07
**Canonical refs**: `.gsd/phases/02-core-movement/`, `docs/gameplay/controls.md`, `docs/architecture/state-machines.md`, `docs/decisions/ADR-0006-movement-model.md`, `docs/decisions/ADR-0014-simulation-tick-model.md`, `docs/design/balance.md` §2 e §11
**Success Criteria** (what must be TRUE):
  1. A simulação roda em `_physics_process` a 60 Hz fixo e produz o mesmo estado final em 10 execuções com a mesma seed e os mesmos inputs, **sem instanciar nenhum nó visual** (teste headless de 600 ticks)
  2. O Runner tem posição e direção contínuas com taxa máxima de giro vinda de `RunnerBalance`; inverter 180° leva exatamente `180/turn_rate` segundos
  3. Os três esquemas de input (swipe com zona morta em mm físicos, joystick flutuante, relativo) produzem apenas um vetor de direção — nenhum `InputEvent` chega ao Runner — e podem ser trocados em runtime com test drive ao vivo
  4. O buffer de input executa dois comandos recebidos no mesmo tick na ordem correta e descarta comando velho por idade
  5. `latency_test` mede p95 < 50 ms nos três esquemas, em dispositivo real, e o número está em `docs/performance/device-results.md`
  6. A FSM do jogo cobre Boot→Menu→Loading→Countdown→Playing→Paused→Results com transições declaradas; `Paused` congela a simulação inteira (posição, contadores e timers não avançam)
**Plans**: TBD

### Phase 3: Territory Engine
**Goal**: Sair do Claim desenha um Arc e voltar captura exatamente a região cercada — correto em todos os casos topológicos, dentro do orçamento de CPU e com render de custo constante
**Depends on**: Phase 2
**Requirements**: TER-01, TER-02, TER-03, TER-04, TER-05, TER-06, TER-07
**Canonical refs**: `.gsd/phases/03-territory-engine/`, `docs/architecture/territory-system.md` (inteiro), `docs/decisions/ADR-0002-territory-representation.md`, `docs/gameplay/rules.md` §4 e §9, `docs/performance/territory-benchmarks.md`
**Success Criteria** (what must be TRUE):
  1. O Arc rasterizado é 4-conectado em 10 000 trajetos aleatórios (teste de propriedade) — sem isso o flood fill vaza e o jogo captura o mapa inteiro
  2. `SealSolver` passa nos 30 casos de mesa listados em `.gsd/phases/03-territory-engine/TASKS.md` (TERR-006), incluindo côncavo, contra a borda, com buraco, anel com ilha, espiral, roubo, Arc inimigo engolido e Claim côncavo maior que a bbox do Arc
  3. `SealSolver` é função pura: não emite sinal, não escreve no grid, não conhece partida — e não aloca em 1 000 chamadas sequenciais (benchmark B06)
  4. Em dispositivo Android real, Seal típico (~3 % do mapa) tem p95 < 0,8 ms e o pior caso (mapa inteiro) < 4,0 ms (benchmarks B01–B04)
  5. O território renderiza em **1 draw call** e capturar 20 % custa o mesmo que capturar 1 % em tempo de render (benchmark B14)
  6. 500 partidas headless terminam com 0 crash, 0 invariante violada e 0 partida infinita; a invariante `Σ claim_count + neutras + bloqueadas == total` é verificada a cada tick
  7. O Seal resolve no mesmo tick e o input continua sendo processado durante a animação de captura
**Plans**: TBD

### Phase 4: Combat & Elimination
**Goal**: O Arc passa a ser perigoso — cortar elimina, tocar o próprio dá Backwash sem virar rota de fuga, e nenhuma morte parece arbitrária
**Depends on**: Phase 3
**Requirements**: CMB-01, CMB-02, CMB-03, CMB-04, CMB-05
**Canonical refs**: `.gsd/phases/04-combat-elimination/`, `docs/gameplay/rules.md` §5 e §6, `docs/decisions/ADR-0007-self-collision-rule.md`, `docs/architecture/territory-system.md` §6
**Success Criteria** (what must be TRUE):
  1. Entrar numa célula de Arc inimigo causa Break; o Claim do eliminado vira **neutro** (não vai para o matador) e a invariante de soma continua verde
  2. Pisar no próprio Arc dispara Backwash: Arc apagado, novo Arc iniciado na posição atual no mesmo tick, Surge zerado, penalidade de velocidade que expira sem resíduo — e existe um teste provando que o Runner **continua cortável** logo após o Backwash
  3. Colidir com borda ou obstáculo enquanto desenha dá Backwash com deflexão; dentro do Claim a borda apenas desliza
  4. Morte mútua no mesmo tick elimina os dois sem crédito; dois agressores no mesmo Arc creditam o menor `runner_id`; um Seal no mesmo tick de uma morte resolve **antes** da morte
  5. Respawn encontra local válido em 1 000 tentativas com o mapa lotado, respeitando distância mínima, com invulnerabilidade que cai ao sair do Claim
  6. Nenhuma causa de morte fora da lista fechada de R5.7 existe no código, e a colisão de 8 Runners custa < 0,02 ms/tick sem usar `Area2D`
**Plans**: TBD

### Phase 5: Bot AI
**Goal**: Adversários com intenção legível — o jogador consegue dizer "ele está me caçando" — com dificuldade que sobe por comportamento e nunca por velocidade
**Depends on**: Phase 4
**Requirements**: BOT-01, BOT-02, BOT-03, BOT-04, BOT-05
**Canonical refs**: `.gsd/phases/05-bot-ai/`, `docs/gameplay/bots.md`, `docs/decisions/ADR-0008-bot-ai-architecture.md`, `docs/design/balance.md` §8
**Success Criteria** (what must be TRUE):
  1. `BotBrain` pontua 8 ações candidatas e executa a maior, com pesos vindos de `BotProfileResource` — criar um arquétipo novo não exige tocar em código
  2. Os 4 arquétipos do MVP (Grazer, Raider, Hunter, Warden) são distinguíveis: em teste com 5 pessoas assistindo clipes de 20 s, ≥ 70 % identificam corretamente a intenção do `Hunter`
  3. Os 3 níveis de dificuldade mudam percepção, tempo de reação e taxa de erro — a velocidade base é **idêntica** à do jogador em todos eles (verificado por teste, não por revisão)
  4. Em 500 partidas headless: 0 crash, 0 invariante violada, 0 bot parado por mais de 3 s, nenhuma partida infinita
  5. A distribuição de vitórias por arquétipo fica entre 8 % e 45 % em composições mistas, e o resultado do ajuste está registrado no histórico de `docs/design/balance.md`
  6. A IA de 8 bots custa < 1,2 ms/tick com no máximo 2 decisões por tick (benchmark B09), e as decisões são determinísticas dada a seed
**Plans**: TBD

### Phase 6: Complete Match Loop
**Goal**: Existe um jogo completo — countdown, score com Surge e bônus, fim de partida, resultado e restart em um toque. Fecha o marco MVP
**Depends on**: Phase 5
**Requirements**: MTC-01, MTC-02, MTC-03, MTC-04, UIX-06
**Canonical refs**: `.gsd/phases/06-match-loop/`, `docs/design/scoring.md`, `docs/design/balance.md` §4–§6, `docs/gameplay/rules.md` §7, `docs/ui/hud.md`, `docs/product/analytics-plan.md`
**Success Criteria** (what must be TRUE):
  1. O score implementa a fórmula de `docs/design/scoring.md` termo a termo, é determinístico, nunca negativo e respeita todos os tetos — com um teste por termo usando valor calculado à mão
  2. O Surge sobe por Seal e Break dentro das janelas, decai por inatividade, zera em morte e Backwash, e respeita o teto de nível
  3. Os 9 bônus nomeados disparam nas condições certas e **não** disparam fora delas (18 testes), e cada um ocorre ao menos uma vez em 500 partidas
  4. A partida termina pelas três condições (tempo, meta, último vivo) e o ranking resolve empate em cascata: território → score → maior Seal → menor tempo desenhando
  5. `PLAY AGAIN` reinicia em menos de 0,8 s sem passar pelo menu, e a contagem animada do resultado pode ser pulada ao toque
  6. A HUD tem exatamente os 5 elementos permitidos, com números tabulares que não fazem o layout tremer, e nenhum popup interrompe o controle durante a partida
  7. A checklist de 16 itens do MVP em `.gsd/phases/06-match-loop/ACCEPTANCE.md` está 16/16 verde, com playtest de 3 pessoas de fora registrado
**Plans**: TBD

### Phase 7: UI/UX Foundation
**Goal**: Design system em tokens, todas as telas navegáveis, settings que funcionam de verdade, i18n desde o primeiro texto e onboarding dentro da partida
**Depends on**: Phase 6
**Requirements**: UIX-01, UIX-02, UIX-03, UIX-04, UIX-05
**Canonical refs**: `.gsd/phases/07-ui-ux-foundation/`, `docs/ui/design-system.md`, `docs/ui/screens.md`, `docs/ui/accessibility.md`, `docs/design/onboarding.md`, `docs/decisions/ADR-0009-ui-framework.md`
**Success Criteria** (what must be TRUE):
  1. Nenhum valor de espaçamento, cor, raio ou duração existe fora dos tokens em `Resource`; trocar de tema muda a UI inteira sem reiniciar
  2. Os 12 componentes existem com todos os estados e aparecem numa cena de showcase; todo alvo de toque tem ≥ 48 dp
  3. Capturas automáticas de todas as telas em 16:9, 18:9, 19,5:9, 20:9 e tablet, em escala de UI 1,0 e 1,25, sem sobreposição nem corte
  4. Nenhum texto está hardcoded: en e pt-BR completos, e `check_i18n.sh` falha com chave faltando plantada
  5. Todas as opções de settings persistem e têm efeito imediato, incluindo o test drive de controles ao vivo
  6. O onboarding tem 6 passos que somem ao serem demonstrados, a primeira execução vai direto para a partida, e em playtest com 5 pessoas novas ≥ 80 % fazem o primeiro Seal em menos de 25 s
  7. Back físico do Android e gesto do iOS fazem a coisa óbvia em toda tela; nenhuma transição passa de 300 ms
**Plans**: TBD

### Phase 8: Art Direction
**Goal**: O jogo deixa de parecer protótipo — direção de arte aplicada, 8 temas verificados e zero placeholder
**Depends on**: Phase 7
**Requirements**: ART-01, ART-02, ART-03
**Canonical refs**: `.gsd/phases/08-art-direction/`, `docs/art/art-direction.md`, `docs/art/themes.md`, `docs/art/vfx.md`, `docs/decisions/ADR-0011-theming-and-cosmetics.md`
**Success Criteria** (what must be TRUE):
  1. `./tools/ci/validate-repo.sh` não encontra nenhum `PLACEHOLDER-ART-*` no repositório
  2. Os 8 temas passam no verificador automático de contraste (4,5:1 texto, 3:1 UI) e de separação de matiz (≥ 40° entre cores de jogador), rodando no CI
  3. A identificação de Runner usa cor **+ forma + padrão**, provado pelo tema `Monochrome` ser jogável
  4. Em teste cego com 5 pessoas usando 10 capturas, ≥ 90 % apontam corretamente onde está a ameaça — a hierarquia visual (Runner > Arc > borda > preenchimento > fundo) não foi invertida por nenhum efeito
  5. Os presets Low/Medium/High alteram os efeitos conforme a tabela de `docs/art/vfx.md`, e `Auto` acerta o preset em um aparelho Low e num High
  6. VFX custa < 2,0 ms de GPU no aparelho Mid em preset Medium, com draw calls dentro do teto e texturas ≤ 24 MB
  7. Toda fonte e todo asset de terceiros está listado em `assets/CREDITS.md` com licença
**Plans**: TBD

### Phase 9: Game Feel & Polish
**Goal**: Toda ação principal responde nos sete canais — Gameplay, Animation, VFX, SFX, Haptics, Camera e UI Feedback — com intensidade proporcional ao evento
**Depends on**: Phase 8
**Requirements**: ART-04, ART-05, ART-06
**Canonical refs**: `.gsd/phases/09-game-feel/`, `docs/design/game-feel.md`, `docs/audio/audio-direction.md`, `docs/art/vfx.md`, `docs/ui/accessibility.md`
**Success Criteria** (what must be TRUE):
  1. A matriz "ação × 7 canais" de `docs/design/game-feel.md` está 100 % preenchida, com vídeo antes/depois de cada ação principal
  2. Capturar 1 % e capturar 20 % produzem resposta visivelmente diferente em intensidade — a escala é contínua, não discreta
  3. Nenhum efeito bloqueia o controle, incluindo o micro slow-mo do Mega Seal (teste de input durante os efeitos)
  4. Em teste de olhos fechados, é possível identificar Seal, Break, morte própria e Backwash **só pelo som**
  5. Uma partida inteira com `Reduce shake` + `Reduce flashes` + `Haptics off` continua legível e divertida, avaliada em playtest
  6. Nenhum efeito aloca durante a partida (tudo vem de pool); VFX custa < 0,7 ms de CPU e < 2,0 ms de GPU; áudio ≤ 16 vozes e ≤ 12 MB
  7. Em playtest com 5 pessoas, a nota média para "capturar território é satisfatório" é ≥ 4,0 de 5
**Plans**: TBD

### Phase 10: Progression
**Goal**: Motivo para voltar amanhã — perfil, XP, ranks, estatísticas, conquistas e desafios — sem que nada disso toque a simulação
**Depends on**: Phase 9
**Requirements**: PRG-01, PRG-02, PRG-03
**Canonical refs**: `.gsd/phases/10-progression/`, `docs/design/progression.md`, `docs/design/economy.md`, `docs/design/balance.md` §10, `docs/architecture/save-system.md`
**Success Criteria** (what must be TRUE):
  1. Toda partida dá XP, inclusive derrota, e o primeiro nível sobe na primeira partida
  2. 15+ estatísticas são rastreadas e persistidas corretamente, com divisão por zero tratada em K/D e winrate
  3. Existem ≥ 30 conquistas nas 3 famílias, com progresso parcial visível e desbloqueio único
  4. Desafios diários são gerados por seed diária determinística, sem repetir tipo no mesmo dia, com 1 reroll gratuito e expiração correta mesmo com fuso e relógio do sistema alterados
  5. Sparks respeitam o teto por partida e o saldo nunca fica negativo; toda entrada e saída passa pela carteira
  6. O progresso sobrevive a fechar o app em qualquer momento, e o save fica abaixo de 100 KB com tudo desbloqueado
  7. Nenhuma classe de progressão é importada por `gameplay/`, `runner/` ou `territory/` (verificado pela checagem de camadas)
**Plans**: TBD

### Phase 11: Cosmetics
**Goal**: Identidade visual para o jogador e a única fonte legítima de receita — catálogo como dado, com zero impacto de gameplay
**Depends on**: Phase 10
**Requirements**: PRG-04
**Canonical refs**: `.gsd/phases/11-cosmetics/`, `docs/decisions/ADR-0011-theming-and-cosmetics.md`, `docs/product/monetization.md`, `docs/art/themes.md`
**Success Criteria** (what must be TRUE):
  1. O catálogo tem ≥ 20 skins, ≥ 12 Arc Styles, 8 temas e 5 efeitos de Seal, todos como `Resource` — adicionar item novo não exige código
  2. Testes de equidade provam que hitbox, largura efetiva de Arc, duração e custo de render são idênticos entre todos os itens
  3. Desbloqueio funciona pelas 3 fontes (rank, conquista, compra com moeda), com item permanente e compra dupla impedida
  4. A tela de skins comunica os estados (possuído, equipado, bloqueado, comprável) sem depender de texto, e o preview mostra o item aplicado antes de equipar
  5. A matriz item × 8 temas foi auditada; em teste cego com skins variadas, ≥ 90 % ainda identificam a ameaça
  6. Nenhum dark pattern da lista de `docs/product/monetization.md` existe na tela de compra
**Plans**: TBD

### Phase 12: Additional Game Modes
**Goal**: Cinco modos sobre a mesma simulação, definidos por dado — Time Attack, Survival, Domination e Endless somam ao Classic
**Depends on**: Phase 11
**Requirements**: MTC-05, BOT-02
**Canonical refs**: `.gsd/phases/12-game-modes/`, `docs/gameplay/game-modes.md`, `docs/design/balance.md` §7, `docs/gameplay/bots.md`
**Success Criteria** (what must be TRUE):
  1. `grep -r "if mode ==" src/` retorna vazio — todo modo é um `MatchRulesResource`
  2. Time Attack adiciona tempo por Seal com teto por captura, e o relógio nunca fica negativo
  3. Survival escala por composição de bots por onda, com velocidade base constante em todas as ondas (verificado por teste)
  4. Domination encerra na meta com HUD mostrando o progresso de todos, e Endless roda 30 minutos sem queda de FPS nem crescimento de memória
  5. O *Reset Pulse* do Endless é telegrafado com antecedência e nunca zera o Claim de alguém (nunca causa Squeeze acidental)
  6. Os 3 arquétipos novos (Vulture, Nemesis, Baron) funcionam — `Nemesis` persegue comprovadamente quem o matou
  7. 2 500 partidas headless (500 por modo) sem crash, sem invariante violada e sem partida infinita, com duração de cada modo dentro da janela projetada
**Plans**: TBD

### Phase 13: Maps & Arena Variations
**Goal**: Quatro arenas novas que mudam a estratégia sem mudar as regras, com o solver correto em topologias adversas
**Depends on**: Phase 12
**Requirements**: MTC-06
**Canonical refs**: `.gsd/phases/13-maps-arenas/`, `docs/art/themes.md` §Arenas, `docs/architecture/territory-system.md` §7, `docs/gameplay/rules.md` §9
**Success Criteria** (what must be TRUE):
  1. Arena é `ArenaDefinition` (dado): nenhuma linha de código específica por arena, e arena com região isolada é rejeitada na validação
  2. Células bloqueadas nunca são capturadas nem entram no percentual, e cercar contra obstáculo interno funciona como contra a borda (casos de mesa novos)
  3. `Halo` (buraco central grande) produz Seal correto e fica dentro do orçamento de benchmark — é a topologia mais adversa do jogo
  4. A fenda de `Rift` é a única exceção da lista fechada de causas de morte, telegrafada com aviso visual e sonoro, e os bots a evitam
  5. 500 partidas por arena com 0 bot travado e nenhuma estratégia degenerada (canto inexpugnável) encontrada
  6. Cada arena é reconhecível num relance e herda a paleta do tema ativo — nenhuma traz cor própria
**Plans**: TBD

### Phase 14: Power-ups
**Goal**: Seis power-ups que movem a posição do risco sem decidir a partida — cada um com contra-jogo executável. Fecha o marco Alpha
**Depends on**: Phase 13
**Requirements**: MTC-07
**Canonical refs**: `.gsd/phases/14-power-ups/`, `docs/gameplay/power-ups.md`, `docs/design/balance.md` §9, `docs/design/game-feel.md`
**Success Criteria** (what must be TRUE):
  1. Efeito nunca escreve direto no Runner: empilha modificadores num `StatBlock` resolvido em ponto único, e 1 000 ciclos de aplicar/expirar não deixam resíduo
  2. Cada contra-jogo é provado por teste: `Overdrive` não muda a taxa de giro, `Arc Guard` deixa a ponta do Arc vulnerável, `Amplify` não altera área capturada, `Bulwark` não protege contra Squeeze, `Drag Field` afeta também quem soltou
  3. Orbes piscam antes de existir e nunca nascem a menos da distância mínima de um Runner
  4. Bots coletam e reagem a power-ups sem que a distribuição de vitórias saia da faixa saudável
  5. Em 2 000 partidas: menos de 15 % decididas por power-up e winrate de quem pega o primeiro orbe em 50 % ± 8 pp
  6. A checklist do gate da Alpha em `.gsd/phases/14-power-ups/ACCEPTANCE.md` está inteira marcada, incluindo zero placeholder e os dois playtests
**Plans**: TBD

### Phase 15: Backend Foundation
**Goal**: API Laravel que sustenta leaderboard confiável, cloud save e desafios — com o cliente nunca sendo fonte de verdade. O cliente não muda nesta fase
**Depends on**: Phase 10
**Requirements**: SRV-01, SRV-02, SRV-03
**Canonical refs**: `.gsd/phases/15-backend-foundation/`, `docs/backend/api-design.md`, `docs/backend/security.md`, `docs/backend/anti-cheat.md`, `docs/decisions/ADR-0004-backend.md`
**Success Criteria** (what must be TRUE):
  1. `docker compose up` + `api_up.sh` sobem Postgres, Redis e a API; `php artisan test` fica verde
  2. Todas as rotas de `docs/backend/api-design.md` existem, com FormRequest, rate limit e `Idempotency-Key` nas escritas
  3. `POST /matches` **recalcula** o score no servidor e rejeita partida implausível — 8 testes de limite (duração, taxa de captura, Seals por segundo, Breaks possíveis, teto de Surge, `largest_seal <= claim_pct`, assinatura, duplicata)
  4. Leaderboards funcionam nas 4 janelas com Redis ZSET, incluindo virada de período e reconstrução a partir do Postgres; leitura < 50 ms
  5. Cloud save resolve conflito por reconciliação monotônica e guarda as últimas 3 versões — teste prova que XP nunca diminui
  6. Pint e PHPStan nível 6 limpos, cobertura ≥ 85 % nas rotas críticas, migrações reversíveis, nenhum segredo no repositório
  7. Backup do Postgres foi **restaurado com sucesso** em ambiente limpo — backup não testado não conta
**Plans**: TBD

### Phase 16: Online Services
**Goal**: Trocar `Local*` por `Remote*` sem que a ausência de rede mude qualquer coisa para quem está jogando
**Depends on**: Phase 15
**Requirements**: SRV-03, SRV-04
**Canonical refs**: `.gsd/phases/16-online-services/`, `docs/architecture/networking.md`, `docs/backend/api-design.md`, `.gsd/BACKLOG.md` (MOCK-001, MOCK-003, MOCK-004)
**Success Criteria** (what must be TRUE):
  1. Em modo avião, uma partida completa com progressão, desafios, cosméticos e recorde local funciona sem nenhuma degradação perceptível
  2. Nenhuma chamada de rede existe no caminho de simulação, e nenhum erro de rede vira popup durante a partida
  3. A fila offline persiste, sobrevive ao app morto no meio e nunca duplica submissão (idempotência ponta a ponta)
  4. Com o servidor retornando 500 ou com 5 s de latência, o boot não espera rede e o jogo segue jogável
  5. Cloud save preserva progresso numa troca simulada de aparelho, nos dois sentidos de conflito
  6. Remote config valida faixa também no cliente, nunca é aplicado durante `Playing` e cai no embutido em qualquer falha
  7. MOCK-001, MOCK-003 e MOCK-004 estão fechados em `.gsd/BACKLOG.md`
**Plans**: TBD

### Phase 17: Multiplayer Architecture
**Goal**: Provar com números se o multiplayer autoritativo é viável nesta arquitetura — entregando protótipo e relatório, **não** um recurso lançável
**Depends on**: Phase 16
**Requirements**: SRV-06
**Canonical refs**: `.gsd/phases/17-multiplayer/`, `docs/architecture/networking.md` §3, `docs/decisions/ADR-0005-networking.md`
**Success Criteria** (what must be TRUE):
  1. O servidor headless roda **o mesmo código** de simulação do cliente e produz estado idêntico com a mesma seed (checksum de grid a cada 60 ticks)
  2. O cliente envia apenas input; o território **nunca** é predito — o Seal só é confirmado pelo servidor, e a reversão de Seal negado é visualmente suave
  3. Uma partida com 4+ participantes é jogável com 120 ms de RTT, e o jogador é avisado acima de 250 ms
  4. Input implausível (flood, timestamp fora de ordem, direção inválida) é descartado sem afetar a partida
  5. Reconexão dentro de 30 s restaura o estado, com piloto automático defensivo enquanto o jogador está fora
  6. Banda < 12 KB/s por cliente e ≥ 4 partidas de 6 Runners por vCPU, medidos — não estimados
  7. Existe um relatório de viabilidade com recomendação explícita (seguir, adiar ou mudar de abordagem); "não vale a pena assim" é resultado válido se fundamentado
**Plans**: TBD

### Phase 18: Analytics & Telemetry
**Goal**: Passar a saber em vez de achar — onboarding, retenção, balanceamento, performance e crashes — com privacidade levada a sério e nenhum SDK dentro do gameplay
**Depends on**: Phase 16
**Requirements**: SRV-05
**Canonical refs**: `.gsd/phases/18-analytics/`, `docs/product/analytics-plan.md`, `docs/decisions/ADR-0010-analytics-abstraction.md`
**Success Criteria** (what must be TRUE):
  1. Nenhum sistema de gameplay chama analytics diretamente — tudo passa pelo `AnalyticsBridge`
  2. Todos os eventos de `docs/product/analytics-plan.md` chegam com as propriedades certas, validados numa build de produção com 10 partidas reais
  3. Auditoria de payload campo a campo confirma **zero PII**, e o opt-out impede qualquer requisição (verificado por proxy)
  4. Crash forçado é capturado e enviado com contexto útil e sem dado sensível
  5. `perf_sample` permite responder "o jogo roda bem no aparelho X?" com dado agregado por modelo
  6. Nenhum evento por frame; envio em lote com fila offline, sem duplicação, com banda e bateria desprezíveis
  7. A documentação de privacidade reflete exatamente a coleta real, e MOCK-002 está fechado
**Plans**: TBD

### Phase 19: Optimization
**Goal**: O jogo cabe no orçamento em Low, Mid e High — com medição antes e depois de cada mudança, sem alterar comportamento
**Depends on**: Phase 14, Phase 18
**Requirements**: QLT-01
**Canonical refs**: `.gsd/phases/19-optimization/`, `docs/performance/performance-budget.md`, `docs/performance/territory-benchmarks.md`
**Success Criteria** (what must be TRUE):
  1. Existe um baseline completo medido **antes** de qualquer otimização, registrado em `docs/performance/device-results.md`
  2. Todos os orçamentos de `docs/performance/performance-budget.md` são respeitados: simulação < 3,0 ms, território < 2,0 ms em regime, IA < 1,2 ms, VFX < 0,7 ms CPU / < 2,0 ms GPU
  3. 60 FPS no Mid sem hitch > 50 ms em 3 minutos; 120 FPS no High; 60 FPS no Low com preset Low
  4. Memória fica plana em 10 partidas seguidas (± 5 MB), cold start < 3 s e restart < 0,8 s
  5. Bateria < 8 %/hora e nenhum throttling perceptível em 20 minutos
  6. Após as otimizações, 2 000 partidas headless mantêm a distribuição de vitórias e a duração equivalentes ao baseline — otimização não pode mudar comportamento
  7. Toda otimização tem antes/depois documentado no PR; nenhuma foi feita sem medição que a justificasse
**Plans**: TBD

### Phase 20: Accessibility & Device Compatibility
**Goal**: Funcionar para mais gente e em mais aparelhos, e fechar o marco Beta
**Depends on**: Phase 19
**Requirements**: QLT-02, QLT-03
**Canonical refs**: `.gsd/phases/20-accessibility-compat/`, `docs/ui/accessibility.md`, `docs/mobile/device-matrix.md`, `.gsd/BACKLOG.md` (BL-011)
**Success Criteria** (what must be TRUE):
  1. A checklist de `docs/mobile/device-matrix.md` foi executada em 4 Android (Low, Mid, High, tablet) e 3 iPhone + 1 iPad, com resultado registrado por aparelho
  2. Safe area correta com notch, Dynamic Island, furo de câmera e barra de gestos; nada interativo sob elementos do sistema
  3. Tablet reflui em vez de esticar, e o comportamento é idêntico em 60, 90, 120 Hz e LTPO — só a suavidade muda
  4. Os 3 temas de daltonismo e o modo de alto contraste passam no verificador e no teste cego de ameaça (≥ 90 %), e ficam em `Accessibility`, nunca na loja
  5. Uma partida completa com todas as reduções ativas (shake, flashes, sons intensos, háptico) continua legível e divertida
  6. Auditoria confirma que nenhuma informação existe só na cor, só no som ou só no háptico, e nenhuma ação exige toque duplo, longo ou multitoque
  7. A decisão sobre upgrade da engine (BL-011) está registrada com custo medido — em ADR novo se migrar, no backlog se não
  8. O gate da Beta está fechado: crash-free ≥ 99 % em teste fechado com ≥ 30 aparelhos distintos
**Plans**: TBD

### Phase 21: Android Release
**Goal**: AAB assinado, validado e pronto para o Google Play, com privacidade e loja em ordem
**Depends on**: Phase 20
**Requirements**: QLT-04
**Canonical refs**: `.gsd/phases/21-android-release/`, `docs/mobile/android.md`, `docs/deployment/release-process.md`
**Success Criteria** (what must be TRUE):
  1. O CI gera um AAB assinado e reprodutível, com split por ABI e `versionCode` monotônico derivado do semver
  2. `check_release_build.sh` reprova qualquer build com cena de debug, addon de teste, overlay ou placeholder — provado por um caso plantado
  3. Ícone adaptativo correto nas três máscaras e splash com logo vetorial, verificados em aparelho real
  4. Permissões reduzidas ao mínimo necessário e justificadas em `docs/mobile/android.md`
  5. O formulário de Data Safety foi preenchido por revisão cruzada com a auditoria de payload da fase 18 — sem divergência entre o que o app faz e o que declara
  6. Download ≤ 60 MB, validado em Low, Mid, High e tablet com build de release, e o back button se comporta em toda tela
  7. Teste interno no Play instalado e jogado por ≥ 3 pessoas, sem bloqueador, com relatório registrado
**Plans**: TBD

### Phase 22: iOS Release
**Goal**: Build validada no TestFlight, com assinatura, ícones, Privacy Label e loja prontos
**Depends on**: Phase 20
**Requirements**: QLT-04
**Canonical refs**: `.gsd/phases/22-ios-release/`, `docs/mobile/ios.md`, `docs/deployment/release-process.md`
**Success Criteria** (what must be TRUE):
  1. `build_ios.sh` + `archive_ios.sh` geram um IPA assinado, sem nenhuma ferramenta de debug
  2. O conjunto de ícones está completo (validação do Xcode sem aviso) e a launch screen é um storyboard
  3. O Privacy Nutrition Label foi preenchido por revisão cruzada com a coleta real, sem ATT no v0.1.0
  4. Safe area correta com notch, Dynamic Island e home indicator; nada interativo nos últimos 20 pt
  5. Áudio se comporta com ligação, alarme e botão de silencioso; háptico usa Core Haptics com fallback; ProMotion 120 Hz funciona
  6. Tamanho ≤ 80 MB e validação em iPhone mínimo, atual, Pro e iPad com 30 min de jogo em cada
  7. TestFlight validado por ≥ 3 pessoas, com paridade de comportamento em relação ao Android (ou diferença justificada)
**Plans**: TBD

### Phase 23: Production Readiness
**Goal**: Última chance de encontrar problema antes dos jogadores — QA completo, regressão, migração de save e rollback ensaiado. Nenhuma feature nova
**Depends on**: Phase 21, Phase 22
**Requirements**: QLT-05
**Canonical refs**: `.gsd/phases/23-production-readiness/`, `docs/deployment/release-process.md`, `docs/backend/security.md`, `docs/architecture/save-system.md`
**Success Criteria** (what must be TRUE):
  1. Zero bug blocker e zero crítico abertos em `.gsd/BACKLOG.md`
  2. Suíte completa verde nas duas plataformas + 5 000 partidas headless em todos os modos e arenas, sem crash nem invariante violada
  3. Migração de save testada a partir de **todas** as versões usadas em teste, com fixtures versionados, mais corrompido, versão futura e vazio
  4. Matar o app em 10 momentos diferentes não perde progresso em nenhum deles
  5. Rollback ensaiado de verdade nas duas lojas e desativação de feature por remote config, ambos documentados com o procedimento real
  6. Checklist de segurança assinada, `composer audit` limpo e backup da API restaurado em ambiente limpo
  7. Textos revisados em en e pt-BR sem truncamento em escala 1,25, e `validate-repo.sh` sem placeholder, mock vencido ou TODO sem tarefa
**Plans**: TBD

### Phase 24: Launch
**Goal**: Publicar a v0.1.0 com rollout gradual, monitoramento ativo e rollback armado
**Depends on**: Phase 23
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/24-launch/`, `docs/deployment/release-process.md`, `CHANGELOG.md`
**Success Criteria** (what must be TRUE):
  1. Versão `0.1.0` coerente em `project.godot`, Android e iOS; CHANGELOG no formato Release Notes com a seção da versão; tag anotada `v0.1.0` criada em `master`
  2. A checklist de release de `docs/deployment/release-process.md` está marcada item a item **com evidência** — nenhum "provavelmente ok"
  3. As builds finais foram geradas a partir da tag pelo CI, com símbolos guardados para desofuscar crash
  4. Rollout gradual respeitado: 5 % → 20 % → 50 % → 100 %, com 24 h de métrica saudável entre degraus
  5. Crash-free ≥ 99,5 % antes de cada degrau; ao primeiro sinal ruim o rollout para
  6. Monitoramento ativo por 72 h com relatório escrito: crash-free, ANR, retenção D1, funil de onboarding, avaliações e erros da API
  7. Avaliações da loja respondidas na primeira semana
**Plans**: TBD

### Phase 25: Post Launch
**Goal**: Transformar o jogo publicado em produto vivo — balanceamento por dados reais, monetização ética, temporadas e conteúdo, sem ferir os pilares
**Depends on**: Phase 24
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/25-post-launch/`, `docs/product/monetization.md`, `docs/design/economy.md`, `docs/design/balance.md`
**Success Criteria** (what must be TRUE):
  1. Crash-free ≥ 99,5 % mantido, com triagem de feedback e hotfix `patch` para qualquer crítico
  2. Todo ajuste de balanceamento tem antes/depois medido e registrado no histórico de `docs/design/balance.md` — nunca "parece melhor"
  3. Anúncios existem apenas como rewarded opt-in nos dois pontos definidos, dentro dos limites diários, e nunca no meio da partida
  4. Compras são validadas no servidor com recibo único; reembolso revoga o item; restauração funciona
  5. Nenhum item novo — inclusive de season pass — altera a simulação, verificado item a item
  6. Conteúdo novo passa pelos mesmos gates de qualidade e stress test da fase de origem
  7. Nenhum dark pattern da lista de `docs/product/monetization.md` foi introduzido
**Plans**: TBD
