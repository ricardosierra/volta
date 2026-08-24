# GSD 13 — Tarefas

### MAPS-001 — `ArenaDefinition` completo e ferramenta de autoria
**Dependências:** GSD 12. **Arquivos:** `src/arena/arena_definition.gd`, `tools/dev/arena_editor.gd`.
**Passos:** definição com máscara de células bloqueadas, spawns, zonas de perigo, metadados →
ferramenta simples de debug para desenhar e exportar a máscara (só em build de debug) →
validação: arena precisa ter todas as regiões jogáveis alcançáveis.
**Testes:** arena inválida (região isolada) é rejeitada; máscara carrega corretamente.
**DoD:** criar arena não exige código.

### MAPS-002 — `Archipelago`
**Passos:** ilhas separadas por vazio intransponível → travessias estreitas obrigatórias →
spawn uma ilha por Runner → validar que nenhuma ilha é inalcançável.
**Testes:** captura por ilha correta; percentual coerente; bots atravessam as pontes.
**DoD:** a estratégia muda: expansão em pedaços, gargalos disputados.

### MAPS-003 — `Rift`
**Passos:** fenda central **letal**, com telegrafia visual e sonora forte (borda pulsante, som
de alerta ao se aproximar) → documentar como a única exceção de R5.7 → travessias seguras nas
extremidades.
**Testes:** morte na fenda registrada com causa própria; aviso perceptível; bots não se
suicidam nela (anti-suicídio considera zona de perigo).
**DoD:** ninguém morre na fenda sem ter visto que ela estava lá.

### MAPS-004 — `Crossroads`
**Passos:** corredores em cruz com centro aberto → centro vale muito território, mas é exposto
→ spawns nas quatro pontas.
**Testes:** captura no centro funciona; nenhuma quina permite defesa infinita.
**DoD:** o centro é uma decisão, não uma obrigação.

### MAPS-005 — `Halo`
**Passos:** anel jogável com centro bloqueado → perseguições circulares → cercar é mais fácil,
então o risco muda de natureza.
**Testes:** flood fill correto com um buraco central grande (caso topológico importante);
percentual correto.
**DoD:** benchmark de Seal nesta arena dentro do orçamento (é a topologia mais adversa).

### MAPS-006 — IA e obstáculos
**Dependências:** MAPS-002..005. **Arquivos:** `src/ai/bot_steering.gd`, `bot_safety.gd`.
**Passos:** desvio local considerando células bloqueadas → zonas de perigo entram no cálculo de
risco → anti-travamento reforçado em corredores estreitos.
**Testes:** 500 partidas por arena com 0 bot travado; bots não morrem repetidamente na fenda.
**DoD:** bots continuam legíveis em todas as arenas.

### MAPS-007 — Visual e áudio por arena
**Dependências:** GSD 08, 09. **Arquivos:** `resources/arenas/*.tres`, `assets/audio/music/`.
**Passos:** silhueta e tratamento de fundo por arena, **dentro** da paleta do tema ativo →
faixa de música por arena, com as mesmas 6 camadas → ícone de arena para a UI.
**Testes:** nenhuma arena introduz cor fora do tema; camadas de música funcionam em todas.
**DoD:** dá para reconhecer a arena por um instante de tela.

### MAPS-008 — Stress e balanceamento por arena
**Dependências:** MAPS-001..007. **Arquivos:** `.reports/`, `docs/design/balance.md`.
**Passos:** 500 partidas por arena × modos compatíveis → medir duração, território final,
mortes por causa, bots travados, tempo de Seal → caçar estratégia degenerada → ajustar máscara
ou spawns.
**Testes:** 0 crash, 0 invariante; benchmark de Seal dentro do orçamento em todas.
**DoD:** relatório por arena; ajustes registrados.
