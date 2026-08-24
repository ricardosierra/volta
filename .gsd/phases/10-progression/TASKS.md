# GSD 10 — Tarefas

### PROG-001 — `Profile` e `ProfileRepository`
**Objetivo:** a identidade persistente do jogador. **Dependências:** GSD 09.
**Arquivos:** `src/progression/profile.gd`, `profile_repository.gd`, `local_profile_repository.gd`.
**Passos:** estrutura do perfil (id, apelido, avatar, título, moldura, rank, XP) → interface de
repositório com a forma final → implementação local sobre o `SaveService` → apelido gerado
automaticamente na primeira execução, editável depois.
**Testes:** round-trip; apelido inválido rejeitado; migração de save de perfil.
**DoD:** MOCK registrado com destino GSD 16 (`ONLN-002`).

### PROG-002 — XP e ranks
**Objetivo:** progresso garantido a cada partida. **Dependências:** PROG-001.
**Arquivos:** `src/progression/xp_service.gd`, `resources/config/progression/xp_curve.tres`.
**Passos:** fórmula de XP → curva `100 × n^1,35` → recompensas por nível → animação de barra na
tela de resultado → prestígio visual acima do nível 50.
**Testes:** XP em vitória e derrota; nível 1 na primeira partida; curva coerente; sem teto.
**DoD:** subir de nível é visível e comemorado.

### PROG-003 — Estatísticas
**Objetivo:** número que sobe é motivação barata e honesta. **Dependências:** PROG-001.
**Arquivos:** `src/progression/stats_service.gd`.
**Passos:** as 15+ estatísticas de `docs/design/progression.md` §2 → atualização a partir do
`MatchResult` → agregação eficiente → exibição em `Profile`.
**Testes:** cada estatística atualizada corretamente; K/D e winrate com divisão por zero tratada.
**DoD:** nenhuma estatística calculada em dois lugares.

### PROG-004 — Conquistas
**Objetivo:** metas permanentes, incluindo as divertidas. **Dependências:** PROG-003.
**Arquivos:** `src/progression/achievements/*.gd`, `resources/progression/achievements/*.tres`.
**Passos:** definição como `Resource` (id, família, condição, progresso, recompensa) → avaliador
que ouve eventos e estatísticas → progresso parcial visível → popup de desbloqueio → tela
`Achievements` agrupada por família.
**Testes:** cada tipo de condição; progresso parcial correto; desbloqueio só uma vez.
**DoD:** ≥ 30 conquistas definidas, nenhuma dependente de sorte pura ou de dinheiro.

### PROG-005 — Desafios diários e semanais
**Objetivo:** objetivo do dia. **Dependências:** PROG-003.
**Arquivos:** `src/progression/challenges/*.gd`, `local_challenge_repository.gd`,
`resources/progression/challenge_pool.tres`.
**Passos:** pool com pesos → geração por seed diária (determinística, sem repetir tipo no mesmo
dia) → progresso e resgate → 1 reroll gratuito + rerolls pagos com limite → expiração à
meia-noite local, com virada tratada corretamente.
**Testes:** geração determinística; sem tipo repetido; reroll; expiração e virada de dia;
fuso horário e mudança de relógio do sistema.
**DoD:** MOCK-004 registrado com destino GSD 16.

### PROG-006 — Carteira
**Objetivo:** Sparks e Prisms, com histórico. **Dependências:** PROG-002.
**Arquivos:** `src/progression/wallet.gd`.
**Passos:** saldo persistido → ganho conforme `economy.md` (com teto por partida) → histórico
de transações (fonte e destino) → animação de contagem no `VCurrencyPill`.
**Testes:** teto respeitado; saldo nunca negativo; histórico consistente; concorrência de
escrita tratada.
**DoD:** toda entrada e saída de moeda passa pela carteira — nenhum atalho.

### PROG-007 — Tela de perfil
**Objetivo:** o lugar de olhar o próprio progresso. **Dependências:** PROG-003, PROG-004.
**Arquivos:** `src/ui/screens/profile_screen.gd`.
**Passos:** avatar, título, moldura, rank e barra de XP → estatísticas em cartões →
recordes por modo → atalho para conquistas → tudo com os componentes do design system.
**Testes:** carrega em < 200 ms; layout correto em toda a matriz de telas.
**DoD:** dá gosto de olhar.

### PROG-008 — Tela de desafios
**Objetivo:** o objetivo do dia, visível em um toque do menu. **Dependências:** PROG-005.
**Arquivos:** `src/ui/screens/challenges_screen.gd`.
**Passos:** 3 diários + 3 semanais com barra de progresso, recompensa e tempo restante →
botão de reroll com estado claro → resgate com celebração → indicador no menu principal.
**Testes:** progresso ao vivo durante a partida; resgate único; contagem regressiva correta.
**DoD:** o jogador sabe o que fazer hoje sem procurar.

### PROG-009 — Integração com o fim de partida
**Objetivo:** fechar o loop de recompensa. **Dependências:** PROG-002..006.
**Arquivos:** `src/ui/screens/results_screen.gd`, `src/progression/progression_bridge.gd`.
**Passos:** o `MatchResult` alimenta XP, estatísticas, conquistas, desafios e carteira em um
único ponto → tela de resultado mostra tudo em cascata, cada item entrando em sequência →
tudo pulável ao toque → salvar ao fim.
**Testes:** cálculo < 5 ms; ordem de cascata correta; salvar acontece de fato; abandono preserva
o ganho (R7.4).
**DoD:** o resultado passa a ser recompensador, não só informativo.

### PROG-010 — Simulação de economia e balanceamento
**Objetivo:** validar as torneiras antes de existir loja. **Dependências:** PROG-006.
**Arquivos:** `tools/dev/economy_sim.php`, `docs/design/economy.md`.
**Passos:** perfis sintéticos (casual, médio, hardcore) por 30 dias → medir Sparks/dia, saldo,
tempo até o primeiro cosmético → ajustar divisores e recompensas → registrar em `economy.md`.
**Testes:** métricas dentro das faixas-alvo de `economy.md`.
**DoD:** valores ajustados e histórico atualizado em `balance.md`.
