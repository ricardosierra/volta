# GSD 00 — Tarefas

Todas concluídas em 2026-08-24.

---

### DISC-001 — Definir visão, público e diferencial ✅

**Objetivo:** estabelecer o que é o produto e para quem, com um diferencial defensável.
**Contexto:** o gênero é grande e mal executado; o espaço está em execução, não em conceito.
**Dependências:** nenhuma.
**Arquivos:** `docs/product/vision.md`, `docs/product/game-pillars.md`.
**Passos:** pitch → público em 3 segmentos → 5 diferenciais → o que o jogo NÃO é → métrica-norte
→ ordem de prioridade (North Star) → escopo do primeiro release.
**Testes:** um leitor externo consegue explicar o jogo em 2 frases.
**DoD:** visão e pilares escritos; pilares utilizáveis como critério de decisão (têm tabela
"fere este pilar").

---

### DISC-002 — Formalizar as regras do jogo ✅

**Objetivo:** transformar o conceito em regras normativas testáveis.
**Contexto:** regra ambígua vira bug de simulação e discussão infinita.
**Dependências:** DISC-001.
**Arquivos:** `docs/gameplay/rules.md`, `docs/gameplay/core-loop.md`, `docs/gameplay/game-modes.md`.
**Passos:** entidades → estados → movimento → captura → combate → auto-colisão → fim de partida
→ regras de justiça → 12 casos de borda com comportamento obrigatório.
**Testes:** cada regra tem identificador (`R4.7`) referenciável em código e teste.
**DoD:** lista de causas de morte **fechada**; toda regra numerada; casos de borda cobertos.

---

### DISC-003 — Decidir a representação do território ✅

**Objetivo:** escolher a estrutura de dados do subsistema mais crítico.
**Contexto:** RISK-001 e RISK-002 nascem aqui.
**Dependências:** DISC-002.
**Arquivos:** `docs/architecture/territory-system.md`, `docs/decisions/ADR-0002-*.md`.
**Passos:** requisitos T1–T9 → comparar 6 alternativas → escolher grid denso + flood fill do
exterior → especificar rasterização supercover → orçamento → interface pública → serialização
→ 14 casos de borda.
**Testes:** 15 benchmarks especificados com orçamento.
**DoD:** ADR-0002 aceito; algoritmo descrito com precisão suficiente para implementar sem
inventar nada.

---

### DISC-004 — Definir a arquitetura do cliente ✅

**Objetivo:** camadas, módulos, comunicação, convenções e proibições.
**Dependências:** DISC-003.
**Arquivos:** `docs/architecture/overview.md`, `state-machines.md`, `save-system.md`,
`configuration.md`, `logging.md`, `debug-tools.md`, `networking.md`.
**Passos:** camadas e regra de dependência → responsabilidade por módulo → três mecanismos de
comunicação com uso definido → injeção de dependência → convenções de código → pooling →
modelo de tick → estrutura de pastas → lista do que NÃO fazemos.
**Testes:** a regra de camadas é verificável por script (`check_layering.gd`, GSD 01).
**DoD:** um agente consegue criar um arquivo novo e saber exatamente onde ele mora e o que
pode importar.

---

### DISC-005 — Definir direção de arte, UI, áudio e game feel ✅

**Objetivo:** identidade visual e sensorial própria, com regras aplicáveis.
**Dependências:** DISC-001.
**Arquivos:** `docs/art/*`, `docs/ui/*`, `docs/audio/*`, `docs/design/game-feel.md`.
**Passos:** conceito visual → hierarquia visual normativa → elementos → cor → temas → VFX com
orçamento → design system com tokens → telas → HUD → acessibilidade → áudio adaptativo →
contrato dos sete canais de game feel.
**Testes:** a hierarquia visual é critério de reprovação de VFX no quality gate.
**DoD:** nenhuma referência a assets de terceiros; toda regra é verificável.

---

### DISC-006 — Definir balanceamento, score, progressão e economia ✅

**Objetivo:** todos os números em um lugar, separados do código.
**Dependências:** DISC-002.
**Arquivos:** `docs/design/balance.md`, `scoring.md`, `progression.md`, `economy.md`,
`docs/product/monetization.md`.
**Passos:** fórmula de score com tetos → Surge → bônus nomeados → tabela única de constantes →
XP e moedas → monetização com lista de proibições → métricas de saúde econômica.
**Testes:** toda constante tem nome usável como chave de `Resource`.
**DoD:** nenhum número de gameplay existe fora de `balance.md`; história de ajustes iniciada.

---

### DISC-007 — Registrar decisões arquiteturais (ADRs) ✅

**Objetivo:** deixar registrado por que cada escolha foi feita, com alternativas.
**Dependências:** DISC-003, DISC-004, DISC-005, DISC-006.
**Arquivos:** `docs/decisions/ADR-0001` a `ADR-0014`.
**Passos:** para cada decisão cara de reverter: Context → Decision → Alternatives →
Consequences → Status.
**Testes:** toda pergunta "por que assim?" das fases 01–25 tem resposta em algum ADR.
**DoD:** 14 ADRs aceitos; índice em `docs/decisions/README.md`.

---

### DISC-008 — Construir o Master Repository e o sistema GSD ✅

**Objetivo:** o cérebro operacional: 26 fases executáveis por comando.
**Dependências:** todas as anteriores.
**Arquivos:** estrutura do repositório, arquivos-raiz, `.gsd/*`, `.gsd/phases/*`, `.github/*`,
`tools/*`.
**Passos:** estrutura de pastas → arquivos-raiz → `MASTER_PLAN` → `STATUS` → `DEPENDENCIES` →
`DECISIONS` → `RISKS` → `QUALITY_GATES` → `BACKLOG` → `COMMANDS` → 26 fases × 7 documentos →
CI → scripts de validação.
**Testes:** `tools/ci/validate-repo.sh` passa; toda fase tem os 7 documentos.
**DoD:** `MASTER PLAN READY`; próximo comando é `Execute GSD 01`.
