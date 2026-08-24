# GSD 19 — Tarefas

### PERF-001 — Baseline completo
**Passos:** medir tudo, em Low, Mid e High, com build de release: FPS p50/p10, frame time,
tick por subsistema, GPU, draw calls, memória, carregamento, bateria, tamanho → registrar em
`docs/performance/device-results.md` **antes** de qualquer mudança.
**DoD:** foto do "antes" completa. Sem ela, nenhuma otimização pode ser provada.

### PERF-002 — Profiling de CPU
**Passos:** identificar os 10 maiores custos por tick com o profiler e com o overlay próprio →
comparar com o orçamento → listar gargalos com custo estimado de correção.
**DoD:** lista priorizada por (custo atual × facilidade de corrigir).

### PERF-003 — Otimização do território
**Passos:** aplicar, **somente se necessário**, as estratégias de
`territory-benchmarks.md` §Estratégias, na ordem de preferência (bbox mais justa → scanline →
cache de alcance → amortização em 2 ticks → chunks → GDExtension) → re-rodar B01–B15.
**Testes:** benchmarks dentro do orçamento; nenhum caso de mesa quebrado.
**DoD:** cada mudança com antes/depois no PR; nenhuma otimização especulativa.

### PERF-004 — Otimização de IA
**Passos:** revisar frequência de decisão e custo por ação → cachear o que for estável entre
decisões → reduzir alocação → verificar `OpportunityMap` (atualização por evento, nunca varredura).
**Testes:** B09/B10 dentro do orçamento; comportamento **inalterado** (distribuição de vitórias
igual em 500 partidas).
**DoD:** mais barato, mesmo comportamento — provado por relatório comparativo.

### PERF-005 — Otimização de GPU
**Passos:** medir cada shader → simplificar os mais caros → revisar overdraw → conferir batching
e número de materiais → ajustar densidade de partículas por preset.
**Testes:** GPU dentro do orçamento nos 3 tiers; nenhuma perda visual perceptível (comparação
lado a lado).
**DoD:** antes/depois em vídeo anexado ao PR.

### PERF-006 — Memória e vazamentos
**Passos:** 10 partidas seguidas medindo RSS → caçar nós órfãos, sinais não desconectados e
pools crescendo → revisar `RefCounted` mantidos vivos → verificar descarregamento de arena e
áudio entre partidas.
**Testes:** crescimento ≈ 0; nenhum objeto órfão no monitor.
**DoD:** memória plana em sessão longa.

### PERF-007 — Carregamento e tamanho do app
**Passos:** medir e reduzir cold start (o que é carregado à toa no boot?) → pré-carregar durante
a animação do resultado → revisar compressão de textura (ETC2/ASTC), bitrate de áudio e assets
não usados → reduzir o pacote.
**Testes:** cold start < 3 s; transições dentro do alvo; tamanho dentro do orçamento.
**DoD:** nada é carregado no boot que não seja usado no boot.

### PERF-008 — Bateria e térmica
**Passos:** medir consumo em 1 hora de jogo contínuo em cada tier → verificar throttling em
20 min → ajustar `Engine.max_fps`, `low_processor_mode` e densidade de efeito.
**Testes:** < 8 %/hora; sem throttling perceptível.
**DoD:** o jogo não esquenta o telefone a ponto de incomodar.

### PERF-009 — Re-baseline e regressão
**Passos:** re-rodar todos os benchmarks e o stress test de 2 000 partidas → atualizar baselines
versionados → confirmar o gate de regressão de 10 % no CI → documentar tudo.
**Testes:** todos os benchmarks dentro do orçamento; nenhuma regressão funcional.
**DoD:** `docs/performance/*` atualizado com antes/depois; baselines novos versionados.
