# GSD 18 — Tarefas

### ANLT-001 — Auditoria do plano de eventos
**Passos:** revisar `docs/product/analytics-plan.md` à luz do jogo real → confirmar que cada
evento responde a uma pergunta de produto → remover o que não serve → congelar os nomes.
**DoD:** lista final de eventos aprovada antes de qualquer implementação.

### ANLT-002 — `LocalFileAnalytics` e `RemoteAnalytics` (fecha MOCK-002)
**Passos:** adapter local em JSONL (debug/QA) → adapter remoto com lote, compressão, fila
offline e deduplicação → seleção por config → `NoopAnalytics` continua sendo o padrão em builds
sem consentimento.
**Testes:** eventos gravados; lote enviado uma vez só; fila sobrevive ao app morto.
**DoD:** MOCK-002 fechado.

### ANLT-003 — Ingestão na API
**Passos:** `POST /telemetry` com lote, validação de schema e rate limit → armazenamento
particionado por data → job de agregação → retenção definida (bruto por 90 dias, agregado por 2 anos).
**Testes:** lote válido e inválido; rate limit; agregação correta.
**DoD:** volume e custo estimados e documentados.

### ANLT-004 — Crash reporting
**Passos:** captura de erro não tratado e de falha de script → contexto: versão, dispositivo,
tier, cena, últimos N logs (sem PII) → envio na próxima abertura → agrupamento por assinatura.
**Testes:** crash forçado é capturado e enviado; nenhum dado sensível no payload.
**DoD:** taxa crash-free mensurável.

### ANLT-005 — Métricas de performance
**Passos:** `perf_sample` a cada 15 s com FPS p50/p10, memória, preset, modo e arena →
agregação por modelo de aparelho → consulta que compara com o orçamento.
**Testes:** amostragem não custa frame; agregação correta.
**DoD:** dá para responder "o jogo roda bem no aparelho X?" com dado.

### ANLT-006 — Privacidade e opt-out
**Contexto:** `docs/product/analytics-plan.md` §Privacidade.
**Passos:** `Settings > Privacy` com opt-out real, reset de id e explicação em linguagem simples
→ auditoria de payload campo a campo → política de privacidade atualizada.
**Testes:** com opt-out, nenhuma requisição sai (verificado por proxy); reset gera id novo.
**DoD:** auditoria de payload anexada ao PR.

### ANLT-007 — Painel mínimo
**Passos:** consultas para: funil de onboarding, partidas por sessão, retenção D1/D7, mortes por
causa, distribuição de território final, vitórias por arquétipo, FPS por modelo → painel simples
(pode ser página autenticada na API) → alertas para crash rate e erro de submissão.
**Testes:** consultas retornam dado coerente com o stress test.
**DoD:** decisões de balanceamento passam a ter fonte.

### ANLT-008 — Validação ponta a ponta
**Passos:** build de produção → jogar 10 partidas reais → conferir cada evento chegando com as
propriedades certas → conferir crash e `perf_sample` → medir impacto de bateria e banda.
**Testes:** todos os eventos chegam; nenhum evento por frame; banda desprezível.
**DoD:** relatório de validação no `HANDOFF.md`.
