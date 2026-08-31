import re

roadmap_path = "/Users/sierra/Dev/Jogos/volta/.planning/ROADMAP.md"

with open(roadmap_path, 'r') as f:
    content = f.read()

# Find the start of Phase 26
phase_26_idx = content.find("### Phase 26:")

if phase_26_idx != -1:
    base_content = content[:phase_26_idx]
else:
    base_content = content + "\n\n"

new_phases = """### Phase 26: Google Play Discovery - Auditoria de Gamificação e Sidekick
**Goal**: Mapear projeto, arquitetura, gameplay, backend e gamificação existente para criar a fundação da integração com ecossistema Google.
**Depends on**: Phase 25
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/26-google-play-discovery/`, `docs/google-play/compatibility-audit.md`
**Success Criteria** (what must be TRUE):
  1. O arquivo `docs/google-play/compatibility-audit.md` foi gerado contendo o estado atual do projeto e riscos.
  2. O arquivo `docs/google-play/current-requirements.md` mapeia todos os requisitos oficiais vigentes para Sidekick e Level Up.
  3. A arquitetura de integração (Gameplay -> Domain Events -> Gamification Engine -> Integração Google) foi validada para o projeto.
  4. Nenhuma linha de código final foi alterada antes da auditoria completa.
**Plans**: TBD

### Phase 27: Gamification Foundation - Eventos de Domínio e Integração
**Goal**: Criar o Event Bus de gameplay e a infraestrutura básica para receber a gamificação sem acoplamento forte.
**Depends on**: Phase 26
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/27-gamification-foundation/`, `docs/google-play/architecture.md`
**Success Criteria** (what must be TRUE):
  1. O `Gamification Engine` foi criado com componentes independentes (Progression, Quests, Stats, etc.).
  2. Os eventos de domínio do jogo (ex: `GameStarted`, `LevelCompleted`, `EnemyDefeated`) são disparados e capturados corretamente.
  3. Feature flags para todos os novos sistemas (ex: `google_play_sidekick`, `game_stats`) estão implementadas.
  4. O jogo continua funcionando normalmente offline através de filas (`pending_game_events`) preparadas para sincronização.
**Plans**: TBD

### Phase 28: Play Games Services v2 e Autenticação
**Goal**: Integrar Play Games Services v2 com autenticação automática e idempotência total.
**Depends on**: Phase 27
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/28-play-games-services/`, `docs/google-play/play-games-services.md`
**Success Criteria** (what must be TRUE):
  1. O PGS v2 inicializa corretamente no startup, realizando login transparente.
  2. A associação de `play_games_player_id` com `internal_player_id` ocorre sem falhas (via Recall API se aplicável).
  3. Se o PGS estiver indisponível (ou offline), a gameplay flui com resiliência total via fallbacks.
  4. O sistema lida corretamente com reconexão, reinstalação, troca de conta, mudança de device e lifecycle do Android.
**Plans**: TBD

### Phase 29: Sistema de Conquistas e Progression Loop
**Goal**: Implementar achievements ricos e loop de XP/Níveis recompensando habilidade, exploração e persistência.
**Depends on**: Phase 28
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/29-achievements/`, `docs/google-play/achievement-matrix.md`
**Success Criteria** (what must be TRUE):
  1. Catálogo com aproximadamente 40 a 60 achievements balanceados e baseados no matriz documentada.
  2. Pelo menos 4 conquistas realizáveis durante a primeira hora de gameplay.
  3. Nível e XP recompensam habilidades variadas evitando paredes de grind excessivas.
  4. Eventos e UI elegantes com feedback visual (microanimações) de progresso, evitando pop-ups interruptivos.
**Plans**: TBD

### Phase 30: Game Stats e Integração Analytics
**Goal**: Mapear e reportar as estatísticas-chave para o Google Play Games, alimentando o perfil do jogador e telemetria.
**Depends on**: Phase 29
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/30-game-stats/`, `docs/google-play/game-stats-schema.md`
**Success Criteria** (what must be TRUE):
  1. `Progression Stat` principal e `Repetitive Stats` definidos e sincronizados com a API moderna do Sidekick.
  2. Arquivos de configuração CSV para a Play Console foram gerados.
  3. Somente eventos válidos do gameplay são enviados para o Google; nada de lixo analítico ou dados pessoais.
  4. O funil da primeira sessão (install até first achievement) está instrumentado para descobrir gargalos de abandono.
**Plans**: TBD

### Phase 31: Gamificação Avançada - XP, Quests e Rewards
**Goal**: Construir Daily Loops, Weekly Loops e sistema dinâmico de missões que prendam o engajamento saudável (D1 a D30).
**Depends on**: Phase 30
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/31-quests-and-rewards/`, `docs/google-play/quests.md`
**Success Criteria** (what must be TRUE):
  1. Daily e Weekly Quests funcionais incentivando retornos curtos e regulares.
  2. Sistema de Gaming Streaks com punições justas (ex: Freeze/Grace Period).
  3. Comeback System ativo: jogadores ausentes por dias têm objetivos rápidos em seu retorno.
  4. Play Games Rewards e Play Points possuem infraestrutura preparada e são concedidos por serviços idempotentes.
**Plans**: TBD

### Phase 32: Leaderboards e Social Engagement
**Goal**: Preparar métricas competitivas de curto e longo prazo que interagem com o ecossistema social Google.
**Depends on**: Phase 31
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/32-social/`, `docs/google-play/social.md`
**Success Criteria** (what must be TRUE):
  1. Leaderboards (Global, Amigos, Ligas) implementados e com dados higienizados para evitar cheating.
  2. Suporte para futuros "Social Challenges" planejado (ex: desafios cooperativos).
  3. Ligas estruturadas garantindo que jogadores casuais tenham metas alcançáveis em seu tier.
**Plans**: TBD

### Phase 33: LiveOps - Seasons e Quests Dinâmicas
**Goal**: Capacidade de atualizar o jogo remotamente para reengajar jogadores sem enviar novas builds na loja.
**Depends on**: Phase 32
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/33-liveops/`, `docs/google-play/architecture.md`
**Success Criteria** (what must be TRUE):
  1. Configurações de missões diárias/semanais e recompensas vêm via Server-Driven JSON (início, fim e meta).
  2. Infraestrutura de Temporadas (Seasons) criada (recompensas, missões exclusivas e ranks temporários).
  3. Testes A/B estão suportados (possibilidade de dividir balanceamento de missões entre coortes).
**Plans**: TBD

### Phase 34: Google Play Games Sidekick - Integração Completa
**Goal**: Transformar Sidekick em uma extensão fluida da experiência e atestar que a navegação do Game Hub está perfeita.
**Depends on**: Phase 33
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/34-sidekick-integration/`, `docs/google-play/sidekick-integration.md`
**Success Criteria** (what must be TRUE):
  1. Overlay testado: não quebra controles, imersão, toques, cutouts ou interrupções de rotação e backgrounding.
  2. Funcionalidades do Sidekick (conquistas, metas e Game Tips) abrem de maneira natural.
  3. Jogo continua rodando lisamente e se adaptando bem sem Sidekick (em dispositivos antigos).
**Plans**: TBD

### Phase 35: Segurança, Anti-cheat e Play Integrity
**Goal**: Blindar pontuações altas, progressões raras e recompensas monetárias contra manipulação.
**Depends on**: Phase 34
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/35-security/`, `docs/backend/security.md`
**Success Criteria** (what must be TRUE):
  1. Leaderboards e economias validadas via backend (authority validation).
  2. Implementadas defesas (nonces, replays e limitadores de rate) para evitar abuso no Rewards System.
  3. Salvamento na Nuvem garante merge e resolve conflitos (Local vs Nuvem) corretamente, prevenindo rollback fraudulento de progresso.
**Plans**: TBD

### Phase 36: QA Gamificação e Sidekick
**Goal**: Varredura massiva na qualidade de software das features implementadas de ecossistema e compliance da Google.
**Depends on**: Phase 35
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/36-qa-testing/`, `docs/google-play/testing.md`
**Success Criteria** (what must be TRUE):
  1. Matriz de testes testou offline, troca de conta, resyncs, clear data e duplos inputs nas recompensas.
  2. Funcionalidades operacionais em dispositivos Low, Mid e High (incluindo Portrait, Landscape, Tablets e offline modes).
  3. Documentação Level Up Quality (`docs/google-play/level-up-quality.md`) mapeada sem falhas.
**Plans**: TBD

### Phase 37: Performance Gamificação e Otimização
**Goal**: Garantir que as features do ecossistema Google não afetam os pilares técnicos de framerate e autonomia.
**Depends on**: Phase 36
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/37-performance/`, `docs/performance/performance-budget.md`
**Success Criteria** (what must be TRUE):
  1. Eventos processados em batch e assíncronos. Frame pacing continua intacto.
  2. Análise final de FPS, Memória e Bateria apresenta métricas sem deterioramento contra baseline (Phase 19).
  3. Sem gargalos de carregamento ao exibir overlays e notificações do jogo/Sidekick.
**Plans**: TBD

### Phase 38: Release - Rollout Google Play Games
**Goal**: Publicar as funcionalidades Google Play Games sob alto monitoramento, garantindo suporte pleno ao Gamer Profile.
**Depends on**: Phase 37
**Requirements**: QLT-06
**Canonical refs**: `.gsd/phases/38-release-rollout/`, `docs/google-play/play-console-checklist.md`, `docs/google-play/README.md`
**Success Criteria** (what must be TRUE):
  1. Checklist completa `play-console-checklist.md` preenchida com o que é automático e o que foi realizado MANUAL.
  2. Resultados comprovados em relatórios (Auditoria, Sidekick, Compatibilidade 100%).
  3. Matriz final entregue justificando todo status ✅ ou N/A (Level Up requirements, Analytics, etc.).
  4. Plano de Rollout documentado com thresholds de rollback baseados em crashes/ANRs reportados.
**Plans**: TBD
"""

with open(roadmap_path, 'w') as f:
    f.write(base_content + new_phases)

print("Roadmap updated successfully.")
