# Context: Gamification Foundation - Eventos de Domínio e Integração

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
