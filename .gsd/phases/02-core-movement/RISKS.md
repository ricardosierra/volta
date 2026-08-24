# GSD 02 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F02-01 | Latência acima de 50 ms e causa difícil de isolar | 3 | 5 | `MOVE-010` instrumenta o caminho inteiro (evento → tick → frame); suspeitos listados na tarefa; se não fechar, a fase **não** fecha |
| F02-02 | Interpolação manual introduzir jitter | 3 | 4 | componente único e testado; verificação por gravação em câmera lenta; se falhar, avaliar antecipar o upgrade de engine (BL-011) |
| F02-03 | Zona morta em mm ficar errada por DPI mal reportado | 2 | 3 | fallback para valor em pixels com calibração; testar em dois aparelhos de densidades diferentes |
| F02-04 | Taxa de giro escolhida por chute deixar o controle ruim | 3 | 3 | valor em config, ajustável em runtime pelo menu de debug; teste de sensação com 3 pessoas |
| F02-05 | Escopo vazar para território ("já que estou aqui, marco umas células") | 3 | 4 | escopo negativo explícito; a GSD 03 tem 14 tarefas exatamente para não ser apressada |
| F02-06 | Câmera causar enjoo (lookahead agressivo demais) | 2 | 3 | parâmetros em config; teste de 2 minutos contínuos com 3 pessoas |
| F02-07 | Determinismo quebrar por ordem de iteração ou float | 2 | 5 | ordem fixa de atualização; teste de 10 execuções com a mesma seed; é pré-requisito de RISK-014 |

## Riscos globais tocados

- **RISK-004** (60 FPS): primeira medição real do orçamento acontece aqui.
- **RISK-013** (limitação da engine em mobile): primeira validação em dispositivo real.
- **RISK-014** (determinismo): a garantia começa nesta fase e é verificada em todas as seguintes.
