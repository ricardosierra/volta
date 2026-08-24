# GSD 09 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F09-01 | Excesso de efeito virar poluição e esconder ameaça | 3 | 4 | hierarquia visual continua normativa; auditoria da GSD 08 é refeita ao fim desta fase |
| F09-02 | Efeitos estourarem o orçamento de CPU/GPU | 3 | 4 | pool obrigatório; densidade por preset; medição em dispositivo |
| F09-03 | Áudio pesar na memória e no tamanho do app | 2 | 3 | orçamento de 12 MB; OGG com bitrate controlado; camadas de apoio em mono |
| F09-04 | Slow-mo travar o input | 2 | 5 | teste dedicado; slow-mo é apenas escala de tempo visual, nunca de leitura de input |
| F09-05 | Háptico irritar ou consumir bateria | 2 | 3 | nunca contínuo; três níveis; medição de bateria |
| F09-06 | Fadiga auditiva por repetição | 3 | 2 | 3–4 variações + randomização de tom + limite de vozes |
| F09-07 | Acessibilidade tratada como "desligar coisas" e virar experiência pobre | 2 | 3 | requisito explícito: com tudo reduzido o jogo continua **divertido**, verificado em playtest |

## Riscos globais tocados
- **RISK-005** (não ser divertido): o game feel é o maior multiplicador de diversão disponível.
- **RISK-004** (60 FPS): último grande consumidor entra no orçamento antes da GSD 19.
