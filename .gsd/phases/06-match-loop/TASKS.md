# GSD 06 — Tarefas

---

### LOOP-001 — Countdown e início de partida

**Objetivo:** entrar na partida com ritmo, sem tela morta.
**Dependências:** GSD 05.
**Arquivos:** `src/gameplay/states/countdown_state.gd`, `src/ui/hud/countdown_view.gd`.
**Passos:**
1. 3 s de contagem, com os Runners já posicionados e a câmera enquadrada.
2. Input **já é lido** durante o countdown (o jogador se prepara, mas não se move).
3. Transição para `Playing` sem corte visual.
**Testes:** integração — nenhum movimento acontece antes do fim; a direção escolhida durante o
countdown é aplicada no primeiro tick.
**DoD:** entrar na partida parece rápido; nada trava.

---

### LOOP-002 — `ScoreService`: termos base

**Objetivo:** implementar a fórmula, termo a termo.
**Contexto:** `docs/design/scoring.md` §1.
**Dependências:** GSD 05.
**Arquivos:** `src/gameplay/score/score_service.gd`, `score_state.gd`,
`resources/config/balance/score.tres`.
**Passos:**
1. Ouvir os eventos de simulação (`seal_completed`, `runner_broken`, tick de sobrevivência).
2. Calcular `seal_points` com risco, Surge e Final Push; contabilizar células roubadas com
   o multiplicador extra.
3. Acumular `break_points` com sequência, `survival_points`, `largest_seal`.
4. Ao fim: `final_territory_points`, `placement_bonus`, `victory_multiplier`.
5. Todas as constantes vindas do `.tres`.
**Testes:** um teste por termo, com valores esperados calculados à mão; score total de um
cenário completo; determinismo; score ≥ 0; tetos respeitados.
**DoD:** a fórmula do documento e o código são a mesma coisa, verificado termo a termo.

---

### LOOP-003 — Surge

**Objetivo:** o sistema de combo que dá ritmo à partida.
**Contexto:** `docs/design/scoring.md` §2.
**Dependências:** LOOP-002.
**Arquivos:** `src/gameplay/score/surge_service.gd`, `resources/config/balance/surge.tres`.
**Passos:**
1. Subida por Seal e por Break dentro das janelas.
2. Decaimento por inatividade; zeragem em morte e Backwash.
3. Teto de nível; multiplicador derivado.
4. Sinais para HUD e (futuro) áudio e VFX.
**Testes:** subida, decaimento, zeragem, teto; janelas exatas; Backwash zera de fato.
**DoD:** o Surge é sentido no score e visível na HUD.

---

### LOOP-004 — Bônus nomeados

**Objetivo:** dar nome ao que o jogador fez bem.
**Contexto:** `docs/design/scoring.md` §3; valores em `balance.md` §6.
**Dependências:** LOOP-003.
**Arquivos:** `src/gameplay/score/bonus_detector.gd`, `resources/config/balance/bonuses.tres`.
**Passos:**
1. Detectar os 9: Double Seal, Triple Seal, Claim Streak, Break Streak, Risk Bonus,
   Close Call, Mega Seal, Cut, Squeeze.
2. Emitir evento com nome, valor e posição na tela.
3. Popup empilhável (máx. 3), provisório visualmente.
**Testes:** 9 testes, um por bônus, com o cenário mínimo que o dispara — e um teste que garante
que ele **não** dispara fora da condição.
**DoD:** todos os bônus alcançáveis em jogo real (verificado no stress test).

---

### LOOP-005 — Final Push

**Objetivo:** terminar a partida com o pé no acelerador.
**Contexto:** R7.3.
**Dependências:** LOOP-002.
**Arquivos:** `src/gameplay/match_director.gd`, `src/ui/hud/final_push_banner.gd`.
**Passos:**
1. Nos últimos 30 s, aplicar `PUSH_MULT` aos pontos de Seal.
2. Aviso: banner curto + mudança de cor da moldura da HUD.
3. Habilitado por modo (`final_push_enabled`).
**Testes:** multiplicador aplicado só na janela; desabilitado nos modos que não usam.
**DoD:** dá para perceber que entrou no Final Push sem ler texto.

---

### LOOP-006 — Fim de partida e ranking

**Objetivo:** decidir quem ganhou, sem ambiguidade.
**Contexto:** R7.1, R7.2.
**Dependências:** LOOP-002.
**Arquivos:** `src/gameplay/match_director.gd`, `src/gameplay/match_result.gd`.
**Passos:**
1. Condições de fim: tempo, meta de domínio, último vivo.
2. Ranking por percentual de Claim; desempate: score → maior Seal → menor tempo desenhando.
3. `MatchResult` com todos os dados que a tela de resultado e o analytics precisam.
4. Abandono registra derrota e preserva o que foi ganho (R7.4).
**Testes:** três condições de fim; empate resolvido em cada nível do desempate; abandono.
**DoD:** nenhum empate fica sem solução determinística.

---

### LOOP-007 — HUD funcional

**Objetivo:** a informação essencial, e só ela.
**Contexto:** `docs/ui/hud.md`.
**Dependências:** LOOP-003, LOOP-006.
**Arquivos:** `src/ui/hud/hud.gd`, `territory_label.gd`, `position_label.gd`, `timer_label.gd`,
`risk_indicator.gd`, `surge_meter.gd`, `pause_button.gd`.
**Passos:**
1. Os 5 elementos permitidos, com números tabulares (o layout não pode tremer).
2. Indicador de risco flutuando acima do Runner durante `DrawingTrail`.
3. Medidor de Surge aparecendo só quando ativo.
4. Popups efêmeros de `+X%` e de bônus.
5. Safe area respeitada (mesmo antes do design system da GSD 07).
**Testes:** HUD nunca cobre o Runner; nenhum elemento além dos 5; layout estável ao mudar valores.
**DoD:** dá para jogar olhando só o campo, com a HUD na periferia.

---

### LOOP-008 — Tela de resultado e restart

**Objetivo:** fechar o loop e reabri-lo em um toque.
**Contexto:** `docs/ui/screens.md`.
**Dependências:** LOOP-006.
**Arquivos:** `src/ui/screens/results_screen.gd`.
**Passos:**
1. Colocação, percentual final, score com contagem animada, lista de bônus, recorde pessoal
   (com destaque quando for novo).
2. **PLAY AGAIN** como maior alvo de toque da tela, na zona do polegar.
3. `Results → Loading` direto, sem passar pelo menu.
4. Pré-carregar a próxima partida enquanto a contagem anima (para o restart ser instantâneo).
**Testes:** restart em < 0,8 s; contagem animada não bloqueia o toque (tocar acelera/pula).
**DoD:** reiniciar é mais fácil que sair — como deve ser.

---

### LOOP-009 — Leaderboard local e recordes

**Objetivo:** dar o que perseguir, mesmo offline.
**Contexto:** ADR-0005; `docs/architecture/networking.md`.
**Dependências:** LOOP-006, `SaveService`.
**Arquivos:** `src/progression/leaderboard/leaderboard_repository.gd`,
`local_leaderboard_repository.gd`.
**Passos:**
1. Interface `LeaderboardRepository` com a forma final (a implementação remota chega na GSD 16).
2. `LocalLeaderboardRepository`: top 20 pessoal por modo, persistido.
3. Marcar o mock com `## MOCK / Replacement Phase: GSD 16 / Replacement Task: ONLN-003`.
**Testes:** persistência entre sessões; ordenação; limite de entradas.
**DoD:** MOCK-001 registrado no `BACKLOG.md` com destino.

---

### LOOP-010 — Analytics (interface) e validação do MVP

**Objetivo:** emitir os eventos certos e conferir a checklist do MVP.
**Contexto:** ADR-0010; `docs/product/analytics-plan.md`.
**Dependências:** LOOP-001..009.
**Arquivos:** `src/platform/analytics/analytics_service.gd`, `noop_analytics.gd`,
`src/gameplay/analytics_bridge.gd`.
**Passos:**
1. Interface + `NoopAnalytics` (MOCK-002, destino GSD 18).
2. `AnalyticsBridge` ouve os eventos de simulação e traduz para os eventos do plano —
   **nenhum sistema de gameplay chama analytics diretamente**.
3. Contexto comum injetado pelo serviço.
4. Rodar a checklist do MVP inteira, em dispositivo real, e registrar no `HANDOFF.md`.
5. Sessão de playtest com 3 pessoas de fora.
**Testes:** adapter falso recebe os eventos esperados, com as propriedades certas; nenhum
evento por frame.
**DoD:** **checklist do MVP 16/16 verde**; relatório de playtest anexado.
