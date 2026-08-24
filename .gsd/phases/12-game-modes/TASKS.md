# GSD 12 — Tarefas

### MODE-001 — `MatchRulesResource` completo
**Objetivo:** transformar "modo" em dado. **Dependências:** GSD 06.
**Arquivos:** `src/gameplay/modes/match_rules.gd`, `resources/config/modes/*.tres`.
**Passos:** campos de `docs/gameplay/game-modes.md` (duração, runners, respawn, meta, curva de
dificuldade, pool de arenas, power-ups, Final Push, perfil de score, regras especiais) →
migrar o Classic para o recurso → remover qualquer `if mode ==` existente.
**Testes:** Classic idêntico ao anterior; recurso inválido rejeitado no boot.
**DoD:** `grep -r "if mode ==" src/` retorna vazio.

### MODE-002 — Time Attack
**Dependências:** MODE-001. **Arquivos:** `resources/config/modes/time_attack.tres`,
`src/gameplay/modes/rules/time_bonus_rule.gd`.
**Passos:** 90 s, 4 Runners, respawn mais lento → bônus de tempo por Seal (`2 s + 0,4 s por 1 %`,
teto 8 s) → feedback visual e sonoro do tempo ganho → HUD com o relógio em destaque.
**Testes:** bônus calculado e limitado; relógio nunca negativo; partida termina no zero.
**DoD:** jogo agressivo se auto-sustenta — verificado no stress test.

### MODE-003 — Arquétipos `Vulture`, `Nemesis`, `Baron`
**Dependências:** GSD 05. **Arquivos:** `resources/config/bots/archetypes/*.tres`,
`src/ai/actions/*.gd`.
**Passos:** `Vulture` prioriza território recém-liberado por mortes → `Nemesis` guarda o id de
quem o matou e aplica `target_selection = revenge` → `Baron` mira liderança com `expand_deep` →
ativar a ação `bait` para perfis apropriados.
**Testes:** `Nemesis` persegue o alvo correto após morrer; `Vulture` reage a morte próxima;
legibilidade com 5 pessoas.
**DoD:** 7 arquétipos disponíveis, todos distinguíveis.

### MODE-004 — Survival
**Dependências:** MODE-001, MODE-003. **Arquivos:** `resources/config/modes/survival.tres`,
`src/gameplay/modes/rules/wave_rule.gd`.
**Passos:** sem respawn para o jogador → ondas conforme a tabela de `game-modes.md`, entrando
arquétipos progressivamente → aumento de percepção e risco por onda, **nunca** de velocidade →
aviso de nova onda → recorde por tempo sobrevivido.
**Testes:** composição por onda correta; velocidade constante em todas as ondas; recorde salvo.
**DoD:** a dificuldade sobe e o jogador percebe **o que** mudou.

### MODE-005 — Domination
**Dependências:** MODE-001. **Arquivos:** `resources/config/modes/domination.tres`,
`src/ui/hud/domination_bars.gd`.
**Passos:** meta de 50 %, teto de segurança de 300 s, sem power-ups → HUD com barra de todos os
Runners (único modo com informação completa do adversário) → tensão crescente perto da meta.
**Testes:** vitória exata na meta; teto encerra e ranqueia; barras corretas com 4 Runners.
**DoD:** roubar do líder é visivelmente a jogada certa.

### MODE-006 — Endless e Reset Pulse
**Dependências:** MODE-001. **Arquivos:** `resources/config/modes/endless.tres`,
`src/gameplay/modes/rules/reset_pulse_rule.gd`.
**Passos:** partida infinita com reposição contínua de bots → *Reset Pulse* a cada 120 s
devolvendo ao neutro as células mais antigas de quem passar de 45 %, com 5 s de aviso claro →
score acumulado como recorde.
**Testes:** o pulso nunca zera o Claim inteiro de alguém (não pode causar Squeeze acidental);
aviso aparece; memória estável em 30 min de partida.
**DoD:** partida de 30 min sem degradação de FPS nem crescimento de memória.

### MODE-007 — Seleção de modo
**Dependências:** MODE-002..006. **Arquivos:** `src/ui/screens/mode_select_screen.gd`.
**Passos:** cartão por modo com nome, ícone, duração típica, recorde pessoal e uma linha
explicando o que ele faz de diferente → último modo jogado em destaque → PLAY direto do menu
usa o último modo.
**Testes:** navegação; recordes corretos; layout na matriz de telas.
**DoD:** escolher modo custa um toque a mais, no máximo.

### MODE-008 — Leaderboards e recordes por modo
**Dependências:** MODE-007. **Arquivos:** `src/progression/leaderboard/*.gd`.
**Passos:** critério por modo (score, % capturado, tempo vivo, tempo até a meta) → recordes
pessoais separados → exibição no resultado e na seleção de modo.
**Testes:** critério correto por modo; recorde novo destacado.
**DoD:** cada modo tem o que perseguir.

### MODE-009 — Stress test dos 5 modos
**Dependências:** MODE-001..008. **Arquivos:** `tools/dev/simulate.gd`, `.reports/`.
**Passos:** 500 partidas por modo (2 500 no total) → verificar duração dentro da janela,
distribuição de vitórias, ausência de partida infinita → ajustar `.tres` conforme os dados →
registrar em `balance.md`.
**Testes:** 0 crash, 0 invariante violada, 0 partida infinita, em todos os modos.
**DoD:** relatório por modo no `HANDOFF.md`.
