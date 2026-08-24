# GSD 23 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F23-01 | Encontrar bug grave tarde | 3 | 4 | é exatamente o objetivo da fase; melhor aqui que em produção; escopo congelado permite corrigir sem introduzir risco novo |
| F23-02 | Tentação de adicionar "só mais uma coisinha" | 3 | 4 | escopo congelado por regra; qualquer feature vai para pós-launch |
| F23-03 | Migração de save falhar para alguma versão de teste | 2 | 5 | fixtures de todas as versões; teste encadeado obrigatório |
| F23-04 | Rollback não funcionar quando for preciso | 2 | 5 | ensaiado **antes**, com capturas do procedimento real |
| F23-05 | QA manual incompleto por cansaço | 3 | 3 | checklist versionada e assinada, executada em sessões separadas |
| F23-06 | Backup da API existir e não restaurar | 2 | 5 | restauração testada em ambiente limpo, de novo |
