# GSD 14 — Tarefas

### PWUP-001 — Infraestrutura de efeitos
**Dependências:** GSD 13. **Arquivos:** `src/gameplay/powerups/power_up_effect.gd`,
`power_up_service.gd`, `power_up_descriptor.gd`.
**Passos:** interface `on_apply/on_tick/on_expire/describe` → modificadores empilhados no
`StatBlock`, resolvidos em um ponto → substituição do efeito ativo → descritor com ícone, cor,
nome, duração, VFX, SFX e háptico (sem isso não passa no gate de game feel).
**Testes:** aplicar/expirar sem resíduo; substituição limpa o anterior; 1 000 ciclos sem
vazamento no `StatBlock`.
**DoD:** adicionar power-up novo não toca no `Runner`.

### PWUP-002 — Spawn de orbes
**Dependências:** PWUP-001. **Arquivos:** `src/gameplay/powerups/power_up_spawner.gd`.
**Passos:** intervalo e máximo simultâneo por config → aviso piscando antes de existir →
distância mínima de qualquer Runner → pool de orbes → coleta por proximidade.
**Testes:** nunca nasce a menos da distância mínima; máximo respeitado; determinístico por seed.
**DoD:** ninguém é surpreendido por um orbe.

### PWUP-003 — Bulwark e Overdrive
**Passos:** `Bulwark` absorve 1 Break, com casca visível que quebra com estrondo; **não**
protege contra Squeeze → `Overdrive` aumenta velocidade sem tocar na taxa de giro, com rastro
alongado e som ascendente.
**Testes:** escudo consumido exatamente uma vez; Squeeze ignora o escudo; giro inalterado
durante Overdrive (o contra-jogo depende disso).
**DoD:** contra-jogo verificado em playtest.

### PWUP-004 — Arc Guard e Pulse
**Passos:** `Arc Guard` torna incortáveis as células de Arc com idade acima do limite,
brilhando em branco; a ponta continua vulnerável → `Pulse` revela Runners e Arcs na borda da
tela por alguns segundos, **e quem é revelado vê o pulso acontecer**.
**Testes:** ponta do Arc continua cortável; idade calculada corretamente; revelação simétrica.
**DoD:** `Arc Guard` ensina uma habilidade real (cortar perto de quem desenha).

### PWUP-005 — Amplify e Drag Field
**Passos:** `Amplify` multiplica os pontos do **próximo** Seal, com aura dourada e teto de
duração → `Drag Field` deixa área que reduz velocidade de qualquer um que entrar, inclusive
de quem soltou.
**Testes:** `Amplify` não altera área capturada; expira se o jogador não selar; `Drag Field`
afeta o dono; área visível e contornável.
**DoD:** nenhum dos dois altera território — só pontos e mobilidade.

### PWUP-006 — HUD e feedback
**Dependências:** PWUP-003..005, GSD 09. **Arquivos:** `src/ui/hud/power_up_indicator.gd`.
**Passos:** ícone com timer radial no canto inferior-direito → nome e efeito mostrados por
1,5 s na primeira coleta de cada tipo (ensino contínuo) → VFX, SFX e háptico por tipo.
**Testes:** HUD continua com no máximo 5 elementos permanentes (o indicador é contextual);
os 7 canais marcados para cada power-up.
**DoD:** dá para saber o que o adversário pegou olhando para ele.

### PWUP-007 — IA e power-ups
**Dependências:** PWUP-002. **Arquivos:** `src/ai/actions/collect_powerup.gd`, `bot_brain.gd`.
**Passos:** nova ação candidata `collect_powerup`, pontuada por distância, tipo e situação →
bots reagem a efeitos inimigos (recuar de quem tem Overdrive, evitar `Drag Field`) → perfis
agressivos priorizam orbes ofensivos.
**Testes:** bots coletam sem se suicidar; a nova ação não desequilibra a distribuição de vitórias.
**DoD:** orbe não vira item exclusivo do jogador humano.

### PWUP-008 — Balanceamento e gate da Alpha
**Dependências:** PWUP-001..007. **Arquivos:** `.reports/`, `docs/design/balance.md`,
`docs/gameplay/power-ups.md`.
**Passos:** 2 000 partidas com power-ups → medir: % de partidas decididas por power-up (< 15 %),
winrate de quem pega o primeiro orbe (50 % ± 8 pp), tempo médio com efeito ativo (< 20 %) →
ajustar duração e taxa de spawn → **executar o gate da Alpha inteiro**.
**Testes:** métricas dentro do alvo; checklist da Alpha completo.
**DoD:** marco Alpha fechado e registrado em `STATUS.md`.
