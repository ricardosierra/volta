# GSD 09 — Tarefas

---

### FEEL-001 — Infraestrutura de VFX e pooling
**Objetivo:** base para todo efeito, sem alocação em partida.
**Contexto:** `docs/art/vfx.md`. **Dependências:** GSD 08.
**Arquivos:** `src/presentation/vfx/vfx_service.gd`, `vfx_pool.gd`, `effect_descriptor.gd`.
**Passos:** pool por tipo, dimensionado pelo preset de qualidade → API `VfxService.play(id, pos, intensity)`
→ limpeza garantida (nada acumula) → respeito a `Reduce flashes` no serviço, não em cada efeito.
**Testes:** 1 000 efeitos sem alocação; pool esgotado degrada (descarta o menos importante) sem
erro; nada sobra ao fim da partida.
**DoD:** nenhum `instantiate()` de efeito fora do pool.

---

### FEEL-002 — VFX de captura e roubo
**Objetivo:** o evento mais importante, no capricho. **Dependências:** FEEL-001.
**Arquivos:** `src/presentation/vfx/seal_vfx.gd`.
**Passos:** faíscas no perímetro novo (densidade por preset) → onda de choque no Mega Seal →
flash proporcional → `Steal Shatter` reforçado → intensidade contínua em função da área.
**Testes:** capturas de 1 % e de 20 % visivelmente diferentes; sem queda de FPS no Mega Seal.
**DoD:** os 7 canais marcados para "Seal pequeno/médio/Mega".

---

### FEEL-003 — VFX de combate
**Objetivo:** morte e eliminação com peso. **Dependências:** FEEL-001.
**Arquivos:** `src/presentation/vfx/break_vfx.gd`, `death_vfx.gd`, `backwash_vfx.gd`.
**Passos:** `Break Burst` (explosão geométrica + onda) → `Arc Dissolve` em cascata a partir da
origem → `Backwash Leak` em âmbar, claramente diferente de morte → aura de Surge por nível.
**Testes:** o jogador distingue Break, morte própria e Backwash sem ler texto.
**DoD:** os 7 canais marcados para Break, morte e Backwash.

---

### FEEL-004 — Reações de câmera
**Objetivo:** a câmera participar do jogo sem enjoar.
**Contexto:** `docs/design/balance.md` §11. **Dependências:** GSD 08.
**Arquivos:** `src/presentation/camera/camera_reactions.gd`.
**Passos:** punch por Seal (proporcional) e por Break → zoom-out momentâneo em captura grande →
micro slow-mo (0,12 s) só no Mega Seal, **sem** travar input → shake escalado por configuração,
podendo ser zero → limite rígido de deslocamento.
**Testes:** input continua sendo lido durante o slow-mo; com `Reduce shake` no máximo, nenhum
deslocamento; 2 min de jogo sem enjoo (3 pessoas).
**DoD:** a câmera reage e ninguém repara nela.

---

### FEEL-005 — Háptico
**Objetivo:** o terceiro canal de informação. **Contexto:** `docs/design/game-feel.md` §Háptico.
**Dependências:** GSD 07. **Arquivos:** `src/presentation/haptics/haptic_service.gd`, `patterns/*.tres`.
**Passos:** padrões por evento conforme a tabela → intensidade proporcional em Seal → Core
Haptics no iOS com fallback → Off/Light/Full → nunca vibração contínua.
**Testes:** cada evento dispara o padrão certo; Off silencia tudo; aparelho sem suporte degrada
sem erro; consumo de bateria aceitável.
**DoD:** dá para saber que capturou com o telefone no bolso — literalmente.

---

### FEEL-006 — SFX de gameplay
**Objetivo:** fechar `PLACEHOLDER-AUDIO-001`.
**Contexto:** `docs/audio/audio-direction.md`. **Dependências:** GSD 07.
**Arquivos:** `assets/audio/sfx/`, `src/presentation/audio/sfx_service.gd`.
**Passos:** todos os eventos da tabela de áudio → 3–4 variações com randomização de ±3 % de tom
→ limite de 3 sons simultâneos do mesmo tipo, com prioridade (captura vence ambiente) →
duck de música em Break e Mega Seal → mixagem validada **no alto-falante do celular**.
**Testes:** nenhum estouro; latência < 60 ms; fadiga auditiva avaliada em 10 min contínuos.
**DoD:** dá para jogar de olhos fechados por 5 segundos e saber o que aconteceu.

---

### FEEL-007 — Música adaptativa
**Objetivo:** a trilha acompanhar a tensão. **Dependências:** FEEL-006.
**Arquivos:** `assets/audio/music/`, `src/presentation/audio/adaptive_music.gd`.
**Passos:** 6 camadas (`base`, `rhythm`, `tension`, `melody`, `surge`, `push`) → gatilhos por
território, comprimento de Arc, ameaça próxima e Final Push → crossfade de 0,4 s sincronizado ao
compasso → pulso do grid do fundo dirigido pelo BPM.
**Testes:** camadas entram e saem nas condições certas; nenhuma troca no meio da batida;
pause/resume sem estalo.
**DoD:** a música conta a história da partida.

---

### FEEL-008 — Popups, flashes e transições finais
**Objetivo:** o feedback de UI no capricho. **Dependências:** FEEL-002.
**Arquivos:** `src/ui/hud/bonus_popup.gd`, `src/ui/navigation/transitions.gd`.
**Passos:** popup de bônus com `ease_out_back`, empilhando no máximo 3 → `+X%` subindo do ponto
de fechamento (não do topo da tela) → flashes respeitando `Reduce flashes` → transições finais
de tela em 250 ms.
**Testes:** popups nunca cobrem o Runner; máximo respeitado; transições dentro do tempo.
**DoD:** a HUD celebra sem atrapalhar.

---

### FEEL-009 — Acessibilidade dos efeitos
**Objetivo:** o jogo continuar ótimo com tudo reduzido.
**Contexto:** `docs/ui/accessibility.md`. **Dependências:** FEEL-001..008.
**Arquivos:** `src/presentation/accessibility_settings.gd`.
**Passos:** `Reduce shake` (escala global, inclusive 0) → `Reduce flashes` (sem flash de tela
cheia, glow suavizado, partículas brilhantes limitadas) → `Reduzir sons intensos` →
`Haptics off` → tudo aplicado num único ponto, não espalhado.
**Testes:** partida inteira com todas as reduções ativas — legível, informativa e divertida.
**DoD:** nenhum canal é imprescindível sozinho; sempre há redundância.

---

### FEEL-010 — Auditoria dos sete canais
**Objetivo:** provar que o contrato foi cumprido, ação por ação.
**Dependências:** FEEL-001..009. **Arquivos:** `docs/design/game-feel.md`.
**Passos:** para cada linha da tabela de `game-feel.md`, verificar os 7 canais → gravar vídeo
antes/depois de cada ação principal → medir orçamento de CPU/GPU/áudio → corrigir o que faltar.
**Testes:** matriz ação × canal 100 % preenchida; orçamentos respeitados.
**DoD:** vídeo comparativo anexado ao PR; nenhuma ação com canal vazio.
