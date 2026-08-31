import os
import glob
import re

phases_dir = "/Users/sierra/Dev/Jogos/volta/.planning/phases"

phase_data = {
    26: """# Context: Google Play Discovery - Auditoria de Gamificação e Sidekick

## Princípio Fundamental
Antes de modificar qualquer código:
1. Leia todo o repositório.
2. Entenda sua arquitetura e descubra automaticamente detalhes do framework, build, sistema atual de usuários, save, progressão, moedas, ranking, etc.
3. Identifique o que já existe e o que pode ser reaproveitado.
4. Identifique conflitos e débito técnico.

Somente depois comece a implementação. NÃO crie sistemas paralelos desnecessariamente.

## Verificação da Documentação
Antes de implementar:
* Consultar a documentação oficial atual do Play Games Services, Sidekick, Level Up, Game Stats, Achievements, Cloud Save, Recall, Rewards, Quests, Play Points, Play Pass.
* Registrar tudo em `docs/google-play/current-requirements.md`.

## Fases de Execução: Fase 0 — Discovery
* Mapear projeto, arquitetura, gameplay, gamificação existente, backend, Android, Google Play atual e riscos.
* Entregável: `compatibility-audit.md`
""",
    27: """# Context: Gamification Foundation - Eventos de Domínio e Integração

## Arquitetura Desejada
```
Gameplay -> Game Domain Events -> Gamification Engine -> Integration Layer
```
Crie uma camada clara de integração. O Google Play Games não deve ficar espalhado pelo código inteiro.

## Gamification Engine
Criar ou refatorar um módulo Gamification com componentes independentes (Achievements, Experience, Levels, Progression, Quests, etc.), respeitando a arquitetura existente.

## Event Bus de Gameplay
Gamificação não deve depender de chamadas manuais espalhadas.
Criar eventos de domínio como `GameStarted`, `LevelCompleted`, `BossDefeated`, `QuestCompleted`, etc. Os consumidores alimentarão os sistemas de gamificação, evitando forte acoplamento.

## Feature Flags
Toda funcionalidade importante nova deve possuir feature flag (ex: `google_play_sidekick`, `game_stats`, `daily_quests`), permitindo rollback rápido.
""",
    28: """# Context: Play Games Services v2 e Autenticação

## Google Play Games Services v2
Garantir a implementação correta do PGS v2:
* Inicialização no startup e autenticação automática.
* Tratamento assíncrono correto e fallback se indisponível.
* Reconexão, troca de conta, reinstalação, mudança de device e retomada.
* O PGS deve melhorar a experiência, não ser ponto único de falha.

## Identidade
Não substituir cegamente o sistema de contas próprio se existir.
Criar associação segura: `internal_player_id <-> play_games_player_id`.
Avaliar utilização da Recall API. Nunca usar atributos mutáveis (nickname, e-mail) como chave de identidade.
""",
    29: """# Context: Sistema de Conquistas e Progression Loop

## Sistema de XP e Níveis
Criar curva sustentável: progressão rápida no início, aumentando gradualmente. Premiar habilidade, progresso, exploração e colaboração. Evitar paredes artificiais de grind.

## Conquistas (Achievements)
Sistema profundo integrado ao PGS (40 a 60 conquistas iniciais). Categorias: Progressão, Habilidade, Exploração, Coleção, Social, Persistência, Segredos.
**Primeira Hora:** Garantir pelo menos 4 conquistas alcançáveis na primeira hora de jogo, distribuídas gradativamente.
Criar `docs/google-play/achievement-matrix.md` para documentar cada conquista com ID, nome, categoria, critério, recompensa, etc.
""",
    30: """# Context: Game Stats e Integração Analytics

## Game Stats
Implementar a API moderna de Game Stats, focando em eventos relevantes do gameplay (vitórias, itens, nível, tempo, combos).
Nunca usar Game Stats para dados sensíveis, compras ou aberturas genéricas de app.

## Player Progression Stat
Definir estatística principal (ex: Level, Rank, World Progress). Enviar atualização sempre que progresso mudar, mantendo o estado consistente no início das sessões.

## Analytics
Instrumentar o sistema com eventos analíticos relevantes (`gamification_viewed`, `achievement_unlocked`, `quest_completed`, etc.) e KPIs (D1, D7, retenção). Medir o funil da primeira sessão para detectar gargalos.
Gerar arquivos CSV de configuração quando aplicável.
""",
    31: """# Context: Gamificação Avançada - XP, Quests e Rewards

## Quest System e Daily/Weekly Loop
Infraestrutura baseada em eventos. Criar cadeias de Quests (objetivos curto, médio e longo prazo).
Implementar loop diário ("O que posso fazer agora?") e objetivos semanais mais ambiciosos.

## Streak e Comeback System
Criar streaks inteligentes com Streak Freeze e Comeback Bonus.
Criar experiência de retorno (Comeback Quest, recompensa equilibrada) para jogadores que não logavam há dias, sem conceder vantagens injustas.

## Play Games Rewards & Play Points
Preparar compatibilidade. Criar tabela central de recompensas com regras claras (id, amount, rarity, expiry).
O sistema de concessão (Reward Service) deve garantir idempotência (Server Validation, Persistence, Telemetry) e tratar crash/timeout sem duplicar a recompensa.
""",
    32: """# Context: Leaderboards e Social Engagement

## Leaderboards e Leagues
Integrar rankings (Global, Friends, Season, Skill) com validação (não confiar em score puramente local).
Criar Ligas (Bronze, Silver, Gold, etc.) para que jogadores normais tenham metas alcançáveis fora do ranking global único.

## Social Engagement
Criar loops sociais: comparar conquistas, desafios, objetivos cooperativos e marcos comunitários. Preparar arquitetura para futuros Desafios Sociais do Google Play.
""",
    33: """# Context: LiveOps - Seasons e Quests Dinâmicas

## LiveOps e Personalização
Criar sistema server-driven para missões diárias, semanas, temporadas e recompensas, evitando necessidade de update de loja para cada alteração de conteúdo.
Dificuldade dinâmica baseada no perfil (através de sugestões, sem adulterar gameplay competitivo).
Testes A/B (experimentação) devem ter infraestrutura preparada.

## Seasons (Temporadas) e Coleções
Se compatível, criar estrutura de Seasons (XP, Missions, Leaderboards, Special Events).
Progresso visual (ex: 37/100 skins) com Collection System, criando metas naturais de longo prazo e sistema de "Mastery".
""",
    34: """# Context: Google Play Games Sidekick - Integração Completa

## Play Games Sidekick e UI/UX
Integrar Sidekick plenamente e testar HUD/UI/UX. O overlay não pode inutilizar controles essenciais do jogo, nem em multitarefa, cutouts ou gestos de navegação.
Garantir microanimações e feedback elegante para notificações. Sidekick é parte do Game Design, tornando o Gamer Profile uma representação real da história do jogador.

## Game Tips e Gemini
Preparar design para funcionar com Game Tips. Regras do jogo devem possuir nomenclatura clara. Criar `docs/gameplay/game-knowledge.md`.
Preparar pontos para vídeos/tutorais no ecossistema.
""",
    35: """# Context: Segurança, Anti-cheat e Play Integrity

## Anti-cheat e Resolução de Conflitos
Tudo que afeta leaderboards, moedas ou recompensas raras vindo do cliente é não confiável.
Implementar limites, nonces, timestamps, replay protection e idempotência (Server Authority).
Cloud Save: resolver conflitos explicitamente e tratar versionamento, merge e offline saves adequadamente, sem sobrescrever cegamente o progresso mais recente.
""",
    36: """# Context: QA Gamificação e Sidekick

## Testes Extensivos
QA completo focado no Google Play:
* Autenticação e contas múltiplas.
* Offline modes (fila e sincronização posterior).
* Achievements e Rewards (testar timeouts e duplicate requests garantindo exactly-once).
* Testes Sidekick (abrir durante cutscenes, gravação de tela, interrupções).
* Matriz de dispositivos rigorosa (desde os mínimos suportados).

Documentar os limites no arquivo `docs/google-play/level-up-quality.md`.
""",
    37: """# Context: Performance Gamificação e Otimização

## Performance
A gamificação não pode deteriorar o gameplay. Evitar verificações pesadas a cada frame.
Priorizar processamento batch, event-driven, counters incrementais e sincronização assíncrona.
Auditar ANRs, memory, battery e background/foreground transitions na matriz de dispositivos.
""",
    38: """# Context: Release - Rollout Google Play Games

## Checklist e Rollout Seguro
Produzir matriz final confirmando a compatibilidade 100% com Play Games Level Up, Sidekick e Play Services v2, preenchendo todos os `N/A` com justificativa técnica.
Apresentar a `play-console-checklist.md` detalhando ações que não puderam ser automatizadas.
Planejar o rollout (Internal -> Closed -> Gradual Production) avaliando metrics e KPIs, com procedimentos de rollback definidos.

Nenhum percentual deve ser inventado no Relatório Final. Tudo precisa derivar da matriz validada.
"""
}

# find phase directories matching N-
directories = glob.glob(os.path.join(phases_dir, "[0-9][0-9]-*"))
for d in directories:
    basename = os.path.basename(d)
    match = re.match(r"^(\d{2})-", basename)
    if match:
        phase_num = int(match.group(1))
        if phase_num in phase_data:
            context_path = os.path.join(d, f"{phase_num}-CONTEXT.md")
            with open(context_path, "w") as f:
                f.write(phase_data[phase_num])
            print(f"Created {context_path}")

