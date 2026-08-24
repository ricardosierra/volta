# GSD 21 — Tarefas

### ANDR-001 — Configuração de release
**Passos:** revisar `project.godot` para release → `VOLTA_DEBUG_TOOLS=false` → nível de log
`warn` → renderer e fallback confirmados → `versionCode` e `versionName` derivados do semver.
**Testes:** `Build.is_debug()` retorna `false`; nível de log correto.
**DoD:** build de release distinta e verificável.

### ANDR-002 — Assinatura e export presets
**Passos:** keystore de release gerado e guardado **fora** do repositório → secrets no GitHub
Actions → `make_export_presets.sh` gera o preset a partir de template + variáveis → validação
de que nenhuma senha aparece em log.
**Testes:** build assinada verificada com `apksigner`/`bundletool`; log limpo.
**DoD:** ninguém precisa da máquina de alguém para gerar release.

### ANDR-003 — Verificação de build limpa
**Passos:** `check_release_build.sh` — sem `addons/gut`, sem cenas de debug, sem overlay, sem
arquivo de teste, sem `PLACEHOLDER-*`, sem TODO sem tarefa → integrar ao workflow de release.
**Testes:** build com cena de debug plantada é reprovada.
**DoD:** impossível publicar com ferramenta de debug dentro.

### ANDR-004 — Ícones e splash
**Passos:** ícone adaptativo (foreground + background) em todas as densidades → teste nas três
máscaras → splash com cor do tema e logo vetorial → sem tela de carregamento longa.
**Testes:** dispositivo real com launchers diferentes.
**DoD:** o ícone parece profissional em qualquer launcher.

### ANDR-005 — Permissões e manifest
**Passos:** revisar cada permissão; remover tudo que não for essencial → `INTERNET` justificada
pelos serviços online → sem armazenamento externo, localização ou identificador de publicidade →
`android:allowBackup` avaliado.
**Testes:** app funciona com o conjunto mínimo; instalação não mostra pedido estranho.
**DoD:** lista de permissões documentada em `docs/mobile/android.md`.

### ANDR-006 — Privacidade e Data Safety
**Passos:** cruzar a auditoria de payload da GSD 18 com o formulário → preencher Data Safety →
publicar a política de privacidade e ligá-la em `Settings > Sobre` e na ficha da loja.
**Testes:** revisão cruzada linha a linha entre coleta real e declaração.
**DoD:** nenhuma divergência entre o que o app faz e o que declara.

### ANDR-007 — Assets de loja
**Passos:** ícone 512², feature graphic 1024×500, ≥ 4 screenshots por tamanho, vídeo opcional,
descrição curta e longa em en e pt-BR, classificação etária, categoria e tags.
**Testes:** todos os assets nas dimensões corretas; textos revisados.
**DoD:** ficha pronta para submissão.

### ANDR-008 — Validação em dispositivo
**Passos:** instalar o AAB (via bundletool) em Low, Mid, High e tablet → jogar 30 min em cada →
verificar performance, back button, background/foreground, ausência de debug → medir cold start
e bateria na build de release.
**Testes:** checklist da matriz de dispositivos com build de release.
**DoD:** nenhum comportamento diferente do esperado.

### ANDR-009 — Teste interno no Play
**Passos:** subir para Internal Testing → instalar via Play em pelo menos 3 aparelhos de pessoas
diferentes → coletar feedback e crash → corrigir bloqueadores.
**Testes:** instalação pela loja funciona; crash-free na faixa esperada.
**DoD:** relatório de teste interno no `HANDOFF.md`.
