# GSD 15 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F15-01 | Score do servidor divergir do cliente e rejeitar partida legítima | 3 | 4 | mesma fórmula, mesmas constantes (compartilhadas em `packages/shared`); tolerância explícita; `flags` em vez de banimento |
| F15-02 | Anti-cheat gerar falso positivo | 3 | 4 | escala de resposta em 4 níveis; nunca banir por anomalia única |
| F15-03 | Cloud save sobrescrever progresso | 2 | 5 | reconciliação monotônica; 3 versões guardadas; teste de conflito obrigatório |
| F15-04 | Custo de hospedagem surpreender | 2 | 3 | stack barata; Redis e Postgres pequenos no início; decisão humana H-03 antes do deploy |
| F15-05 | Segredo vazar no repositório | 2 | 5 | `.env` ignorado; verificação no CI; nenhum segredo em log |
| F15-06 | Backup existir e não funcionar | 2 | 5 | restauração **testada** é critério de aceite, não item de documentação |
| F15-07 | Bloquear a fase esperando infraestrutura | 3 | 2 | tudo roda em Docker local; deploy é a última tarefa |

## Riscos globais tocados
- **RISK-011** (backend indisponível): o cliente continua 100 % offline-first (garantido na GSD 16).
- **RISK-019** (dependência externa): H-03 tem prazo antes do deploy.
