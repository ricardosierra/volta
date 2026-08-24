# ADR-0007 — Regra de auto-colisão

## Context

O que acontece quando o Runner toca o próprio Arc? Três opções clássicas: **mata**, **cancela**
ou **é permitido**. A decisão muda a sensação do jogo inteiro. Com movimento de ângulo livre
(ADR-0006), tocar o próprio rastro por acidente é comum — principalmente com o polegar, em
tela pequena, sob pressão.

Restrição forte: o Pilar 1 exige que morte nunca pareça arbitrária. E há um risco oposto:
qualquer regra que remova o Arc pode virar botão de invulnerabilidade ("estou prestes a ser
cortado → toco meu rastro e fico seguro").

## Decision

**Auto-colisão não mata: dispara `Backwash`.**

No mesmo tick:
1. o Arc inteiro é apagado (nada é capturado — a punição é perder o trabalho);
2. um **novo Arc começa imediatamente na posição atual** — o Runner continua vulnerável;
3. o Surge cai a zero;
4. penalidade temporária de velocidade (−40 % por 1,2 s 🎯), com VFX, SFX e háptico próprios.

A mesma regra vale para colisão com a borda da arena ou obstáculo sólido enquanto desenha
(com deflexão do vetor de movimento). Dentro do próprio Claim, a borda apenas desliza.

Consequência normativa: **a lista de causas de morte é fechada** (regra R5.7) — corte de Arc
inimigo, morte mútua, Squeeze e perigos de arena explicitamente telegrafados. Nada mais mata.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **Mata (padrão do gênero)** | Com ângulo livre, produz mortes que o jogador sente como injustas; empurra todo mundo para arcos curtos e covardes, matando a tensão que o jogo quer criar |
| **Permitido (atravessa o próprio rastro)** | Cria topologias ambíguas (oito, laços aninhados) que tornam o Seal indefinido; abre exploits de auto-cerco |
| **Cancela e teleporta para o Claim** | Vira fuga garantida: perde o Arc, mas fica seguro. Quebra o Pilar 5 |
| **Cancela e paralisa por 1 s** | Punição sem informação: o jogador fica parado sem entender; pior legibilidade que a penalidade de velocidade |

## Consequences

**Positivas:** morte sempre tem culpado identificável (alguém cortou seu Arc) → regra fácil de
ensinar: *"você só morre se cortarem seu arco"*; jogadores novos sobrevivem mais na primeira
partida; incentiva arcos ambiciosos, que é onde o jogo é divertido.

**Negativas / mitigações:**
- Menos punitivo que o gênero → compensado pela perda total do Arc e do Surge, que em Surge alto
  dói mais que morrer.
- Risco de virar escape hatch → **anulado** pelo reinício imediato do Arc (o Runner segue cortável).
- Um jogador pode "raspar" o próprio rastro de propósito para reposicionar → custa velocidade e
  todo o progresso do arco; nas simulações de balanceamento isso é monitorado (GSD 05/19) e, se
  virar estratégia dominante, a penalidade aumenta antes de qualquer mudança de regra.

**Validação:** o stress test mede a frequência de Backwash por partida e por arquétipo; playtest
de Alpha verifica se jogadores entendem a mecânica sem explicação escrita.

## Status

**Accepted** — 2026-08-24. Regra normativa em `docs/gameplay/rules.md` (§6).
