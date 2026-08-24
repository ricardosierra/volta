# GSD 18 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F18-01 | Coletar demais e virar problema de privacidade (RISK-015) | 2 | 4 | auditoria de payload; zero PII; um único ponto de saída; opt-out real |
| F18-02 | Analytics acoplar ao gameplay | 2 | 4 | `AnalyticsBridge` como único tradutor; verificação de camadas |
| F18-03 | Volume de telemetria custar caro | 2 | 3 | lote, amostragem, retenção definida, estimativa de custo antes de ligar |
| F18-04 | Evento renomeado quebrar a série histórica | 3 | 3 | nomes congelados na ANLT-001; renomear exige evento novo |
| F18-05 | Analytics custar frame ou bateria | 2 | 3 | nada por frame; envio em lote fora de partida; medição obrigatória |
| F18-06 | Declaração de loja divergir da coleta real | 2 | 4 | auditoria alimenta diretamente Data Safety e Privacy Label (GSD 21/22) |
