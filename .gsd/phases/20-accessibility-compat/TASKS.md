# GSD 20 — Tarefas

### A11Y-001 — Matriz de dispositivos
**Passos:** executar a checklist de `docs/mobile/device-matrix.md` em 4 Android (Low, Mid, High,
tablet) e 3 iPhone + 1 iPad → registrar resultado por aparelho → abrir bug para cada desvio.
**DoD:** tabela por aparelho preenchida em `device-results.md`.

### A11Y-002 — Safe area e proporções
**Passos:** capturas de todas as telas × 6 formatos × 2 escalas → corrigir tudo que quebrar →
testar com notch, Dynamic Island, furo de câmera e barra de gestos.
**Testes:** nada interativo sob elementos do sistema; nada cortado.
**DoD:** conjunto de capturas anexado, sem exceção.

### A11Y-003 — Tablet
**Passos:** layout que reflui em vez de esticar → Field com margem adequada → HUD reposicionada
→ alvos de toque proporcionais.
**Testes:** iPad e tablet Android; nenhuma tela com espaço morto grotesco.
**DoD:** tablet parece intencional, não tolerado.

### A11Y-004 — Taxa de atualização
**Passos:** verificar 60/90/120 Hz e LTPO → confirmar que a simulação continua a 60 Hz fixo →
opção de limitar FPS para poupar bateria.
**Testes:** comportamento idêntico em todas as taxas; só a suavidade muda.
**DoD:** nenhuma dependência de taxa de quadros no comportamento.

### A11Y-005 — Temas de daltonismo e alto contraste
**Passos:** 3 temas (deuteranopia, protanopia, tritanopia) validados com simulador →
modo de alto contraste que reduz o atmosférico e reforça a separação → sempre disponíveis em
`Settings > Accessibility`, nunca na loja.
**Testes:** verificador de contraste; teste cego de ameaça em cada tema (≥ 90 %).
**DoD:** identificação por cor + forma + padrão funciona em todos.

### A11Y-006 — Reduções e acessibilidade sensorial
**Passos:** revisar `Reduce shake`, `Reduce flashes`, `Reduzir sons intensos` e `Haptics off` →
partida completa com tudo ativo → garantir redundância de canal em toda informação crítica.
**Testes:** auditoria: nenhuma informação só na cor, só no som ou só no háptico.
**DoD:** com tudo reduzido o jogo continua **divertido**, não apenas jogável.

### A11Y-007 — Acessibilidade motora e cognitiva
**Passos:** confirmar os 3 esquemas de controle, sensibilidade, zona morta, modo canhoto,
"manter direção ao soltar" → nenhuma ação exige gesto complexo → tutorial sem tempo limite →
`HUD mínima` → sem penalidade por pausar.
**Testes:** auditoria da checklist de `docs/ui/accessibility.md`.
**DoD:** checklist 100 %.

### A11Y-008 — Avaliação do upgrade da engine (BL-011)
**Passos:** avaliar a versão estável mais recente contra a 4.3: interpolação 2D nativa, ganhos
em mobile, custo de migração, risco de regressão → protótipo em branch separado se o ganho
parecer relevante → decidir e registrar.
**DoD:** ADR novo (se migrar) ou registro fundamentado no backlog (se não).

### A11Y-009 — Gate da Beta
**Passos:** executar a checklist completa da Beta → build de teste fechado em ≥ 30 aparelhos
distintos (nuvem de dispositivos + reais) → medir crash-free ≥ 99 % → corrigir bloqueadores.
**DoD:** marco Beta fechado e registrado em `STATUS.md` e `QUALITY_GATES.md`.
