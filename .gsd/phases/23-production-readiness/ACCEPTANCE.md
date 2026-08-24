# GSD 23 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A23-01 | 0 blocker, 0 crítico | `BACKLOG.md` |
| A23-02 | QA manual completo executado nas duas plataformas | checklist assinada |
| A23-03 | Suíte completa verde | CI |
| A23-04 | 5 000 partidas sem crash nem invariante violada | relatório |
| A23-05 | Migração de save de todas as versões | testes com fixtures |
| A23-06 | Nenhuma perda de progresso nos 10 cenários de crash | teste |
| A23-07 | Rollback ensaiado e documentado nas duas lojas | procedimento |
| A23-08 | Checklist de segurança assinada | documento |
| A23-09 | Backup da API restaurado com sucesso | procedimento |
| A23-10 | Textos revisados, sem truncamento | capturas |
| A23-11 | Nenhum placeholder, mock vencido ou TODO sem tarefa | `validate-repo.sh` |
| A23-12 | Analytics e crash reporting validados na build final | validação |
| A23-13 | Documentação coerente com o produto entregue | revisão |
