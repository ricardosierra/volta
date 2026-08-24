# GSD 23 — Tarefas

### PROD-001 — QA manual completo
**Passos:** roteiro cobrindo todos os modos, arenas, telas, settings, progressão, cosméticos,
online e offline → executar em Android e iOS → registrar tudo, inclusive o que for cosmético.
**DoD:** roteiro versionado em `tests/qa/release_checklist.md`, executado e assinado.

### PROD-002 — Regressão automatizada
**Passos:** suíte completa (unit, integration, gameplay, API) → 5 000 partidas em todos os modos
e arenas → benchmarks → comparar tudo com os baselines.
**DoD:** nenhum teste vermelho, nenhuma regressão de performance.

### PROD-003 — Migração de save
**Passos:** coletar fixtures de **todas** as versões usadas em teste → testar migração encadeada
até a versão atual → testar save corrompido, save de versão futura e save vazio → validar que
nada é perdido.
**DoD:** fixtures versionados em `tests/fixtures/saves/`; migração 100 % coberta.

### PROD-004 — Teste de crash e recuperação
**Passos:** matar o app em 10 momentos diferentes (boot, menu, loading, partida, captura,
resultado, compra, sincronização, background, com fila pendente) → verificar recuperação e
integridade do progresso.
**DoD:** nenhuma perda de progresso em nenhum dos 10 cenários.

### PROD-005 — Validação de rollback
**Passos:** ensaiar halt de rollout no Play e pausa de phased release na App Store → ensaiar
desativar uma feature por remote config → documentar o procedimento com capturas.
**DoD:** `docs/deployment/release-process.md` com o passo a passo real, testado.

### PROD-006 — Revisão de segurança
**Passos:** checklist de `docs/backend/security.md` → `composer audit` → revisar rate limits,
validação de score e sanitização → confirmar ausência de segredo no cliente e em logs →
testar backup e restauração da API.
**DoD:** checklist assinada; nenhuma pendência de alta severidade.

### PROD-007 — Revisão de conteúdo e textos
**Passos:** revisar todos os textos em en e pt-BR → conferir truncamento em escala 1,25 →
revisar textos de loja → conferir créditos e licenças de assets → conferir ausência de conteúdo
provisório.
**DoD:** nenhuma string errada, truncada ou provisória.

### PROD-008 — Fechamento do backlog de bloqueadores
**Passos:** revisar `BACKLOG.md` inteiro → classificar cada item aberto → corrigir todos os
`blocker` e `critical` → mover o restante para pós-launch com justificativa → atualizar
`STATUS.md` e `QUALITY_GATES.md`.
**DoD:** lista de bugs conhecidos publicada no handoff, com severidade e decisão.
