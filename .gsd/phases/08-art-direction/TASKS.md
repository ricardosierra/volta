# GSD 08 — Tarefas

---

### ART-001 — Tipografia definitiva
**Objetivo:** fechar `PLACEHOLDER-ART-004`. **Dependências:** GSD 07.
**Arquivos:** `assets/fonts/`, `resources/themes/typography.tres`, `assets/CREDITS.md`.
**Passos:** escolher família geométrica com licença comercial e latim estendido → importar com
subconjunto → aplicar a escala tipográfica de `design-system.md` → **figuras tabulares** nos
números da HUD → registrar licença.
**Testes:** nenhum texto truncado em pt-BR (mais longo que en) em escala 1,25; números da HUD
não fazem o layout tremer.
**DoD:** licença registrada; `PLACEHOLDER-ART-004` fechado.

---

### ART-002 — Runner final
**Objetivo:** fechar `PLACEHOLDER-ART-001`. **Dependências:** ART-001.
**Arquivos:** `src/presentation/runner_view.gd`, `assets/shaders/runner.gdshader`.
**Passos:** silhueta geométrica + núcleo pulsante + anel fino → **marcador geométrico distinto
por jogador** (círculo, losango, triângulo, hexágono, estrela, cruz, pentágono, quadrado) →
rastro curto opaco (≠ Arc) → rotação suave → squash/stretch leve em aceleração.
**Testes:** jogador humano identificável instantaneamente; 8 Runners distinguíveis no tema
Monochrome; hitbox inalterada.
**DoD:** `PLACEHOLDER-ART-001` fechado.

---

### ART-003 — Claim final
**Objetivo:** fechar `PLACEHOLDER-ART-002`; o território precisa parecer vivo.
**Dependências:** ART-002. **Arquivos:** `assets/shaders/territory.gdshader`.
**Passos:** preenchimento translúcido na cor do jogador → padrão geométrico interno único por
jogador (baixo contraste) → borda nítida com glow curto → brilho percorrendo a borda
lentamente → detecção de borda no shader (custo zero de CPU).
**Testes:** ainda 1 draw call; borda correta em Claim desconectado e com buraco; legível em
todos os temas.
**DoD:** `PLACEHOLDER-ART-002` fechado; benchmark B14 mantido.

---

### ART-004 — Arc final
**Objetivo:** fechar `PLACEHOLDER-ART-003`; o Arc é a tradução visual do risco (Pilar 1).
**Dependências:** ART-002. **Arquivos:** `assets/shaders/arc.gdshader`.
**Passos:** núcleo claro + halo → intensidade e frequência de pulso = f(comprimento) →
estado de Overload com cintilação âmbar e ruído na cauda → cor herdada do dono.
**Testes:** a diferença entre Arc curto e longo é óbvia sem olhar o número; Arc de 1 200 células
sem queda de FPS.
**DoD:** `PLACEHOLDER-ART-003` fechado.

---

### ART-005 — Fundo atmosférico
**Objetivo:** fechar `PLACEHOLDER-ART-006`, sem competir com o campo.
**Dependências:** ART-003. **Arquivos:** `assets/shaders/field_background.gdshader`.
**Passos:** gradiente escuro + vinheta → grid sutil com pulso quase imperceptível → partículas
ambientais raras e lentas, nunca no centro da ação → tudo derivado do tema ativo.
**Testes:** o fundo nunca reduz a legibilidade de um Arc inimigo; custo de GPU dentro do orçamento.
**DoD:** `PLACEHOLDER-ART-006` fechado.

---

### ART-006 — Os 8 temas
**Objetivo:** o sistema de paletas completo (ADR-0011).
**Dependências:** ART-003, ART-004, ART-005. **Arquivos:** `resources/themes/*.tres`,
`tools/ci/check_contrast.gd`.
**Passos:** implementar os 8 temas de `docs/art/themes.md` → verificador automático de contraste
e de separação de matiz → auditoria de equilíbrio: nenhum tema pode tornar o Arc inimigo mais
visível que os outros → simulador de daltonismo aplicado a capturas.
**Testes:** os 8 passam no verificador; `Monochrome` jogável só por forma e padrão.
**DoD:** verificação de contraste no CI.

---

### ART-007 — Ícones e marca
**Objetivo:** fechar `PLACEHOLDER-ART-005` e dar identidade ao produto.
**Dependências:** ART-001. **Arquivos:** `assets/brand/`, `assets/sprites/icons/`.
**Passos:** conjunto de ícones de UI vetoriais e coerentes → logo e wordmark → ícone do app
(adaptativo no Android, conjunto completo no iOS) → splash com logo vetorial.
**Testes:** ícone legível em 48 dp; máscara circular, squircle e quadrada corretas.
**DoD:** `PLACEHOLDER-ART-005` fechado.

---

### ART-008 — Animação de Seal final
**Objetivo:** o momento mais importante do jogo, visualmente resolvido.
**Contexto:** `docs/art/art-direction.md` §3. **Dependências:** ART-003, ART-004.
**Arquivos:** `src/presentation/seal_animation.gd`, shaders.
**Passos:** onda de luz percorrendo o Arc (0,12 s) → preenchimento radial com máscara (0,28 s)
→ faíscas no perímetro novo → flash proporcional à área → `Steal Shatter` nas células roubadas.
**Testes:** capturas grandes e pequenas com intensidade proporcional; nenhuma queda de FPS;
o efeito não esconde ameaça.
**DoD:** capturar é visualmente satisfatório — verificado por 3 pessoas.

---

### ART-009 — Presets de qualidade
**Objetivo:** o jogo bonito onde dá, e bom onde não dá.
**Contexto:** `docs/art/vfx.md`. **Dependências:** ART-008.
**Arquivos:** `resources/config/quality/*.tres`, `src/presentation/quality_service.gd`.
**Passos:** Low/Medium/High conforme a tabela → `Auto` decidindo por RAM, núcleos, renderer e
micro-benchmark de 1 s no boot → resultado salvo e sobrescrevível → aplicação em runtime,
sem reiniciar.
**Testes:** cada preset dentro do orçamento em dispositivo do tier correspondente; `Auto`
acerta em Low e em High.
**DoD:** Low continua legível e satisfatório — não é castigo.

---

### ART-010 — Auditoria de legibilidade
**Objetivo:** garantir que a beleza não comeu a clareza (Pilar 3).
**Dependências:** ART-001..009. **Arquivos:** `docs/art/art-direction.md`.
**Passos:** para cada tema e preset, verificar a hierarquia visual → caçar caso em que um VFX
esconde Arc inimigo → conferir contraste em movimento (não só estático) → aplicar simulador de
daltonismo em 3 momentos de partida.
**Testes:** teste cego: mostrar 10 capturas e pedir "onde está a ameaça?" — meta ≥ 90 % de acerto.
**DoD:** nenhum efeito inverte a hierarquia; correções aplicadas.

---

### ART-011 — Validação de performance visual
**Objetivo:** confirmar o orçamento de GPU com a arte real.
**Dependências:** ART-009. **Arquivos:** `docs/performance/device-results.md`.
**Passos:** medir GPU, draw calls e memória de textura nos 3 tiers → comparar com o orçamento →
otimizar o que estourar (shader, resolução de efeito, densidade de partícula) → registrar.
**Testes:** benchmarks visuais dentro do orçamento; 60 FPS no Mid com preset Medium.
**DoD:** `device-results.md` atualizado; nenhum orçamento estourado.
