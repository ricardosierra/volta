# GSD 24 — Tarefas

### LNCH-001 — Fechar a versão
**Passos:** branch `release/v0.1.0` → bump em `project.godot` e nas configurações de plataforma →
CHANGELOG: mover `[Unreleased]` para `## [v0.1.0 (AAAA-MM-DD)]` seguido do link de comparação no formato
Release Notes (seções `✨ Novidades`, `🎨 Melhorias`, `🐛 Correções`, `🔧 Técnico`, itens `- [x]`) →
congelar escopo.
**DoD:** versão coerente em todos os lugares; CHANGELOG no formato do projeto.

### LNCH-002 — Checklist de release
**Passos:** executar a checklist completa de `docs/deployment/release-process.md`, item a item,
marcando cada um com evidência.
**DoD:** checklist marcada com links e capturas; nenhum item "provavelmente ok".

### LNCH-003 — Builds finais
**Passos:** gerar AAB e IPA a partir da tag, pelo CI → verificar assinatura e ausência de debug →
guardar os artefatos e os mapas de símbolo (para desofuscar crash).
**DoD:** builds reprodutíveis a partir da tag.

### LNCH-004 — Tag e release
**Passos:** merge `release/v0.1.0` → `main` com `--no-ff` → tag anotada `v0.1.0` → release no
GitHub com as notas → merge de volta em `develop`.
**DoD:** histórico limpo e rastreável.

### LNCH-005 — Submissão
**Passos:** submeter ao Play (produção, rollout 5 %) e à App Store (phased release) → responder
a eventuais pedidos da revisão → confirmar metadados e ficha.
**DoD:** builds aceitas nas duas lojas.

### LNCH-006 — Rollout e monitoramento
**Passos:** 5 % → 20 % → 50 % → 100 %, com 24 h de métrica saudável entre degraus → monitorar
crash-free, ANR, retenção D1, funil de onboarding, avaliações e erros da API → parar o rollout
ao primeiro sinal ruim.
**Testes:** crash-free ≥ 99,5 % em cada degrau.
**DoD:** rollout concluído ou interrompido com decisão registrada.

### LNCH-007 — Pós-lançamento imediato (72 h)
**Passos:** acompanhar métricas e avaliações → responder avaliações → corrigir bloqueador com
hotfix `patch` se aparecer → registrar aprendizados e alimentar a GSD 25.
**DoD:** relatório de 72 h com métricas reais e lista de prioridades para o pós-launch.
