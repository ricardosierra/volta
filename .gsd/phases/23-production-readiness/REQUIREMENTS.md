# GSD 23 — Requisitos

| # | Requisito | Verificação |
|---|---|---|
| R23-01 | 0 bugs blocker e 0 críticos | `BACKLOG.md` |
| R23-02 | Suíte completa verde nas duas plataformas | CI + dispositivo |
| R23-03 | 5 000 partidas headless sem crash nem invariante violada | relatório |
| R23-04 | Migração de save testada a partir de **todas** as versões publicadas em teste | testes com fixtures |
| R23-05 | App se recupera de crash sem perder progresso | teste com kill forçado |
| R23-06 | Rollback ensaiado nas duas lojas | procedimento |
| R23-07 | Checklist de segurança revisada | documento |
| R23-08 | Textos revisados em en e pt-BR, sem truncamento | revisão + capturas |
| R23-09 | Nenhum placeholder, mock vencido ou TODO sem tarefa | `validate-repo.sh` |
| R23-10 | Analytics e crash reporting funcionando na build final | validação |
| R23-11 | Documentação atualizada e coerente com o produto | revisão |
| R23-12 | Backup e restauração da API testados de novo | procedimento |
