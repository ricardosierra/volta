# GSD 11 — Tarefas

### COSM-001 — Catálogo e modelo de item
**Objetivo:** cosmético é dado. **Dependências:** GSD 10.
**Arquivos:** `src/progression/cosmetics/cosmetic_item.gd`, `catalog.gd`, `resources/cosmetics/**`.
**Passos:** `Resource` com id, tipo (skin/arc/theme/seal_fx/title/frame), raridade, preço em
Sparks e/ou Prisms, fonte de desbloqueio e referências de asset → catálogo carregado e validado
no boot → validação: nenhum campo de gameplay permitido no schema.
**Testes:** catálogo carrega; item com campo inválido é rejeitado; ids únicos.
**DoD:** adicionar item novo = adicionar `.tres`.

### COSM-002 — Inventário e equipamento
**Objetivo:** possuir e equipar. **Dependências:** COSM-001.
**Arquivos:** `src/progression/cosmetics/inventory.gd`, `loadout.gd`.
**Passos:** inventário persistido → loadout por slot (skin, arc, seal_fx, title, frame, theme) →
equipar aplica em runtime → item padrão sempre disponível por slot.
**Testes:** persistência; equipar/desequipar; slot nunca fica vazio; item inexistente ignorado
com log.
**DoD:** troca aplicada em < 200 ms, sem reiniciar.

### COSM-003 — Skins de Runner
**Objetivo:** identidade sem vantagem. **Dependências:** COSM-002, GSD 08.
**Arquivos:** `assets/sprites/skins/`, `src/presentation/runner_view.gd`.
**Passos:** ≥ 20 skins vetoriais/procedurais em 4 raridades → todas dentro do mesmo envelope de
tamanho → marcador geométrico de jogador preservado → teste contra os 8 temas.
**Testes:** hitbox idêntica em todas; legibilidade em todos os temas; custo de render igual.
**DoD:** nenhuma skin é "melhor" para jogar.

### COSM-004 — Arc Styles
**Objetivo:** o rastro como assinatura. **Dependências:** COSM-002.
**Arquivos:** `assets/shaders/arc_styles/`, `resources/cosmetics/arcs/`.
**Passos:** ≥ 12 estilos (sólido, tracejado, gradiente, partículas, ondulado, cristal…) →
largura efetiva e visibilidade equivalentes → intensidade de risco preservada em todos.
**Testes:** largura de colisão inalterada; o sinal de risco (brilho crescente) funciona em
todos os estilos.
**DoD:** nenhum estilo esconde o próprio Arc do adversário.

### COSM-005 — Efeitos de Seal
**Objetivo:** o momento de captura personalizado. **Dependências:** COSM-002, GSD 09.
**Arquivos:** `src/presentation/vfx/seal_fx/*.gd`.
**Passos:** 5 variações (`Ripple`, `Shatter`, `Bloom`, `Pixelate`, `Ink`) → mesma duração e
mesmo custo-alvo → nenhuma esconde informação nem atrapalha o adversário.
**Testes:** duração idêntica; custo dentro do orçamento; auditoria de legibilidade.
**DoD:** premium sem ser vantagem.

### COSM-006 — Desbloqueio e compra
**Objetivo:** ganhar ou comprar, sem armadilha. **Dependências:** COSM-002, PROG-006.
**Arquivos:** `src/progression/cosmetics/unlock_service.gd`.
**Passos:** desbloqueio por rank, por conquista e por compra com Sparks/Prisms → confirmação
clara com preço e saldo → saldo insuficiente informa e oferece caminho legítimo (jogar), nunca
empurra compra → recibo no histórico da carteira.
**Testes:** as 3 fontes; saldo insuficiente; compra dupla impedida; item permanente.
**DoD:** nenhum dark pattern — revisado item a item contra a lista de `monetization.md`.

### COSM-007 — Telas Character e Skins
**Objetivo:** a vitrine. **Dependências:** COSM-003..006.
**Arquivos:** `src/ui/screens/character_screen.gd`, `skins_screen.gd`.
**Passos:** `Character` com preview grande animado (Runner desenhando um Arc em loop) e slots →
`Skins` em grade com filtro por tipo e raridade, estados visuais claros e preview ao tocar →
troca de tema aplicada ao vivo.
**Testes:** carrega em < 300 ms; layout correto em toda a matriz; preview reflete o loadout.
**DoD:** dá vontade de colecionar.

### COSM-008 — Auditoria de equidade e legibilidade
**Objetivo:** provar que nada disso dá vantagem. **Dependências:** COSM-001..007.
**Arquivos:** `docs/art/themes.md`, `docs/product/monetization.md`.
**Passos:** matriz item × tema, verificando legibilidade → conferir hitbox, largura de Arc,
duração de efeito e custo de render de todos os itens → teste cego: com skins diferentes,
identificar a ameaça em capturas.
**Testes:** teste cego ≥ 90 % de acerto; nenhuma diferença mensurável de gameplay entre itens.
**DoD:** relatório de equidade no `HANDOFF.md`.
