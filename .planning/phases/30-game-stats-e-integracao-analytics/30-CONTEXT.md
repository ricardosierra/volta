# Context: Game Stats e Integração Analytics

## Game Stats
Implementar a API moderna de Game Stats, focando em eventos relevantes do gameplay (vitórias, itens, nível, tempo, combos).
Nunca usar Game Stats para dados sensíveis, compras ou aberturas genéricas de app.

## Player Progression Stat
Definir estatística principal (ex: Level, Rank, World Progress). Enviar atualização sempre que progresso mudar, mantendo o estado consistente no início das sessões.

## Analytics
Instrumentar o sistema com eventos analíticos relevantes (`gamification_viewed`, `achievement_unlocked`, `quest_completed`, etc.) e KPIs (D1, D7, retenção). Medir o funil da primeira sessão para detectar gargalos.
Gerar arquivos CSV de configuração quando aplicável.
