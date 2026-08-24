# GSD 22 — Tarefas

### IOS-001 — Configuração e export
**Passos:** preset de export iOS → `CFBundleShortVersionString` = semver, `CFBundleVersion`
monotônico → orientação travada → `VOLTA_DEBUG_TOOLS=false` → script `build_ios.sh` que gera o
projeto Xcode.
**DoD:** export reprodutível por script.

### IOS-002 — Assinatura e arquivamento
**Passos:** App ID, provisioning de distribuição, certificados → `archive_ios.sh` com
`xcodebuild archive` + export do IPA → secrets no CI (opcional, macOS runner).
**Testes:** IPA gerado e validado pelo Xcode.
**DoD:** processo documentado em `docs/mobile/ios.md`.

### IOS-003 — Ícones e launch screen
**Passos:** conjunto completo do `AppIcon` (1024² sem alfa) → launch screen em storyboard com
cor do tema e logo → verificar em iPhone e iPad.
**Testes:** validação do Xcode sem aviso de ícone faltando.
**DoD:** nada de imagem estática por tamanho.

### IOS-004 — Privacidade e entitlements
**Passos:** Privacy Nutrition Label a partir da auditoria da GSD 18 → `PrivacyInfo.xcprivacy`
se aplicável → nenhum entitlement especial → **sem** ATT no v0.1.0.
**Testes:** revisão cruzada declaração × coleta real.
**DoD:** coerência total.

### IOS-005 — Comportamentos do sistema
**Passos:** safe area (notch, Dynamic Island, home indicator) → nada interativo nos últimos 20 pt
→ áudio com categoria correta e retomada limpa após interrupção → salvar em background →
Core Haptics com fallback.
**Testes:** ligação durante a partida; alarme; botão de silencioso; app suspenso e retomado.
**DoD:** o app se comporta como um cidadão bem-educado do iOS.

### IOS-006 — Validação em dispositivo
**Passos:** iPhone mínimo suportado, iPhone atual, iPhone Pro (120 Hz) e iPad → 30 min de jogo
em cada → performance, safe area, háptico, áudio, gestos.
**Testes:** checklist da matriz com build de release.
**DoD:** nenhum comportamento diferente do Android sem justificativa.

### IOS-007 — Assets de loja
**Passos:** ícone 1024² sem alfa, screenshots 6,7" e 5,5" (obrigatórios) + iPad, texto
promocional, descrição, palavras-chave, faixa etária, política de privacidade — tudo em en e pt-BR.
**DoD:** ficha pronta para submissão.

### IOS-008 — TestFlight
**Passos:** subir a build → teste interno com ≥ 3 pessoas → coletar feedback e crash →
corrigir bloqueadores → validar que a build passa na verificação automática da App Store.
**DoD:** relatório de TestFlight no `HANDOFF.md`.
