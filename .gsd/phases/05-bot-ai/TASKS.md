# GSD 05 — Tarefas

---

### BOTS-001 — `BotProfileResource` e arquétipos como dado

**Objetivo:** personalidade e dificuldade viram `.tres`.
**Contexto:** ADR-0008; `docs/design/balance.md` §8.
**Dependências:** GSD 04.
**Arquivos:** `src/ai/bot_profile.gd`, `resources/config/bots/*.tres`.
**Passos:**
1. `Resource` com os 8 parâmetros documentados, com faixa validada.
2. Três `.tres` de dificuldade (Rookie, Skilled, Elite) com os valores 🎯 de `balance.md`.
3. Quatro `.tres` de arquétipo aplicando deltas sobre a dificuldade.
4. Combinação = dificuldade + arquétipo, resolvida na criação do bot.
**Testes:** carga e validação; combinação produz os valores esperados; valor fora de faixa é
rejeitado.
**DoD:** criar um arquétipo novo não exige tocar em código.

---

### BOTS-002 — Percepção

**Objetivo:** o bot enxerga só o que deveria.
**Dependências:** BOTS-001.
**Arquivos:** `src/ai/perception/perception.gd`, `threat_map.gd`, `opportunity_map.gd`.
**Passos:**
1. Runners e células de Arc inimigo dentro do raio derivado de `enemy_awareness`.
2. `ThreatMap`: proximidade e trajetória estimada dos inimigos em relação ao **meu Arc**.
3. `OpportunityMap`: densidade de território por *chunk* grosso, atualizada por evento
   (`cells_changed`), nunca por varredura por frame.
4. Reuso de buffers; zero alocação.
**Testes:** inimigo fora do raio não é percebido; mapa de oportunidade coerente após capturas;
custo dentro do orçamento com 8 bots.
**DoD:** nenhuma leitura de estado privado de outro Runner.

---

### BOTS-003 — Ações candidatas e função de utilidade

**Objetivo:** o núcleo da decisão.
**Contexto:** `docs/gameplay/bots.md`.
**Dependências:** BOTS-002.
**Arquivos:** `src/ai/actions/*.gd`, `src/ai/bot_brain.gd`.
**Passos:**
1. Interface `BotAction.score(ctx) -> float` e `direction(ctx) -> Vector2`.
2. Implementar: `expand_frontier`, `expand_deep`, `steal_from`, `intercept`, `flee_home`,
   `seal_now`, `patrol_border`, `bait` (esta última só declarada, ativa na GSD 12).
3. `BotBrain` pontua todas, aplica os pesos do perfil e escolhe a maior.
4. **Histerese:** a ação atual ganha bônus, para não oscilar entre duas quase empatadas.
5. Tempo mínimo de compromisso por decisão.
**Testes:** cada ação isolada com contexto montado à mão (ex.: inimigo com Arc longo e
previsível → `intercept` vence); histerese impede oscilação em cenário de empate.
**DoD:** trocar um peso muda o comportamento de forma previsível e explicável.

---

### BOTS-004 — Steering e execução

**Objetivo:** transformar a decisão em movimento humano, não em caminho perfeito.
**Dependências:** BOTS-003.
**Arquivos:** `src/ai/bot_steering.gd`.
**Passos:**
1. Converter a direção sugerida em direção desejada, respeitando a taxa de giro (igual à do
   jogador).
2. Desvio local de barreiras (borda e células bloqueadas) sem pathfinding global.
3. O bot alimenta o mesmo pipeline de input que o jogador — ele **não** escreve na posição.
**Testes:** bot contorna a borda sem travar; bot não teleporta; usa exatamente as mesmas
funções de movimento do jogador.
**DoD:** trocar o jogador por um bot no mesmo assento não muda uma linha da simulação.

---

### BOTS-005 — Atraso de reação e taxa de erro

**Objetivo:** errar como gente.
**Dependências:** BOTS-003.
**Arquivos:** `src/ai/bot_brain.gd`.
**Passos:**
1. `reaction_delay_ms`: a mudança de decisão só entra em vigor após o atraso do perfil.
2. `error_rate`: chance de escolher a **segunda** melhor ação (não uma aleatória — erro
   plausível, não burrice).
3. Aleatoriedade sempre a partir da seed da partida (determinismo).
**Testes:** com `error_rate = 0` o comportamento é ótimo; com 0,22 a taxa medida bate; a mesma
seed produz a mesma sequência de decisões.
**DoD:** determinismo preservado com aleatoriedade presente.

---

### BOTS-006 — Segurança comportamental

**Objetivo:** nenhum bot travado, nenhum bot suicida sem querer, nenhuma partida parada.
**Contexto:** `docs/gameplay/bots.md` §Segurança.
**Dependências:** BOTS-004.
**Arquivos:** `src/ai/bot_safety.gd`.
**Passos:**
1. **Anti-travamento:** sem mudar de célula por 1,5 s → reavaliar; 3 repetições → direção de
   emergência.
2. **Anti-suicídio:** antes de aceitar uma direção, estimar a rota de retorno dentro do
   orçamento de risco; Rookie pula essa checagem com frequência (é por isso que ele morre).
3. **Anti-partida-parada:** todos em `Safe` por mais de 20 s → o `MatchDirector` aumenta a
   pressão de expansão.
**Testes:** bot encurralado escapa; bot Elite raramente morre por auto-erro; partida nunca
fica estagnada.
**DoD:** invariante "0 bots travados > 3 s" verde em 500 partidas.

---

### BOTS-007 — Escalonamento e orçamento de CPU

**Objetivo:** IA barata e previsível.
**Dependências:** BOTS-003.
**Arquivos:** `src/ai/ai_scheduler.gd`.
**Passos:**
1. Round-robin: no máximo 2 bots decidem por tick; ciclo de decisão de ~150 ms por bot.
2. Evitar coincidir decisão com um Seal previsto no mesmo tick (o Seal é detectado no começo
   do tick).
3. Buffers reutilizados entre bots.
**Testes:** 8 bots dentro de 1,2 ms; nenhum bot fica sem decidir por mais de 200 ms;
zero alocação por decisão.
**DoD:** benchmarks B09 (10 bots) e B10 (20 bots) dentro do orçamento.

---

### BOTS-008 — Os 4 arquétipos do MVP

**Objetivo:** personalidades distinguíveis a olho nu.
**Dependências:** BOTS-001..006.
**Arquivos:** `resources/config/bots/archetypes/*.tres`.
**Passos:**
1. `Grazer` — expande em fatias pequenas e seguras, evita conflito.
2. `Raider` — expande, mas desvia para cortar Arc exposto próximo.
3. `Hunter` — escolhe uma presa e persegue o Arc dela.
4. `Warden` — fica perto do Claim, intercepta invasores, raramente arrisca.
5. Ajustar pesos até que a intenção seja legível em vídeo de 20 s.
**Testes:** teste de legibilidade — 5 pessoas assistem a 4 clipes de 20 s e identificam a
intenção; meta ≥ 70 % de acerto para o `Hunter`.
**DoD:** os quatro comportamentos são descritíveis por quem assiste, sem ler o código.

---

### BOTS-009 — Overlay de intenção (debug)

**Objetivo:** poder diagnosticar "o bot está burro".
**Contexto:** `docs/architecture/debug-tools.md`.
**Dependências:** BOTS-003.
**Arquivos:** `src/ai/debug/bot_intent_overlay.gd`.
**Passos:**
1. Sobre cada bot: ação escolhida, score dela, segunda colocada e score.
2. Desenhar raio de percepção e alvo atual.
3. Tudo atrás de `Build.is_debug()`.
**Testes:** overlay não existe na build de release (verificação de export).
**DoD:** é possível explicar qualquer comportamento estranho em menos de 1 minuto.

---

### BOTS-010 — Stress test e balanceamento

**Objetivo:** o primeiro ajuste de balanceamento **por dado** do projeto.
**Contexto:** `docs/testing/stress-testing.md`.
**Dependências:** BOTS-008.
**Arquivos:** `tools/dev/simulate.gd`, `.reports/`, `docs/design/balance.md`.
**Passos:**
1. Rodar 500 partidas com composições mistas de arquétipos e dificuldades.
2. Coletar: distribuição de vitórias, duração, território final, Breaks, Backwash, bots
   travados, tick p95.
3. Ajustar pesos e perfis até: nenhum arquétipo entre < 8 % ou > 45 % de vitórias.
4. Registrar antes/depois na tabela de histórico de `balance.md`.
**Testes:** o próprio relatório; nenhuma partida infinita; 0 crash.
**DoD:** relatório anexado ao `HANDOFF.md`; `balance.md` atualizado com os valores ajustados.

---

### BOTS-011 — Partida completa jogável

**Objetivo:** o momento em que isto vira um jogo.
**Dependências:** BOTS-001..010.
**Arquivos:** `src/gameplay/match_director.gd`, `resources/config/modes/classic.tres`.
**Passos:**
1. Popular a partida com 5 bots (composição definida pelo modo).
2. Rodar uma partida Classic inteira, do spawn ao fim do tempo.
3. Sessão de jogo de 30 minutos anotando tudo que incomoda.
4. Corrigir o que for da fase; registrar o resto no `BACKLOG.md`.
**Testes:** manual + 500 partidas headless.
**DoD:** dá vontade de jogar de novo — e isso é anotado com honestidade no `HANDOFF.md`,
inclusive se a resposta for "ainda não".
