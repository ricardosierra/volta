# Context: Gamificação Avançada - XP, Quests e Rewards

## Quest System e Daily/Weekly Loop
Infraestrutura baseada em eventos. Criar cadeias de Quests (objetivos curto, médio e longo prazo).
Implementar loop diário ("O que posso fazer agora?") e objetivos semanais mais ambiciosos.

## Streak e Comeback System
Criar streaks inteligentes com Streak Freeze e Comeback Bonus.
Criar experiência de retorno (Comeback Quest, recompensa equilibrada) para jogadores que não logavam há dias, sem conceder vantagens injustas.

## Play Games Rewards & Play Points
Preparar compatibilidade. Criar tabela central de recompensas com regras claras (id, amount, rarity, expiry).
O sistema de concessão (Reward Service) deve garantir idempotência (Server Validation, Persistence, Telemetry) e tratar crash/timeout sem duplicar a recompensa.
