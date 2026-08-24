# GSD 04 — Tarefas

---

### CMBT-001 — Detecção de colisão por grid

**Objetivo:** o "sistema de colisão" inteiro: uma consulta de célula por Runner por tick.
**Contexto:** `docs/architecture/territory-system.md` §6.
**Dependências:** GSD 03.
**Arquivos:** `src/gameplay/collision_resolver.gd`.
**Passos:**
1. Por Runner: obter a célula atual, consultar `arc_owner_of`.
2. Se for Arc de outro → evento de Break. Se for Arc próprio e estiver desenhando → Backwash.
3. Coletar os eventos do tick inteiro **antes** de aplicar, para tratar simultaneidade.
4. Repulsão Runner × Runner por distância direta (no máximo 8 entidades).
**Testes:** 8 Runners, 10 000 ticks, dentro do orçamento; nenhuma colisão perdida quando o
Runner atravessa mais de uma célula no tick (usar o mesmo traçado do rasterizador).
**DoD:** nenhuma `Area2D` no projeto para isso; orçamento respeitado.

---

### CMBT-002 — Break e liberação de território

**Objetivo:** morrer e o mapa reagir.
**Dependências:** CMBT-001.
**Arquivos:** `src/gameplay/elimination_service.gd`, `src/runner/states/hit_state.gd`.
**Passos:**
1. `Hit` na FSM do Runner; Arc limpo; Claim devolvido ao neutro (`release_claim`).
2. Evento `runner_broken(victim, killer, cause)`.
3. Morte mútua: os dois em `Hit`, sem crédito (R5.4).
4. Dois agressores no mesmo Arc no mesmo tick: crédito ao menor `runner_id` (E05).
**Testes:** território liberado corretamente (invariante de soma verde); crédito correto;
morte mútua sem crédito.
**DoD:** eventos com dados suficientes para score (GSD 06) e analytics (GSD 18).

---

### CMBT-003 — Backwash

**Objetivo:** a penalidade que substitui a morte por auto-colisão (ADR-0007).
**Dependências:** CMBT-001.
**Arquivos:** `src/runner/states/backwash_state.gd`, `resources/config/balance/backwash.tres`.
**Passos:**
1. Apagar o Arc inteiro; **iniciar um novo** na posição atual, no mesmo tick.
2. Zerar Surge (o sistema chega na GSD 06; aqui, emitir o evento).
3. Aplicar modificador de velocidade no `StatBlock`, com expiração automática.
4. Feedback provisório: cor do Runner muda; texto `BACKWASH` na tela.
**Testes:**
- o Arc some e um novo começa no mesmo tick;
- **o Runner continua cortável imediatamente após o Backwash** (o teste que impede o exploit);
- a penalidade expira sem resíduo no `StatBlock`;
- Backwash durante Backwash não empilha penalidade.
**DoD:** R6.4 provada por teste; comportamento coerente com o ADR.

---

### CMBT-004 — Colisão com borda e obstáculo

**Objetivo:** bater na parede é penalidade, não morte (R6.2).
**Dependências:** CMBT-003.
**Arquivos:** `src/gameplay/collision_resolver.gd`, `src/runner/movement.gd`.
**Passos:**
1. Desenhando + barreira → Backwash com deflexão tangente.
2. Em `Safe` → apenas desliza (R6.5).
3. Células bloqueadas da arena tratadas como barreira (usado de verdade na GSD 13).
**Testes:** deflexão suave, sem travar nem vibrar; `Safe` na borda não sofre penalidade;
obstáculo interno se comporta como a borda.
**DoD:** nenhuma morte por parede em nenhuma situação.

---

### CMBT-005 — Squeeze

**Objetivo:** zerar o território de alguém é uma forma de eliminação (R4.6).
**Dependências:** CMBT-002, TERR-007.
**Arquivos:** `src/gameplay/elimination_service.gd`.
**Passos:**
1. Ouvir `squeezed` do grid e encaminhar para o fluxo de eliminação.
2. Crédito ao Runner que selou.
3. Respawn conforme o modo.
**Testes:** Seal que engole o Claim inteiro de um inimigo elimina; contadores corretos;
o Runner eliminado não fica em estado inconsistente.
**DoD:** Squeeze funciona inclusive quando a vítima está desenhando fora do Claim.

---

### CMBT-006 — Respawn

**Objetivo:** voltar ao jogo rápido e em local justo.
**Contexto:** R2.4, R8.4, E10.
**Dependências:** CMBT-002.
**Arquivos:** `src/arena/spawner.gd`, `src/runner/states/respawning_state.gd`.
**Passos:**
1. Atraso de respawn vindo do modo.
2. Escolha de local: célula neutra que respeite distância mínima de outros Runners e espaço
   livre suficiente para o Claim inicial; se não houver ideal, o melhor disponível (nunca falhar).
3. `seed_claim` novo + invulnerabilidade + anel visual.
4. Invulnerabilidade cai ao sair do Claim.
**Testes:** 1 000 respawns em mapa lotado sempre encontram local; distância mínima respeitada
quando possível; invulnerabilidade expira corretamente nas duas condições.
**DoD:** nunca renasce em cima de alguém; nunca falha em achar lugar.

---

### CMBT-007 — Ordem de resolução do tick

**Objetivo:** simultaneidade sem ambiguidade.
**Contexto:** R4.7, E05, E08.
**Dependências:** CMBT-001..006.
**Arquivos:** `src/gameplay/match_director.gd`.
**Passos:**
1. Fixar e documentar a ordem: movimento → marcação de Arc → detecção de colisões →
   **Seals** (por `runner_id`) → **mortes** → respawns → eventos.
2. Garantir que um Seal no mesmo tick da morte resolve primeiro (E08).
3. Documentar a ordem em `docs/architecture/state-machines.md`.
**Testes:** cenário montado com Seal + morte no mesmo tick; dois Seals no mesmo tick;
morte mútua + Seal.
**DoD:** ordem determinística documentada e testada; nenhum resultado depende de ordem de
iteração de dicionário.

---

### CMBT-008 — Aviso periférico de ameaça

**Objetivo:** ninguém morre por surpresa (Pilar 1).
**Dependências:** CMBT-001.
**Arquivos:** `src/ui/hud/threat_indicator.gd`.
**Passos:**
1. Quando um inimigo entra num raio do **seu Arc** (não do seu Runner), mostrar seta na borda
   da tela, na direção dele.
2. Opacidade e pulso por proximidade.
3. Só durante `DrawingTrail`.
**Testes:** aparece e some nas condições certas; não polui a tela com múltiplas ameaças
(máximo 2 setas, as mais próximas).
**DoD:** em playtest interno, nenhuma morte é descrita como "veio do nada".

---

### CMBT-009 — Validação de combate no stress test

**Objetivo:** provar que o combate não cria estados inválidos.
**Dependências:** CMBT-001..008.
**Arquivos:** `tools/dev/simulate.gd`, `src/territory/territory_invariants.gd`.
**Passos:**
1. Novas invariantes: nenhum Runner morto com Claim; nenhum Runner vivo em `Hit` por mais de
   1 tick; nenhum Arc órfão de Runner morto; contadores de Break coerentes.
2. Rodar 500 partidas com 4 Runners de script agressivos.
3. Coletar: mortes por causa, Backwash por partida, mortes nos primeiros 15 s.
**Testes:** 0 crash, 0 invariante violada; distribuição de causas de morte plausível.
**DoD:** relatório no `HANDOFF.md`; frequência de Backwash registrada como baseline para
RISK-007.
