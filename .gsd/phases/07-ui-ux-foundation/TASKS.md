# GSD 07 — Tarefas

---

### UIUX-001 — Tokens do design system
**Objetivo:** a fonte única de verdade visual.
**Contexto:** `docs/ui/design-system.md` §1. **Dependências:** GSD 06.
**Arquivos:** `src/ui/design_system/tokens/*.gd` e `.tres`, `resources/themes/neon.tres`.
**Passos:** classes de `Resource` para espaçamento, raio, tipografia, cor semântica, elevação e
movimento → `ThemePalette` com os papéis de `docs/art/themes.md` → tema `Neon` provisório →
`ThemeService` que aplica em runtime.
**Testes:** trocar de tema muda a UI inteira sem reiniciar; token ausente falha alto em debug.
**DoD:** nenhum valor visual fora dos tokens.

---

### UIUX-002 — `SafeAreaContainer` e responsividade
**Objetivo:** funcionar em qualquer tela, sem gambiarra por aparelho.
**Contexto:** `docs/ui/design-system.md` §3; ADR-0009. **Dependências:** UIUX-001.
**Arquivos:** `src/ui/components/safe_area_container.gd`, `tools/dev/screenshot_matrix.sh`.
**Passos:** ler `DisplayServer.get_display_safe_area()` e reagir a mudanças → margens mínimas →
script de captura automática nas 5 proporções + tablet → conferir todas as telas existentes.
**Testes:** capturas nas 5 proporções sem sobreposição nem corte.
**DoD:** nenhuma tela quebra em nenhuma proporção da matriz.

---

### UIUX-003 — Componentes base
**Objetivo:** os 12 componentes, com todos os estados.
**Dependências:** UIUX-001. **Arquivos:** `src/ui/components/*.gd/.tscn`.
**Passos:** implementar `VButton` (3 variantes, 4 estados, háptico mínimo), `VIconButton`,
`VCard`, `VToggle`, `VSlider`, `VTabs`, `VModal`, `VToast`, `VProgressBar`, `VCurrencyPill`,
`VRunnerPreview` → alvo de toque ≥ 48 dp em todos → foco e estados acessíveis.
**Testes:** showcase cobre todos os estados; script verifica tamanho mínimo de alvo.
**DoD:** nenhuma tela implementa botão próprio.

---

### UIUX-004 — Showcase de componentes
**Objetivo:** vitrine e regressão visual.
**Dependências:** UIUX-003. **Arquivos:** `src/ui/design_system/showcase.tscn`.
**Passos:** uma página por família de componente → todos os estados visíveis ao mesmo tempo →
seletor de tema e de escala de UI → captura automatizada para comparação entre versões.
**Testes:** captura do showcase é gerada no CI e anexada como artefato.
**DoD:** revisar UI passa a ser olhar uma tela, não caçar pelo app.

---

### UIUX-005 — Navegação
**Objetivo:** ir e voltar sem surpresa.
**Contexto:** `docs/ui/screens.md`. **Dependências:** UIUX-003.
**Arquivos:** `src/ui/navigation/screen_stack.gd`, `screen.gd`.
**Passos:** pilha de telas com push/pop e transições de 250 ms → back do Android e gesto do iOS
mapeados → confirmação de saída na raiz → profundidade máxima 2 → estado preservado em
pause/resume.
**Testes:** pilha correta em toda navegação; back na raiz pede confirmação; transição não
bloqueia toque.
**DoD:** nunca dá para se perder no app.

---

### UIUX-006 — i18n
**Objetivo:** nenhum texto hardcoded, desde a primeira string.
**Dependências:** UIUX-003. **Arquivos:** `resources/i18n/en.csv`, `pt_BR.csv`,
`tools/ci/check_i18n.sh`.
**Passos:** chaves em `snake_case` por tela → en e pt-BR → detecção de idioma do sistema com
troca manual → script que detecta chave faltando, chave órfã e texto solto em `.tscn`/`.gd`.
**Testes:** o script falha com chave faltando plantada; troca de idioma em runtime.
**DoD:** verificação de i18n no CI.

---

### UIUX-007 — Splash e Main Menu
**Objetivo:** a primeira impressão.
**Contexto:** `docs/ui/screens.md` §Main Menu. **Dependências:** UIUX-005.
**Arquivos:** `src/ui/screens/splash_screen.gd`, `main_menu_screen.gd`.
**Passos:** splash ≤ 1,5 s com carga real por trás → menu com logo, PLAY dominante,
`VRunnerPreview` animado, moedas, rank, atalho de desafios e engrenagem → hierarquia visual
conforme o diagrama do documento.
**Testes:** PLAY é o maior alvo de toque; menu abre em < 300 ms; preview anima sem custo alto.
**DoD:** o menu não parece uma lista de botões.

---

### UIUX-008 — Pause e Results
**Objetivo:** as duas telas que aparecem toda partida.
**Dependências:** UIUX-005. **Arquivos:** `src/ui/screens/pause_screen.gd`, `results_screen.gd`.
**Passos:** pause com Retomar dominante, Reiniciar, Configurações e Sair, congelando tudo →
Results refinada sobre a base da GSD 06, com cascata de entrada, contagem animada pulável ao
toque, e PLAY AGAIN dominante.
**Testes:** pause congela; tocar durante a contagem completa na hora; restart continua < 0,8 s.
**DoD:** as duas telas respeitam a zona do polegar.

---

### UIUX-009 — Settings
**Objetivo:** controle real nas mãos do jogador.
**Contexto:** `docs/ui/screens.md`, `docs/gameplay/controls.md`. **Dependências:** UIUX-003, UIUX-006.
**Arquivos:** `src/ui/screens/settings/*.gd`.
**Passos:** seções Áudio (3 sliders), Controles (esquema, sensibilidade, zona morta, manter
direção, mão dominante, zona de toque, **test drive** ao vivo), Gráficos (preset + toggles),
Háptico (Off/Light/Full), Acessibilidade (reduzir shake, reduzir flashes, escala de UI, alto
contraste, tema de daltonismo), Idioma, Privacidade (opt-out, resetar id de analytics), Sobre →
tudo persistido pelo `SaveService` com efeito imediato.
**Testes:** cada opção persiste e tem efeito; test drive responde ao vivo; reset restaura padrões.
**DoD:** nenhuma opção é decorativa.

---

### UIUX-010 — Onboarding
**Objetivo:** ensinar sem tutorial.
**Contexto:** `docs/design/onboarding.md`. **Dependências:** UIUX-005.
**Arquivos:** `src/ui/onboarding/tutorial_director.gd`, `tutorial_step.gd`,
`resources/onboarding/steps/*.tres`.
**Passos:** 6 passos como `Resource` (gatilho, texto, condição de saída, evento) → primeira
execução vai direto para a partida com 2 bots Rookie → dica nunca aparece com inimigo a menos
de 10 células → progresso salvo → opção de rejogar nas settings.
**Testes:** cada passo sai na condição certa; pular/repetir funciona; nenhuma dica durante
momento de tensão.
**DoD:** medir tempo até o primeiro Seal com 3 pessoas novas (alvo < 25 s).

---

### UIUX-011 — Som e háptico de UI
**Objetivo:** a interface responder ao toque.
**Dependências:** UIUX-003. **Arquivos:** `src/presentation/audio/ui_audio.gd`,
`src/presentation/haptics/haptic_service.gd`.
**Passos:** barramentos de áudio (Master, Music, SFX, UI) → sons provisórios de toque, voltar,
abrir, confirmar (`PLACEHOLDER-AUDIO-001`, destino GSD 09) → `HapticService` com Off/Light/Full
e degradação silenciosa onde não houver suporte.
**Testes:** volumes independentes; háptico respeita a configuração; ausência de suporte não
gera erro.
**DoD:** todo componente interativo responde em som e háptico.

---

### UIUX-012 — Validação de UI em dispositivos
**Objetivo:** provar a responsividade com imagem, não com fé.
**Dependências:** UIUX-001..011. **Arquivos:** `tools/dev/screenshot_matrix.sh`, `docs/ui/screens.md`.
**Passos:** capturas de todas as telas nas 5 proporções + tablet, em escala 1,0 e 1,25 →
verificação de contraste automatizada sobre os tokens → conferência manual em 2 aparelhos reais
→ corrigir tudo que quebrar.
**Testes:** conjunto de capturas anexado ao PR; script de contraste verde.
**DoD:** nenhuma tela quebrada em nenhuma combinação da matriz.
