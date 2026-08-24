# Game Design Document — VOLTA

> Documento-guarda-chuva. Cada seção resume e aponta para o documento normativo. Se houver
> divergência, **o documento específico vence** — este aqui é o mapa, não o território.

| | |
|---|---|
| **Título de trabalho** | VOLTA |
| **Gênero** | Arcade de conquista territorial (`.io`) |
| **Plataformas** | Android (primária), iOS |
| **Público** | 16–34, sessões de 2–10 min |
| **Sessão típica** | 4 partidas × 2–3 min |
| **Modelo** | Free-to-play com cosméticos e remove-ads |
| **Engine** | Godot 4.3, GDScript tipado |
| **Orientação** | Retrato (portrait) travado |
| **Rede** | Offline no v0.1.0; serviços online a partir de GSD 15 |

---

## 1. Conceito

Você controla um **Runner** dentro de um **Field**. Dentro do seu **Claim** você está seguro.
Ao sair, começa a desenhar um **Arc** — e o Arc pode ser cortado. Ao voltar a tocar o próprio
Claim, tudo que ficou cercado vira seu: um **Seal**.

Uma decisão, repetida: *fechar agora e garantir, ou esticar e dobrar?*

→ [`../gameplay/core-loop.md`](../gameplay/core-loop.md)

## 2. Pilares

Risco legível · Resposta imediata · Clareza em movimento · Expansão como recompensa · Justiça.
→ [`../product/game-pillars.md`](../product/game-pillars.md)

## 3. Regras

Estados, captura, combate, Backwash, fim de partida e 12 casos de borda normativos.
→ [`../gameplay/rules.md`](../gameplay/rules.md)

## 4. Controles

Swipe (padrão), joystick flutuante, relativo. Latência-alvo < 50 ms. Test drive nas settings.
→ [`../gameplay/controls.md`](../gameplay/controls.md)

## 5. Modos

Classic · Time Attack · Survival · Domination · Endless — todos sobre a mesma simulação.
→ [`../gameplay/game-modes.md`](../gameplay/game-modes.md)

## 6. Arenas

Open Field, Archipelago, Rift, Crossroads, Halo no v0.1.0. Lattice, Drift e Gate pós-launch.
Cada arena muda a estratégia, não as regras.
→ [`../art/themes.md`](../art/themes.md) e `.gsd/phases/13-maps-arenas/`

## 7. Adversários

IA por utilidade, 7 arquétipos, 3 níveis, imperfeição proposital. Bots seguem as mesmas regras
físicas do jogador.
→ [`../gameplay/bots.md`](../gameplay/bots.md)

## 8. Score e Surge

Território × risco × combo, com bônus nomeados e Final Push.
→ [`scoring.md`](scoring.md) · números em [`balance.md`](balance.md)

## 9. Progressão e economia

XP, ranks, conquistas, desafios, Sparks e Prisms — tudo cosmético.
→ [`progression.md`](progression.md) · [`economy.md`](economy.md) · [`../product/monetization.md`](../product/monetization.md)

## 10. Power-ups

Bulwark · Overdrive · Arc Guard · Pulse · Amplify · Drag Field. Todos com contra-jogo.
→ [`../gameplay/power-ups.md`](../gameplay/power-ups.md)

## 11. Direção de arte

Minimalismo neon premium: geometria limpa, glow controlado, fundo atmosférico, contraste alto.
→ [`../art/art-direction.md`](../art/art-direction.md) · [`../art/vfx.md`](../art/vfx.md)

## 12. Áudio

Música adaptativa por camadas dirigida por território, Surge e Final Push.
→ [`../audio/audio-direction.md`](../audio/audio-direction.md)

## 13. Game feel

Contrato de sete canais por ação. Captura sem impacto = implementação incompleta.
→ [`game-feel.md`](game-feel.md)

## 14. UI

Mobile-first, portrait, safe areas, HUD de no máximo 5 elementos.
→ [`../ui/design-system.md`](../ui/design-system.md) · [`../ui/screens.md`](../ui/screens.md) · [`../ui/hud.md`](../ui/hud.md)

## 15. Onboarding

Ensino dentro da partida, 6 passos, cada um some ao ser demonstrado.
→ [`onboarding.md`](onboarding.md)

## 16. Arquitetura

Simulação isolada de apresentação, território como grid denso, tudo por interface.
→ [`../architecture/overview.md`](../architecture/overview.md) · [`../architecture/territory-system.md`](../architecture/territory-system.md)

---

## Riscos de design conhecidos

| Risco | Mitigação |
|---|---|
| Backwash vira escape hatch | o Arc reinicia imediatamente; o Runner segue vulnerável (R6.4) |
| Snowball de Surge | teto de nível + decaimento + o líder é alvo natural dos bots `Baron`/`Nemesis` |
| Partida virar corrida ao canto vazio | células roubadas valem mais que neutras |
| Morte por surpresa | aviso periférico + lista fechada de causas de morte (R5.7) |
| Bots previsíveis demais | `error_rate` e `reaction_delay` por perfil, arquétipos misturados por partida |
| Endless infinito e sem tensão | *Reset Pulse* telegrafado |

## Perguntas em aberto (decidir até a Alpha)

1. O Final Push deve valer para Domination? (hoje: não)
2. Roubo deve dar Surge extra além dos pontos? (hoje: não)
3. Arenas com obstáculo móvel entram no v0.1.0? (hoje: não, ficam pós-launch)

Cada uma vira ADR quando decidida.
